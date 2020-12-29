export const message = {
    W001: 'ステータス保存が成功しました。',
    W002: ({ kensyuu_mei, star }) => `あなたは ${kensyuu_mei || ''}を ${star || ''} ☆評価しました。\nコンメント内容：「{{comment}}」。`, //Ban da danh gia ${star} ☆ cho khoa hoc ${kensyuu_mei}
    W003: ({ kensyuu_mei }) => `${kensyuu_mei || ''} に申込をしました。`, //Đã đăng ký khóa học ${kensyuu_mei}
    W004: ({ shain_name, status }) => `あなたは ${shain_name || ''}さんの ステータスを ${status || ''}に変更しました。`, //Admin: Bạn vừa thay đổi trạng thái ${status} cho ${shain_cd}
    // W005: ({kensyuu_mei, status, boss_name}) => `${kensyuu_mei || ''}は ${status || ''}のステータスが${boss_name || ''}さんに変更されました。`,     //User: ${kensyuu_mei} vừa được ${koushinsha} đổi trạng thái thành ${status}
    W005: ({ kensyuu_mei, status, boss_name }) => `${kensyuu_mei || ''}のステータスは、${boss_name || ''}さんによって${status || ''}に変更されました`,
    W006: ({ shain_name, kensyuu_mei }) => `あなたは${shain_name || ''}さんの代わりに、${kensyuu_mei || ''} を登録しました。`, //Admin: Bạn vừa đăng ký hộ khóa học ${kensyuu_mei} cho ${shain_name}
    W007: ({ boss_name, kensyuu_mei }) => `あなたは${boss_name || ''}さんに${kensyuu_mei || ''}が代替登録されました。`, //User: Bạn vừa được đăng ký hộ khóa học ${kensyuu_mei} bởi ${koushinsha}
    W008: ({ shain_name, kensyuu_mei }) => `あなたは${shain_name || ''}さんの代わりに、${kensyuu_mei || ''} をキャンセルしました。`, //Admin: Bạn vừa cancel hộ khóa học ${kensyuu_mei} cho ${shain_name}
    W009: ({ boss_name, kensyuu_mei }) => `あなたは${boss_name || ''}さんに${kensyuu_mei || ''}がキャンセルされました。`, //User: Bạn vừa được cancel hộ khóa học ${kensyuu_mei} bởi ${koushinsha}
    W010: ({ param }) => `${param || ''}は空白にすることはできません`, // ${param} khong duoc null
    W011: ({ param }) => `${param || ''}が不正フォーマットです`, // ${param} khong dung format
    W012: ({ param }) => `${param || ''}は数値で入力してください。`, //Vui long nhap so vao truong ${param}
    W013: ({ param }) => `${param || ''}は存在しません。`, // ${param} khong ton tai
    W014: `[適用終了日]は[適用開始日]より大きくなければなりません。`, // ${to_date} phai lon hon ${from_date}
    W015: `データがありません。`, // Khong co data
    W016: `この研修は今までの開講が多いので、削除したいですか。`, // Khóa học này đã có nhiều đợt khai giảng trước đó, bạn có chắc muốn xóa không?
    W017: `新権限での開始日は旧権限での終了日より大きくしてください`, // [適用開始日] quyền mới phải lớn hơn [適用終了日] của quyền trước đó
    W018: `少なくとも1つのスキルカテゴリを選択しなければなりません。`, // Bạn phải chọn　ít nhất một スキルカテゴリ
    W019: ({ param }) => `${param || ''}は存在しました。`, // ${param} da ton tai
    W020: `この研修を削除したいですか。`, // Bạn có chắc muốn xóa khoa hoc nay không?
    W021: ({ kensyuu_mei }) => `${kensyuu_mei || ''} をキャンセルしました。`, //Da huy khoa hoc ${kensyuu_mei}
    W022: `登録が成功しました。`,
    W023: `キャンセルが成功しました。`,
    W024: '上司の承認を得てから申込して下さい。', //Vui lòng đăng ký sau khi nhận được sự chấp thuận từ sếp của bạn.
    W025: '変更をしていますが、保存されていません。あなたは続けたいですか。', //Bạn đã thay đổi, nhưng bạn quên lưu. Bạn có muốn tiếp tục không?
    W026: 'あなたは自分のために代理登録できません。', //Bạn không thể đăng kí hộ cho chính mình
    W027: '未回答項目があります', //Có những câu hỏi chưa được trả lời
    W028: ({ file_name }) => `${file_name || ''} ファイルをアップロードしてよろしいですか。`, //Bạn có chắc chắn muốn tải lên tệp {variable} không?
    W029: `該当の社員は存在しません。`, // // Nhan vien khong ton tai
    W030: `このアンケートがありません。人材開発屋へ連絡してください。`, // Anketto khong ton tai, vui long lien he bo phan quan ly
    W031: ({ kensyuu_mei }) => `${kensyuu_mei || ''} を削除しました。`, //Da xoa khoa hoc ${kensyuu_mei}
    W032: `情報修正が成功になりました。`, //Chinh sua thong so thanh cong
    W033: `情報修正が失敗になりました。`, //Chinh sua thong so that bai
    W034: ` 登録が成功になりました。`, //Ban da dang ki thanh cog
    W035: ` 削除が成功になりました。`, //Ban da xoa thanh cong
    W036: ` 削除は成功になりましたが、メール送信は失敗になりました。`, //Ban da xoa thanh cong nhung goi mail that bai
    W037: ` 登録は成功になりましたが、メール送信は失敗になりました。`, //Ban da dang ki thanh cong nhung goi mail that bai
    W038: `登録が失敗になりました。`, //Ban da dang ki khong thanh cong
    W039: `削除が失敗になりました。`, //Xoa khong thanh cong

    //Permission
    PE001: `権限付与が成功しました`, //Them quyen thanh cong
    PE002: `権限変更を成功しました`, //Cap nhap quyen thanh cong
    PE003: `権限削除を成功しました`, //Xoa quyen thanh cong

    PE004: `権限付与が失敗しました`, //Them quyen that bai
    PE005: `権限変更が失敗しました`, //Cap nhap quyen that bai
    PE006: `権限削除が失敗しました`, //Xoa quyen that bai

    //研修詳細-kensyuu Shosai
    SS001: `登録が成功しました`, //Register successful
    SS002: `キャンセルが成功しました`, //Cancel successful
    SS009: `削除が成功しました。`, //Remove successful

    SS003: `登録が失敗しました`, //Register that bai
    SS004: `キャンセルが失敗しました`, //Cancel that bai

    SS005: `この研修を評価してください。`, // Vui long danh gia khoa hoc
    SS006: `この研修をコメントしません。引き続き保存する。`, // Khong binh luan ve khoa hoc va tiep tuc save
    SS007: `評価とコンメントを保存しました。`, // Da luu danh gia va comment thanh cong
    SS008: `この研修もう評価しました。`, // Toi da danh gia khoa hoc nay

    //Kensyuu
    KS001: `研修を追加しました`, //Them khoa hoc thanh cong
    KS002: `研修を更新しました`, //Cap nhap khoa hoc thanh cong
    KS003: `研修を削除しました`, //Xoa khoa hoc thanh cong

    KS004: `研修の追加が失敗しました`, //Them khoa hoc that bai
    KS005: `研修の更新が失敗しました`, //Cap nhap khoa hoc that bai
    KS006: `研修の削除が失敗しました`, //Xoa khoa hoc that bai

    KS007: `該当の研修は存在しません。`, // Khoa hoc khong ton tai
    KS008: `現在、来期の研修は、検討中です。`, // Khoa hoc cho ky toi dang duoc cap nhat

    // File
    FL001: `アップロード処理が成功しました。`, // Upload file thanh cong
    FL002: `アップロード処理が失敗しました。ファイルを確認してください。`, // Upload file that bai, vui long kiem tra file
    FL003: `アップロードファイルを選択してください。`, // Vui long chon file de upload
    FL004: `アンケートファイルをダウンロードします。`, // Download anketto file
    FL005: `このファイルをダウンロードします。`, // Download file nay
    FL006: `今の期と次の期のみアップロードできる。`, // Ban chi co the upload cho ki nay va ki tiep theo
    FL007: (ki) => `第${ki}期の研修カタログをアップロードします。`, // Upload file cho ${ki}

    // Log in
    AU001: `IDまたはパスワードが間違っています。`, // ID hoac mat khau khong dung
    AU002: `ログインが失敗しました。システム担当へ連絡してください。`, // Dang nhap that bai, vui long lien he quan tri vien he thong

    //Setting
    SETT001: `変更が成功しました`, //Chinh sua thanh cong
    SETT002: `変更が失敗しました`, // Chinh sua that bai
    SETT003: `「メール送信元」を修正することが失敗しました`, //Chỉnh sửa người gởi mail thất bại
    SETT004: `「メール送信タイミング」を修正することが失敗しました`, // Chỉnh sửa ngày gởi mail thất bại
    SETT005: `「管理者へのメール送信の宛先設定」を修正することが失敗しました`, // Chỉnh sửa mail người nhận thất bại
}
