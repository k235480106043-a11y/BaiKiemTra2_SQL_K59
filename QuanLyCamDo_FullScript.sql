USE [master]
GO
/****** Object:  Database [QuanLyCamDo]    Script Date: 11/05/2026 8:52:48 SA ******/
CREATE DATABASE [QuanLyCamDo]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'QuanLyCamDo', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\QuanLyCamDo.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'QuanLyCamDo_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\QuanLyCamDo_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [QuanLyCamDo] SET COMPATIBILITY_LEVEL = 170
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [QuanLyCamDo].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [QuanLyCamDo] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [QuanLyCamDo] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [QuanLyCamDo] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [QuanLyCamDo] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [QuanLyCamDo] SET ARITHABORT OFF 
GO
ALTER DATABASE [QuanLyCamDo] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [QuanLyCamDo] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [QuanLyCamDo] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [QuanLyCamDo] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [QuanLyCamDo] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [QuanLyCamDo] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [QuanLyCamDo] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [QuanLyCamDo] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [QuanLyCamDo] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [QuanLyCamDo] SET  ENABLE_BROKER 
GO
ALTER DATABASE [QuanLyCamDo] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [QuanLyCamDo] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [QuanLyCamDo] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [QuanLyCamDo] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [QuanLyCamDo] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [QuanLyCamDo] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [QuanLyCamDo] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [QuanLyCamDo] SET RECOVERY FULL 
GO
ALTER DATABASE [QuanLyCamDo] SET  MULTI_USER 
GO
ALTER DATABASE [QuanLyCamDo] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [QuanLyCamDo] SET DB_CHAINING OFF 
GO
ALTER DATABASE [QuanLyCamDo] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [QuanLyCamDo] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [QuanLyCamDo] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [QuanLyCamDo] SET OPTIMIZED_LOCKING = OFF 
GO
ALTER DATABASE [QuanLyCamDo] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'QuanLyCamDo', N'ON'
GO
ALTER DATABASE [QuanLyCamDo] SET QUERY_STORE = ON
GO
ALTER DATABASE [QuanLyCamDo] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [QuanLyCamDo]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_CalcMoneyContract]    Script Date: 11/05/2026 8:52:48 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_CalcMoneyContract]
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
/****** Object:  UserDefinedFunction [dbo].[fn_CalcMoneyTransaction]    Script Date: 11/05/2026 8:52:48 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_CalcMoneyTransaction]
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


    -- Lấy thông tin giao dịch
    SELECT
        @ContractID = HopDongID,
        @NgayGD     = CAST(NgayGiaoDich AS DATE),
        @DuNo       = DuNoSauKhi
    FROM GiaoDich
    WHERE GiaoDichID = @TransactionID


    -- Lấy Deadline1 của hợp đồng
    SELECT
        @D1 = Deadline1
    FROM HopDong
    WHERE HopDongID = @ContractID


    -- Nếu ngày cần tính nhỏ hơn ngày giao dịch
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

        -- Nếu giao dịch trước hoặc đúng D1
        IF @NgayGD <= @D1
        BEGIN

            -- Tính lãi đơn tới D1
            SET @SoNgayD1 =
                DATEDIFF(DAY, @NgayGD, @D1)

            SET @NoDenD1 =
                @DuNo *
                (1 + @LaiSuat * @SoNgayD1)

            -- Tính số ngày lãi kép
            SET @SoNgayKep =
                DATEDIFF(DAY, @D1, @TargetDate)

        END

        -- Nếu giao dịch sau D1
        ELSE
        BEGIN

            -- Không có lãi đơn
            SET @NoDenD1 = @DuNo

            -- Chỉ tính từ ngày giao dịch
            SET @SoNgayKep =
                DATEDIFF(DAY, @NgayGD, @TargetDate)

        END


        -- Tính lãi kép
        SET @KetQua =
            @NoDenD1 *
            POWER(
                CAST(1 + @LaiSuat AS FLOAT),
                @SoNgayKep
            )

    END


    -- Không cho âm
    IF @KetQua < 0
        SET @KetQua = 0


    RETURN ROUND(@KetQua, 2)

END

GO
/****** Object:  Table [dbo].[GiaoDich]    Script Date: 11/05/2026 8:52:49 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GiaoDich](
	[GiaoDichID] [int] IDENTITY(1,1) NOT NULL,
	[HopDongID] [int] NOT NULL,
	[NhanVienID] [int] NULL,
	[NgayGiaoDich] [datetime] NOT NULL,
	[SoTienTra] [decimal](18, 2) NOT NULL,
	[DuNoTruocKhi] [decimal](18, 2) NOT NULL,
	[DuNoSauKhi] [decimal](18, 2) NOT NULL,
	[GhiChu] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[GiaoDichID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HopDong]    Script Date: 11/05/2026 8:52:49 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HopDong](
	[HopDongID] [int] IDENTITY(1,1) NOT NULL,
	[KhachHangID] [int] NOT NULL,
	[NhanVienID] [int] NULL,
	[SoTienVayGoc] [decimal](18, 2) NOT NULL,
	[NgayVay] [date] NOT NULL,
	[Deadline1] [date] NOT NULL,
	[Deadline2] [date] NOT NULL,
	[TrangThai] [nvarchar](50) NOT NULL,
	[GhiChu] [nvarchar](500) NULL,
	[NgayTao] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[HopDongID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KhachHang]    Script Date: 11/05/2026 8:52:49 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KhachHang](
	[KhachHangID] [int] IDENTITY(1,1) NOT NULL,
	[HoTen] [nvarchar](100) NOT NULL,
	[SoDienThoai] [varchar](15) NOT NULL,
	[CMND_CCCD] [varchar](20) NOT NULL,
	[DiaChi] [nvarchar](255) NULL,
	[NgayTao] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[KhachHangID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[SoDienThoai] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CMND_CCCD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LichSuTrangThai]    Script Date: 11/05/2026 8:52:49 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LichSuTrangThai](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[HopDongID] [int] NOT NULL,
	[TrangThaiCu] [nvarchar](50) NULL,
	[TrangThaiMoi] [nvarchar](50) NULL,
	[ThoiGian] [datetime] NULL,
	[GhiChu] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NhanVien]    Script Date: 11/05/2026 8:52:49 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NhanVien](
	[NhanVienID] [int] IDENTITY(1,1) NOT NULL,
	[HoTen] [nvarchar](100) NOT NULL,
	[SoDienThoai] [varchar](15) NULL,
	[ChucVu] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[NhanVienID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TaiSan]    Script Date: 11/05/2026 8:52:49 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaiSan](
	[TaiSanID] [int] IDENTITY(1,1) NOT NULL,
	[HopDongID] [int] NOT NULL,
	[TenTaiSan] [nvarchar](200) NOT NULL,
	[MoTa] [nvarchar](500) NULL,
	[GiaTriDinhGia] [decimal](18, 2) NOT NULL,
	[TrangThai] [nvarchar](50) NOT NULL,
	[IsSold] [bit] NOT NULL,
	[NgayCapNhat] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[TaiSanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GiaoDich] ADD  DEFAULT (getdate()) FOR [NgayGiaoDich]
GO
ALTER TABLE [dbo].[HopDong] ADD  DEFAULT (N'Đang vay') FOR [TrangThai]
GO
ALTER TABLE [dbo].[HopDong] ADD  DEFAULT (getdate()) FOR [NgayTao]
GO
ALTER TABLE [dbo].[KhachHang] ADD  DEFAULT (getdate()) FOR [NgayTao]
GO
ALTER TABLE [dbo].[LichSuTrangThai] ADD  DEFAULT (getdate()) FOR [ThoiGian]
GO
ALTER TABLE [dbo].[TaiSan] ADD  DEFAULT (N'Đang cầm cố') FOR [TrangThai]
GO
ALTER TABLE [dbo].[TaiSan] ADD  DEFAULT ((0)) FOR [IsSold]
GO
ALTER TABLE [dbo].[TaiSan] ADD  DEFAULT (getdate()) FOR [NgayCapNhat]
GO
ALTER TABLE [dbo].[GiaoDich]  WITH CHECK ADD  CONSTRAINT [FK_GiaoDich_HopDong] FOREIGN KEY([HopDongID])
REFERENCES [dbo].[HopDong] ([HopDongID])
GO
ALTER TABLE [dbo].[GiaoDich] CHECK CONSTRAINT [FK_GiaoDich_HopDong]
GO
ALTER TABLE [dbo].[GiaoDich]  WITH CHECK ADD  CONSTRAINT [FK_GiaoDich_NhanVien] FOREIGN KEY([NhanVienID])
REFERENCES [dbo].[NhanVien] ([NhanVienID])
GO
ALTER TABLE [dbo].[GiaoDich] CHECK CONSTRAINT [FK_GiaoDich_NhanVien]
GO
ALTER TABLE [dbo].[HopDong]  WITH CHECK ADD  CONSTRAINT [FK_HopDong_KhachHang] FOREIGN KEY([KhachHangID])
REFERENCES [dbo].[KhachHang] ([KhachHangID])
GO
ALTER TABLE [dbo].[HopDong] CHECK CONSTRAINT [FK_HopDong_KhachHang]
GO
ALTER TABLE [dbo].[HopDong]  WITH CHECK ADD  CONSTRAINT [FK_HopDong_NhanVien] FOREIGN KEY([NhanVienID])
REFERENCES [dbo].[NhanVien] ([NhanVienID])
GO
ALTER TABLE [dbo].[HopDong] CHECK CONSTRAINT [FK_HopDong_NhanVien]
GO
ALTER TABLE [dbo].[LichSuTrangThai]  WITH CHECK ADD  CONSTRAINT [FK_LichSu_HopDong] FOREIGN KEY([HopDongID])
REFERENCES [dbo].[HopDong] ([HopDongID])
GO
ALTER TABLE [dbo].[LichSuTrangThai] CHECK CONSTRAINT [FK_LichSu_HopDong]
GO
ALTER TABLE [dbo].[TaiSan]  WITH CHECK ADD  CONSTRAINT [FK_TaiSan_HopDong] FOREIGN KEY([HopDongID])
REFERENCES [dbo].[HopDong] ([HopDongID])
GO
ALTER TABLE [dbo].[TaiSan] CHECK CONSTRAINT [FK_TaiSan_HopDong]
GO
/****** Object:  StoredProcedure [dbo].[sp_DanhSachNoXau]    Script Date: 11/05/2026 8:52:49 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DanhSachNoXau]
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
/****** Object:  StoredProcedure [dbo].[sp_TaoHopDong]    Script Date: 11/05/2026 8:52:49 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_TaoHopDong]
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
/****** Object:  StoredProcedure [dbo].[sp_ThanhToanHopDong]    Script Date: 11/05/2026 8:52:49 SA ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ThanhToanHopDong]
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
    DECLARE @TrangThai        NVARCHAR(100)
    DECLARE @Deadline2        DATE
    DECLARE @IsSold           BIT


    -- =============================================
    -- Lấy thông tin hợp đồng
    -- =============================================
    SELECT
        @TrangThai = TrangThai,
        @Deadline2 = Deadline2
    FROM HopDong
    WHERE HopDongID = @HopDongID


    -- =============================================
    -- Kiểm tra tài sản đã thanh lý chưa
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

        PRINT N'Tài sản đã bị thanh lý. Không thể thu tiền hoặc trả tài sản.';
        RETURN;

    END


    -- =============================================
    -- Tính tổng công nợ hiện tại
    -- =============================================
    SET @TongNo =
        dbo.fn_CalcMoneyContract(
            @HopDongID,
            @NgayTra
        )


    -- =============================================
    -- Tính số nợ còn lại
    -- =============================================
    SET @ConNo = @TongNo - @SoTienTra

    IF @ConNo < 0
        SET @ConNo = 0


    -- =============================================
    -- Ghi nhận giao dịch thanh toán
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
    -- Nếu đã trả hết nợ
    -- =============================================
    IF @ConNo = 0
    BEGIN

        UPDATE HopDong
        SET TrangThai = N'Đã thanh toán đủ'
        WHERE HopDongID = @HopDongID


        UPDATE TaiSan
        SET TrangThai = N'Đã trả khách'
        WHERE HopDongID = @HopDongID


        PRINT N'Khách đã thanh toán hết công nợ. Đã trả lại tài sản.';

    END

    ELSE
    BEGIN

        UPDATE HopDong
        SET TrangThai = N'Đang trả góp'
        WHERE HopDongID = @HopDongID


        PRINT N'Đã ghi nhận thanh toán. Khách vẫn còn công nợ.';

    END


    -- =============================================
    -- Hiển thị thông tin sau thanh toán
    -- =============================================
    SELECT
        @TongNo AS TongNoTruocKhiTra,
        @SoTienTra AS SoTienKhachTra,
        @ConNo AS DuNoConLai


    -- =============================================
    -- Gợi ý tài sản phù hợp với dư nợ
    -- =============================================
    SELECT
        TaiSanID,
        TenTaiSan,
        GiaTriDinhGia,
        TrangThai
    FROM TaiSan
    WHERE HopDongID = @HopDongID
      AND GiaTriDinhGia >= @ConNo

END
GO
USE [master]
GO
ALTER DATABASE [QuanLyCamDo] SET  READ_WRITE 
GO
