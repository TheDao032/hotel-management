export const message = {
    W010: ({ param }) => `${param || ''} Can Be Null`, // ${param} khong duoc null
    W033: `情報の修正に失敗しました。`, //Chinh sua thong so that bai
    // Log in
    AU001: `employee_id Or Password Are Not Correct`, // ID hoac mat khau khong dung
    AU002: `Connect Successfully`, // Dang nhap that bai, vui long lien he quan tri vien he thong

    //Setting
    SETT001: `Change Setting Successfully`, //Chinh sua thanh cong
    SETT002: `Change Setting Unsuccessfully`, // Chinh sua that bai
    SETT003: `Update Personal Mail Sending Failed`, //Chỉnh sửa người gởi mail thất bại
    SETT004: `Update Sending Mail Date Failed`, // Chỉnh sửa ngày gởi mail thất bại
    SETT005: `Update Receive Mail Failed`, // Chỉnh sửa mail người nhận thất bại

    //Permission
    PE001: `Add Permission Successfully`, //Them quyen thanh cong
    PE002: `Update Permission Successfully`, //Cap nhap quyen thanh cong
    PE003: `Delete Permission Successfully`, //Xoa quyen thanh cong

    PE004: `Add Permission Failed`, //Them quyen that bai
    PE005: `Update Permission Failed`, //Cap nhap quyen that bai
    PE006: `Delete Permission Failed`, //Xoa quyen that bai
}
