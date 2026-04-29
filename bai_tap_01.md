# BÁO CÁO CHI TIẾT CÁC BƯỚC THỰC HIỆN SQL SERVER

## Thông tin sinh viên
* **Họ và tên:** Nguyễn Thị Ngọc Linh
* **MSSV:** K235480106043
* **Lớp:** K59.KMT.K01

---

### 1. Download và cài đặt SQL Server 2025
Đã tải và cài đặt phiên bản **Developer** từ trang chủ Microsoft.
<img width="1919" height="1079" alt="Ảnh chụp màn hình 2026-04-10 153837" src="https://github.com/user-attachments/assets/004f65e0-44b6-4e22-811f-b946ea9f3103" />


### 2. Cấu hình SQL
Cấu hình SQL server làm việc ở cổng động (Dynamic Port), TCP Dynamic Ports: 36043 (MSSV: K235480106043)
<img width="1919" height="1079" alt="Ảnh chụp màn hình 2026-04-10 154650" src="https://github.com/user-attachments/assets/086096d6-2194-4363-a7b0-5cfa42fc99b8" />


<img width="1919" height="1079" alt="Ảnh chụp màn hình 2026-04-10 154229" src="https://github.com/user-attachments/assets/83c31c17-67bc-4072-a3f9-1aba156aea30" />

### 3. Kiểm tra trạng thái cổng (LISTENING)
Sử dụng lệnh `netstat -ano | findstr LISTENING`. Kết quả xác nhận cổng 36043 đang mở..

<img width="1919" height="1079" alt="Ảnh chụp màn hình 2026-04-10 155142" src="https://github.com/user-attachments/assets/a76b301b-8868-4d4f-8159-55283d3f8551" />


### 4. Cài đặt SQL Server Management Studio (SSMS)

<img width="1919" height="1079" alt="Ảnh chụp màn hình 2026-04-10 155349" src="https://github.com/user-attachments/assets/804c6d1e-2b97-4f17-875c-797690d4bc15" />


### 5. Sử dụng SSMS để đăng nhập vào SQL Server bằng 2 cách:

**Cách 1: Windows Authentication**
<img width="1919" height="1079" alt="Ảnh chụp màn hình 2026-04-10 155643" src="https://github.com/user-attachments/assets/1ec89424-eb8d-4d3e-b23e-695675b51683" />

**Cách 2: SQL Server Authentication**
<img width="1894" height="1062" alt="Ảnh chụp màn hình 2026-04-10 155705" src="https://github.com/user-attachments/assets/a1f85675-9361-432f-b642-0ba5a51587c7" />


### 6. Tạo Cơ sở dữ liệu (Database)
Tạo DB `QuanLySinhVien`, lưu file `.mdf` và `.ldf` tại ổ **D:** (khác ổ C hệ thống).
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/d329593e-f239-438c-869e-85cf40a0ad48" />


### 7. Thiết kế bảng dữ liệu (Design Table)
Tạo bảng `svtnut` với các trường dữ liệu tương ứng file mẫu, thiết lập **Primary Key** cho trường `masv`.
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/82411b5e-3cb8-410a-a353-0e0e07794351" />


### 8. Import dữ liệu từ file CSV
Sử dụng công cụ Import của SSMS để đưa dữ liệu từ file mẫu vào bảng `svtnut`.
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/7af16060-5a6d-4036-9844-dea189f92ab8" />

### 9. Kiểm tra số lượng dòng dữ liệu
Dùng lệnh `SELECT COUNT(*) AS Sodong FROM svtnut;` để xác nhận tổng số dòng là **12,020**.
<img width="1916" height="1077" alt="image" src="https://github.com/user-attachments/assets/7a98e811-7e65-4090-b562-dd33f5f6594b" />


### 10. Thêm dữ liệu cá nhân (Insert)
Thực hiện lệnh chèn 1 dòng mới với thông tin cá nhân của bản thân vào bảng.
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/a83f014b-e528-4b81-b190-0a2be1e54d25" />


### 11. Cập nhật thông tin sinh viên (Update)
Cập nhật `noisinh = 'Sao Hoả'` cho các dòng có dữ liệu `noisinh` và `diachi` là NULL.
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/10f9e684-6292-489f-8df8-675cd1122e6d" />


### 12. Tạo bảng SaoHoa (Select Into)
Tạo bảng mới tên `SaoHoa` chứa danh sách các sinh viên có nơi sinh ở 'Sao Hoả'.
<img width="1912" height="1078" alt="image" src="https://github.com/user-attachments/assets/510ea402-a786-4e42-b57e-32731334b41c" />


### 13. Xóa dữ liệu theo họ sinh viên (Delete)
Thực hiện lệnh xóa các sinh viên có họ **Nguyễn** trong bảng `SaoHoa`.
<img width="1919" height="1079" alt="Ảnh chụp màn hình 2026-04-10 135405" src="https://github.com/user-attachments/assets/8aaf8fb0-96c8-4cb9-acd7-b4501fe359d5" />


### 14. Xuất Script tổng hợp (Generate Scripts)
Sử dụng tính năng Gen Script (Data + Schema) để xuất toàn bộ cấu trúc và dữ liệu ra file `dulieu.sql`.

<img width="1919" height="1079" alt="Ảnh chụp màn hình 2026-04-10 145115" src="https://github.com/user-attachments/assets/d312eed5-e19d-4820-811b-540a4ae19507" />

<img width="1919" height="1079" alt="Ảnh chụp màn hình 2026-04-10 145226" src="https://github.com/user-attachments/assets/ec810de6-6462-4a9a-a86a-4210ce48ba04" />

### 15. Xóa CSDL để kiểm chứng
Đã xóa database trong SSMS và xác nhận 2 file vật lý trong ổ D đã biến mất hoàn toàn.
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/2b113cbb-2046-43e3-8ed6-3dada7dfbe57" />

Kiểm tra ổ D:
<img width="1917" height="1078" alt="image" src="https://github.com/user-attachments/assets/919ff166-4ee9-49f9-86e9-c7a55bbb0475" />


### 16. Phục hồi và Kiểm chứng kết quả
Mở file `dulieu.sql`, chạy lệnh để phục hồi lại Database. 
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/1cd87f5b-59c9-4889-a758-2cddb04a2188" />

Kết quả kiểm tra:
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/691191c4-f82a-4dbc-a336-734aa0dfe0b9" />


### 17. Upload và Hoàn thiện báo cáo
Upload file `dulieu.sql` và hình ảnh minh chứng lên GitHub Repository cá nhân.
<img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/da23311c-cfcc-47f2-964c-757871121646" />




