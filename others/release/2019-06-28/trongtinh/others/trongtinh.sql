-- 2019-30-07

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
07/08/2019

create table tbl_mail_log(
	id serial,
	mail_from text,
	mail_to text,
	mail_html text ,
	mail_query text,
	mail_result json,
	create_time timestamp with time zone DEFAULT now(),
	decode_text text default 'unescape',
	primary key(id)
)
13/08/2019


INSERT INTO public.tbl_mail_template(
	template_id)
	VALUES ('end_nittei');

INSERT INTO public.tbl_mail_template(
	template_id)
	VALUES ('start_nittei');

