-- Table: public.tbl_employee_permission

-- DROP TABLE public.tbl_employee_permission;

CREATE TABLE public.tbl_employee_permission
(
    employee_id character varying(10) COLLATE pg_catalog."default" NOT NULL,
    employee_name text COLLATE pg_catalog."default" NOT NULL,
    employee_status integer,
    mail_address text COLLATE pg_catalog."default" NOT NULL,
    permission integer NOT NULL,
    create_date date,
    update_date date,
	begin_date date,
	expired_date date,
    password character varying(20) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT tbl_employee_permission_pkey PRIMARY KEY (employee_id)
)

TABLESPACE pg_default;

ALTER TABLE public.tbl_employee_permission
    OWNER to postgres;
