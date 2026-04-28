# BÀI KIỂM TRA SỐ 02 - HỆ QUẢN TRỊ CSDL SQL SERVER

## 1. Thông tin sinh viên

- **Họ và tên:** Nguyễn Thị Ngọc Linh  
- **Mã số sinh viên:** K235480106043  
- **Lớp:** K59KMT.K01 - Kỹ thuật Máy tính  
- **Môn học:** Hệ Quản Trị Cơ Sở Dữ Liệu (SQL Server)  
- **Khoa:** Điện tử  
- **Trường:** Đại học Kỹ thuật Công nghiệp Thái Nguyên (TNUT)  


## 2. Yêu Cầu Đầu Bài

### Đề tài: Quản lý cửa hàng mỹ phẩm

Thực hiện xây dựng một hệ thống quản lý cửa hàng mỹ phẩm hoàn chỉnh trên SQL Server, đáp ứng đầy đủ các yêu cầu của bài kiểm tra.

Toàn bộ quá trình thực hiện phải được ghi lại bằng các screenshot minh họa. Mỗi hình ảnh cần đi kèm câu lệnh SQL tương ứng và phần chú thích rõ ràng về chức năng, mục đích xử lý cũng như kết quả đạt được.

Bài tập được nộp dưới dạng **GitHub Repository (public)** gồm hai thành phần chính:

- **README.md**: chứa toàn bộ nội dung báo cáo, hình ảnh minh họa và giải thích chi tiết  
- **baikiemtra2.sql**: chứa toàn bộ mã SQL sử dụng trong bài làm  


## 3. Giới Thiệu Về Hệ Thống Quản Lý Mỹ Phẩm

Xây dựng hệ thống **Quản lý cửa hàng mỹ phẩm (QuanLyMyPham)** trên nền tảng SQL Server với các chức năng chính như quản lý sản phẩm, quản lý hóa đơn và quản lý chi tiết giao dịch bán hàng.

Mỗi sản phẩm được lưu trữ đầy đủ thông tin gồm tên sản phẩm, giá niêm yết và số lượng tồn kho hiện tại.

Mỗi hóa đơn lưu các thông tin tổng quan như ngày lập, tên khách hàng và tổng tiền thanh toán.

Bảng chi tiết hóa đơn thể hiện mối quan hệ giữa hóa đơn và sản phẩm, bao gồm số lượng mua thực tế và đơn giá tại thời điểm bán.

Toàn bộ bài làm được chia thành 5 phần chính:

- Thiết kế cơ sở dữ liệu với các bảng `SanPham`, `HoaDon`, `ChiTietHoaDon`, kèm các ràng buộc Primary Key, Foreign Key, Check Constraint và dữ liệu mẫu  
- Xây dựng Function để tính tổng tiền hóa đơn và lọc danh sách sản phẩm sắp hết hàng  
- Xây dựng Stored Procedure để xử lý nhập thêm hàng hóa và thống kê doanh thu bán hàng theo tháng  
- Xây dựng Trigger để tự động cập nhật tồn kho khi bán hàng và ghi log thay đổi dữ liệu  
- Sử dụng Cursor để duyệt từng bản ghi và so sánh với phương pháp Set-based nhằm tối ưu hiệu suất xử lý  

Cơ sở dữ liệu được đặt tên theo đúng yêu cầu: **QuanLyMyPham_K235480106043**

Mỗi phần lệnh SQL đều có screenshot minh họa, kết quả thực thi và phần giải thích chi tiết để đảm bảo bài làm đầy đủ, rõ ràng và đúng chuẩn yêu cầu môn học.


## Phần 1: Thiết kế và Khởi tạo Cấu trúc Dữ liệu

### 1.1. Khởi tạo Database
Hệ thống sử dụng lệnh `CREATE DATABASE` để tạo vùng lưu trữ. Ngay sau đó dùng lệnh `USE` để xác định phiên làm việc, tránh việc tạo nhầm bảng vào các cơ sở dữ liệu hệ thống.

```sql
CREATE DATABASE [QuanLyMyPham_K235480106043];
GO
USE [QuanLyMyPham_K235480106043];
GO
```
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/0d690d30-f09f-42a3-8454-9b2a4ec1df51" />

_Tạo cơ sở dữ liệu [QuanLyMyPham_K23548006043]_

### 1.2. Thiết lập các bảng dữ liệu
#### a) Bảng `[SanPham]`: Đây là bảng lưu trữ thông tin gốc của các loại mỹ phẩm có trong cửa hàng.
- `[MaSanPham]`: Làm Khóa chính `(PK)`, dùng [INT] để tối ưu bộ nhớ cho các trường làm khóa. Kết hợp với IDENTITY(1,1) để hệ thống tự sinh mã duy nhất, không trùng lặp.

- `[TenSanPham]`: Dùng NVARCHAR để hỗ trợ lưu tiếng Việt có dấu cho tên mỹ phẩm (ví dụ: Nước tẩy trang, Kem chống nắng).

- `[GiaBan]`: Dùng MONEY để đảm bảo độ chính xác cao khi tính toán tiền tệ, tránh sai số như kiểu Float.

```
CREATE TABLE [SanPham] (
    [MaSanPham] INT IDENTITY(1,1) NOT NULL,
    [TenSanPham] NVARCHAR(150) NOT NULL,
    [GiaBan] MONEY NOT NULL,
    [SoLuongTon] INT DEFAULT 0,
    CONSTRAINT [PK_SanPham] PRIMARY KEY ([MaSanPham]),
    CONSTRAINT [CK_GiaBan] CHECK ([GiaBan] > 0),
    CONSTRAINT [CK_SoLuongTon] CHECK ([SoLuongTon] >= 0)
);
```
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/081d34d6-9571-49e9-b177-28e29180e1c6" />

_Tạo bảng Sản Phẩm - Bảng cha chứa thông tin mỹ phẩm_

#### b) Bảng `[HoaDon]`: Bảng này lưu trữ thông tin tổng quát về các lần giao dịch với khách hàng.
- `[MaHoaDon]`: Làm Khóa chính `(PK)` tự động tăng. 

- `[NgayLap]`: Dùng DATETIME để lưu chính xác cả ngày và giờ khách mua hàng. Sử dụng DEFAULT GETDATE() để hệ thống tự động lấy giờ máy chủ khi lập hóa đơn.

- `[TongTien]`: Mặc định khởi tạo bằng 0 và sẽ được cập nhật sau khi tính toán các chi tiết hóa đơn.
- `[TenKhachHang]`: Dùng NVARCHAR để lưu tên khách hàng có dấu.
  
```
CREATE TABLE [HoaDon] (
    [MaHoaDon] INT IDENTITY(1,1) NOT NULL,
    [NgayLap] DATETIME DEFAULT GETDATE(),
    [TenKhachHang] NVARCHAR(100),
    [TongTien] MONEY DEFAULT 0,
    CONSTRAINT [PK_HoaDon] PRIMARY KEY ([MaHoaDon])
);
```
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/accbbc3a-8dc6-402e-a2f2-ba84538dc095" />

_Tạo bảng Hóa Đơn - Bảng cha chứa thông tin chung của giao dịch_

#### c) Bảng `[ChiTietHoaDon]`: Đây là bảng quan trọng nhất để thiết lập quan hệ Nhiều - Nhiều (n-n) giữa bảng `[Hoa đon]` và bảng `[San pham]`.

- Sử dụng Khóa chính hỗn hợp (Composite PK): Kết hợp cả `[MaHoaDon]` và `[MaSanPham]` làm khóa chính. Điều này đảm bảo trong một hóa đơn, mỗi loại mỹ phẩm chỉ xuất hiện một lần (nếu mua thêm thì cộng dồn số lượng).

- Chứa 2 Khóa ngoại `(FK)` tham chiếu trực tiếp đến bảng `HoaDon` và `SanPham` để đảm bảo tính toàn vẹn (không thể bán sản phẩm không tồn tại).

- `[DonGiaBan]`: Được lưu riêng tại đây để chốt giá tại thời điểm bán, tránh việc giá sản phẩm trong kho thay đổi làm sai lệch lịch sử hóa đơn cũ.
```
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
```
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/66bdf8a0-0f4b-4a58-9946-c29b40652b6b" />

_Tạo bảng Chi Tiết Hoá Đơn - Bảng con thể hiện quan hệ N-N_

### 1.3. Chèn dữ liệu mẫu vào các bảng

Sau khi hoàn thiện cấu trúc các bảng, em tiến hành chèn dữ liệu mẫu để kiểm tra tính toàn vẹn và chuẩn bị dữ liệu cho các phần tính toán tiếp theo.

```sql
INSERT INTO [SanPham] ([TenSanPham], [GiaBan], [SoLuongTon])
VALUES 
    (N'Son MAC Ruby Woo', 550000, 50),
    (N'Nước tẩy trang Bioderma 500ml', 395000, 10),    
    (N'Kem chống nắng La Roche-Posay', 485000, 30),
    (N'Serum Estee Lauder Advanced Night Repair', 2500000, 15), 
    (N'Sữa rửa mặt Cerave Hydrating', 370000, 40);
GO


INSERT INTO [HoaDon] ([TenKhachHang]) 
VALUES 
    (N'Nguyễn Đăng Thịnh'), 
    (N'Vũ Hoàng Long'),
    (N'Đỗ Phương Thảo'),
    (N'Trần Minh Khôi');
GO

INSERT INTO [ChiTietHoaDon] ([MaHoaDon], [MaSanPham], [SoLuongMua], [DonGiaBan])
VALUES (1, 1, 10, 550000);

INSERT INTO [ChiTietHoaDon] ([MaHoaDon], [MaSanPham], [SoLuongMua], [DonGiaBan])
VALUES 
    (2, 2, 1, 395000),
    (2, 3, 1, 485000);

INSERT INTO [ChiTietHoaDon] ([MaHoaDon], [MaSanPham], [SoLuongMua], [DonGiaBan])
VALUES (3, 4, 1, 2500000);

INSERT INTO [ChiTietHoaDon] ([MaHoaDon], [MaSanPham], [SoLuongMua], [DonGiaBan])
VALUES (4, 5, 2, 370000);
GO

SELECT * FROM [SanPham];
SELECT * FROM [HoaDon];
SELECT * FROM [ChiTietHoaDon];
```
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/61bd12cd-cb9f-4482-908d-02a612e66d98" />

_Chèn dữ liệu vào bảng_

## Phần 2: Xây dựng Function 

### 2.1. Các loại hàm có sẵn (Built-in Functions)
SQL Server cung cấp hàng trăm hàm có sẵn để xử lý dữ liệu, được chia thành các nhóm chính:
* **Hàm chuỗi (String Functions):** `LEN()`, `SUBSTRING()`, `REPLACE()`, `UPPER()`...
* **Hàm ngày tháng (Date/Time Functions):** `GETDATE()`, `DAY()`, `MONTH()`, `YEAR()`, `DATEDIFF()`...
* **Hàm toán học (Mathematical Functions):** `ROUND()`, `ABS()`, `CEILING()`, `FLOOR()`...
* **Hàm chuyển đổi (Conversion Functions):** `CAST()`, `CONVERT()`, `FORMAT()`...
* **Hàm hệ thống (System/Logical Functions):** `ISNULL()`, `IIF()`, `COALESCE()`...
---

### Sử dụng một số Built - in functions

- `FORMAT()` - Định dạng bảng giá :
Trong cơ sở dữ liệu, giá bán được lưu ở dạng số thực (kiểu `MONEY`) để phục vụ tính toán. Tuy nhiên, khi in ra hóa đơn cho khách, con số `2500000.0000` trông rất thiếu chuyên nghiệp. Em sử dụng hàm `FORMAT()` để tự động biến đổi nó thành chuỗi tiền tệ có dấu phẩy phân cách hàng nghìn.

```sql
SELECT 
    [MaSanPham], 
    [TenSanPham], 
    [GiaBan] AS [GiaGoc_HeThong],
    FORMAT([GiaBan], 'N0') + N' VNĐ' AS [GiaNiemYet_HienThi]
FROM [SanPham];
```
<img width="1917" height="1073" alt="image" src="https://github.com/user-attachments/assets/6b446db8-d15f-43f0-9438-43603e8f297f" />

_Định dạng cột giá bán của mỹ phẩm sang chuẩn tiền tệ VNĐ_

- `IIF()` - Rẽ nhánh nhanh gọn kiểm tra tồn kho:
Thay vì phải viết câu lệnh CASE WHEN ... THEN dài dòng, hàm IIF() (If and Only If) cho phép kiểm tra một điều kiện logic và trả về kết quả ngay lập tức. Em dùng hàm này để quét nhanh xem mỹ phẩm nào còn hàng, mỹ phẩm nào đã hết.
```
SELECT 
    [TenSanPham], 
    [SoLuongTon],
    IIF([SoLuongTon] > 0, N'Còn hàng', N'Đã hết hàng') AS [TinhTrangKho]
FROM [SanPham];
```
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/301a3b34-f541-432c-b7ca-dd4607165d6c" />

_Kiểm tra tình trạng kho của từng loại mỹ phẩm_

- DATEDIFF() - Tính toán khoảng cách thời gian:
Hàm này giúp tính toán số lượng ngày, tháng, năm giữa hai mốc thời gian. Em áp dụng để tính xem các hóa đơn mỹ phẩm đã được lập cách đây bao lâu.
```
SELECT [MaHoaDon], [TenKhachHang], [NgayLap],
       DATEDIFF(DAY, [NgayLap], GETDATE()) AS [SoNgayDaTroiQua]
FROM [HoaDon];
```
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/626afe66-41db-402b-9560-d9103b735e2c" />

_Tính số ngày từ lúc lập hóa đơn đến nay_

### 2.2. Xây dựng các hàm tự định nghĩa (User-Defined Functions - UDF)

Mặc dù SQL Server đã có sẵn nhiều hàm hệ thống như tính toán, xử lý chuỗi, ngày tháng…, nhưng những yêu cầu riêng của bài toán quản lý cửa hàng như tính điểm khách hàng VIP, đánh giá sản phẩm bán chậm hay phân loại hiệu quả kinh doanh thì hệ thống không có sẵn.

Vì vậy, cần sử dụng UDF để tự xây dựng các hàm phù hợp với nghiệp vụ thực tế của cửa hàng. Việc này giúp:

- Tối ưu hóa: Chỉ cần gọi hàm một lần thay vì phải viết lại nhiều câu lệnh SQL dài và phức tạp.
- Đảm bảo tính nhất quán: Khi quy tắc tính toán thay đổi, chỉ cần sửa trong hàm, các báo cáo và chức năng liên quan sẽ tự cập nhật.

##### Phân loại và ứng dụng UDF trong bài toán quản lý
Trong SQL Server, UDF gồm 3 loại chính:

- Scalar Function (Hàm trả về 1 giá trị)
Dùng khi kết quả chỉ là một giá trị duy nhất như số, chữ hoặc ngày tháng.

Ví dụ: Tính tổng tiền của một mặt hàng, tính số ngày làm việc của nhân viên.

- Inline Table-Valued Function (Hàm nội tuyến trả về bảng)
Dùng khi cần trả về một bảng dữ liệu từ một câu lệnh SELECT duy nhất. Loại này thực hiện nhanh và thường dùng để lọc dữ liệu.

Ví dụ: Lấy danh sách mỹ phẩm có số lượng tồn kho dưới 15.

- Multi-statement Table-Valued Function (Hàm đa lệnh trả về bảng)
Dùng khi cần xử lý dữ liệu qua nhiều bước trước khi trả kết quả ra bảng. Có thể sử dụng biến bảng, điều kiện IF...ELSE, CASE...WHEN.
#### a) Hàm vô hướng (Scalar Function): Tính tổng doanh thu theo sản phẩm
- **Ý tưởng:** Người quản lý thường xuyên cần kiểm tra chéo xem một mặt hàng cụ thể (VD: Son MAC) từ trước đến nay đã mang về tổng cộng bao nhiêu doanh thu. Thay vì mỗi lần kiểm tra phải viết lại các câu lệnh `JOIN` và `SUM` phức tạp, hàm này tạo ra một "công tắc" gom gọn mọi thứ.
- **Thuật toán xử lý**
  
Bước 1: Tiếp nhận tham số. Hàm nhận đầu vào là Mã sản phẩm `(@MaSP)` do người dùng truyền vào.

Bước 2: Quét lịch sử giao dịch. Trỏ thẳng vào bảng `[ChiTietHoaDon]`, lọc ra tất cả các dòng khớp với @MaSP. Tiến hành nhân `[SoLuongMua]` với `[DonGiaBan]` và cộng dồn lại `(SUM)`.

Bước 3: Xử lý ngoại lệ (Exception Handling). Đây là bước quan trọng nhất. Nếu mặt hàng bị ế (chưa từng được bán), lệnh `SUM` sẽ trả về `NULL`. Thuật toán sử dụng hàm `ISNULL()` để ép giá trị `NULL` này thành `0 VNĐ`, đảm bảo an toàn cho các báo cáo tài chính phía sau không bị lỗi sập hệ thống.

```
CREATE FUNCTION [dbo].[fn_TinhDoanhThuTungMyPham] (@MaSP INT)
RETURNS MONEY
AS
BEGIN
    DECLARE @TongTien MONEY;
    
    SELECT @TongTien = SUM([SoLuongMua] * [DonGiaBan])
    FROM [ChiTietHoaDon]
    WHERE [MaSanPham] = @MaSP;
    
    RETURN ISNULL(@TongTien, 0); 
END;
GO

SELECT 
    [TenSanPham], 
    FORMAT([dbo].[fn_TinhDoanhThuTungMyPham]([MaSanPham]), 'N0') + N' VNĐ' AS [TongDoanhThu]
FROM [SanPham];
```
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/482a481c-912d-4c0b-9d94-5706bc7393a2" />

_Khởi tạo hàm tính tổng doanh thu. Lấy danh sách sản phẩm và in kèm doanh thu_

#### b) Hàm trả về bảng nội tuyến (Inline TVF): Bộ lọc động cảnh báo tồn kho
- **Ý tưởng:** Thủ kho cần biết mặt hàng nào sắp hết để lên kế hoạch nhập khẩu. Tuy nhiên, định mức "sắp hết" thay đổi theo từng mùa (tháng thấp điểm tồn 5 món mới lo, tháng cao điểm tồn 20 món đã phải nhập gấp). Hàm này cung cấp một bộ lọc động thay vì cố định một con số.
- **Thuật toán xử lý:** 

Bước 1: Khai báo tham số đầu vào `@MucTonToiThieu`.

Bước 2: Do cấu trúc chỉ là một câu lệnh `RETURN (SELECT...)` duy nhất, hệ thống không cần tạo bảng trung gian. Thuật toán quét trực tiếp vào bảng `[SanPham]`, giữ lại các dòng có `[SoLuongTon]` <= `@MucTonToiThieu` và trả về ngay lập tức. Điều này giúp tối ưu hóa hiệu năng (Performance) tới mức tối đa.

```
CREATE FUNCTION [dbo].[fn_LocMyPhamSapHet] (@MucTonToiThieu INT)
RETURNS TABLE
AS
RETURN (
    SELECT [MaSanPham], [TenSanPham], [SoLuongTon], [GiaBan]
    FROM [SanPham]
    WHERE [SoLuongTon] <= @MucTonToiThieu
);
GO

SELECT * FROM [dbo].[fn_LocMyPhamSapHet](15);
```
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/0555c2f7-5e3d-4575-943f-fd466d4d6dde" />

_Khởi tạo hàm lọc mỹ phẩm theo mức tồn kho động. Tìm các món chỉ còn từ 15 hộp trở xuống_

#### c) Hàm trả về bảng đa lệnh (Multi-statement TVF): Phân loại thị trường
- **Ý tưởng:** Phòng Marketing cần một báo cáo đánh giá toàn bộ kho hàng để quyết định mặt hàng nào cần chạy Sale, mặt hàng nào cần đẩy mạnh quảng cáo. Đây là bài toán phức tạp đòi hỏi phải tính toán gom nhóm rồi rẽ nhánh logic.
- **Thuật toán xử lý:**

Bước 1: Khởi tạo bộ nhớ tạm. Tạo một biến bảng `@BangBaoCao` làm nơi chứa dữ liệu nháp.

Bước 2: Thu thập dữ liệu toàn diện. Sử dụng phép nối `LEFT JOIN` từ `[SanPham]` sang `[ChiTietHoaDon]`. Thuật toán `LEFT JOIN` đảm bảo những sản phẩm ế (không có trong hóa đơn) vẫn được lôi vào báo cáo với số lượng bán là 0.
Bước 3: Phân tích rẽ nhánh: Sử dụng lệnh `UPDATE` kết hợp `CASE WHEN` duyệt qua từng dòng trong bảng ảo. Nếu bán được `>= 10` món gán nhãn "Hàng HOT", `> 0` gán "Bán ổn", còn lại gán "Ế ẩm".

Bước 4: Trả bảng kết quả đã gắn nhãn hoàn chỉnh ra ngoài.

```
CREATE FUNCTION [dbo].[fn_BaoCaoKinhDoanh] ()
RETURNS @BangBaoCao TABLE (
    [TenSP] NVARCHAR(150),
    [TongSoLuongDaBan] INT,
    [DanhGia] NVARCHAR(50)
)
AS
BEGIN
  
    INSERT INTO @BangBaoCao ([TenSP], [TongSoLuongDaBan])
    SELECT 
        S.[TenSanPham], 
        ISNULL(SUM(C.[SoLuongMua]), 0)
    FROM [SanPham] S
    LEFT JOIN [ChiTietHoaDon] C ON S.[MaSanPham] = C.[MaSanPham]
    GROUP BY S.[TenSanPham];

    
    UPDATE @BangBaoCao
    SET [DanhGia] = CASE 
        WHEN [TongSoLuongDaBan] >= 10 THEN N'🔥 Hàng HOT (Bán chạy)'
        WHEN [TongSoLuongDaBan] > 0 THEN N'✅ Bán ổn định'
        ELSE N'⚠️ Hàng tồn đọng (Cần chạy Sale)'
    END;

    RETURN;
END;
GO

SELECT * FROM [dbo].[fn_BaoCaoKinhDoanh]();
```
<img width="1918" height="1073" alt="image" src="https://github.com/user-attachments/assets/fdfb94b8-4cb1-4e81-ac81-6803743d222c" />

_Hàm báo cáo phân loại tình trạng kinh doanh. Xuất báo cáo cho Marketing_

## Phần 3: Xây dựng Store Procedure

### 3.1. Tìm hiểu các Thủ tục lưu trữ hệ thống (System Stored Procedures)
Bên cạnh các thủ tục tự viết, SQL Server cung cấp sẵn một tập hợp các System Stored Procedure (bắt đầu bằng tiền tố sp_) để quản trị hệ thống và truy xuất siêu dữ liệu (metadata) cực kỳ mạnh mẽ. Trong quá trình phát triển CSDL Quản lý Mỹ phẩm, em đã tìm hiểu và ứng dụng các System SP sau:

- `sp_help`: Thủ tục "cứu cánh" của lập trình viên. Khi truyền tên một đối tượng vào (VD: `EXEC sp_help 'SanPham'`), nó sẽ trả về toàn bộ thông tin về bảng đó: các cột, kiểu dữ liệu, chiều dài, và các khóa chính/ngoại mà không cần mở giao diện thiết kế.

- `sp_rename`: Dùng để đổi tên một đối tượng (bảng, cột) bằng lệnh thay vì click chuột. VD: `EXEC sp_rename 'SanPham.GiaBan'`, `'DonGia', 'COLUMN'`.

- `sp_databases`: Liệt kê toàn bộ các cơ sở dữ liệu đang có trên máy chủ. Rất hữu ích khi cần kiểm tra xem CSDL `QuanLyMyPham` đã được khởi tạo thành công chưa.
### 3.2. SP kiểm tra điều kiện logic (Lệnh INSERT/UPDATE)
- **Bài toán** : Cửa hàng cần thêm các dòng mỹ phẩm mới vào kho. Tuy nhiên, nhân viên nhập liệu thường xuyên gõ nhầm giá bán thành số âm hoặc quên nhập số lượng.
- **Giải pháp**: Xây dựng thủ tục `sp_ThemMoiSanPham` có tích hợp bộ lọc logic. Chỉ khi giá bán > 0 và số lượng tồn >= 0 thì lệnh `INSERT` mới được thực thi.

```
CREATE PROCEDURE [dbo].[sp_ThemMoiSanPham]
    @TenSP NVARCHAR(150),
    @GiaBan MONEY,
    @SoLuong INT
AS
BEGIN
 
    IF (@GiaBan <= 0)
    BEGIN
        PRINT N'❌ THẤT BẠI: Giá bán mỹ phẩm phải lớn hơn 0 VNĐ.';
        RETURN; 
    END
    
    IF (@SoLuong < 0)
    BEGIN
        PRINT N'❌ THẤT BẠI: Số lượng nhập kho không được phép là số âm.';
        RETURN;
    END

   
    INSERT INTO [SanPham] ([TenSanPham], [GiaBan], [SoLuongTon])
    VALUES (@TenSP, @GiaBan, @SoLuong);
    
    PRINT N'✅ THÀNH CÔNG: Đã thêm mỹ phẩm mới vào hệ thống!';
END;
GO


EXEC [dbo].[sp_ThemMoiSanPham] @TenSP = N'Mặt nạ Innisfree', @GiaBan = -50000, @SoLuong = 10;


EXEC [dbo].[sp_ThemMoiSanPham] @TenSP = N'Mặt nạ Innisfree', @GiaBan = 25000, @SoLuong = 100;
```

<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/95ef5020-80e0-4245-83a6-f356af1a5efe" />

_Kiểm tra điều kiện logic. Thử test 1 lệnh giá âm và 1 lệnh giá chuẩn_

### 3.3. SP sử dụng tham số OUTPUT trả về giá trị tính toán
- **Bài toán**: Vào cuối năm, cửa hàng cần tính tổng số tiền một khách hàng VIP đã chi tiêu để tặng quà tri ân.
- **Giải pháp**: Viết thủ tục sp_TinhTongTienKhachHang. Thủ tục này nhận tên khách làm đầu vào, tự động tính toán tổng doanh thu và trả kết quả ra ngoài thông qua biến `@TongTien OUTPUT` để các ứng dụng khác (như C#, Java) có thể bắt lấy.

```
CREATE PROCEDURE [dbo].[sp_TinhTongTienKhachHang]
    @TenKhach NVARCHAR(100),
    @TongTien MONEY OUTPUT 
AS
BEGIN

    SELECT @TongTien = SUM(C.[SoLuongMua] * C.[DonGiaBan])
    FROM [HoaDon] H
    JOIN [ChiTietHoaDon] C ON H.[MaHoaDon] = C.[MaHoaDon]
    WHERE H.[TenKhachHang] = @TenKhach;


    SET @TongTien = ISNULL(@TongTien, 0);
END;
GO


DECLARE @SoTienTichLuy MONEY;

EXEC [dbo].[sp_TinhTongTienKhachHang] 
    @TenKhach = N'Nguyễn Đăng Thịnh', 
    @TongTien = @SoTienTichLuy OUTPUT;


SELECT FORMAT(@SoTienTichLuy, 'N0') + N' VNĐ' AS [TongTienKhachDaChiTieu];
```

<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/58519603-5022-44e7-9145-a47428fff3d4" />

_Tính tổng tiền có tham số OUTPUT_

### 3.4. SP trả về tập kết quả (Result Set) kết hợp JOIN nhiều bảng
- **Bài toán**: Khi khách hàng yêu cầu in biên lai thanh toán chi tiết cho một lần mua hàng, thu ngân cần xem được: Tên khách, ngày mua, mua món gì, số lượng bao nhiêu và thành tiền từng món.
- **Giải pháp**: Dữ liệu này nằm rải rác ở 3 bảng (HoaDon, ChiTietHoaDon, SanPham). SP `sp_InBienLaiChiTiet` sẽ dùng lệnh `JOIN` để gom 3 bảng này lại và trả về một bảng kết quả hoàn chỉnh.

```
CREATE PROCEDURE [dbo].[sp_InBienLaiChiTiet]
    @MaHD INT
AS
BEGIN
    SELECT 
        H.[MaHoaDon],
        H.[TenKhachHang],
        FORMAT(H.[NgayLap], 'dd/MM/yyyy HH:mm') AS [ThoiGianMua],
        S.[TenSanPham],
        C.[SoLuongMua],
        FORMAT(C.[DonGiaBan], 'N0') + N' VNĐ' AS [DonGia],
        FORMAT(C.[SoLuongMua] * C.[DonGiaBan], 'N0') + N' VNĐ' AS [ThanhTien]
    FROM [HoaDon] H
    JOIN [ChiTietHoaDon] C ON H.[MaHoaDon] = C.[MaHoaDon]
    JOIN [SanPham] S ON C.[MaSanPham] = S.[MaSanPham]
    WHERE H.[MaHoaDon] = @MaHD;
END;
GO

EXEC [dbo].[sp_InBienLaiChiTiet] @MaHD = 2;
```
<img width="1918" height="1077" alt="image" src="https://github.com/user-attachments/assets/9922e665-11fc-44c1-9159-82ca5e76f1bf" />

_SP xuất biên lai thanh toán. Thử in biên lai cho Hóa đơn số 2_

## Phần 4: Trigger và Xử lý logic nghiệp vụ
### 4.1. Trigger tự động trừ tồn kho (AFTER INSERT)
- **Ý tưởng:** Ở Phần 3, em đã dùng SP để trừ tồn kho khi bán hàng. Tuy nhiên, rủi ro là nếu nhân viên dùng lệnh `INSERT` chèn trực tiếp dữ liệu vào bảng `[ChiTietHoaDon]` (không thông qua SP), kho sẽ không bị trừ. Trigger này giải quyết triệt để lỗ hổng đó. Bất cứ khi nào có một giao dịch mới được ghi nhận, kho tự động giảm đi.

- **Phân tích thuật toán:**
Bước 1: Gắn Trigger vào sự kiện AFTER INSERT trên bảng `[ChiTietHoaDon]`.

Bước 2: Hệ thống SQL Server tự động sinh ra một bảng ảo tên là Inserted chứa dòng dữ liệu vừa được thêm vào.

Bước 3: Thuật toán `JOIN` bảng ảo `Inserted` với bảng `[SanPham]` để lấy đúng mã mỹ phẩm và số lượng mua, sau đó thực hiện lệnh `UPDATE` giảm `[SoLuongTon]`.

```
CREATE TRIGGER [dbo].[trg_TuDongTruKho]
ON [ChiTietHoaDon]
AFTER INSERT
AS
BEGIN

    UPDATE S
    SET S.[SoLuongTon] = S.[SoLuongTon] - I.[SoLuongMua]
    FROM [SanPham] S
    JOIN Inserted I ON S.[MaSanPham] = I.[MaSanPham];

    PRINT N'⚡ TRIGGER KÍCH HOẠT: Đã tự động trừ số lượng tồn kho!';
END;
GO

INSERT INTO [ChiTietHoaDon] ([MaHoaDon], [MaSanPham], [SoLuongMua], [DonGiaBan])
VALUES (1, 3, 1, 450000);

SELECT * FROM [SanPham] WHERE [MaSanPham] = 3;
```
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/0119a3e1-1237-4793-9009-ec79841126e1" />

_Trigger tự động trừ kho. Khách mua thêm Sản phẩm số 3 (số lượng 1, giá 450k) vào Hóa đơn số 1_

## 4.2. Trigger kiểm toán lịch sử giá bán (AFTER UPDATE
- **Ý tưởng:** Giá mỹ phẩm thay đổi liên tục theo các chương trình Sale. Quản lý cần biết giá cũ là bao nhiêu, đổi thành giá mới là bao nhiêu và đổi khi nào. Em thiết kế một Trigger để tự động "nghe lén" hành động sửa giá và ghi chép lại vào một bảng nhật ký (Audit Log).

- **Phân tích thuật toán:**

Bước 1: Khởi tạo một bảng phụ `[LichSuGia]` để làm sổ nhật ký.

Bước 2: Gắn Trigger vào sự kiện `AFTER UPDATE` trên bảng `[SanPham]`. Sử dụng hàm `UPDATE(GiaBan)` để đảm bảo Trigger chỉ chạy khi cột Giá bị tác động.

Bước 3: Kết hợp bảng ảo `Deleted` (chứa giá cũ trước khi sửa) và bảng ảo `Inserted` (chứa giá mới sau khi sửa) để ghi nhận biến động vào sổ nhật ký.

```
CREATE TABLE [LichSuGia] (
    [MaLog] INT IDENTITY(1,1) PRIMARY KEY,
    [MaSanPham] INT,
    [GiaCu] MONEY,
    [GiaMoi] MONEY,
    [NgayThayDoi] DATETIME DEFAULT GETDATE()
);
GO


CREATE TRIGGER [dbo].[trg_KiemToanGiaBan]
ON [SanPham]
AFTER UPDATE
AS
BEGIN
    
    IF UPDATE([GiaBan])
    BEGIN
        INSERT INTO [LichSuGia] ([MaSanPham], [GiaCu], [GiaMoi])
        SELECT 
            I.[MaSanPham], 
            D.[GiaBan], 
            I.[GiaBan]  
        FROM Inserted I
        JOIN Deleted D ON I.[MaSanPham] = D.[MaSanPham]
        WHERE I.[GiaBan] <> D.[GiaBan]; 

        PRINT N'⚡ TRIGGER KÍCH HOẠT: Đã ghi nhận lịch sử thay đổi giá!';
    END
END;
GO


UPDATE [SanPham] SET [GiaBan] = 600000 WHERE [MaSanPham] = 1;

SELECT * FROM [LichSuGia];
```

<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/57b45972-cb02-47e1-815d-fd9e2e36730d" />

_Trigger kiểm toán. Thử tăng giá Son MAC (Mã 1) từ 550k lên 600k_

## 4.3. Trigger bảo vệ dữ liệu nhạy cảm (INSTEAD OF DELETE)
- **Ý tưởng:** Dữ liệu hóa đơn là chứng từ tài chính cực kỳ quan trọng, tuyệt đối không được phép xóa (kể cả xóa nhầm). Kẻ gian có thể xóa hóa đơn để bỏ túi tiền bán hàng. Em viết một Trigger chặn đứng mọi lệnh DELETE nhắm vào bảng Hóa Đơn.

- **Phân tích thuật toán:**

Bước 1: Sử dụng loại Trigger `INSTEAD OF DELETE` (Thay thế hoàn toàn lệnh xóa).

Bước 2: Khi có ai đó chạy lệnh `DELETE FROM [HoaDon]`, lệnh xóa đó sẽ bị hủy bỏ ngay lập tức. Thay vào đó, SQL Server sẽ thực thi đoạn mã trong Trigger.

Bước 3: Thuật toán sử dụng `ROLLBACK TRANSACTION` để đảo ngược thao tác và in ra cảnh báo an ninh.

```
CREATE TRIGGER [dbo].[trg_ChongXoaHoaDon]
ON [HoaDon]
INSTEAD OF DELETE
AS
BEGIN
 
    ROLLBACK TRANSACTION;
    
   
    RAISERROR (N'🚨 CẢNH BÁO AN NINH: Không được phép xóa dữ liệu Hóa Đơn tài chính!', 16, 1);
END;
GO

DELETE FROM [HoaDon] WHERE [MaHoaDon] = 1;


SELECT * FROM [HoaDon];
```
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/517018c3-fa29-4a98-b911-367e32440806" />

_Khởi tạo Trigger chống xóa hóa đơn. Cố tình xóa Hóa đơn số 1 và sẽ thấy cảnh báo an ninh_

