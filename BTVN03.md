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

### **Khởi tạo cơ sở dữ liệu và các bảng**

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

---
### Event 1: Đăng ký hợp đồng mới (Vay tiền)

**Yêu cầu:**  
Viết Store Procedure dùng để khởi tạo hợp đồng vay, lưu thông tin khoản vay và thiết lập hai mốc thời hạn `Deadline1`, `Deadline2`.

Thông tin tài sản cầm cố sẽ được lưu bổ sung vào bảng `TaiSan` sau khi hợp đồng được tạo thành công.

```
-- =============================================
-- EVENT 1: ĐĂNG KÝ HỢP ĐỒNG MỚI
-- =============================================

DROP PROCEDURE IF EXISTS sp_TaoHopDong
GO

CREATE PROCEDURE sp_TaoHopDong
(
    @KhachHangID    INT,
    @NhanVienID     INT,
    @SoTienVay      DECIMAL(18,2),
    @NgayVay        DATE,
    @SoNgayHanD1    INT,
    @SoNgayHanD2    INT,
    @GhiChu         NVARCHAR(500) = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @Deadline1 DATE =
        DATEADD(DAY, @SoNgayHanD1, @NgayVay);

    DECLARE @Deadline2 DATE =
        DATEADD(DAY, @SoNgayHanD2, @NgayVay);

    DECLARE @HopDongID INT;


    INSERT INTO HopDong
    (
        KhachHangID,
        NhanVienID,
        SoTienVayGoc,
        NgayVay,
        Deadline1,
        Deadline2,
        TrangThai,
        GhiChu
    )
    VALUES
    (
        @KhachHangID,
        @NhanVienID,
        @SoTienVay,
        @NgayVay,
        @Deadline1,
        @Deadline2,
        N'Đang vay',
        @GhiChu
    );


    SET @HopDongID = SCOPE_IDENTITY();


    INSERT INTO LichSuTrangThai
    (
        HopDongID,
        TrangThaiCu,
        TrangThaiMoi,
        GhiChu
    )
    VALUES
    (
        @HopDongID,
        NULL,
        N'Đang vay',
        N'Tạo hợp đồng mới'
    );


    SELECT @HopDongID AS HopDongID;

END
GO
```


<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/e6785221-0a8d-4759-be63-2db7cc093ab5" />

#### **Test case: Thực thi Event 1 - Đăng ký hợp đồng vay tiền mới**

```
EXEC sp_TaoHopDong
    @KhachHangID = 1,
    @NhanVienID  = 1,
    @SoTienVay   = 5000000,
    @NgayVay     = '2025-03-01',
    @SoNgayHanD1 = 30,
    @SoNgayHanD2 = 60,
    @GhiChu      = N'Vay tiền mua hàng'
GO


SELECT * FROM HopDong
GO


INSERT INTO TaiSan
(
    HopDongID,
    TenTaiSan,
    MoTa,
    GiaTriDinhGia
)
VALUES
(
    2,
    N'iPhone 13 Pro Max',
    N'256GB màu xanh',
    15000000
),
(
    2,
    N'Laptop Dell Inspiron',
    N'Core i5 RAM 8GB',
    12000000
)
GO
```

<img width="1917" height="1077" alt="image" src="https://github.com/user-attachments/assets/2cf3daed-2bc9-4875-9ebe-999ae8d15056" />


#### **Nhận xét & Giải thích logic:**

Chạy thử Store Procedure khởi tạo hợp đồng cho thấy hệ thống đã xử lý chính xác các nghiệp vụ chính của bài toán quản lý tiệm cầm đồ:

1. **Tự động tính Deadline hợp đồng:**  
Khi truyền vào ngày vay `2025-03-01`, thời hạn `Deadline1 = 30 ngày` và `Deadline2 = 60 ngày`, hệ thống sử dụng hàm xử lý ngày tháng của SQL Server để tự động tính:
- `Deadline1 = 2025-03-31`
- `Deadline2 = 2025-04-30`

Việc tính tự động giúp hạn chế sai sót khi nhập liệu thủ công và hỗ trợ quản lý thời gian vay chính xác hơn.

2. **Tự động lưu lịch sử trạng thái hợp đồng:**  
Ngay sau khi hợp đồng được tạo thành công, hệ thống tự động thêm dữ liệu vào bảng `LichSuTrangThai` với:
- `TrangThaiCu = NULL`
- `TrangThaiMoi = 'Đang vay'`

Điều này giúp theo dõi toàn bộ quá trình thay đổi trạng thái của hợp đồng trong suốt vòng đời hoạt động.

3. **Quản lý tài sản thế chấp:**  
Sau khi tạo hợp đồng, hệ thống tiếp tục lưu danh sách tài sản cầm cố vào bảng `TaiSan`, bao gồm:
- tên tài sản
- mô tả tài sản
- giá trị định giá

Một hợp đồng có thể quản lý nhiều tài sản khác nhau, phù hợp với nghiệp vụ thực tế của hệ thống cầm đồ.

---
### Event 2: Tính toán công nợ thời gian thực 
#### **FUNCTION 1: Tính tổng tiền phải trả của 1 hợp đồng**
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


#### **FUNCTION 2: Tính lãi từ 1 giao dịch cụ thể đến TargetDate**

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


    -- =========================
    -- GIAI ĐOẠN LÃI ĐƠN
    -- =========================
    IF @TargetDate <= @D1
    BEGIN

        SET @SoNgayD1 =
            DATEDIFF(DAY, @NgayGD, @TargetDate)

        SET @KetQua =
            @DuNo +
            (@DuNo * @LaiSuat * @SoNgayD1)

    END

    -- =========================
    -- GIAI ĐOẠN LÃI KÉP
    -- =========================
    ELSE
    BEGIN

        
        IF @NgayGD <= @D1
        BEGIN

           
            SET @SoNgayD1 =
                DATEDIFF(DAY, @NgayGD, @D1)

            SET @NoDenD1 =
                @DuNo *
                (1 + @LaiSuat * @SoNgayD1)

            
            SET @SoNgayKep =
                DATEDIFF(DAY, @D1, @TargetDate)

        END

      
        ELSE
        BEGIN

            
            SET @NoDenD1 = @DuNo

           
            SET @SoNgayKep =
                DATEDIFF(DAY, @NgayGD, @TargetDate)

        END

        SET @KetQua =
            @NoDenD1 *
            POWER(
                CAST(1 + @LaiSuat AS FLOAT),
                @SoNgayKep
            )

    END

    IF @KetQua < 0
        SET @KetQua = 0


    RETURN ROUND(@KetQua, 2)

END
GO
```

<img width="1917" height="1072" alt="image" src="https://github.com/user-attachments/assets/baae3bfd-a98d-42d7-965f-ec97f267a815" />


#### **Test case: Thực thi Event 2.1 - TEST FUNCTION: fn_CalcMoneyTransaction**

**Giả sử:**

*Thông tin giao dịch test:*
- GiaoDichID      = 2
- HopDongID       = 2
- Ngày giao dịch  = 2025-03-10
- Dư nợ sau giao dịch = 4.000.000đ
- Deadline1 của hợp đồng: 2025-03-31
- Lãi suất:
 5.000đ / 1.000.000đ / ngày
 => r = 0.005 (0.5% / ngày)

**TRƯỜNG HỢP 1: Trước Deadline1**
- TargetDate = 2025-03-20
- Số ngày: 2025-03-10 -> 2025-03-20 = 10 ngày
- Áp dụng lãi đơn: Lãi = 4.000.000 x 0.005 x 10 = 200.000đ
- Tổng nợ kỳ vọng: = 4.200.000đ

```
SELECT dbo.fn_CalcMoneyTransaction
(
    2,
    '2025-03-20'
) AS TH1_TruocDeadline1
GO
```

<img width="1917" height="1077" alt="image" src="https://github.com/user-attachments/assets/c74fee64-ba79-4b4f-abb3-4c4c60904fb4" />


**TRƯỜNG HỢP 2: Đúng Deadline1**
- TargetDate = 2025-03-31
- Số ngày: 2025-03-10 -> 2025-03-31 = 21 ngày
- Áp dụng lãi đơn: Lãi = 4.000.000 x 0.005 x 21 = 420.000đ
- Tổng nợ kỳ vọng: = 4.420.000đ

```
SELECT dbo.fn_CalcMoneyTransaction
(
    2,
    '2025-03-31'
) AS TH2_TaiDeadline1
GO
```

<img width="1915" height="1077" alt="image" src="https://github.com/user-attachments/assets/06436302-77cd-4c09-99dc-390a105764f8" />


**TRƯỜNG HỢP 3: Sau Deadline1**
- TargetDate = 2025-04-10
-  Bước 1:
-  Nợ đến Deadline1:  4.000.000 x (1 + 0.005 x 21) =  4.420.000đ
-  Bước 2: Lãi kép 10 ngày: 4.420.000 x (1.005)^10
-  Kỳ vọng ≈ 4.646.000đ

```
SELECT dbo.fn_CalcMoneyTransaction
(
    2,
    '2025-04-10'
) AS TH3_SauDeadline1
GO
```

<img width="1917" height="1077" alt="image" src="https://github.com/user-attachments/assets/05940576-4da2-4342-92fc-3b0117fc465b" />


#### **Test case: Thực thi Event 2.2 - TEST FUNCTION: fn_CalcMoneyContract**
**Giả sử:**

- Thông tin hợp đồng test:
- HopDongID       = 2
- Số tiền vay gốc = 5.000.000đ
- Ngày vay        = 2025-03-01
- Deadline1       = 2025-03-31
- Khách đã thanh toán: (GiaoDichID = 2 : trả 1.000.000đ, GiaoDichID = 3 : trả 1.000.000đ)
- Tổng khách đã trả: 2.000.000đ
- Lãi suất: 5.000đ / 1.000.000đ / ngày => r = 0.005 (0.5% / ngày)


**TRƯỜNG HỢP 1: Trước Deadline1**
- TargetDate = 2025-03-20
- Số ngày tính lãi: 2025-03-01 -> 2025-03-20 = 19 ngày
- Áp dụng lãi đơn:
- Lãi = 5.000.000 x 0.005 x 19 = 475.000đ
- Tổng nợ trước khi trừ thanh toán: 5.000.000 + 475.000 = 5.475.000đ
- Sau khi trừ khách đã trả 2.000.000đ: = 3.475.000đ
- Kỳ vọng: 3.475.000đ

```
SELECT dbo.fn_CalcMoneyContract
(
    2,
    '2025-03-20'
) AS TH1_HopDong_TruocDeadline1
GO
```

<img width="1917" height="1077" alt="image" src="https://github.com/user-attachments/assets/5ac85c1d-93bf-4c59-b316-a7d178c260ed" />


**TRƯỜNG HỢP 2: Đúng Deadline1**
- TargetDate = 2025-03-31
- Số ngày tính lãi: 2025-03-01 -> 2025-03-31 = 30 ngày
- Áp dụng lãi đơn:
- Lãi = 5.000.000 x 0.005 x 30 = 750.000đ
- Tổng nợ trước khi trừ thanh toán: 5.000.000 + 750.000 = 5.750.000đ
- Sau khi trừ khách đã trả 2.000.000đ: = 3.750.000đ
- Kỳ vọng: 3.750.000đ

```
SELECT dbo.fn_CalcMoneyContract
(
    2,
    '2025-03-31'
) AS TH2_HopDong_TaiDeadline1
GO
```

<img width="1917" height="1077" alt="image" src="https://github.com/user-attachments/assets/4049c9ee-9d71-4aca-b1e9-ce3e9ca2a065" />


**TRƯỜNG HỢP 3: Sau Deadline1**
- TargetDate = 2025-04-15
- Bước 1: Tính tổng nợ tại Deadline1
- Nợ tại D1: 5.000.000 + 750.000 = 5.750.000đ
- Bước 2: Tính lãi kép sau Deadline1
- Số ngày lãi kép: 2025-03-31 -> 2025-04-15 = 15 ngày
- Tổng nợ: 5.750.000 x (1.005)^15 ≈ 6.196.000đ
- Sau khi trừ khách đã trả 2.000.000đ: ≈ 4.196.000đ
- Kỳ vọng: ≈ 4.196.000đ

```
SELECT dbo.fn_CalcMoneyContract
(
    2,
    '2025-04-15'
) AS TH3_HopDong_SauDeadline1
GO
```

<img width="1917" height="1077" alt="image" src="https://github.com/user-attachments/assets/16a8007f-3bcf-493e-9b22-98501bcbad47" />

---
### Event 3: Xử lý trả nợ và hoàn trả tài sản

```
-- =============================================
-- EVENT 3: XỬ LÝ THANH TOÁN HỢP ĐỒNG
-- =============================================

DROP PROCEDURE IF EXISTS sp_ThanhToanHopDong
GO

CREATE PROCEDURE sp_ThanhToanHopDong
(
    @HopDongID     INT,
    @NhanVienID    INT,
    @SoTienTra     DECIMAL(18,2),
    @NgayTra       DATE
)
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @TongNo           DECIMAL(18,2)
    DECLARE @ConNo            DECIMAL(18,2)

    DECLARE @TrangThaiCu      NVARCHAR(100)
    DECLARE @TrangThaiMoi     NVARCHAR(100)

    DECLARE @Deadline2        DATE

    DECLARE @TongGiaTriTS     DECIMAL(18,2)

    DECLARE @IsSold           BIT


    -- =============================================
    -- KIỂM TRA HỢP ĐỒNG TỒN TẠI
    -- =============================================
    IF NOT EXISTS
    (
        SELECT 1
        FROM HopDong
        WHERE HopDongID = @HopDongID
    )
    BEGIN

        PRINT N'Hợp đồng không tồn tại';
        RETURN;

    END


    -- =============================================
    -- LẤY THÔNG TIN HỢP ĐỒNG
    -- =============================================
    SELECT
        @TrangThaiCu = TrangThai,
        @Deadline2   = Deadline2
    FROM HopDong
    WHERE HopDongID = @HopDongID


    -- =============================================
    -- KIỂM TRA TÀI SẢN ĐÃ THANH LÝ
    -- =============================================
    SELECT
        @IsSold =
            CASE
                WHEN COUNT(*) > 0 THEN 1
                ELSE 0
            END
    FROM TaiSan
    WHERE HopDongID = @HopDongID
      AND TrangThai = N'Đã bán thanh lý'


    IF @NgayTra > @Deadline2
       AND @IsSold = 1
    BEGIN

        PRINT N'Tài sản đã bị thanh lý. Không thể tiếp tục thanh toán.';
        RETURN;

    END


    -- =============================================
    -- TÍNH TỔNG CÔNG NỢ
    -- =============================================
    SET @TongNo =
        dbo.fn_CalcMoneyContract
        (
            @HopDongID,
            @NgayTra
        )


    -- =============================================
    -- KIỂM TRA SỐ TIỀN TRẢ
    -- =============================================
    IF @SoTienTra <= 0
    BEGIN

        PRINT N'Số tiền thanh toán không hợp lệ';
        RETURN;

    END


    -- =============================================
    -- TÍNH DƯ NỢ CÒN LẠI
    -- =============================================
    SET @ConNo = @TongNo - @SoTienTra

    IF @ConNo < 0
        SET @ConNo = 0


    -- =============================================
    -- GHI NHẬN GIAO DỊCH
    -- =============================================
    INSERT INTO GiaoDich
    (
        HopDongID,
        NhanVienID,
        NgayGiaoDich,
        SoTienTra,
        DuNoTruocKhi,
        DuNoSauKhi,
        GhiChu
    )
    VALUES
    (
        @HopDongID,
        @NhanVienID,
        @NgayTra,
        @SoTienTra,
        @TongNo,
        @ConNo,
        N'Khách thanh toán công nợ'
    )


    -- =============================================
    -- XỬ LÝ TRẠNG THÁI HỢP ĐỒNG
    -- =============================================
    IF @ConNo = 0
    BEGIN

        SET @TrangThaiMoi = N'Đã thanh toán đủ'


        UPDATE HopDong
        SET TrangThai = @TrangThaiMoi
        WHERE HopDongID = @HopDongID


        UPDATE TaiSan
        SET TrangThai = N'Đã trả khách'
        WHERE HopDongID = @HopDongID


        PRINT N'Khách đã thanh toán hết công nợ. Đã trả lại tài sản.';

    END

    ELSE
    BEGIN

        SET @TrangThaiMoi = N'Đang trả góp'


        UPDATE HopDong
        SET TrangThai = @TrangThaiMoi
        WHERE HopDongID = @HopDongID


        PRINT N'Đã ghi nhận thanh toán. Khách vẫn còn công nợ.';

    END


    -- =============================================
    -- GHI LỊCH SỬ TRẠNG THÁI
    -- =============================================
    INSERT INTO LichSuTrangThai
    (
        HopDongID,
        TrangThaiCu,
        TrangThaiMoi,
        GhiChu
    )
    VALUES
    (
        @HopDongID,
        @TrangThaiCu,
        @TrangThaiMoi,
        N'Cập nhật trạng thái sau thanh toán'
    )


    -- =============================================
    -- TỔNG GIÁ TRỊ TÀI SẢN CÒN GIỮ
    -- =============================================
    SELECT
        @TongGiaTriTS =
            ISNULL(SUM(GiaTriDinhGia), 0)
    FROM TaiSan
    WHERE HopDongID = @HopDongID
      AND TrangThai <> N'Đã bán thanh lý'


    -- =============================================
    -- HIỂN THỊ THÔNG TIN THANH TOÁN
    -- =============================================
    SELECT
        @TongNo           AS TongNoTruocKhiTra,
        @SoTienTra        AS SoTienKhachTra,
        @ConNo            AS DuNoConLai,
        @TongGiaTriTS     AS TongGiaTriTaiSan


    -- =============================================
    -- KIỂM TRA KHẢ NĂNG ĐẢM BẢO CÔNG NỢ
    -- =============================================
    IF @TongGiaTriTS >= @ConNo
    BEGIN

        PRINT N'Giá trị tài sản vẫn đảm bảo đủ cho dư nợ còn lại';

    END
    ELSE
    BEGIN

        PRINT N'Cảnh báo: Giá trị tài sản thấp hơn dư nợ còn lại';

    END

END
GO
```

<img width="1917" height="1077" alt="image" src="https://github.com/user-attachments/assets/58c7e8a8-2df3-4b9d-b24c-24fbcec86038" />


#### **Test case: Thực thi Event 3 - PROCEDURE: sp_ThanhToanHopDong**
#### **TRƯỜNG HỢP 1: Khách thanh toán một phần công nợ**
**Giả sử:**
- Hợp đồng ID = 2
- Khách thanh toán thêm 1.000.000đ
- Ngày thanh toán: `2025-03-25`

**Kỳ vọng:**
- Hệ thống ghi nhận giao dịch thanh toán mới
- Dư nợ giảm tương ứng
- Trạng thái hợp đồng chuyển sang: `"Đang trả góp"`
- Hệ thống lưu lịch sử thay đổi trạng thái vào bảng `LichSuTrangThai`
  
```
EXEC sp_ThanhToanHopDong
    @HopDongID  = 2,
    @NhanVienID = 1,
    @SoTienTra  = 1000000,
    @NgayTra    = '2025-03-25'
GO

SELECT * FROM GiaoDich
WHERE HopDongID = 2
GO

SELECT * FROM LichSuTrangThai
WHERE HopDongID = 2
GO
```

<img width="1917" height="1077" alt="image" src="https://github.com/user-attachments/assets/4055e056-a97c-40b2-b362-63b4c76b7a3e" />

#### **TRƯỜNG HỢP 2: Khách thanh toán toàn bộ công nợ còn lại**
**Giả sử:**
- Hợp đồng ID = 2
- Khách thanh toán toàn bộ dư nợ còn lại
- Ngày thanh toán: `2025-04-01`

**Kỳ vọng:**
- Hợp đồng chuyển sang trạng thái `"Đã thanh toán đủ"`
- Tài sản cầm cố được cập nhật trạng thái `"Đã trả khách"`
- Dư nợ còn lại bằng `0`
- Hệ thống tiếp tục ghi nhận lịch sử trạng thái hợp đồng

```
EXEC sp_ThanhToanHopDong
    @HopDongID  = 2,
    @NhanVienID = 1,
    @SoTienTra  = 10000000,
    @NgayTra    = '2025-04-01'
GO


SELECT
    HopDongID,
    TrangThai
FROM HopDong
WHERE HopDongID = 2
GO


SELECT * FROM TaiSan
WHERE HopDongID = 2
GO


SELECT * FROM LichSuTrangThai
WHERE HopDongID = 2
GO
```

<img width="1917" height="1077" alt="image" src="https://github.com/user-attachments/assets/6db411ca-091b-4342-bf85-78fdc7b63c79" />

---
### Event 4: Truy vấn danh sách nợ xấu (Nợ khó đòi)

Tạo `CREATE PROCEDURE` có tên `sp_DanhSachNoXau`

```
CREATE PROCEDURE sp_DanhSachNoXau
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        KH.HoTen                         AS TenKhachHang,
        KH.SoDienThoai,

        HD.SoTienVayGoc,

        DATEDIFF(
            DAY,
            HD.Deadline1,
            GETDATE()
        ) AS SoNgayQuaHan,


        dbo.fn_CalcMoneyContract
        (
            HD.HopDongID,
            GETDATE()
        ) AS TongNoHienTai,


        dbo.fn_CalcMoneyContract
        (
            HD.HopDongID,
            DATEADD(MONTH, 1, GETDATE())
        ) AS TongNoSau1Thang


    FROM HopDong HD
    INNER JOIN KhachHang KH
        ON HD.KhachHangID = KH.KhachHangID

    WHERE
        GETDATE() > HD.Deadline1
        AND HD.TrangThai <> N'Đã thanh toán đủ'

END
GO
```
<img width="1917" height="1077" alt="image" src="https://github.com/user-attachments/assets/e82026cf-774c-4377-aba5-1270e466c5cb" />

#### **Test case: Thực thi Event 4 - DANH SÁCH KHÁCH HÀNG NỢ XẤU**

**Mục đích:**
- Liệt kê các khách hàng đã quá Deadline1 nhưng chưa thanh toán đầy đủ công nợ.
- Điều kiện lọc:
`- Ngày hiện tại > Deadline1`
`- Trạng thái hợp đồng khác "Đã thanh toán đủ"`
-  Kết quả hiển thị:
`- Tên khách hàng`
`- Số điện thoại`
`- Số tiền vay gốc`
`- Số ngày quá hạn`
`- Tổng nợ hiện tại`
`- Tổng nợ dự kiến sau 1 tháng nữa`
- Hợp đồng test:
`- HopDongID = 2`
`- Khách hàng: Lê Văn Cường`
`- Deadline1 = 2025-03-31`
- Vì hợp đồng đã quá Deadline1 và chưa thanh toán đủ nên khách hàng được đưa vào danh sách nợ xấu.

```
EXEC sp_DanhSachNoXau
GO
```
<img width="1890" height="1077" alt="image" src="https://github.com/user-attachments/assets/68830770-875b-4433-a375-6079325343ae" />

---
### Event 5: Quản lý thanh lý tài sản

Để tự động hóa quá trình xử lý nợ xấu và thanh lý tài sản trong hệ thống cầm đồ, hệ thống sử dụng các `TRIGGER` để theo dõi trạng thái hợp đồng và cập nhật trạng thái tài sản tương ứng.

#### **TRIGGER 1: trg_HopDong_NoXau**
**Chức năng:**  
Tự động chuyển trạng thái hợp đồng sang `"Quá hạn (nợ xấu)"`.

**Điều kiện kích hoạt:**
- Hợp đồng đang có trạng thái `"Đang vay"`
- Ngày hiện tại đã vượt quá `Deadline1`

**Ý nghĩa:**  
Giúp hệ thống tự động phát hiện các hợp đồng quá hạn thanh toán để đưa vào nhóm nợ xấu mà không cần cập nhật thủ công.


#### **TRIGGER 2: trg_TaiSan_SanSangThanhLy**
**Chức năng:**  
Tự động chuyển trạng thái tài sản sang `"Sẵn sàng thanh lý"`.

**Điều kiện kích hoạt:**
- Hợp đồng đã ở trạng thái `"Quá hạn (nợ xấu)"`
- Ngày hiện tại đã vượt quá `Deadline2`

**Ý nghĩa:**  
Cho phép hệ thống xác định các tài sản đủ điều kiện xử lý thanh lý do khách hàng đã quá hạn thanh toán quá lâu.


#### **TRIGGER 3: trg_TaiSan_DaThanhLy**
**Chức năng:**  
Tự động cập nhật trạng thái tài sản thành `"Đã bán thanh lý"` và đánh dấu tài sản đã được bán.

**Điều kiện kích hoạt:**
- Hợp đồng chuyển sang trạng thái `"Đã thanh lý"`

**Ý nghĩa:**  
Đảm bảo trạng thái tài sản luôn đồng bộ với trạng thái cuối cùng của hợp đồng trong quá trình thanh lý.

```
-- =============================================
-- EVENT 5: QUẢN LÝ THANH LÝ TÀI SẢN
-- =============================================

DROP TRIGGER IF EXISTS trg_HopDong_NoXau
GO

DROP TRIGGER IF EXISTS trg_TaiSan_SanSangThanhLy
GO

DROP TRIGGER IF EXISTS trg_TaiSan_DaThanhLy
GO


-- =============================================
-- TRIGGER 1:
-- CHUYỂN HỢP ĐỒNG SANG NỢ XẤU
-- =============================================

CREATE TRIGGER trg_HopDong_NoXau
ON HopDong
AFTER UPDATE
AS
BEGIN

    SET NOCOUNT ON;

    UPDATE HD
    SET TrangThai = N'Quá hạn (nợ xấu)'
    FROM HopDong HD
    INNER JOIN inserted I
        ON HD.HopDongID = I.HopDongID

    WHERE
        I.TrangThai = N'Đang vay'
        AND GETDATE() > HD.Deadline1
        AND HD.TrangThai <> N'Quá hạn (nợ xấu)'

END
GO


-- =============================================
-- TRIGGER 2:
-- TÀI SẢN SẴN SÀNG THANH LÝ
-- =============================================

CREATE TRIGGER trg_TaiSan_SanSangThanhLy
ON HopDong
AFTER UPDATE
AS
BEGIN

    SET NOCOUNT ON;

    UPDATE TS
    SET TrangThai = N'Sẵn sàng thanh lý'
    FROM TaiSan TS
    INNER JOIN inserted I
        ON TS.HopDongID = I.HopDongID
    INNER JOIN HopDong HD
        ON HD.HopDongID = I.HopDongID

    WHERE
        I.TrangThai = N'Quá hạn (nợ xấu)'
        AND GETDATE() > HD.Deadline2
        AND TS.TrangThai <> N'Sẵn sàng thanh lý'

END
GO


-- =============================================
-- TRIGGER 3:
-- ĐÃ BÁN THANH LÝ TÀI SẢN
-- =============================================

CREATE TRIGGER trg_TaiSan_DaThanhLy
ON HopDong
AFTER UPDATE
AS
BEGIN

    SET NOCOUNT ON;

    UPDATE TS
    SET
        TrangThai = N'Đã bán thanh lý',
        IsSold = 1,
        NgayCapNhat = GETDATE()

    FROM TaiSan TS
    INNER JOIN inserted I
        ON TS.HopDongID = I.HopDongID

    WHERE
        I.TrangThai = N'Đã thanh lý'
        AND TS.TrangThai <> N'Đã bán thanh lý'

END
GO
```

<img width="1917" height="1077" alt="image" src="https://github.com/user-attachments/assets/092cec65-1a91-46c0-aa09-ec0733e14605" />

#### **Test case: Thực thi Event 5 - QUẢN LÝ THANH LÝ TÀI SẢN**
**TEST TRIGGER 1**

- Cập nhật hợp đồng sang trạng thái "Đang vay" Trigger sẽ tự động chuyển thành: "Quá hạn (nợ xấu)" vì đã vượt Deadline1

```
UPDATE HopDong
SET TrangThai = N'Đang vay'
WHERE HopDongID = 2
GO


SELECT
    HopDongID,
    TrangThai,
    Deadline1
FROM HopDong
WHERE HopDongID = 2
GO

```

<img width="1917" height="1077" alt="image" src="https://github.com/user-attachments/assets/f9f856b9-6514-47b5-b367-a73252ba347f" />


**TEST TRIGGER 2**

- Chuyển hợp đồng sang: "Quá hạn (nợ xấu)". Nếu đã vượt Deadline2trigger sẽ tự động chuyển trạng thái tài sản sang: "Sẵn sàng thanh lý"

```
UPDATE HopDong
SET TrangThai = N'Quá hạn (nợ xấu)'
WHERE HopDongID = 2
GO


SELECT
    TaiSanID,
    TenTaiSan,
    TrangThai
FROM TaiSan
WHERE HopDongID = 2
GO
```
<img width="1917" height="1077" alt="image" src="https://github.com/user-attachments/assets/1e8c0f83-38b9-4f49-9863-f9acd6b97488" />


**TEST TRIGGER 3**

- Khi hợp đồng chuyển sang: "Đã thanh lý"
- Trigger sẽ tự động cập nhật trạng thái tài sản thành: "Đã bán thanh lý"
- Đồng thời đánh dấu IsSold = 1

```
UPDATE HopDong
SET TrangThai = N'Đã thanh lý'
WHERE HopDongID = 2
GO


SELECT
    TaiSanID,
    TenTaiSan,
    TrangThai,
    IsSold
FROM TaiSan
WHERE HopDongID = 2
GO
```

<img width="1912" height="1077" alt="image" src="https://github.com/user-attachments/assets/db9d7549-ca96-48b8-a18c-27301ce329d2" />


