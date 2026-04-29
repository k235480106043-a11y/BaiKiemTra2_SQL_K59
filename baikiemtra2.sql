/* ======================================================================
   BÀI KIỂM TRA SỐ 02 - HỆ QUẢN TRỊ CSDL SQL SERVER
   SINH VIÊN: NGUYỄN THỊ NGỌC LINH - K235480106043
   LỚP: K59KMT.K01
   ĐỀ TÀI: QUẢN LÝ CỬA HÀNG MỸ PHẨM
   ====================================================================== */

-- ==========================================
-- PHẦN 1: KHỞI TẠO CƠ SỞ DỮ LIỆU VÀ BẢNG
-- ==========================================
CREATE DATABASE [QuanLyMyPham_K235480106043];
GO
USE [QuanLyMyPham_K235480106043];
GO

CREATE TABLE [SanPham] (
    [MaSanPham] INT IDENTITY(1,1) NOT NULL,
    [TenSanPham] NVARCHAR(150) NOT NULL,
    [GiaBan] MONEY NOT NULL,
    [SoLuongTon] INT DEFAULT 0,
    CONSTRAINT [PK_SanPham] PRIMARY KEY ([MaSanPham]),
    CONSTRAINT [CK_GiaBan] CHECK ([GiaBan] > 0),
    CONSTRAINT [CK_SoLuongTon] CHECK ([SoLuongTon] >= 0)
);
GO

CREATE TABLE [HoaDon] (
    [MaHoaDon] INT IDENTITY(1,1) NOT NULL,
    [NgayLap] DATETIME DEFAULT GETDATE(),
    [TenKhachHang] NVARCHAR(100),
    [TongTien] MONEY DEFAULT 0,
    CONSTRAINT [PK_HoaDon] PRIMARY KEY ([MaHoaDon])
);
GO

CREATE TABLE [ChiTietHoaDon] (
    [MaHoaDon] INT NOT NULL,
    [MaSanPham] INT NOT NULL,
    [SoLuongMua] INT NOT NULL,
    [DonGiaBan] MONEY NOT NULL,
    CONSTRAINT [PK_ChiTietHoaDon] PRIMARY KEY ([MaHoaDon], [MaSanPham]),
    CONSTRAINT [FK_CTHD_HoaDon] FOREIGN KEY ([MaHoaDon]) REFERENCES [HoaDon]([MaHoaDon]),
    CONSTRAINT [FK_CTHD_SanPham] FOREIGN KEY ([MaSanPham]) REFERENCES [SanPham]([MaSanPham]),
    CONSTRAINT [CK_SoLuongMua] CHECK ([SoLuongMua] > 0)
);
GO

-- Bảng phụ cho phần Trigger 4.2
CREATE TABLE [LichSuGia] (
    [MaLog] INT IDENTITY(1,1) PRIMARY KEY,
    [MaSanPham] INT,
    [GiaCu] MONEY,
    [GiaMoi] MONEY,
    [NgayThayDoi] DATETIME DEFAULT GETDATE()
);
GO

-- CHÈN DỮ LIỆU MẪU
INSERT INTO [SanPham] ([TenSanPham], [GiaBan], [SoLuongTon]) VALUES 
(N'Son MAC Ruby Woo', 550000, 50),
(N'Nước tẩy trang Bioderma 500ml', 395000, 10),    
(N'Kem chống nắng La Roche-Posay', 485000, 30),
(N'Serum Estee Lauder Advanced Night Repair', 2500000, 15), 
(N'Sữa rửa mặt Cerave Hydrating', 370000, 40);
GO

INSERT INTO [HoaDon] ([TenKhachHang]) VALUES 
(N'Nguyễn Đăng Thịnh'), (N'Vũ Hoàng Long'), (N'Đỗ Phương Thảo'), (N'Trần Minh Khôi');
GO

INSERT INTO [ChiTietHoaDon] ([MaHoaDon], [MaSanPham], [SoLuongMua], [DonGiaBan]) VALUES 
(1, 1, 10, 550000), (2, 2, 1, 395000), (2, 3, 1, 485000), (3, 4, 1, 2500000), (4, 5, 2, 370000);
GO

-- TEST KHỞI TẠO
SELECT * FROM [SanPham];
SELECT * FROM [HoaDon];
SELECT * FROM [ChiTietHoaDon];
GO


-- ==========================================
-- PHẦN 2: USER-DEFINED FUNCTIONS (UDF)
-- ==========================================

-- Test Built-in Functions
SELECT [MaSanPham], [TenSanPham], [GiaBan] AS [GiaGoc_HeThong], FORMAT([GiaBan], 'N0') + N' VNĐ' AS [GiaNiemYet_HienThi] FROM [SanPham];
SELECT [TenSanPham], [SoLuongTon], IIF([SoLuongTon] > 0, N'Còn hàng', N'Đã hết hàng') AS [TinhTrangKho] FROM [SanPham];
SELECT [MaHoaDon], [TenKhachHang], [NgayLap], DATEDIFF(DAY, [NgayLap], GETDATE()) AS [SoNgayDaTroiQua] FROM [HoaDon];
GO

-- 2.1. Hàm vô hướng (Tính doanh thu)
CREATE FUNCTION [dbo].[fn_TinhDoanhThuTungMyPham] (@MaSP INT)
RETURNS MONEY
AS
BEGIN
    DECLARE @TongTien MONEY;
    SELECT @TongTien = SUM([SoLuongMua] * [DonGiaBan]) FROM [ChiTietHoaDon] WHERE [MaSanPham] = @MaSP;
    RETURN ISNULL(@TongTien, 0); 
END;
GO
-- Test 2.1
SELECT [TenSanPham], FORMAT([dbo].[fn_TinhDoanhThuTungMyPham]([MaSanPham]), 'N0') + N' VNĐ' AS [TongDoanhThu] FROM [SanPham];
GO

-- 2.2. Hàm nội tuyến (Lọc kho)
CREATE FUNCTION [dbo].[fn_LocMyPhamSapHet] (@MucTonToiThieu INT)
RETURNS TABLE
AS
RETURN (
    SELECT [MaSanPham], [TenSanPham], [SoLuongTon], [GiaBan] FROM [SanPham] WHERE [SoLuongTon] <= @MucTonToiThieu
);
GO
-- Test 2.2
SELECT * FROM [dbo].[fn_LocMyPhamSapHet](15);
GO

-- 2.3. Hàm đa lệnh (Phân loại kinh doanh)
CREATE FUNCTION [dbo].[fn_BaoCaoKinhDoanh] ()
RETURNS @BangBaoCao TABLE ([TenSP] NVARCHAR(150), [TongSoLuongDaBan] INT, [DanhGia] NVARCHAR(50))
AS
BEGIN
    INSERT INTO @BangBaoCao ([TenSP], [TongSoLuongDaBan])
    SELECT S.[TenSanPham], ISNULL(SUM(C.[SoLuongMua]), 0) FROM [SanPham] S
    LEFT JOIN [ChiTietHoaDon] C ON S.[MaSanPham] = C.[MaSanPham] GROUP BY S.[TenSanPham];

    UPDATE @BangBaoCao
    SET [DanhGia] = CASE 
        WHEN [TongSoLuongDaBan] >= 10 THEN N'🔥 Hàng HOT (Bán chạy)'
        WHEN [TongSoLuongDaBan] > 0 THEN N'✅ Bán ổn định'
        ELSE N'⚠️ Hàng tồn đọng (Cần chạy Sale)'
    END;
    RETURN;
END;
GO
-- Test 2.3
SELECT * FROM [dbo].[fn_BaoCaoKinhDoanh]();
GO


-- ==========================================
-- PHẦN 3: STORED PROCEDURES (SP)
-- ==========================================

-- 3.1. SP kiểm tra điều kiện
CREATE PROCEDURE [dbo].[sp_ThemMoiSanPham]
    @TenSP NVARCHAR(150), @GiaBan MONEY, @SoLuong INT
AS
BEGIN
    IF (@GiaBan <= 0) BEGIN PRINT N'❌ THẤT BẠI: Giá bán phải lớn hơn 0.'; RETURN; END
    IF (@SoLuong < 0) BEGIN PRINT N'❌ THẤT BẠI: Số lượng không được âm.'; RETURN; END
    INSERT INTO [SanPham] ([TenSanPham], [GiaBan], [SoLuongTon]) VALUES (@TenSP, @GiaBan, @SoLuong);
    PRINT N'✅ THÀNH CÔNG: Đã thêm mỹ phẩm mới!';
END;
GO
-- Test 3.1
EXEC [dbo].[sp_ThemMoiSanPham] @TenSP = N'Mặt nạ Innisfree', @GiaBan = -50000, @SoLuong = 10;
EXEC [dbo].[sp_ThemMoiSanPham] @TenSP = N'Mặt nạ Innisfree', @GiaBan = 25000, @SoLuong = 100;
GO

-- 3.2. SP tham số OUTPUT
CREATE PROCEDURE [dbo].[sp_TinhTongTienKhachHang]
    @TenKhach NVARCHAR(100), @TongTien MONEY OUTPUT 
AS
BEGIN
    SELECT @TongTien = SUM(C.[SoLuongMua] * C.[DonGiaBan]) FROM [HoaDon] H
    JOIN [ChiTietHoaDon] C ON H.[MaHoaDon] = C.[MaHoaDon] WHERE H.[TenKhachHang] = @TenKhach;
    SET @TongTien = ISNULL(@TongTien, 0);
END;
GO
-- Test 3.2
DECLARE @SoTienTichLuy MONEY;
EXEC [dbo].[sp_TinhTongTienKhachHang] @TenKhach = N'Nguyễn Đăng Thịnh', @TongTien = @SoTienTichLuy OUTPUT;
SELECT FORMAT(@SoTienTichLuy, 'N0') + N' VNĐ' AS [TongTienKhachDaChiTieu];
GO

-- 3.3. SP Join bảng
CREATE PROCEDURE [dbo].[sp_InBienLaiChiTiet] @MaHD INT
AS
BEGIN
    SELECT H.[MaHoaDon], H.[TenKhachHang], FORMAT(H.[NgayLap], 'dd/MM/yyyy HH:mm') AS [ThoiGianMua], S.[TenSanPham], C.[SoLuongMua], FORMAT(C.[DonGiaBan], 'N0') + N' VNĐ' AS [DonGia], FORMAT(C.[SoLuongMua] * C.[DonGiaBan], 'N0') + N' VNĐ' AS [ThanhTien]
    FROM [HoaDon] H JOIN [ChiTietHoaDon] C ON H.[MaHoaDon] = C.[MaHoaDon] JOIN [SanPham] S ON C.[MaSanPham] = S.[MaSanPham] WHERE H.[MaHoaDon] = @MaHD;
END;
GO
-- Test 3.3
EXEC [dbo].[sp_InBienLaiChiTiet] @MaHD = 2;
GO


-- ==========================================
-- PHẦN 4: TRIGGERS
-- ==========================================

-- 4.1. Trừ tồn kho
CREATE TRIGGER [dbo].[trg_TuDongTruKho]
ON [ChiTietHoaDon] AFTER INSERT
AS
BEGIN
    UPDATE S SET S.[SoLuongTon] = S.[SoLuongTon] - I.[SoLuongMua]
    FROM [SanPham] S JOIN Inserted I ON S.[MaSanPham] = I.[MaSanPham];
    PRINT N'⚡ TRIGGER KÍCH HOẠT: Đã tự động trừ số lượng tồn kho!';
END;
GO
-- Test 4.1
INSERT INTO [ChiTietHoaDon] ([MaHoaDon], [MaSanPham], [SoLuongMua], [DonGiaBan]) VALUES (1, 3, 1, 450000);
SELECT * FROM [SanPham] WHERE [MaSanPham] = 3;
GO

-- 4.2. Ghi nhật ký giá
CREATE TRIGGER [dbo].[trg_KiemToanGiaBan]
ON [SanPham] AFTER UPDATE
AS
BEGIN
    IF UPDATE([GiaBan])
    BEGIN
        INSERT INTO [LichSuGia] ([MaSanPham], [GiaCu], [GiaMoi])
        SELECT I.[MaSanPham], D.[GiaBan], I.[GiaBan] FROM Inserted I JOIN Deleted D ON I.[MaSanPham] = D.[MaSanPham] WHERE I.[GiaBan] <> D.[GiaBan]; 
        PRINT N'⚡ TRIGGER KÍCH HOẠT: Đã ghi nhận lịch sử thay đổi giá!';
    END
END;
GO
-- Test 4.2
UPDATE [SanPham] SET [GiaBan] = 600000 WHERE [MaSanPham] = 1;
SELECT * FROM [LichSuGia];
GO

-- 4.3. Chống xóa
CREATE TRIGGER [dbo].[trg_ChongXoaHoaDon]
ON [HoaDon] INSTEAD OF DELETE
AS
BEGIN
    ROLLBACK TRANSACTION;
    RAISERROR (N'🚨 CẢNH BÁO AN NINH: Không được phép xóa dữ liệu Hóa Đơn tài chính!', 16, 1);
END;
GO
-- Test 4.3 (Sẽ báo lỗi đỏ như báo cáo)
-- DELETE FROM [HoaDon] WHERE [MaHoaDon] = 1;
-- SELECT * FROM [HoaDon];
GO

-- 4.4. Thí nghiệm vòng lặp
CREATE TRIGGER [dbo].[trg_A_Update_B]
ON [SanPham] AFTER UPDATE
AS
BEGIN
    IF UPDATE([GiaBan])
    BEGIN
        UPDATE C SET C.[DonGiaBan] = I.[GiaBan] FROM [ChiTietHoaDon] C JOIN Inserted I ON C.[MaSanPham] = I.[MaSanPham];
        PRINT N'Trigger A->B: Đã cập nhật giá từ Sản Phẩm sang Chi Tiết Hóa Đơn.';
    END
END;
GO

CREATE TRIGGER [dbo].[trg_B_Update_A]
ON [ChiTietHoaDon] AFTER UPDATE
AS
BEGIN
    IF UPDATE([DonGiaBan])
    BEGIN
        UPDATE S SET S.[GiaBan] = I.[DonGiaBan] FROM [SanPham] S JOIN Inserted I ON S.[MaSanPham] = I.[MaSanPham];
        PRINT N'Trigger B->A: Đã cập nhật giá từ Chi Tiết Hóa Đơn ngược về Sản Phẩm.';
    END
END;
GO

-- Test 4.4 (Lệnh này gây lỗi Limit 32 như trong báo cáo, đã được comment lại để không chặn luồng chạy chung)
-- UPDATE [SanPham] SET [GiaBan] = 650000 WHERE [MaSanPham] = 1;
GO


-- ==========================================
-- PHẦN 5: CURSOR & SET-BASED LOGIC
-- ==========================================

-- Tạm khóa Trigger gây vòng lặp để test Cursor
DISABLE TRIGGER [dbo].[trg_A_Update_B] ON [SanPham];
DISABLE TRIGGER [dbo].[trg_B_Update_A] ON [ChiTietHoaDon];
GO

-- 5.1. Dùng CURSOR
SET STATISTICS TIME ON;
GO
PRINT N'--- BẮT ĐẦU CHẠY BẰNG CURSOR ---';

DECLARE @MaSP INT, @TonKho INT, @GiaHienTai MONEY, @GiaMoi MONEY;
DECLARE cur_DieuChinhGia CURSOR FOR SELECT [MaSanPham], [SoLuongTon], [GiaBan] FROM [SanPham];

OPEN cur_DieuChinhGia;
FETCH NEXT FROM cur_DieuChinhGia INTO @MaSP, @TonKho, @GiaHienTai;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @TonKho > 40 SET @GiaMoi = @GiaHienTai * 0.9; 
    ELSE IF @TonKho < 10 SET @GiaMoi = @GiaHienTai * 1.05; 
    ELSE SET @GiaMoi = @GiaHienTai; 

    UPDATE [SanPham] SET [GiaBan] = @GiaMoi WHERE [MaSanPham] = @MaSP;
    FETCH NEXT FROM cur_DieuChinhGia INTO @MaSP, @TonKho, @GiaHienTai;
END;

CLOSE cur_DieuChinhGia;
DEALLOCATE cur_DieuChinhGia;
PRINT N'--- KẾT THÚC CHẠY BẰNG CURSOR ---';

SET STATISTICS TIME OFF;
GO

-- 5.2. Dùng SQL Thuần (Set-based)
SET STATISTICS TIME ON;
GO
PRINT N'--- BẮT ĐẦU CHẠY BẰNG SQL THUẦN (SET-BASED) ---';

UPDATE [SanPham]
SET [GiaBan] = CASE
    WHEN [SoLuongTon] > 40 THEN [GiaBan] * 0.9
    WHEN [SoLuongTon] < 10 THEN [GiaBan] * 1.05
    ELSE [GiaBan]
END;

PRINT N'--- KẾT THÚC CHẠY BẰNG SQL THUẦN ---';

SET STATISTICS TIME OFF;
GO