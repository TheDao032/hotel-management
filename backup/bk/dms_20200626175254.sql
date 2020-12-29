--
-- PostgreSQL database dump
--

-- Dumped from database version 12.2
-- Dumped by pg_dump version 12.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: tbl_drawings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_drawings (
    drawing_id integer NOT NULL,
    drawing_customer character varying(32),
    drawing_kouban character varying(32),
    drawing_file_name text,
    drawing_relative_path text,
    drawing_created_at timestamp with time zone DEFAULT now(),
    drawing_created_by text,
    drawing_updated_at timestamp with time zone,
    drawing_updated_by text,
    drawing_is_deleted boolean DEFAULT false,
    drawing_part_name text
);


ALTER TABLE public.tbl_drawings OWNER TO postgres;

--
-- Name: tbl_drawings_drawing_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_drawings_drawing_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_drawings_drawing_id_seq OWNER TO postgres;

--
-- Name: tbl_drawings_drawing_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_drawings_drawing_id_seq OWNED BY public.tbl_drawings.drawing_id;


--
-- Name: tbl_drawings_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_drawings_history (
    drawing_history_id integer NOT NULL,
    drawing_id integer NOT NULL,
    drawing_customer character varying(32),
    drawing_kouban character varying(32),
    drawing_file_name text,
    drawing_relative_path text,
    drawing_created_at timestamp with time zone,
    drawing_created_by text,
    drawing_updated_at timestamp with time zone,
    drawing_updated_by text,
    drawing_is_deleted boolean DEFAULT false,
    drawing_part_name text,
    drawing_history_created_at timestamp with time zone DEFAULT now(),
    drawing_history_created_by text NOT NULL
);


ALTER TABLE public.tbl_drawings_history OWNER TO postgres;

--
-- Name: tbl_drawings_history_drawing_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_drawings_history_drawing_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_drawings_history_drawing_history_id_seq OWNER TO postgres;

--
-- Name: tbl_drawings_history_drawing_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_drawings_history_drawing_history_id_seq OWNED BY public.tbl_drawings_history.drawing_history_id;


--
-- Name: tbl_drop_down; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_drop_down (
    drop_down_id integer NOT NULL,
    drop_down_name text,
    folder_id integer,
    drop_down_data jsonb,
    drop_down_created_at timestamp with time zone,
    drop_down_created_by text,
    drop_down_updated_at timestamp with time zone,
    drop_down_updated_by text,
    drop_down_is_deleted boolean DEFAULT false
);


ALTER TABLE public.tbl_drop_down OWNER TO postgres;

--
-- Name: tbl_drop_down_drop_down_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_drop_down_drop_down_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_drop_down_drop_down_id_seq OWNER TO postgres;

--
-- Name: tbl_drop_down_drop_down_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_drop_down_drop_down_id_seq OWNED BY public.tbl_drop_down.drop_down_id;


--
-- Name: tbl_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_files (
    file_id integer NOT NULL,
    file_created_at timestamp with time zone,
    file_created_by text,
    file_updated_at timestamp with time zone,
    file_updated_by text,
    file_is_deleted boolean DEFAULT false,
    folder_id integer,
    file_properties jsonb,
    file_authorized_users text[],
    file_group text,
    file_file_name jsonb,
    file_rule_id text,
    file_department_id integer
);


ALTER TABLE public.tbl_files OWNER TO postgres;

--
-- Name: tbl_files_file_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_files_file_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_files_file_id_seq OWNER TO postgres;

--
-- Name: tbl_files_file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_files_file_id_seq OWNED BY public.tbl_files.file_id;


--
-- Name: tbl_files_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_files_history (
    file_history_id integer NOT NULL,
    file_id integer NOT NULL,
    file_created_at timestamp with time zone,
    file_created_by text,
    file_updated_at timestamp with time zone,
    file_updated_by text,
    file_is_deleted boolean DEFAULT false,
    folder_id integer,
    file_file_name jsonb,
    file_properties jsonb,
    file_authorized_users text[],
    file_group text,
    file_rule_id text,
    file_history_created_at timestamp with time zone,
    file_history_created_by text
);


ALTER TABLE public.tbl_files_history OWNER TO postgres;

--
-- Name: tbl_files_history_file_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_files_history_file_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_files_history_file_history_id_seq OWNER TO postgres;

--
-- Name: tbl_files_history_file_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_files_history_file_history_id_seq OWNED BY public.tbl_files_history.file_history_id;


--
-- Name: tbl_folder_folder_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_folder_folder_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_folder_folder_id_seq OWNER TO postgres;

--
-- Name: tbl_folders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_folders (
    folder_id integer NOT NULL,
    folder_name character varying(32),
    folder_structure jsonb,
    folder_properties jsonb,
    folder_created_at timestamp with time zone,
    folder_created_by text,
    folder_updated_at timestamp with time zone,
    folder_updated_by text,
    folder_is_deleted boolean DEFAULT false,
    folder_authorized_users text[],
    folder_term_year text,
    folder_report text,
    folder_note text,
    folder_group text,
    folder_is_show_updated_count boolean,
    folder_is_show_created_at boolean,
    folder_is_show_updated_at boolean,
    folder_can_open_file_detail boolean,
    folder_document_no text,
    folder_short_name text,
    folder_root_id integer
);


ALTER TABLE public.tbl_folders OWNER TO postgres;

--
-- Name: tbl_folders_folder_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_folders_folder_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_folders_folder_id_seq OWNER TO postgres;

--
-- Name: tbl_folders_folder_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_folders_folder_id_seq OWNED BY public.tbl_folders.folder_id;


--
-- Name: tbl_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_messages (
    message_id integer NOT NULL,
    message_content text NOT NULL,
    created_at timestamp with time zone,
    created_by text,
    message_group text,
    updated_at timestamp with time zone,
    updated_by text,
    message_title text,
    message_attachment_name text
);


ALTER TABLE public.tbl_messages OWNER TO postgres;

--
-- Name: tbl_messages_message_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_messages_message_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_messages_message_id_seq OWNER TO postgres;

--
-- Name: tbl_messages_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_messages_message_id_seq OWNED BY public.tbl_messages.message_id;


--
-- Name: tbl_property_data_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_property_data_type (
    property_data_type_id integer NOT NULL,
    property_data_type_name character varying(32),
    property_data_type_is_number boolean DEFAULT true,
    property_data_type_is_short_text boolean DEFAULT false,
    property_data_type_is_long_text boolean DEFAULT false,
    property_data_type_is_drop_down boolean DEFAULT false,
    property_data_type_created_at timestamp with time zone,
    property_data_type_created_by integer,
    property_data_type_updated_at timestamp with time zone,
    property_data_type_updated_by integer,
    property_data_type_is_deleted boolean DEFAULT false,
    property_data_type_drop_down_id integer
);


ALTER TABLE public.tbl_property_data_type OWNER TO postgres;

--
-- Name: tbl_property_data_type_property_data_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_property_data_type_property_data_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_property_data_type_property_data_type_id_seq OWNER TO postgres;

--
-- Name: tbl_property_data_type_property_data_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_property_data_type_property_data_type_id_seq OWNED BY public.tbl_property_data_type.property_data_type_id;


--
-- Name: tbl_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_settings (
    settings_id integer NOT NULL,
    office_path_value text,
    qc_path_value text,
    theme_color text,
    created_by text,
    created_date timestamp with time zone,
    updated_by text,
    updated_date timestamp with time zone,
    temp_path text,
    logo_title text
);


ALTER TABLE public.tbl_settings OWNER TO postgres;

--
-- Name: tbl_settings_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_settings_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_settings_settings_id_seq OWNER TO postgres;

--
-- Name: tbl_settings_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_settings_settings_id_seq OWNED BY public.tbl_settings.settings_id;


--
-- Name: tbl_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_users (
    user_id text DEFAULT public.uuid_generate_v4() NOT NULL,
    user_username character varying(32) NOT NULL,
    user_email text,
    user_phone character varying(21),
    user_is_deleted boolean DEFAULT false,
    user_permission_code character(2),
    user_password text,
    user_group text,
    user_salt text,
    user_iteration integer,
    user_theme text,
    user_fullname character varying(32),
    user_created_at timestamp with time zone DEFAULT now(),
    user_updated_at timestamp with time zone,
    user_authen_updated_at timestamp with time zone
);


ALTER TABLE public.tbl_users OWNER TO postgres;

--
-- Name: tbl_drawings drawing_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_drawings ALTER COLUMN drawing_id SET DEFAULT nextval('public.tbl_drawings_drawing_id_seq'::regclass);


--
-- Name: tbl_drawings_history drawing_history_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_drawings_history ALTER COLUMN drawing_history_id SET DEFAULT nextval('public.tbl_drawings_history_drawing_history_id_seq'::regclass);


--
-- Name: tbl_drop_down drop_down_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_drop_down ALTER COLUMN drop_down_id SET DEFAULT nextval('public.tbl_drop_down_drop_down_id_seq'::regclass);


--
-- Name: tbl_files file_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_files ALTER COLUMN file_id SET DEFAULT nextval('public.tbl_files_file_id_seq'::regclass);


--
-- Name: tbl_files_history file_history_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_files_history ALTER COLUMN file_history_id SET DEFAULT nextval('public.tbl_files_history_file_history_id_seq'::regclass);


--
-- Name: tbl_folders folder_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_folders ALTER COLUMN folder_id SET DEFAULT nextval('public.tbl_folders_folder_id_seq'::regclass);


--
-- Name: tbl_messages message_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_messages ALTER COLUMN message_id SET DEFAULT nextval('public.tbl_messages_message_id_seq'::regclass);


--
-- Name: tbl_property_data_type property_data_type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_property_data_type ALTER COLUMN property_data_type_id SET DEFAULT nextval('public.tbl_property_data_type_property_data_type_id_seq'::regclass);


--
-- Name: tbl_settings settings_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_settings ALTER COLUMN settings_id SET DEFAULT nextval('public.tbl_settings_settings_id_seq'::regclass);


--
-- Data for Name: tbl_drawings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_drawings (drawing_id, drawing_customer, drawing_kouban, drawing_file_name, drawing_relative_path, drawing_created_at, drawing_created_by, drawing_updated_at, drawing_updated_by, drawing_is_deleted, drawing_part_name) FROM stdin;
82	NKE	22P29-NKE-102-#02	NKE29-0724-A	NKE	2020-06-26 17:13:08.161849+09	cc47abb1-a324-4948-82bf-aa9a28a2935c	\N	\N	f	Vending5
84	NKE	22P23-NKE-102-#02	NKE23-0724-A	NKE	2020-06-26 17:13:08.181608+09	cc47abb1-a324-4948-82bf-aa9a28a2935c	\N	\N	f	Vending3
85	SEJ	22P29-SEJ-102-#02	SEJ29-0724-A	SEJ	2020-06-26 17:13:08.187056+09	cc47abb1-a324-4948-82bf-aa9a28a2935c	\N	\N	f	Vending3
86	NKE	22P20-NKE-102-#02	NKE20-07-A	NKE	2020-06-26 17:13:08.189736+09	cc47abb1-a324-4948-82bf-aa9a28a2935c	\N	\N	f	Vending2
87	NKE	22P19-NKE-102-#02	NKE19-0724-A	NKE	2020-06-26 17:13:08.243183+09	cc47abb1-a324-4948-82bf-aa9a28a2935c	\N	\N	f	Vending1
88	DERS	22P29-DERS-102-#02	DERS29-0724-A	DERS	2020-06-26 17:13:08.265885+09	cc47abb1-a324-4948-82bf-aa9a28a2935c	\N	\N	f	Vending9-SRV
83	NKE	22P25-NKE-102-#02	NKE25-0724-A	NKE	2020-06-26 17:13:08.162285+09	cc47abb1-a324-4948-82bf-aa9a28a2935c	\N	\N	f	Vending4
\.


--
-- Data for Name: tbl_drawings_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_drawings_history (drawing_history_id, drawing_id, drawing_customer, drawing_kouban, drawing_file_name, drawing_relative_path, drawing_created_at, drawing_created_by, drawing_updated_at, drawing_updated_by, drawing_is_deleted, drawing_part_name, drawing_history_created_at, drawing_history_created_by) FROM stdin;
\.


--
-- Data for Name: tbl_drop_down; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_drop_down (drop_down_id, drop_down_name, folder_id, drop_down_data, drop_down_created_at, drop_down_created_by, drop_down_updated_at, drop_down_updated_by, drop_down_is_deleted) FROM stdin;
6	bumon	19	[{"id": "1", "name": "経理"}, {"id": "2", "name": "人事"}, {"id": "3", "name": "エンジニア"}]	2020-06-22 18:30:00.420739+09	cc47abb1-a324-4948-82bf-aa9a28a2935c	2020-06-24 15:18:47.279733+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	f
7	部署名	29	[{"id": "1", "name": "経理"}, {"id": "2", "name": "人事"}, {"id": "3", "name": "エンジニア"}]	2020-06-23 17:35:22.547785+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	2020-06-24 15:18:53.582639+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	t
10	Maker	\N	[{"id": "1", "name": "Electronic"}, {"id": "2", "name": "Toshiba"}]	2020-06-24 15:29:17.374714+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	\N	\N	f
\.


--
-- Data for Name: tbl_files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_files (file_id, file_created_at, file_created_by, file_updated_at, file_updated_by, file_is_deleted, folder_id, file_properties, file_authorized_users, file_group, file_file_name, file_rule_id, file_department_id) FROM stdin;
\.


--
-- Data for Name: tbl_files_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_files_history (file_history_id, file_id, file_created_at, file_created_by, file_updated_at, file_updated_by, file_is_deleted, folder_id, file_file_name, file_properties, file_authorized_users, file_group, file_rule_id, file_history_created_at, file_history_created_by) FROM stdin;
\.


--
-- Data for Name: tbl_folders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_folders (folder_id, folder_name, folder_structure, folder_properties, folder_created_at, folder_created_by, folder_updated_at, folder_updated_by, folder_is_deleted, folder_authorized_users, folder_term_year, folder_report, folder_note, folder_group, folder_is_show_updated_count, folder_is_show_created_at, folder_is_show_updated_at, folder_can_open_file_detail, folder_document_no, folder_short_name, folder_root_id) FROM stdin;
11	QA	\N	\N	2020-06-16 12:01:36.883998+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	2020-06-24 19:53:24.702654+09	cc47abb1-a324-4948-82bf-aa9a28a2935c	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
12	エンジニア	\N	\N	2020-06-16 12:02:09.208985+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	2020-06-23 17:05:28.600969+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
15	経理	\N	\N	2020-06-16 12:04:23.458684+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	2020-06-23 17:05:16.947174+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
14	共通事務	\N	\N	2020-06-16 12:03:15.011918+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	2020-06-19 16:25:31.291697+09	cc47abb1-a324-4948-82bf-aa9a28a2935c	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
16	人事	\N	\N	2020-06-16 12:04:36.806365+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	2020-06-23 17:05:04.809169+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
38	共通社外報告書	\N	[{"id": 1, "max_width": "80", "property_name": "業連タイトル", "property_data_type": "textarea", "property_is_show_in_list": true, "property_is_show_in_detail": true}]	2020-06-23 17:47:21.893591+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	\N	2020-06-24 15:38:12.747933+09	f	{}	\N	\N	\N	\N	t	t	t	\N	Common internal report ID	Common internal report	14
30	作業手順書台帳	\N	[{"id": 1, "max_width": 40, "property_name": "Notice", "property_data_type": "textarea", "property_is_show_in_list": true, "property_is_show_in_detail": true}]	2020-06-23 17:32:48.570416+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	\N	\N	f	{}	\N	\N	\N	\N	t	t	t	\N	WorkFlow ID	WorkFlow	11
31	見積書台帳	\N	[{"id": 1, "max_width": 40, "property_name": "Notice", "property_data_type": "textarea", "property_is_show_in_list": true, "property_is_show_in_detail": true}]	2020-06-23 17:38:55.029954+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	\N	\N	f	{}	\N	\N	\N	\N	t	t	t	\N	Quotation ID	Quotation	12
32	経理月報	\N	[{"id": 1, "max_width": 40, "property_name": "Notice", "property_data_type": "textarea", "property_is_show_in_list": true, "property_is_show_in_detail": true}]	2020-06-23 17:42:14.93788+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	\N	\N	f	{}	\N	\N	\N	\N	t	t	t	\N	Accounting ID	Accounting	15
33	人事月報	\N	[{"id": 1, "max_width": 40, "property_name": "Notice", "property_data_type": "textarea", "property_is_show_in_list": true, "property_is_show_in_detail": true}]	2020-06-23 17:43:07.077994+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	\N	\N	f	{}	\N	\N	\N	\N	t	t	t	\N	Human Report ID	Human-Report	16
34	事務用品手配台帳	\N	[{"id": 1, "max_width": 40, "property_name": "Notice", "property_data_type": "textarea", "property_is_show_in_list": true, "property_is_show_in_detail": true}]	2020-06-23 17:44:02.995181+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	\N	\N	f	{}	\N	\N	\N	\N	t	t	t	\N	Office Supply ID	Office Supply	16
29	QA月報	\N	[{"id": 1, "max_width": 40, "property_name": "Notice", "property_data_type": "textarea", "property_is_show_in_list": true, "property_is_show_in_detail": true}]	2020-06-23 17:31:40.54825+09	cc47abb1-a324-4948-82bf-aa9a28a2935c	\N	2020-06-24 15:28:38.595084+09	f	{}	\N	\N	\N	\N	t	t	t	\N	QA Report ID	QA-Month	11
36	固定資産台帳	\N	[{"id": 1, "max_width": "40", "property_name": "設備名称", "property_data_type": "text", "property_is_show_in_list": true, "property_is_show_in_detail": true}, {"id": 2, "max_width": "20", "property_name": "設備メーカー", "property_data_type": "dropdown_10", "property_is_show_in_list": true, "property_is_show_in_detail": true}, {"id": 3, "max_width": "20", "property_name": "償却年数", "property_data_type": "text", "property_is_show_in_list": true, "property_is_show_in_detail": true}, {"id": 4, "max_width": "20", "property_name": "取得金額", "property_data_type": "text", "property_is_show_in_list": true, "property_is_show_in_detail": true}, {"id": 5, "max_width": "20", "property_name": "使用中 or  廃却済", "property_data_type": "text", "property_is_show_in_list": true, "property_is_show_in_detail": true}]	2020-06-23 17:45:55.268599+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	\N	2020-06-24 15:34:15.46093+09	f	{}	\N	\N	\N	\N	t	t	t	\N	Fixed asset ID	Fixed asset	14
35	規程・要則	\N	[{"id": 1, "max_width": 40, "property_name": "規程要則 名称", "property_data_type": "textarea", "property_is_show_in_list": true, "property_is_show_in_detail": true}]	2020-06-23 17:44:59.988817+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	\N	2020-06-24 15:35:02.451987+09	f	{}	\N	\N	\N	\N	t	t	t	\N	Reg-Rul ID	Reg-Rul	14
37	共通社内報告書	\N	[{"id": 1, "max_width": 40, "property_name": "報告書 タイトル", "property_data_type": "text", "property_is_show_in_list": true, "property_is_show_in_detail": true}, {"id": 2, "max_width": "20", "property_name": "提出先", "property_data_type": "text", "property_is_show_in_list": true, "property_is_show_in_detail": true}, {"id": 3, "max_width": "80", "property_name": "報告概要", "property_data_type": "textarea", "property_is_show_in_list": true, "property_is_show_in_detail": true}, {"id": 4, "max_width": "20", "property_name": "報告書 作成者", "property_data_type": "text", "property_is_show_in_list": true, "property_is_show_in_detail": true}]	2020-06-23 17:46:36.501475+09	5e8260ce-4761-4c1c-bea2-c09689f5b60c	\N	2020-06-24 15:38:19.270959+09	f	{}	\N	\N	\N	\N	t	t	t	\N	Common external report ID	Common external report	14
\.


--
-- Data for Name: tbl_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_messages (message_id, message_content, created_at, created_by, message_group, updated_at, updated_by, message_title, message_attachment_name) FROM stdin;
\.


--
-- Data for Name: tbl_property_data_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_property_data_type (property_data_type_id, property_data_type_name, property_data_type_is_number, property_data_type_is_short_text, property_data_type_is_long_text, property_data_type_is_drop_down, property_data_type_created_at, property_data_type_created_by, property_data_type_updated_at, property_data_type_updated_by, property_data_type_is_deleted, property_data_type_drop_down_id) FROM stdin;
\.


--
-- Data for Name: tbl_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_settings (settings_id, office_path_value, qc_path_value, theme_color, created_by, created_date, updated_by, updated_date, temp_path, logo_title) FROM stdin;
2	C:\\Program Files\\DmsWebsite\\rootFolder\\office	C:\\Program Files\\DmsWebsite\\rootFolder\\qc	default	\N	\N	cc47abb1-a324-4948-82bf-aa9a28a2935c	2020-06-22 21:12:40.517854+09	C:\\Program Files\\DmsWebsite\\rootFolder\\office/QA月報	D-CUBE
\.


--
-- Data for Name: tbl_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_users (user_id, user_username, user_email, user_phone, user_is_deleted, user_permission_code, user_password, user_group, user_salt, user_iteration, user_theme, user_fullname, user_created_at, user_updated_at, user_authen_updated_at) FROM stdin;
aa69166d-f10c-4383-8e65-f92dffa9d295	qcuser	qcuser@emailaddress.com	0123456789	f	11	1590746171921$10$8496b22e8079f2632294befa7cbd26b8	qc	1590746171921	10	default	QC User	2020-05-29 18:55:32.890529+09	\N	2020-05-29 18:56:11.944753+09
f9e3c243-0c81-4a5a-91c3-166e4b2989a9	officeadmin	officeadmin@emailaddress.com	0123456789	f	09	1590746032746$10$d21f277121d853dacdfa175be6f661ce	office	1590746032746	10	default	Office Admin	2020-05-29 18:53:52.770159+09	\N	2020-05-29 18:53:52.770159+09
f14b8265-13bf-4e07-8b89-585d925ebb2c	officeuser	officeuser@emailaddress.com	0123456789	t	01	1590746064116$10$aab4599197fb80df2279946a28f1a0f0	office	1590746064116	10	default	Office User	2020-05-29 18:54:24.14051+09	\N	2020-05-29 18:54:24.14051+09
bfc18e2b-231b-4b57-aacc-52b2f12975a6	qcadmin	qcadmi2n@emailaddress.com	011635464545	f	19	1590746101484$10$5e1f5c6e91c54687d54eb6be3b503050	qc	1590746101484	10	default	QC Admin	2020-05-29 18:55:01.508138+09	\N	2020-05-29 18:55:01.508138+09
cc47abb1-a324-4948-82bf-aa9a28a2935c	superuser	superus2er@emailadress.com	0148612182	f	99	1592479309017$10$dd460ea759ffb9c2b1204ea25dd41c35	admin	1591612985616	10	dark	Super User	2020-06-08 19:43:05.641043+09	\N	2020-06-18 20:21:49.229133+09
5e8260ce-4761-4c1c-bea2-c09689f5b60c	admin	testadmin@gmail.com	12345678	f	99	1590746200922$10$2560914b60d7301d71e45fdd995b5bb6	admin	1590749367925	10	default	Admin	2020-05-29 18:40:34.408978+09	\N	2020-05-29 18:56:40.944319+09
\.


--
-- Name: tbl_drawings_drawing_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_drawings_drawing_id_seq', 88, true);


--
-- Name: tbl_drawings_history_drawing_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_drawings_history_drawing_history_id_seq', 254, true);


--
-- Name: tbl_drop_down_drop_down_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_drop_down_drop_down_id_seq', 12, true);


--
-- Name: tbl_files_file_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_files_file_id_seq', 47, true);


--
-- Name: tbl_files_history_file_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_files_history_file_history_id_seq', 32, true);


--
-- Name: tbl_folder_folder_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_folder_folder_id_seq', 1, false);


--
-- Name: tbl_folders_folder_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_folders_folder_id_seq', 49, true);


--
-- Name: tbl_messages_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_messages_message_id_seq', 39, true);


--
-- Name: tbl_property_data_type_property_data_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_property_data_type_property_data_type_id_seq', 1, false);


--
-- Name: tbl_settings_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_settings_settings_id_seq', 2, true);


--
-- Name: tbl_drawings_history tbl_drawings_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_drawings_history
    ADD CONSTRAINT tbl_drawings_history_pkey PRIMARY KEY (drawing_history_id);


--
-- Name: tbl_drawings tbl_drawings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_drawings
    ADD CONSTRAINT tbl_drawings_pkey PRIMARY KEY (drawing_id);


--
-- Name: tbl_drop_down tbl_drop_down_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_drop_down
    ADD CONSTRAINT tbl_drop_down_pkey PRIMARY KEY (drop_down_id);


--
-- Name: tbl_files_history tbl_files_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_files_history
    ADD CONSTRAINT tbl_files_history_pkey PRIMARY KEY (file_history_id);


--
-- Name: tbl_files tbl_files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_files
    ADD CONSTRAINT tbl_files_pkey PRIMARY KEY (file_id);


--
-- Name: tbl_folders tbl_folders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_folders
    ADD CONSTRAINT tbl_folders_pkey PRIMARY KEY (folder_id);


--
-- Name: tbl_messages tbl_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_messages
    ADD CONSTRAINT tbl_messages_pkey PRIMARY KEY (message_id);


--
-- Name: tbl_property_data_type tbl_property_data_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_property_data_type
    ADD CONSTRAINT tbl_property_data_type_pkey PRIMARY KEY (property_data_type_id);


--
-- Name: tbl_settings tbl_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_settings
    ADD CONSTRAINT tbl_settings_pkey PRIMARY KEY (settings_id);


--
-- Name: tbl_users tbl_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_users
    ADD CONSTRAINT tbl_users_pkey PRIMARY KEY (user_id);


--
-- Name: tbl_files unique_file_rule_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_files
    ADD CONSTRAINT unique_file_rule_id UNIQUE (file_rule_id);


--
-- Name: tbl_folders unique_folder_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_folders
    ADD CONSTRAINT unique_folder_name UNIQUE (folder_name);


--
-- Name: tbl_users unique_user_email; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_users
    ADD CONSTRAINT unique_user_email UNIQUE (user_email);


--
-- Name: tbl_users unique_user_username; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_users
    ADD CONSTRAINT unique_user_username UNIQUE (user_username);


--
-- Name: tbl_drawings_drawing_file_name_unique_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX tbl_drawings_drawing_file_name_unique_idx ON public.tbl_drawings USING btree (drawing_file_name) WHERE (drawing_is_deleted = false);


--
-- PostgreSQL database dump complete
--

