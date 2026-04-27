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


## PHẦN 1: THIẾT KẾ VÀ KHỞI TẠO CẤU TRÚC DỮ LIỆU

### 1.1. Khởi tạo Database
Hệ thống sử dụng lệnh `CREATE DATABASE` để tạo vùng lưu trữ. Ngay sau đó dùng lệnh `USE` để xác định phiên làm việc, tránh việc tạo nhầm bảng vào các cơ sở dữ liệu hệ thống.

```sql
CREATE DATABASE [QuanLyMyPham_K235480106043];
GO
USE [QuanLyMyPham_K235480106043];
GO
```
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/0d690d30-f09f-42a3-8454-9b2a4ec1df51" />

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

## PHẦN 2: XÂY DỰNG FUNCTION 

### 2.1. Các loại hàm có sẵn (Built-in Functions)
SQL Server cung cấp hàng trăm hàm có sẵn để xử lý dữ liệu, được chia thành các nhóm chính:
* **Hàm chuỗi (String Functions):** `LEN()`, `SUBSTRING()`, `REPLACE()`, `UPPER()`...
* **Hàm ngày tháng (Date/Time Functions):** `GETDATE()`, `DAY()`, `MONTH()`, `YEAR()`, `DATEDIFF()`...
* **Hàm toán học (Mathematical Functions):** `ROUND()`, `ABS()`, `CEILING()`, `FLOOR()`...
* **Hàm chuyển đổi (Conversion Functions):** `CAST()`, `CONVERT()`, `FORMAT()`...
* **Hàm hệ thống (System/Logical Functions):** `ISNULL()`, `IIF()`, `COALESCE()`...
---

### Sử dụng một số Built - in functions

`FORMAT()` - Định dạng bảng giá :
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

`IIF()` - Rẽ nhánh nhanh gọn kiểm tra tồn kho:
Thay vì phải viết câu lệnh CASE WHEN ... THEN dài dòng, hàm IIF() (If and Only If) cho phép kiểm tra một điều kiện logic và trả về kết quả ngay lập tức. Em dùng hàm này để quét nhanh xem mỹ phẩm nào còn hàng, mỹ phẩm nào đã hết.
```
SELECT 
    [TenSanPham], 
    [SoLuongTon],
    IIF([SoLuongTon] > 0, N'Còn hàng', N'Đã hết hàng') AS [TinhTrangKho]
FROM [SanPham];
```
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/301a3b34-f541-432c-b7ca-dd4607165d6c" />
*Hình: Kiểm tra tình trạng kho của từng loại mỹ phẩm*
