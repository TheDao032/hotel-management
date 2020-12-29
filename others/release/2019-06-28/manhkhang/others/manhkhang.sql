-- 2019-07-30 --

    CREATE TABLE public.tbl_recommend_template
    (
        id SERIAL,
        column_id text COLLATE pg_catalog."default" NOT NULL,
        column_name text COLLATE pg_catalog."default" NOT NULL,
        is_check boolean NOT NULL,
        CONSTRAINT tbl_recommend_template_pkey PRIMARY KEY (id)
    )
    WITH (
        OIDS = FALSE
    )
    TABLESPACE pg_default;

    ALTER TABLE public.tbl_recommend_template
        OWNER to postgres;

    INSERT INTO public.tbl_recommend_template(
        column_id, column_name, is_check)
        VALUES ( 'kensyuu_category', '研修カテゴリ', false);

    INSERT INTO public.tbl_recommend_template(
        column_id, column_name, is_check)
        VALUES ( 'shukankikan', '主管組織', false);

    INSERT INTO public.tbl_recommend_template(
        column_id, column_name, is_check)
        VALUES ( 'taishosha', '対象者／レベル', false);

    INSERT INTO public.tbl_recommend_template(
        column_id, column_name, is_check)
        VALUES ( 'tema_category', 'テーマカテゴリ', false);

    INSERT INTO public.tbl_recommend_template(
        column_id, column_name, is_check)
        VALUES ( 'skill_list', 'スキルカテゴリ', false);

    INSERT INTO public.tbl_recommend_template(
        column_id, column_name, is_check)
        VALUES ( 'taishosha_level', '対象者', false);

    alter table tbl_setting add column saving_search_time integer default 30;

    alter table tbl_setting add column saving_day_send_mail integer default 14;

    create table tbl_mail_config(
        id SERIAL,
        host text not null,
        port int not null,
        secure boolean not null,
        usermail_auth text not null,
        passmail_auth text not null,
        PRIMARY KEY( id )
    );

    create table tbl_kyouiku_shukankikan(
        id_kyouiku_shukankikan SERIAL,
        name_shukankikan text,
        mail_shukankikan text,
        create_day timestamp with time zone DEFAULT now(),
        PRIMARY KEY(id_kyouiku_shukankikan)
    );

    INSERT INTO tbl_kyouiku_shukankikan(name_shukankikan)
    SELECT DISTINCT shukankikan
    FROM tbl_kensyuu_master ORDER BY shukankikan;

    alter table public.tbl_mail_template add column template_start_regist boolean default false;
    alter table public.tbl_mail_template add column template_end_regist boolean default false;
    alter table public.tbl_mail_template add column template_policy_regist boolean default false;
    alter table public.tbl_mail_template add column template_cancel_day_regist boolean default false;

    insert into public.tbl_mail_template(template_id,template_to_naiyou) values ('early_kyouiku','kyouiku@cubesystem.co.jp');

--
