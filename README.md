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
#### a) Bảng `[SanPham]`:
- Sử dụng `[MaSanPham]` làm Khóa chính `(PK)`, thiết lập `IDENTITY(1,1)` để mã tự động tăng, giúp quản lý danh mục dễ dàng.

- Tên sản phẩm dùng `NVARCHAR` để lưu trữ đầy đủ tiếng Việt có dấu.

- Giá bán dùng kiểu `MONEY` để tối ưu tính toán tiền tệ và có ràng buộc `CHECK` giá phải lớn hơn 0.

- Số lượng tồn kho có ràng buộc `CHECK` không được phép nhỏ hơn 0 để đảm bảo tính chính xác của kho hàng.

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

#### b) Bảng `[HoaDon]`:
- Sử dụng `[MaHoaDon]` làm Khóa chính `(PK)` tự động tăng.

- Trường `[NgayLap]` sử dụng kiểu `DATETIME` với giá trị mặc định là `GETDATE()`, giúp hệ thống tự động ghi nhận thời điểm phát sinh giao dịch.

- Trường `[TongTien]` mặc định khởi tạo bằng 0 và sẽ được cập nhật sau khi tính toán các chi tiết hóa đơn.
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

#### c) Bảng `[ChiTietHoaDon]`:
- Đây là bảng trung gian thể hiện quan hệ nhiều - nhiều `( n-n )` giữa `HoaDon` và `SanPham`.

- Sử dụng Khóa chính hỗn hợp (Composite Key) gồm `[MaHoaDon]` và `[MaSanPham]`.

- Chứa 2 Khóa ngoại `(FK)` tham chiếu trực tiếp đến bảng `HoaDon` và `SanPham` để đảm bảo tính toàn vẹn (không thể bán sản phẩm không tồn tại).

- Số lượng mua có ràng buộc `CHECK` phải lớn hơn 0. Đơn giá bán thực tế được lưu lại để quản lý biến động giá tại thời điểm giao dịch.

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

