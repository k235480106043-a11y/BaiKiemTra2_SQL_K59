<div align="center">
  <h1>BÀI TẬP VỀ NHÀ 03: HỆ QUẢN TRỊ CSDL</h1>
  <h3>ĐỀ TÀI: THIẾT KẾ VÀ CÀI ĐẶT CSDL QUẢN LÝ TIỆM CẦM ĐỒ</h3>
</div>

---
##  THÔNG TIN SINH VIÊN
* **Họ và tên:** Nguyễn Thị Ngọc Linh
* **Mã số sinh viên:** K235480106043
* **Lớp:** K59KMT.K01 - Kỹ thuật Máy tính
* **Trường:** Đại học Kỹ thuật Công nghiệp Thái Nguyên (TNUT)
* **Giảng viên hướng dẫn:** Thầy Đỗ Duy Cốp

---
## NHIỆM VỤ 1 (File PDF)
## NHIỆM VỤ 2 (File script.sql)

- **Khởi tạo cơ sở dữ liệu và các bảng**

```
CREATE DATABASE QuanLyCamDo;
GO
USE QuanLyCamDo;
GO

CREATE TABLE KhachHang (
    KhachHangID     INT IDENTITY(1,1) PRIMARY KEY,
    HoTen           NVARCHAR(100)   NOT NULL,
    SoDienThoai     VARCHAR(15)     NOT NULL UNIQUE,
    CMND_CCCD       VARCHAR(20)     NOT NULL UNIQUE,
    DiaChi          NVARCHAR(255),
    NgayTao         DATETIME        DEFAULT GETDATE()
);
GO

CREATE TABLE NhanVien (
    NhanVienID      INT IDENTITY(1,1) PRIMARY KEY,
    HoTen           NVARCHAR(100)   NOT NULL,
    SoDienThoai     VARCHAR(15),
    ChucVu          NVARCHAR(50)
);
GO

CREATE TABLE HopDong (
    HopDongID       INT IDENTITY(1,1) PRIMARY KEY,
    KhachHangID     INT             NOT NULL,
    NhanVienID      INT,
    SoTienVayGoc    DECIMAL(18,2)   NOT NULL,
    NgayVay         DATE            NOT NULL,
    Deadline1       DATE            NOT NULL,
    Deadline2       DATE            NOT NULL,
    TrangThai       NVARCHAR(50)    NOT NULL DEFAULT N'Đang vay',
    GhiChu          NVARCHAR(500),
    NgayTao         DATETIME        DEFAULT GETDATE(),

    CONSTRAINT FK_HopDong_KhachHang 
        FOREIGN KEY (KhachHangID) REFERENCES KhachHang(KhachHangID),
    CONSTRAINT FK_HopDong_NhanVien  
        FOREIGN KEY (NhanVienID)  REFERENCES NhanVien(NhanVienID)
);
GO

CREATE TABLE TaiSan (
    TaiSanID        INT IDENTITY(1,1) PRIMARY KEY,
    HopDongID       INT             NOT NULL,
    TenTaiSan       NVARCHAR(200)   NOT NULL,
    MoTa            NVARCHAR(500),
    GiaTriDinhGia   DECIMAL(18,2)   NOT NULL,
    TrangThai       NVARCHAR(50)    NOT NULL DEFAULT N'Đang cầm cố',
    IsSold          BIT             NOT NULL DEFAULT 0,
    NgayCapNhat     DATETIME        DEFAULT GETDATE(),

    CONSTRAINT FK_TaiSan_HopDong 
        FOREIGN KEY (HopDongID) REFERENCES HopDong(HopDongID)
);
GO

CREATE TABLE GiaoDich (
    GiaoDichID      INT IDENTITY(1,1) PRIMARY KEY,
    HopDongID       INT             NOT NULL,
    NhanVienID      INT,
    NgayGiaoDich    DATETIME        NOT NULL DEFAULT GETDATE(),
    SoTienTra       DECIMAL(18,2)   NOT NULL,
    DuNoTruocKhi    DECIMAL(18,2)   NOT NULL,
    DuNoSauKhi      DECIMAL(18,2)   NOT NULL,
    GhiChu          NVARCHAR(500),

    CONSTRAINT FK_GiaoDich_HopDong  
        FOREIGN KEY (HopDongID)  REFERENCES HopDong(HopDongID),
    CONSTRAINT FK_GiaoDich_NhanVien 
        FOREIGN KEY (NhanVienID) REFERENCES NhanVien(NhanVienID)
);
GO

CREATE TABLE LichSuTrangThai (
    LogID           INT IDENTITY(1,1) PRIMARY KEY,
    HopDongID       INT             NOT NULL,
    TrangThaiCu     NVARCHAR(50),
    TrangThaiMoi    NVARCHAR(50),
    ThoiGian        DATETIME        DEFAULT GETDATE(),
    GhiChu          NVARCHAR(500),

    CONSTRAINT FK_LichSu_HopDong 
        FOREIGN KEY (HopDongID) REFERENCES HopDong(HopDongID)
);
GO
```

<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/eb16c940-994e-4798-aeee-eb70c4a44c11" />

### Event 1: Đăng ký hợp đồng mới (Vay tiền)
**Yêu cầu: Viết Store Procedure tiếp nhận hợp đồng: Lưu thông tin khách hàng, danh sách tài sản
(kèm giá trị định giá), số tiền vay gốc và thiết lập 2 mốc Deadline1, Deadline2.**

```
-- =============================================
-- EVENT 1: ĐĂNG KÝ HỢP ĐỒNG MỚI
-- =============================================
CREATE PROCEDURE sp_TaoHopDong
    @KhachHangID    INT,
    @NhanVienID     INT,
    @SoTienVay      DECIMAL(18,2),
    @NgayVay        DATE,
    @SoNgayHanD1    INT,
    @SoNgayHanD2    INT,
    @GhiChu         NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

   
    DECLARE @Deadline1  DATE = DATEADD(DAY, @SoNgayHanD1, @NgayVay);
    DECLARE @Deadline2  DATE = DATEADD(DAY, @SoNgayHanD2, @NgayVay);
    DECLARE @HopDongID  INT;

  
    INSERT INTO HopDong (
        KhachHangID, NhanVienID, SoTienVayGoc,
        NgayVay, Deadline1, Deadline2,
        TrangThai, GhiChu
    )
    VALUES (
        @KhachHangID, @NhanVienID, @SoTienVay,
        @NgayVay, @Deadline1, @Deadline2,
        N'Đang vay', @GhiChu
    );

    
    SET @HopDongID = SCOPE_IDENTITY();

   
    INSERT INTO LichSuTrangThai (
        HopDongID, TrangThaiCu, TrangThaiMoi, GhiChu
    )
    VALUES (
        @HopDongID, NULL, N'Đang vay', N'Tạo hợp đồng mới'
    );

    
    SELECT @HopDongID AS HopDongID;
END;
GO
```

<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/e6785221-0a8d-4759-be63-2db7cc093ab5" />

**Test case 1: Thực thi Event 1 - Đăng ký hợp đồng vay tiền mới**

```
INSERT INTO NhanVien (HoTen, SoDienThoai, ChucVu)
VALUES (N'Nguyễn Văn An', '0901234567', N'Quản lý');

INSERT INTO KhachHang (HoTen, SoDienThoai, CMND_CCCD, DiaChi)
VALUES (N'Lê Văn Cường', '0933111222', '036012345678', N'Hà Nội');

EXEC sp_TaoHopDong
    @KhachHangID = 1,
    @NhanVienID  = 1,
    @SoTienVay   = 5000000,
    @NgayVay     = '2025-03-01',
    @SoNgayHanD1 = 30,
    @SoNgayHanD2 = 60,
    @GhiChu      = N'Vay tiền mua hàng';

SELECT * FROM HopDong;

SELECT * FROM LichSuTrangThai;
```

<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/2a7d7da3-9122-42f7-9972-c8d567258b27" />

**Nhận xét & Giải thích logic:**
Chạy thử Store Procedure khởi tạo hợp đồng. Kết quả trả về cho thấy hệ thống đã xử lý hoàn hảo các nghiệp vụ cốt lõi:
1. **Tính toán Deadline tự động & chính xác:** Khi truyền tham số đầu vào là `NgayVay = '2025-03-01'`, số ngày hạn 1 (30 ngày) và hạn 2 (60 ngày), hệ thống đã dùng hàm ngày tháng trong SQL để tự động tính ra `Deadline 1 là 2025-03-31` và `Deadline 2 là 2025-04-30`. Điều này giúp nhân viên không phải tự nhẩm ngày.
2. **Đảm bảo tính toàn vẹn dữ liệu (Transaction):** Bảng kết quả thứ 2 cho thấy ngay khi Hợp đồng mới (ID=2) được tạo, một bản ghi tương ứng đã được tự động chèn vào bảng `LichSuTrangThai` với `TrangThaiCu = NULL` và `TrangThaiMoi = 'Đang vay'`. Việc này đảm bảo mọi biến động của hợp đồng đều được tracking (lưu vết) đầy đủ ngay từ giây phút đầu tiên.

### Event 2: Tính toán công nợ thời gian thực 
- **FUNCTION 1: Tính tổng tiền phải trả của 1 hợp đồng**
```
CREATE FUNCTION dbo.fn_CalcMoneyContract
(
    @ContractID INT,
    @TargetDate DATE
)
RETURNS DECIMAL(18,2)
AS
BEGIN

    DECLARE @Goc           DECIMAL(18,2)
    DECLARE @NgayVay       DATE
    DECLARE @D1            DATE
    DECLARE @LaiSuat       DECIMAL(18,10) = 0.005
    DECLARE @SoNgayD1      INT
    DECLARE @SoNgayKep     INT
    DECLARE @LaiDon        DECIMAL(18,2)
    DECLARE @P0            DECIMAL(18,2)
    DECLARE @TongNo        DECIMAL(18,2)
    DECLARE @TienDaTra     DECIMAL(18,2)

    
    SELECT
        @Goc       = SoTienVayGoc,
        @NgayVay   = NgayVay,
        @D1        = Deadline1
    FROM HopDong
    WHERE HopDongID = @ContractID


    IF @TargetDate < @NgayVay
        RETURN 0


    SELECT
        @TienDaTra = ISNULL(SUM(SoTienTra), 0)
    FROM GiaoDich
    WHERE HopDongID = @ContractID
      AND CAST(NgayGiaoDich AS DATE) <= @TargetDate


    IF @TargetDate <= @D1
    BEGIN
        
        SET @SoNgayD1 = DATEDIFF(DAY, @NgayVay, @TargetDate)

        SET @LaiDon = @Goc * @LaiSuat * @SoNgayD1

        SET @TongNo = @Goc + @LaiDon
    END
    ELSE
    BEGIN
        
        SET @SoNgayD1 = DATEDIFF(DAY, @NgayVay, @D1)

        SET @LaiDon = @Goc * @LaiSuat * @SoNgayD1

        SET @P0 = @Goc + @LaiDon


        SET @SoNgayKep = DATEDIFF(DAY, @D1, @TargetDate)

        SET @TongNo =
            @P0 * POWER(CAST(1 + @LaiSuat AS FLOAT), @SoNgayKep)
    END


    SET @TongNo = @TongNo - @TienDaTra

    IF @TongNo < 0
        SET @TongNo = 0


    RETURN ROUND(@TongNo, 2)

END
GO

```

<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/66777c7a-a16d-4dff-b399-f27c6fbc9d33" />


- **FUNCTION 2: Tính lãi từ 1 giao dịch cụ thể đến TargetDate**

```
CREATE FUNCTION dbo.fn_CalcMoneyTransaction
(
    @TransactionID INT,
    @TargetDate DATE
)
RETURNS DECIMAL(18,2)
AS
BEGIN

    DECLARE @ContractID    INT
    DECLARE @NgayGD        DATE
    DECLARE @DuNo          DECIMAL(18,2)
    DECLARE @D1            DATE
    DECLARE @LaiSuat       DECIMAL(18,10) = 0.005
    DECLARE @SoNgayD1      INT
    DECLARE @SoNgayKep     INT
    DECLARE @NoDenD1       DECIMAL(18,2)
    DECLARE @KetQua        DECIMAL(18,2)


    SELECT
        @ContractID = HopDongID,
        @NgayGD     = CAST(NgayGiaoDich AS DATE),
        @DuNo       = DuNoSauKhi
    FROM GiaoDich
    WHERE GiaoDichID = @TransactionID


    SELECT
        @D1 = Deadline1
    FROM HopDong
    WHERE HopDongID = @ContractID


    IF @TargetDate < @NgayGD
        RETURN @DuNo


    IF @TargetDate <= @D1
    BEGIN
        
        SET @SoNgayD1 = DATEDIFF(DAY, @NgayGD, @TargetDate)

        SET @KetQua =
            @DuNo + (@DuNo * @LaiSuat * @SoNgayD1)
    END
    ELSE
    BEGIN
        
        IF @NgayGD > @D1
            SET @SoNgayD1 = 0
        ELSE
            SET @SoNgayD1 = DATEDIFF(DAY, @NgayGD, @D1)


        SET @NoDenD1 =
            @DuNo * (1 + @LaiSuat * @SoNgayD1)


        SET @SoNgayKep =
            DATEDIFF(DAY, @D1, @TargetDate)


        SET @KetQua =
            @NoDenD1 * POWER(CAST(1 + @LaiSuat AS FLOAT), @SoNgayKep)
    END


    IF @KetQua < 0
        SET @KetQua = 0


    RETURN ROUND(@KetQua, 2)

END
GO

```

<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/733043b5-39eb-4a83-a060-62c811b09731" />
