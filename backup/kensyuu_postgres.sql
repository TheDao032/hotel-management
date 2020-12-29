--
-- PostgreSQL database dump
--

-- Dumped from database version 11.3
-- Dumped by pg_dump version 11.3

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
-- Name: chousa_go(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.chousa_go() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
	k_id text;
	k_mei text;
	s_cd text;
BEGIN
	UPDATE tbl_moushikomi SET status = 6 WHERE moushikomi_id = NEW.moushikomi_id
	RETURNING shain_cd, kensyuu_id INTO s_cd, k_id;

	SELECT kensyuu_mei INTO k_mei FROM tbl_kensyuu_master WHERE kensyuu_id = k_id;

	INSERT INTO tbl_tsuuchi (shain_cd, moushikomi_id, tsuuchi_naiyou)
	VALUES  (s_cd, NEW.moushikomi_id, 'あなたは'|| k_mei || 'のアンケートを完成しました。');
	
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.chousa_go() OWNER TO postgres;

--
-- Name: fill_koushinbi(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fill_koushinbi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.koushinbi = now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fill_koushinbi() OWNER TO postgres;

--
-- Name: get_kensyuu_mei(integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_kensyuu_mei(i_ki integer, i_kensyuu_id text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE 
    result text;

BEGIN
	SELECT kensyuu_mei INTO result
	FROM tbl_kensyuu_master
	WHERE ki = i_ki AND kensyuu_id = i_kensyuu_id;
	RETURN result;
END;	
$$;


ALTER FUNCTION public.get_kensyuu_mei(i_ki integer, i_kensyuu_id text) OWNER TO postgres;

--
-- Name: kensyuu2ki(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kensyuu2ki(i_ki text) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN '0' || substring(i_ki from '^..');
END;	
$$;


ALTER FUNCTION public.kensyuu2ki(i_ki text) OWNER TO postgres;

--
-- Name: nittei2ki(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.nittei2ki(i_ki integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN (SELECT kensyuu2ki(kensyuu_id) AS ki FROM tbl_kensyuu_nittei_master WHERE nittei_id = i_ki);
END;	
$$;


ALTER FUNCTION public.nittei2ki(i_ki integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: tbl_anketto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_anketto (
    anketto_id character varying(3) NOT NULL,
    anketto_naiyou json,
    created_at time with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tbl_anketto OWNER TO postgres;

--
-- Name: tbl_checkin; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_checkin (
    check_in_id integer NOT NULL,
    shain_cd character varying(10),
    checker_cd character varying(10),
    kensyuu_id character varying(5),
    kensyuu_sub_id character varying(3),
    kensyuu_mei text,
    check_in_time timestamp without time zone DEFAULT now()
);


ALTER TABLE public.tbl_checkin OWNER TO postgres;

--
-- Name: tbl_checkin_check_in_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_checkin_check_in_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_checkin_check_in_id_seq OWNER TO postgres;

--
-- Name: tbl_checkin_check_in_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_checkin_check_in_id_seq OWNED BY public.tbl_checkin.check_in_id;


--
-- Name: tbl_event; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_event (
    event_id integer NOT NULL,
    event_title text,
    start_ts timestamp with time zone,
    end_ts timestamp with time zone,
    all_day boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone,
    check_in timestamp with time zone,
    check_out timestamp with time zone,
    event_note text,
    is_deleted boolean DEFAULT false,
    is_auto boolean DEFAULT false,
    user_id text
);


ALTER TABLE public.tbl_event OWNER TO postgres;

--
-- Name: tbl_event_event_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_event_event_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_event_event_id_seq OWNER TO postgres;

--
-- Name: tbl_event_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_event_event_id_seq OWNED BY public.tbl_event.event_id;


--
-- Name: tbl_hyouka; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_hyouka (
    hyouka_id integer NOT NULL,
    moushikomi_id integer,
    rating smallint DEFAULT 0,
    comment text,
    anketto_koutae json,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.tbl_hyouka OWNER TO postgres;

--
-- Name: tbl_hyouka_hyouka_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_hyouka_hyouka_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_hyouka_hyouka_id_seq OWNER TO postgres;

--
-- Name: tbl_hyouka_hyouka_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_hyouka_hyouka_id_seq OWNED BY public.tbl_hyouka.hyouka_id;


--
-- Name: tbl_kensyuu_master; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_kensyuu_master (
    kensyuu_id character varying(5) NOT NULL,
    kensyuu_mei text,
    kensyuu_category text,
    skill_mg_flag bit(1),
    skill_hm_flag bit(1),
    skill_tc_flag bit(1),
    skill_oa_flag bit(1),
    kensyuu_gaiyou text,
    taishosha_level text,
    jyukouryou text,
    shukankikan text,
    bikou text,
    anketto_id text,
    tema_category text,
    taishosha text,
    flag smallint DEFAULT 0,
    tags integer[],
    sub_level text,
    advance_level text,
    tags_father integer[]
);


ALTER TABLE public.tbl_kensyuu_master OWNER TO postgres;

--
-- Name: tbl_kensyuu_nittei_master; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_kensyuu_nittei_master (
    nittei_id integer NOT NULL,
    kensyuu_id character varying(5) NOT NULL,
    kensyuu_sub_id character varying(3) NOT NULL,
    basho text,
    toukyou_oosaka_flag integer,
    nittei_from date,
    nittei_to date,
    moushikomikigen date,
    cancel_date date,
    jikan integer,
    bun integer,
    kansan_jikan integer,
    cancelpolicy text,
    jukou_jouhou text,
    nissuu text,
    ninzuu integer DEFAULT 0,
    jyukouryou text
);


ALTER TABLE public.tbl_kensyuu_nittei_master OWNER TO postgres;

--
-- Name: tbl_kensyuu_nittei_master_nittei_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_kensyuu_nittei_master_nittei_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_kensyuu_nittei_master_nittei_id_seq OWNER TO postgres;

--
-- Name: tbl_kensyuu_nittei_master_nittei_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_kensyuu_nittei_master_nittei_id_seq OWNED BY public.tbl_kensyuu_nittei_master.nittei_id;


--
-- Name: tbl_kyouiku_shukankikan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_kyouiku_shukankikan (
    id_kyouiku_shukankikan integer NOT NULL,
    name_shukankikan text,
    mail_shukankikan text,
    create_day timestamp with time zone DEFAULT now(),
    default_mail text
);


ALTER TABLE public.tbl_kyouiku_shukankikan OWNER TO postgres;

--
-- Name: tbl_kyouiku_shukankikan_id_kyouiku_shukankikan_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_kyouiku_shukankikan_id_kyouiku_shukankikan_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_kyouiku_shukankikan_id_kyouiku_shukankikan_seq OWNER TO postgres;

--
-- Name: tbl_kyouiku_shukankikan_id_kyouiku_shukankikan_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_kyouiku_shukankikan_id_kyouiku_shukankikan_seq OWNED BY public.tbl_kyouiku_shukankikan.id_kyouiku_shukankikan;


--
-- Name: tbl_mail_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_mail_config (
    id integer NOT NULL,
    host text NOT NULL,
    port integer NOT NULL,
    secure boolean NOT NULL,
    usermail_auth text NOT NULL,
    passmail_auth text NOT NULL
);


ALTER TABLE public.tbl_mail_config OWNER TO postgres;

--
-- Name: tbl_mail_config_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_mail_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_mail_config_id_seq OWNER TO postgres;

--
-- Name: tbl_mail_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_mail_config_id_seq OWNED BY public.tbl_mail_config.id;


--
-- Name: tbl_mail_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_mail_log (
    id integer NOT NULL,
    mail_from text,
    mail_to text,
    mail_html text,
    mail_query text,
    mail_result json,
    create_time timestamp with time zone DEFAULT now(),
    decode_text text DEFAULT 'unescape'::text
);


ALTER TABLE public.tbl_mail_log OWNER TO postgres;

--
-- Name: tbl_mail_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_mail_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_mail_log_id_seq OWNER TO postgres;

--
-- Name: tbl_mail_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_mail_log_id_seq OWNED BY public.tbl_mail_log.id;


--
-- Name: tbl_mail_template; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_mail_template (
    template_id text,
    template_from boolean DEFAULT true,
    template_from_naiyou character varying,
    template_to boolean DEFAULT true,
    template_to_naiyou character varying,
    template_cc boolean DEFAULT true,
    template_cc_naiyou character varying,
    template_subject boolean DEFAULT true,
    template_subject_naiyou character varying,
    template_auto_string boolean DEFAULT true,
    template_moushikomi_string boolean DEFAULT true,
    template_moushikomi_date boolean DEFAULT true,
    template_kensyuu_id boolean DEFAULT true,
    template_kensyuu_mei boolean DEFAULT true,
    template_shukankikan boolean DEFAULT true,
    template_start boolean DEFAULT true,
    template_end boolean DEFAULT true,
    template_fee boolean DEFAULT true,
    template_receiver_string boolean DEFAULT true,
    template_shain_cd boolean DEFAULT true,
    template_shain_name boolean DEFAULT true,
    template_mail boolean DEFAULT true,
    template_honbu boolean DEFAULT true,
    template_bumon boolean DEFAULT true,
    template_group boolean DEFAULT true,
    template_note boolean DEFAULT true,
    template_note_naiyou character varying,
    template_start_regist boolean DEFAULT false,
    template_end_regist boolean DEFAULT false,
    template_policy_regist boolean DEFAULT false,
    template_cancel_day_regist boolean DEFAULT false,
    template_moushikomi_string_value text
);


ALTER TABLE public.tbl_mail_template OWNER TO postgres;

--
-- Name: tbl_moushikomi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_moushikomi (
    moushikomi_id integer NOT NULL,
    shain_cd character varying(10) NOT NULL,
    kensyuu_id character varying(5) NOT NULL,
    kensyuu_sub_id character varying(3) NOT NULL,
    moushikomi_date timestamp without time zone DEFAULT now(),
    status integer DEFAULT 0,
    koushinsha text,
    koushinbi timestamp with time zone DEFAULT now(),
    checked_in boolean DEFAULT false
);


ALTER TABLE public.tbl_moushikomi OWNER TO postgres;

--
-- Name: tbl_moushikomi_moushikomi_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_moushikomi_moushikomi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_moushikomi_moushikomi_id_seq OWNER TO postgres;

--
-- Name: tbl_moushikomi_moushikomi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_moushikomi_moushikomi_id_seq OWNED BY public.tbl_moushikomi.moushikomi_id;


--
-- Name: tbl_permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_permission (
    permission_id integer NOT NULL,
    shain_cd text NOT NULL,
    start_date date,
    end_date date,
    permission_cd text NOT NULL
);


ALTER TABLE public.tbl_permission OWNER TO postgres;

--
-- Name: tbl_permission_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_permission_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_permission_permission_id_seq OWNER TO postgres;

--
-- Name: tbl_permission_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_permission_permission_id_seq OWNED BY public.tbl_permission.permission_id;


--
-- Name: tbl_qrcode; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_qrcode (
    qrcode_id integer NOT NULL,
    shain_cd character varying(10),
    qrcode_data text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    nittei_id character varying(10),
    kensyuu_id character varying(10),
    kensyuu_sub_id character varying(10)
);


ALTER TABLE public.tbl_qrcode OWNER TO postgres;

--
-- Name: tbl_qrcode_qrcode_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_qrcode_qrcode_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_qrcode_qrcode_id_seq OWNER TO postgres;

--
-- Name: tbl_qrcode_qrcode_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_qrcode_qrcode_id_seq OWNED BY public.tbl_qrcode.qrcode_id;


--
-- Name: tbl_recommend_template; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_recommend_template (
    id integer NOT NULL,
    column_id text NOT NULL,
    column_name text NOT NULL,
    is_check boolean NOT NULL
);


ALTER TABLE public.tbl_recommend_template OWNER TO postgres;

--
-- Name: tbl_recommend_template_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_recommend_template_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_recommend_template_id_seq OWNER TO postgres;

--
-- Name: tbl_recommend_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_recommend_template_id_seq OWNED BY public.tbl_recommend_template.id;


--
-- Name: tbl_setting; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_setting (
    setting_id integer NOT NULL,
    header_color character varying DEFAULT 'rgb(245, 245, 245)'::character varying,
    header_menu_icon_color character varying DEFAULT 'rgb(0, 0, 0)'::character varying,
    header_title_font_color character varying DEFAULT 'rgb(0, 0, 0)'::character varying,
    header_info_font_color character varying DEFAULT 'rgb(3, 169, 244)'::character varying,
    footer_color character varying DEFAULT 'rgb(245, 245, 245)'::character varying,
    footer_font_color character varying DEFAULT 'rgb(0, 0, 0)'::character varying,
    saving_search_time integer DEFAULT 30,
    saving_day_send_mail integer DEFAULT 14
);


ALTER TABLE public.tbl_setting OWNER TO postgres;

--
-- Name: tbl_setting_setting_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_setting_setting_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_setting_setting_id_seq OWNER TO postgres;

--
-- Name: tbl_setting_setting_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_setting_setting_id_seq OWNED BY public.tbl_setting.setting_id;


--
-- Name: tbl_tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_tags (
    id_tag integer NOT NULL,
    tag_name text NOT NULL,
    id_tag_father integer,
    created_at timestamp with time zone DEFAULT now(),
    created_by text,
    updated_at timestamp with time zone,
    updated_by text,
    del_fg boolean DEFAULT false,
    count_tag bigint DEFAULT 0
);


ALTER TABLE public.tbl_tags OWNER TO postgres;

--
-- Name: tbl_tags_id_tag_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_tags_id_tag_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_tags_id_tag_seq OWNER TO postgres;

--
-- Name: tbl_tags_id_tag_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_tags_id_tag_seq OWNED BY public.tbl_tags.id_tag;


--
-- Name: tbl_temp; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_temp (
    count_shain integer,
    count_kensyuu integer,
    skill_name text
);


ALTER TABLE public.tbl_temp OWNER TO postgres;

--
-- Name: tbl_tsuuchi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_tsuuchi (
    tsuuchi_id integer NOT NULL,
    shain_cd character varying(10),
    moushikomi_id integer,
    tsuuchi_naiyou text,
    tsuuchi_tourokubi date DEFAULT now()
);


ALTER TABLE public.tbl_tsuuchi OWNER TO postgres;

--
-- Name: tbl_tsuuchi_tsuuchi_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbl_tsuuchi_tsuuchi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tbl_tsuuchi_tsuuchi_id_seq OWNER TO postgres;

--
-- Name: tbl_tsuuchi_tsuuchi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbl_tsuuchi_tsuuchi_id_seq OWNED BY public.tbl_tsuuchi.tsuuchi_id;


--
-- Name: v_last_moushikomi; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_last_moushikomi AS
 SELECT d1.moushikomi_id,
    d1.shain_cd,
    d1.kensyuu_id,
    d1.kensyuu_sub_id,
    d1.moushikomi_date,
    d1.status,
    d1.koushinsha,
    d1.koushinbi
   FROM (public.tbl_moushikomi d1
     LEFT JOIN public.tbl_moushikomi d2 ON (((d1.moushikomi_date < d2.moushikomi_date) AND ((d2.shain_cd)::text = (d1.shain_cd)::text) AND ((d2.kensyuu_id)::text = (d1.kensyuu_id)::text) AND ((d2.kensyuu_sub_id)::text = (d1.kensyuu_sub_id)::text))))
  WHERE (d2.moushikomi_date IS NULL);


ALTER TABLE public.v_last_moushikomi OWNER TO postgres;

--
-- Name: view_kensyuu; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_kensyuu WITH (security_barrier='false') AS
 SELECT kn.nittei_id,
    kn.kensyuu_id,
    kn.kensyuu_sub_id,
    kn.nissuu,
    kn.basho,
    kn.toukyou_oosaka_flag,
    kn.nittei_from,
    kn.nittei_to,
    kn.moushikomikigen,
    kn.cancel_date,
    kn.cancelpolicy,
    k.kensyuu_mei,
    k.kensyuu_category,
    kn.jukou_jouhou,
    k.skill_mg_flag,
    k.skill_hm_flag,
    k.skill_tc_flag,
    k.skill_oa_flag,
    k.kensyuu_gaiyou,
    k.taishosha_level,
    k.taishosha,
    kn.jyukouryou,
    k.shukankikan,
    k.bikou,
    k.tema_category,
    k.flag,
        CASE
            WHEN (k.anketto_id IN ( SELECT a.anketto_id
               FROM public.tbl_anketto a)) THEN k.anketto_id
            ELSE NULL::text
        END AS anketto_id,
    k.sub_level,
    k.advance_level,
    k.tags,
    k.tags_father
   FROM (public.tbl_kensyuu_nittei_master kn
     LEFT JOIN public.tbl_kensyuu_master k ON (((kn.kensyuu_id)::text = (k.kensyuu_id)::text)));


ALTER TABLE public.view_kensyuu OWNER TO postgres;

--
-- Name: tbl_checkin check_in_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_checkin ALTER COLUMN check_in_id SET DEFAULT nextval('public.tbl_checkin_check_in_id_seq'::regclass);


--
-- Name: tbl_event event_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_event ALTER COLUMN event_id SET DEFAULT nextval('public.tbl_event_event_id_seq'::regclass);


--
-- Name: tbl_hyouka hyouka_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_hyouka ALTER COLUMN hyouka_id SET DEFAULT nextval('public.tbl_hyouka_hyouka_id_seq'::regclass);


--
-- Name: tbl_kensyuu_nittei_master nittei_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_kensyuu_nittei_master ALTER COLUMN nittei_id SET DEFAULT nextval('public.tbl_kensyuu_nittei_master_nittei_id_seq'::regclass);


--
-- Name: tbl_kyouiku_shukankikan id_kyouiku_shukankikan; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_kyouiku_shukankikan ALTER COLUMN id_kyouiku_shukankikan SET DEFAULT nextval('public.tbl_kyouiku_shukankikan_id_kyouiku_shukankikan_seq'::regclass);


--
-- Name: tbl_mail_config id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_mail_config ALTER COLUMN id SET DEFAULT nextval('public.tbl_mail_config_id_seq'::regclass);


--
-- Name: tbl_mail_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_mail_log ALTER COLUMN id SET DEFAULT nextval('public.tbl_mail_log_id_seq'::regclass);


--
-- Name: tbl_moushikomi moushikomi_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_moushikomi ALTER COLUMN moushikomi_id SET DEFAULT nextval('public.tbl_moushikomi_moushikomi_id_seq'::regclass);


--
-- Name: tbl_permission permission_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_permission ALTER COLUMN permission_id SET DEFAULT nextval('public.tbl_permission_permission_id_seq'::regclass);


--
-- Name: tbl_qrcode qrcode_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_qrcode ALTER COLUMN qrcode_id SET DEFAULT nextval('public.tbl_qrcode_qrcode_id_seq'::regclass);


--
-- Name: tbl_recommend_template id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_recommend_template ALTER COLUMN id SET DEFAULT nextval('public.tbl_recommend_template_id_seq'::regclass);


--
-- Name: tbl_setting setting_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_setting ALTER COLUMN setting_id SET DEFAULT nextval('public.tbl_setting_setting_id_seq'::regclass);


--
-- Name: tbl_tsuuchi tsuuchi_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_tsuuchi ALTER COLUMN tsuuchi_id SET DEFAULT nextval('public.tbl_tsuuchi_tsuuchi_id_seq'::regclass);


--
-- Data for Name: tbl_anketto; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_anketto (anketto_id, anketto_naiyou, created_at) FROM stdin;
001	[{"mondai":"◆研修内容について\\r\\n【役に立った／ためになった点を記載してください】","kaito_type":1,"kaito_list":[],"anketto_no":1},{"mondai":"◆研修内容について\\r\\n【役に立たなかった／期待はずれだった点を記載してください】","kaito_type":1,"kaito_list":[],"anketto_no":2},{"mondai":"◆講師について\\r\\n・講義態度／講師のクラスマネジメント技量／分かりやすさ／質疑応答 等について、当てはまるものを１つ選択してください","kaito_type":2,"kaito_list":["非常に満足","概ね満足","可もなく不可もなく","やや不満足","非常に不満足"],"anketto_no":3},{"mondai":"◆教材・テキストについて\\r\\n・理解しやすさ／内容／使いやすさ 等について、当てはまるものを１つ選択してください","kaito_type":2,"kaito_list":["非常に満足","概ね満足","可もなく不可もなく","やや不満足","非常に不満足"],"anketto_no":4},{"mondai":"◆受講してみて、自分の理解度として最も当てはまるものを１つ選択してください","kaito_type":2,"kaito_list":["理解できた／他人に教えられそう","だいたい理解できた","どちらともいえない","あまり理解できなかった","ほとんど理解できなかった"],"anketto_no":5},{"mondai":"◆今回の研修の総合評価は、どのくらいでしたか？当てはまるものを１つ選択してください","kaito_type":2,"kaito_list":["非常にためになった","所々ためになった","あまりよくなかった","自分には早すぎた（難しかった）","予想より簡単だった（受講が遅かった）"],"anketto_no":6},{"mondai":"◆今回受講した研修のコストパフォーマンスはいかがですか？当てはまるものを１つ選択してください","kaito_type":2,"kaito_list":["ﾎﾞﾘｭｰﾑに対して安く感じた","質・量ともに妥当な値段","内容の割には高く感じる","払う価値なし","自分には判断できない"],"anketto_no":7},{"mondai":"◆受講した研修の受講対象年次はどのくらいが適切だと考えますか？","kaito_type":2,"kaito_list":["新入社員","入社2～3年目","入社4～6年目","入社7年目以上","誰でも可（年次関係なし）"],"anketto_no":8}]	16:52:14.711857+09
002	[{"mondai":"今回の研修は有意義なものでしたか。\\r\\n（カリキュラム１）\\r\\n評価","kaito_type":2,"kaito_list":["5．非常に満足","4．概ね満足","3．可もなく不可もなく","2．やや不満足","1．非常に不満足"],"anketto_no":1},{"mondai":"今回の研修は有意義なものでしたか。\\r\\n（カリキュラム１）\\r\\nそれは何故ですか？理由を書いてください。","kaito_type":1,"kaito_list":[],"anketto_no":2},{"mondai":"今回の研修は有意義なものでしたか。\\r\\n（カリキュラム２）\\r\\n評価","kaito_type":2,"kaito_list":["5．非常に満足","4．概ね満足","3．可もなく不可もなく","2．やや不満足","1．非常に不満足"],"anketto_no":3},{"mondai":"今回の研修は有意義なものでしたか。\\r\\n（カリキュラム２）\\r\\nそれは何故ですか？理由を書いてください。","kaito_type":1,"kaito_list":[],"anketto_no":4},{"mondai":"今回の研修は有意義なものでしたか。\\r\\n（カリキュラム３）\\r\\n評価","kaito_type":2,"kaito_list":["5．非常に満足","4．概ね満足","3．可もなく不可もなく","2．やや不満足","1．非常に不満足"],"anketto_no":5},{"mondai":"今回の研修は有意義なものでしたか。\\r\\n（カリキュラム３）\\r\\nそれは何故ですか？理由を書いてください。","kaito_type":1,"kaito_list":[],"anketto_no":6},{"mondai":"当研修（各プログラム）に受講し、今後に活かせる新たな知識の習得や気付き・発見はありましたか。\\r\\n（カリキュラム１）\\r\\n評価","kaito_type":2,"kaito_list":["5．非常にあった","4．多少あった","3．可もなく不可もなく","2．あまりなかった","1．全くなかった"],"anketto_no":7},{"mondai":"当研修（各プログラム）に受講し、今後に活かせる新たな知識の習得や気付き・発見はありましたか。\\r\\n（カリキュラム１）\\r\\nそれはどのような事ですか？記載してください。","kaito_type":1,"kaito_list":[],"anketto_no":8},{"mondai":"当研修（各プログラム）に受講し、今後に活かせる新たな知識の習得や気付き・発見はありましたか。\\r\\n（カリキュラム２）\\r\\n評価","kaito_type":2,"kaito_list":["5．非常にあった","4．多少あった","3．可もなく不可もなく","2．あまりなかった","1．全くなかった"],"anketto_no":9},{"mondai":"当研修（各プログラム）に受講し、今後に活かせる新たな知識の習得や気付き・発見はありましたか。\\r\\n（カリキュラム２）\\r\\nそれはどのような事ですか？記載してください。","kaito_type":1,"kaito_list":[],"anketto_no":10},{"mondai":"当研修（各プログラム）に受講し、今後に活かせる新たな知識の習得や気付き・発見はありましたか。\\r\\n（カリキュラム３）\\r\\n評価","kaito_type":2,"kaito_list":["5．非常にあった","4．多少あった","3．可もなく不可もなく","2．あまりなかった","1．全くなかった"],"anketto_no":11},{"mondai":"当研修（各プログラム）に受講し、今後に活かせる新たな知識の習得や気付き・発見はありましたか。\\r\\n（カリキュラム３）\\r\\nそれはどのような事ですか？記載してください。","kaito_type":1,"kaito_list":[],"anketto_no":12},{"mondai":"その他、ご意見、ご感想などありましたら、ご記入ください。","kaito_type":1,"kaito_list":[],"anketto_no":13}]	16:52:14.711857+09
003	[{"mondai":"今回の研修は有意義なものでしたか。","kaito_type":2,"kaito_list":["5．非常に満足","4．概ね満足","3．可もなく不可もなく","2．やや不満足","1．非常に不満足"],"anketto_no":1},{"mondai":"今回の研修は有意義なものでしたか。\\r\\nそれは何故ですか？理由を記入してください。","kaito_type":1,"kaito_list":[],"anketto_no":2},{"mondai":"今回の研修は、今後の仕事に活かすことができそうですか。","kaito_type":2,"kaito_list":["5．かなり活かせると思う","4．まあまあ活かせると思う","3．可もなく不可もなく","2．あまり活かせるとは思わない","1．全く活かせると思わない"],"anketto_no":3},{"mondai":"今回の研修は、今後の仕事に活かすことができそうですか。\\r\\nそれは何故ですか？理由を記入してください。","kaito_type":1,"kaito_list":[],"anketto_no":4},{"mondai":"今回の研修の受講時期（社歴／年次）は適切でしたか。","kaito_type":2,"kaito_list":["5．遅すぎた","4．やや遅かった","3．適切だった","2．やや早かった","1．早すぎた"],"anketto_no":5},{"mondai":"今回の研修の受講時期（社歴／年次）は適切でしたか。\\r\\nそれは何故ですか？理由を記入してください。","kaito_type":1,"kaito_list":[],"anketto_no":6},{"mondai":"今回の研修で、役に立たなかった点、期待はずれだった点はありましたか。あれば教えてください。","kaito_type":1,"kaito_list":[],"anketto_no":7},{"mondai":"今回の研修を通して、新たに自分で「学ぶ必要がある」と思ったことはありますか。あれば教えてください。","kaito_type":1,"kaito_list":[],"anketto_no":8},{"mondai":"研修の内容（カリキュラムのスケジュール／コンテンツ／双方向のやり取りなど）はどうでしたか。","kaito_type":2,"kaito_list":["5．良かった","4．まあまあ良かった","3．可もなく不可もなく","2．あまり良くなかった","1．悪かった"],"anketto_no":9},{"mondai":"研修の内容（カリキュラムのスケジュール／コンテンツ／双方向のやり取りなど）はどうでしたか。\\r\\nそれは何故ですか？理由を記入してください。","kaito_type":1,"kaito_list":[],"anketto_no":10},{"mondai":"研修の時間配分（講義や演習の時間配分）はいかがでしたか。","kaito_type":2,"kaito_list":["5．良かった","4．まあまあ良かった","3．可もなく不可もなく","2．あまり良くなかった","1．悪かった"],"anketto_no":11},{"mondai":"研修の時間配分（講義や演習の時間配分）はいかがでしたか。\\r\\nそれは何故ですか？理由を記入してください。","kaito_type":1,"kaito_list":[],"anketto_no":12},{"mondai":"テキスト／配布資料の内容はいかがでしたか。","kaito_type":2,"kaito_list":["5．良かった","4．まあまあ良かった","3．可もなく不可もなく","2．あまり良くなかった","1．悪かった"],"anketto_no":13},{"mondai":"テキスト／配布資料の内容はいかがでしたか。\\r\\nそれは何故ですか？理由を記入してください。","kaito_type":1,"kaito_list":[],"anketto_no":14},{"mondai":"講師の講義はいかがでしたか。","kaito_type":2,"kaito_list":["5．良かった","4．まあまあ良かった","3．可もなく不可もなく","2．あまり良くなかった","1．悪かった"],"anketto_no":15},{"mondai":"講師の講義はいかがでしたか。\\r\\n（コメント欄）","kaito_type":1,"kaito_list":[],"anketto_no":16},{"mondai":"講師の質問に対する回答はいかがでしたか。","kaito_type":2,"kaito_list":["5．良かった","4．まあまあ良かった","3．可もなく不可もなく","2．あまり良くなかった","1．悪かった"],"anketto_no":17},{"mondai":"講師の質問に対する回答はいかがでしたか。\\r\\n（コメント欄）","kaito_type":1,"kaito_list":[],"anketto_no":18},{"mondai":"その他、ご意見、ご感想などありましたら、ご記入ください。","kaito_type":1,"kaito_list":[],"anketto_no":19}]	16:52:14.711857+09
\.


--
-- Data for Name: tbl_checkin; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_checkin (check_in_id, shain_cd, checker_cd, kensyuu_id, kensyuu_sub_id, kensyuu_mei, check_in_time) FROM stdin;
1	000000	000000	00000	000	tinh	2019-09-24 15:55:57.793765
2	000000	000000	00000	000	tinh	2019-09-24 16:08:59.343667
3	000000	000000	48210	004	冨田 隆司	2019-09-24 16:42:20.665339
4	000000	000000	48210	004	冨田 隆司	2019-09-24 17:19:49.46884
5	000000	000000	48210	004	冨田 隆司	2019-09-24 17:19:50.360161
6	000000	000000	48210	004	冨田 隆司	2019-09-24 17:19:52.006834
7	000000	000000	48210	004	冨田 隆司	2019-09-24 17:19:53.031803
8	001120	001120	48503	001	品質分析手法【設計製造編、テスト編】	2019-09-30 17:34:00.226918
9	001120	001120	48503	001	品質分析手法【設計製造編、テスト編】	2019-09-30 17:34:00.822602
10	001120	001120	48503	001	品質分析手法【設計製造編、テスト編】	2019-09-30 17:34:02.602669
11	001120	001120	48503	001	品質分析手法【設計製造編、テスト編】	2019-09-30 17:34:06.675792
\.


--
-- Data for Name: tbl_event; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_event (event_id, event_title, start_ts, end_ts, all_day, created_at, updated_at, check_in, check_out, event_note, is_deleted, is_auto, user_id) FROM stdin;
7	dsad	2019-09-04 07:00:00+07	2019-09-04 08:00:00+07	f	2019-09-04 16:03:51.387485+07	\N	\N	\N	ok	f	f	\N
8	dsad	2019-09-04 07:00:00+07	2019-09-04 08:00:00+07	f	2019-09-04 16:03:55.359494+07	\N	\N	\N	ok	f	f	\N
10	sda	2019-09-05 00:00:00+07	2019-09-05 11:00:00+07	f	2019-09-05 10:25:53.413581+07	\N	\N	\N	dsa	f	f	\N
11	sda	2019-09-05 00:00:00+07	2019-09-05 11:00:00+07	f	2019-09-05 10:26:12.278645+07	\N	\N	\N	dsa	f	f	\N
12	dsad	2019-09-05 11:00:00+07	2019-09-05 22:00:00+07	f	2019-09-05 10:26:53.981887+07	\N	\N	\N	dsa	f	f	\N
13	thu 4	2019-09-05 22:00:00+07	2019-09-05 11:00:00+07	f	2019-09-05 10:27:15.498472+07	\N	\N	\N	dsa	f	f	\N
6	dsa	2019-09-05 11:00:00+07	2019-09-05 22:00:00+07	f	2019-09-03 16:05:18.969295+07	\N	\N	\N	sa	f	f	\N
14	d	2019-09-06 11:00:00+07	2019-09-06 22:00:00+07	f	2019-09-05 10:35:37.562516+07	\N	\N	\N	d	f	f	\N
9	thu 7	2019-09-07 11:00:00+07	2019-09-07 22:00:00+07	f	2019-09-04 16:03:56.520715+07	\N	\N	\N	dsa	f	f	\N
15	tesstttt	2019-09-01 00:00:00+07	2019-09-01 11:00:00+07	f	2019-09-05 10:37:43.07309+07	\N	\N	\N	s	f	f	\N
24	trtrdsadsa	2019-09-11 11:00:00+07	2019-09-11 22:00:00+07	f	2019-09-06 16:56:50.962017+07	\N	\N	\N	dasdas	f	f	000000
25	dsa	2019-09-03 00:00:00+07	2019-09-03 22:00:00+07	f	2019-09-06 16:58:03.709562+07	\N	\N	\N	dsa	f	f	000000
16	dsa	2019-09-10 00:00:00+07	2019-09-10 22:00:00+07	f	2019-09-05 11:32:47.223534+07	\N	\N	\N	dsa	f	f	000000
27	test	2019-09-11 22:00:00+07	2019-09-10 22:00:00+07	f	2019-09-09 10:16:22.778592+07	\N	\N	\N	ds	f	f	000000
\.


--
-- Data for Name: tbl_hyouka; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_hyouka (hyouka_id, moushikomi_id, rating, comment, anketto_koutae, created_at) FROM stdin;
5	4	5	asda	[{"anketto_no":"1","kaito_type":"1","kaito":"asdas"},{"anketto_no":"2","kaito_type":"1","kaito":"asdas"},{"anketto_no":"3","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"4","kaito_type":"2","kaito":""},{"anketto_no":"5","kaito_type":"2","kaito":""},{"anketto_no":"6","kaito_type":"2","kaito":""},{"anketto_no":"7","kaito_type":"2","kaito":""},{"anketto_no":"8","kaito_type":"2","kaito":""},{"anketto_no":"9","kaito_type":"2","kaito":""},{"anketto_no":"10","kaito_type":"2","kaito":""},{"anketto_no":"11","kaito_type":"2","kaito":""},{"anketto_no":"12","kaito_type":"2","kaito":""},{"anketto_no":"13","kaito_type":"2","kaito":""},{"anketto_no":"14","kaito_type":"1","kaito":""}]	2018-08-28 18:03:52.337487+07
6	33	3	テストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストテストストテストテスト	[{"anketto_no":"1","kaito_type":"1","kaito":"テスト"},{"anketto_no":"2","kaito_type":"1","kaito":"テスト"},{"anketto_no":"3","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"4","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"5","kaito_type":"2","kaito":"悪い"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"asdas"},{"anketto_no":"8","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"9","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"10","kaito_type":"2","kaito":"あまりよくなかった"},{"anketto_no":"11","kaito_type":"2","kaito":"特に問題なし"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社4～6年目"},{"anketto_no":"14","kaito_type":"1","kaito":"テスト"}]	2018-08-30 08:49:00.416473+07
7	22	4		[{"anketto_no":"1","kaito_type":"1","kaito":"プランニングが出来るようになった。"},{"anketto_no":"2","kaito_type":"1","kaito":"GWが少なかった。"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"よい"},{"anketto_no":"7","kaito_type":"2","kaito":"やや悪い"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"特に問題なし"},{"anketto_no":"12","kaito_type":"2","kaito":"払う価値なし"},{"anketto_no":"13","kaito_type":"2","kaito":"新入社員"},{"anketto_no":"14","kaito_type":"1","kaito":""}]	2018-09-20 13:36:38.405885+07
8	28	0		[{"anketto_no":"1","kaito_type":"1","kaito":""},{"anketto_no":"2","kaito_type":"1","kaito":""},{"anketto_no":"3","kaito_type":"2","kaito":""},{"anketto_no":"4","kaito_type":"2","kaito":""},{"anketto_no":"5","kaito_type":"2","kaito":""},{"anketto_no":"6","kaito_type":"2","kaito":""},{"anketto_no":"7","kaito_type":"2","kaito":""},{"anketto_no":"8","kaito_type":"2","kaito":""},{"anketto_no":"9","kaito_type":"2","kaito":""},{"anketto_no":"10","kaito_type":"2","kaito":""},{"anketto_no":"11","kaito_type":"2","kaito":""},{"anketto_no":"12","kaito_type":"2","kaito":""},{"anketto_no":"13","kaito_type":"2","kaito":""},{"anketto_no":"14","kaito_type":"1","kaito":""}]	2018-09-20 15:27:52.096505+07
9	28	0		[{"anketto_no":"1","kaito_type":"1","kaito":""},{"anketto_no":"2","kaito_type":"1","kaito":""},{"anketto_no":"3","kaito_type":"2","kaito":""},{"anketto_no":"4","kaito_type":"2","kaito":""},{"anketto_no":"5","kaito_type":"2","kaito":""},{"anketto_no":"6","kaito_type":"2","kaito":""},{"anketto_no":"7","kaito_type":"2","kaito":""},{"anketto_no":"8","kaito_type":"2","kaito":""},{"anketto_no":"9","kaito_type":"2","kaito":""},{"anketto_no":"10","kaito_type":"2","kaito":""},{"anketto_no":"11","kaito_type":"2","kaito":""},{"anketto_no":"12","kaito_type":"2","kaito":""},{"anketto_no":"13","kaito_type":"2","kaito":""},{"anketto_no":"14","kaito_type":"1","kaito":""}]	2018-09-20 15:31:23.66915+07
10	32	1	　　　	[{"anketto_no":"1","kaito_type":"1","kaito":"　　　"},{"anketto_no":"2","kaito_type":"1","kaito":"　　　"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"よい"},{"anketto_no":"7","kaito_type":"2","kaito":"よい"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"適切な時間配分だった"},{"anketto_no":"12","kaito_type":"2","kaito":"ﾎﾞﾘｭｰﾑに対して安く感じた"},{"anketto_no":"13","kaito_type":"2","kaito":"新入社員"},{"anketto_no":"14","kaito_type":"1","kaito":"　　　"}]	2018-09-26 09:44:03.154173+07
11	787	4	前提条件はあったが、業務で少しUNIX系を触っていれば問題なくついていけると感じた。\n業務でUNIX系を使用し始める若手におすすめしたい。	[{"anketto_no":"1","kaito_type":"1","kaito":"シェルの基本的なところを学ぶことができた。\\nまた、上記を通してLinuxのコマンドについても学ぶことができたため、\\n今後の業務に活用していきたいと考えている。"},{"anketto_no":"2","kaito_type":"1","kaito":"特になし"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"適切な時間配分だった"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社2～3年目"},{"anketto_no":"14","kaito_type":"1","kaito":"時間配分が後半が少し急ぎめだったため、\\n前半がもう少し縮まるとよいかとは感じた。"}]	2018-10-31 08:31:04.79308+07
12	789	5	PJリーダに対しておすすめしたい	[{"anketto_no":"1","kaito_type":"1","kaito":"顧客と交渉する機会が増えてきたので、タイムリーな内容で勉強になった"},{"anketto_no":"2","kaito_type":"1","kaito":"特になし"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"よい"},{"anketto_no":"7","kaito_type":"2","kaito":"よい"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"特に問題なし"},{"anketto_no":"12","kaito_type":"2","kaito":"内容の割には高く感じる"},{"anketto_no":"13","kaito_type":"2","kaito":"入社4～6年目"},{"anketto_no":"14","kaito_type":"1","kaito":"演習が多く、退屈せず学習することができた"}]	2018-10-31 13:00:55.051476+07
13	742	2	資料があれば、研修に出なくても理解することができる内容である。	[{"anketto_no":"1","kaito_type":"1","kaito":"Azureの豆知識\\n・「ブチザッキ」というサイトがAzureの新機能を載せている\\n・マネージャーの方が料金シュミレーションを行うには\\n　「料金計算ツール　Azure」と検索をかける\\n・顔認証をするapp「face api」が何かに使えそう"},{"anketto_no":"2","kaito_type":"1","kaito":"資料を事前に読んでいたら、退屈になってしまう\\n"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"よい"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"だいたい理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"適切な時間配分だった"},{"anketto_no":"12","kaito_type":"2","kaito":"内容の割には高く感じる"},{"anketto_no":"13","kaito_type":"2","kaito":"入社2～3年目"},{"anketto_no":"14","kaito_type":"1","kaito":"資料があれば、研修に出なくても理解することができる内容である。"}]	2018-11-01 15:15:59.127362+07
14	793	5	オープン・カフェをイメージした研修だった為、初対面の人とも話しやすかった。	[{"anketto_no":"1","kaito_type":"1","kaito":"フロー状態は、仕事を向上させる。\\n笑顔で声質が変わる。\\n笑顔は大切。\\n印象は大切。"},{"anketto_no":"2","kaito_type":"1","kaito":"ないです。"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"よい"},{"anketto_no":"7","kaito_type":"2","kaito":"よい"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"特に問題なし"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社7年目以上"},{"anketto_no":"14","kaito_type":"1","kaito":"ありません。"}]	2018-11-07 08:50:03.859199+07
15	791	4	\n午前中はグループワークでコミュニケーションについて自由に意見をだした。\n後半は課題に対しグループで作業をした。\nまた、研修資料を用いてコミュニケーションでのポインについて講義を受けた。	[{"anketto_no":"1","kaito_type":"1","kaito":"グループワークや実例を用いて、ビジネスの場でのコミュニケーションで重視することを理解できた。\\n"},{"anketto_no":"2","kaito_type":"1","kaito":"内容は新人向けだと感じた。\\nグループワークが多いので、参加者に左右される。今回人数が定員より少なかったため、もう少し人数が多かったらより意見が聞けたのではと感じた。\\n"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"よい"},{"anketto_no":"7","kaito_type":"2","kaito":"よい"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"予想より簡単だった（受講が遅かった）"},{"anketto_no":"11","kaito_type":"2","kaito":"適切な時間配分だった"},{"anketto_no":"12","kaito_type":"2","kaito":"ﾎﾞﾘｭｰﾑに対して安く感じた"},{"anketto_no":"13","kaito_type":"2","kaito":"新入社員"},{"anketto_no":"14","kaito_type":"1","kaito":"初級編ということで、内容はコミュニケーションについて浅く広い印象だったが、説明はとても丁寧でわかりやすかった。説明はとてもわかりやすかったので、今回の講師の方の別の研修を受けてみたいと感じた。"}]	2018-11-07 14:17:33.856992+07
26	805	5	特になし	[{"anketto_no":"1","kaito_type":"1","kaito":"プロジェクトマネジメントについて、工程別の事例をもとに演習形式で研修を行った。\\n事例を元にしていたため、翌日以降の現場業務に生かしたり、意識することができた。\\n"},{"anketto_no":"2","kaito_type":"1","kaito":"特になし"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"よい"},{"anketto_no":"7","kaito_type":"2","kaito":"よい"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"適切な時間配分だった"},{"anketto_no":"12","kaito_type":"2","kaito":"ﾎﾞﾘｭｰﾑに対して安く感じた"},{"anketto_no":"13","kaito_type":"2","kaito":"入社7年目以上"},{"anketto_no":"14","kaito_type":"1","kaito":"特になし"}]	2018-11-20 08:52:46.276063+07
16	792	5	研修の内容に主観的な話だけではなく、学術的に裏付けされている話も多く盛り込まれていたので、内容に説得力がありました。	[{"anketto_no":"1","kaito_type":"1","kaito":"仕事をする際に、一緒に仕事をする人との「関係」も意識することで、結果的に仕事の「結果」にも良い方向に影響すること。\\n"},{"anketto_no":"2","kaito_type":"1","kaito":"とくになし"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"よい"},{"anketto_no":"7","kaito_type":"2","kaito":"よい"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"適切な時間配分だった"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"新入社員"},{"anketto_no":"14","kaito_type":"1","kaito":"空調が少しだけ低く設定されいたのか、寒く感じることが多かったです。"}]	2018-11-09 07:56:13.937291+07
17	790	4	・受講要件のJavaに加えデータベースを新人研修などで勉強したことがある人で、Android開発をしたことがない人におすすめしたい。Android開発を1度でもした人には物足りないと思われる。\n	[{"anketto_no":"1","kaito_type":"1","kaito":"・必須級の機能のAndroid環境特有の構文に力を入れていたため、すぐにAndroid開発ができるようになりそう。\\n・独学で厳しいと思われる、画面遷移やデータの保存方法が分かりやすい。"},{"anketto_no":"2","kaito_type":"1","kaito":"・特になし"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"特に問題なし"},{"anketto_no":"12","kaito_type":"2","kaito":"その他"},{"anketto_no":"13","kaito_type":"2","kaito":"入社2～3年目"},{"anketto_no":"14","kaito_type":"1","kaito":"・特になし"}]	2018-11-09 13:43:51.064396+07
18	796	5	コミュニケーションが苦手だと感じているメンバには受講してもらいたい研修だと考える。\n実際に他の受講生と話をしながら研修を進めるため、\n他の人が職場のコミュニケーションについてどのような事を感じているのか、苦手だと思っているのかをざっくばらんに話せる雰囲気である。	[{"anketto_no":"1","kaito_type":"1","kaito":"ビジネスにおいてのコミュニケーションを学び、\\nそれぞれの人のスタイルにおいて適切な接し方や話し方が存在することを学びためになった。\\nチーム内でのコミュニケーションや上司、後輩と接する際のコミュニケーションの仕方も学べたので、\\n新人や新任トレーナーなどに受講して頂きたい研修であると考える。"},{"anketto_no":"2","kaito_type":"1","kaito":"受講人数が通常は10人程度だと講師の方にお聞きしたが、\\n私が参加したときには3人であった。\\n質問等は行いやすい雰囲気であったが、受講人数が多い方が色々な人とコミュニケーションがとれ\\n様々な意見が聞けたかもしれない。"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"よい"},{"anketto_no":"7","kaito_type":"2","kaito":"よい"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"適切な時間配分だった"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社2～3年目"},{"anketto_no":"14","kaito_type":"1","kaito":"研修会場も分かりやすい場所であり、静かな場所なので研修に集中できた。"}]	2018-11-10 18:42:27.74475+07
19	794	4	本画面の入力欄で「Enter」を入力すると前画面へ遷移して入力しづらいです。	[{"anketto_no":"1","kaito_type":"1","kaito":"コミュニケーションの手法"},{"anketto_no":"2","kaito_type":"1","kaito":"特になし。"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"7","kaito_type":"2","kaito":"よい"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"特に問題なし"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"新入社員"},{"anketto_no":"14","kaito_type":"1","kaito":"特になし。"}]	2018-11-12 09:37:01.219133+07
20	770	3	事前知識がない方および理解が浅い若手が受けるべき講習だと思う。私としては、現在PM業務は行っていないため、色々な技法を学べたためいい機会になった。ただマネジメントについては正解がないため、実務を通して自分の型を見つけていくしかないと感じた。	[{"anketto_no":"1","kaito_type":"1","kaito":"プロジェクトマネジメントにおける基本的な技法を学ぶことができた。基本情報や応用情報の学習でで知っていた知識もあったが実際にその技法を用いて演習を行ったためより理解が深まった。またグループワークで違う会社、それも自分より一回り年上の方々と今抱えている悩みの共有ができ非常に有意義であった。"},{"anketto_no":"2","kaito_type":"1","kaito":"内容としては、独学で十分補填可能なレベルだと思う。プロジェクトマネジメント業務をすでに実施している方にとってはやや内容が薄いと感じると思う。"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"7","kaito_type":"2","kaito":"やや悪い"},{"anketto_no":"8","kaito_type":"2","kaito":"やや悪い"},{"anketto_no":"9","kaito_type":"2","kaito":"だいたい理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"特に問題なし"},{"anketto_no":"12","kaito_type":"2","kaito":"内容の割には高く感じる"},{"anketto_no":"13","kaito_type":"2","kaito":"入社2～3年目"},{"anketto_no":"14","kaito_type":"1","kaito":"特になし。"}]	2018-11-15 16:51:53.303229+07
21	825	4	受講メンバーの9割がキューブメンバーのため、グループワークの連携は良かったが\n反面、馴れ合いっぽくなってしまった感がある。\n受講タイミングを分散させても良かったのでは、と思う\nまったく異なる業種と会話することで気づきがあると思う。	[{"anketto_no":"1","kaito_type":"1","kaito":"今後、チームリーダとして仕事を進める際に、部下に対しての振る舞い等の気づきができた。\\nまた、自分に不足している課題について認識ができました。"},{"anketto_no":"2","kaito_type":"1","kaito":"特になし"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"5","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"だいたい理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"適切な時間配分だった"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"誰でも可（年次関係なし）"},{"anketto_no":"14","kaito_type":"1","kaito":"特になし　【指摘】設問7について、不要な選択肢があります。恐らくテストでセットした値かと。。。"}]	2018-11-19 08:01:35.078108+07
22	820	3	ほとんどが知っている知識ばかりだった。実際にやれていることやれていないことを振り返るのにはいい機会だったと思っている。\nプロジェクトを初めて任される前後に受けるとよいと思う。	[{"anketto_no":"1","kaito_type":"1","kaito":"マネジメントの方法論というよりより実践的に行うにはどうしたらいいかを学べてよかった。"},{"anketto_no":"2","kaito_type":"1","kaito":"マネジメントの話は知っていることばかりだった。"},{"anketto_no":"3","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"4","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"特に問題なし"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社4～6年目"},{"anketto_no":"14","kaito_type":"1","kaito":"講師の松田さんの過去の話は割愛してもよいのではと感じた。演習の進め方はいまいちだった。"}]	2018-11-19 08:23:48.724825+07
23	812	4	　	[{"anketto_no":"1","kaito_type":"1","kaito":"<よかった点>\\n組織のマネジメントを行うときに、メンバーによってやりかたやマインドをうまくコントロールし\\nうまく導いていくために、そのやり方に関していろいろなパターンがあり使って考えていく。"},{"anketto_no":"2","kaito_type":"1","kaito":"<悪かった点>\\nいろいろなパターンをどんなロケーションで使いわ変えていけばいいか\\n具体的なアクションの説明がなかった。"},{"anketto_no":"3","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"4","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"5","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"6","kaito_type":"2","kaito":"よい"},{"anketto_no":"7","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"適切な時間配分だった"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社7年目以上"},{"anketto_no":"14","kaito_type":"1","kaito":"マネジメントに携わっていくなら研修に参加したほうがいい。\\n部下に対してのマインドを変えていくやり方をきちんと理解し\\nやりがいや楽しさを部下にどう見せていくかきちんと考えていく必要がある。"}]	2018-11-19 16:48:44.511335+07
24	1221	5	有意義な研修だった。年次が若いものでもどんどん受講させることにより、リーダ層に近しい人材を育てやすくなるのではないかと感じた。\n今回の講座を担当した小池講師は、個人的に分かりやすくて興味深い講師だった。同じ講師の方で、別の講座があれば受講したい。\n\n余談だが、開始が朝9時なので西日本からの参加者は朝がつらいかもしれない。	[{"anketto_no":"1","kaito_type":"1","kaito":"体系だった知識を学べてよかった。\\n特に実際にあり得る内容のセンテンスに沿ってワークショップを行うのが印象的だった。"},{"anketto_no":"2","kaito_type":"1","kaito":"他の参加者が自分と似たような考えの持ち主であったため、印象に残る会話がすくなかった。"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"よい"},{"anketto_no":"7","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"特に問題なし"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社4～6年目"},{"anketto_no":"14","kaito_type":"1","kaito":"研修と関係ありませんが、一番上のコメントを入力しようとすると、本アンケートが終了してしまいます。。。\\nコピペなら問題ない？　また、7. ◆教材・テキストについて ・使いやすさ　に不正な文言が表示されています。"}]	2018-11-19 21:39:25.794316+07
25	826	1	正直期待はずれでした。	[{"anketto_no":"1","kaito_type":"1","kaito":"研修参加者の意見を聞いて、同じような課題を持って対応していることを知れた。またその課題に対する対策をどうしているかを知ることができた。"},{"anketto_no":"2","kaito_type":"1","kaito":"グループがすべてCUBE社員だったこと。ありきたりな理論の説明がメインで活用できる内容がほとんどなかったこと。"},{"anketto_no":"3","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"4","kaito_type":"2","kaito":"やや悪い"},{"anketto_no":"5","kaito_type":"2","kaito":"やや悪い"},{"anketto_no":"6","kaito_type":"2","kaito":"やや悪い"},{"anketto_no":"7","kaito_type":"2","kaito":"悪い"},{"anketto_no":"8","kaito_type":"2","kaito":"やや悪い"},{"anketto_no":"9","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"10","kaito_type":"2","kaito":"あまりよくなかった"},{"anketto_no":"11","kaito_type":"2","kaito":"講義が間延びしていた"},{"anketto_no":"12","kaito_type":"2","kaito":"払う価値なし"},{"anketto_no":"13","kaito_type":"2","kaito":"入社7年目以上"},{"anketto_no":"14","kaito_type":"1","kaito":"面白くない。"}]	2018-11-20 08:45:06.474714+07
27	818	4	受講者の9割がキューブ社員だったため、本社で開催しても良かった。	[{"anketto_no":"1","kaito_type":"1","kaito":"体系的に学ぶことができて良かった。"},{"anketto_no":"2","kaito_type":"1","kaito":"グループワークの目的がグループ内での意見交換のみの場合、雑談レベルで終わることが多かった。"},{"anketto_no":"3","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"4","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"5","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"だいたい理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"特に問題なし"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社4～6年目"},{"anketto_no":"14","kaito_type":"1","kaito":"「とらんす・ほーむ」サイトのアンケート回答ページにおいて、アンケート入力中に前ページに戻ってしまう事象が何度も発生した。\\n可能であれば、バグ改修をお願いたい。"}]	2018-11-20 12:21:00.858394+07
28	807	5	無し。	[{"anketto_no":"1","kaito_type":"1","kaito":"・PMの役割・何をすべき\\n・基本設計～UATの各工程にてPMとしてPJの管理、及び顧客とのやり取りの方法"},{"anketto_no":"2","kaito_type":"1","kaito":"・演習を通じて、PMとしての仕事を理解できた。\\n・PJの管理方法を取得できた。"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"よい"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"特に問題なし"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社2～3年目"},{"anketto_no":"14","kaito_type":"1","kaito":"無し。"}]	2018-11-20 15:58:15.192511+07
29	798	4	プログラム系の技術研修を受けてみたいです。	[{"anketto_no":"1","kaito_type":"1","kaito":"自身はPLという立場で作業していますが、普段の業務を振り返ってマネジメントできていたか、判断は正しかったかなどの振り返りができた。講師の実体験なども聞けて、良い体験になったと思います。"},{"anketto_no":"2","kaito_type":"1","kaito":"マネジメント系の研修全般に言えることですが、演習の時間が足りないと思いました。文を読み終えるだけで制限時間に達してしまう。料金は高いと感じた。"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"5","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"6","kaito_type":"2","kaito":"よい"},{"anketto_no":"7","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"だいたい理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"時間が全く足りなかった"},{"anketto_no":"12","kaito_type":"2","kaito":"内容の割には高く感じる"},{"anketto_no":"13","kaito_type":"2","kaito":"入社4～6年目"},{"anketto_no":"14","kaito_type":"1","kaito":"プログラム系の技術研修を受けてみたいです。"}]	2018-11-20 16:16:07.141349+07
30	806	4	講師の先生がこちらの質問に紳士に答えてくださっていました。\n演習時間が少し短く十分な意見交換ができないのが残念だと思いました。	[{"anketto_no":"1","kaito_type":"1","kaito":"演習が役に立ちました。"},{"anketto_no":"2","kaito_type":"1","kaito":"\\nちょっと極端だと思う例や話があったので\\nそのあたりは個人の経験や判断が必要になるかと思います。\\n"},{"anketto_no":"3","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"4","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"5","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"だいたい理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"講義が間延びしていた"},{"anketto_no":"12","kaito_type":"2","kaito":"内容の割には高く感じる"},{"anketto_no":"13","kaito_type":"2","kaito":"入社4～6年目"},{"anketto_no":"14","kaito_type":"1","kaito":"演習は実際に顧客と交渉をしていく場面があったので、\\n役立つ研修でした。"}]	2018-11-20 19:30:34.691962+07
31	801	4	とにかく問題が起こる前に未然に防ぐことが何より大事だと学んだ。	[{"anketto_no":"1","kaito_type":"1","kaito":"プロジェクトを運営していく中で発生しうる事例の模範解答を現場経験のある方から学べた点に意義があった。"},{"anketto_no":"2","kaito_type":"1","kaito":"特になし。"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"だいたい理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"時間が全く足りなかった"},{"anketto_no":"12","kaito_type":"2","kaito":"内容の割には高く感じる"},{"anketto_no":"13","kaito_type":"2","kaito":"入社7年目以上"},{"anketto_no":"14","kaito_type":"1","kaito":"講師の雑談、モザイクアートが面白かった。"}]	2018-11-21 12:08:19.915049+07
37	802	5	今後、プロジェクトマネージャなどで顧客やBPと\nの交渉などが主な業務になるような方にお勧めできると思います。	[{"anketto_no":"1","kaito_type":"1","kaito":"プロジェクトでマネジメントをしていくうえで必要なことややってはいけないことなどを講師の体験をふまえて教えてくださり大変勉強になりました。"},{"anketto_no":"2","kaito_type":"1","kaito":"期待はずれなことは特にありません。"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"だいたい理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"適切な時間配分だった"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社7年目以上"},{"anketto_no":"14","kaito_type":"1","kaito":"大変勉強になりました"}]	2018-11-26 01:43:13.386718+07
38	827	4	Node.jsを使用した現場に配属されるとなった際、事前に受けておくとスムーズに開発できるのだろうと思います。\n	[{"anketto_no":"1","kaito_type":"1","kaito":"各自端末が用意されており、Node.jsの開発方法について、演習を交えながらの研修だったので、Node.jsが初めての方に関しては、わかりやすい研修であったと感じました。"},{"anketto_no":"2","kaito_type":"1","kaito":"開発方法に特化していた為、Node.jsが他の言語と比べて特化していることなどは学べなかったです。"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"だいたい理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"特に問題なし"},{"anketto_no":"12","kaito_type":"2","kaito":"内容の割には高く感じる"},{"anketto_no":"13","kaito_type":"2","kaito":"誰でも可（年次関係なし）"},{"anketto_no":"14","kaito_type":"1","kaito":"特になし"}]	2018-11-26 17:26:18.470893+07
32	814	3	講義としては1時間おきに休憩があり、集中して聞くことが出来た。\nグループでの話し合いが中心であったため、もう少し休憩時間を減らして話し合いの時間などに使えればよかった。	[{"anketto_no":"1","kaito_type":"1","kaito":"これまでリーダーシップ取って牽引をしていくと言うマネジメントを中心を行っていたため、\\nメンバーと対話を行い進めていく方法について、全てではないが学習できた。"},{"anketto_no":"2","kaito_type":"1","kaito":"プロジェクトを成功させる。\\nプロジェクトを維持（下を育てていく）していく。\\nと言ったケースによるプロジェクトのマネジメント方法が変わってくると思うが、\\n下を育てていくためにはと言うマネジメントを中心に研修が進んだため、\\nプロジェクトを選ぶと感じた。"},{"anketto_no":"3","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"4","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"5","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"だいたい理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"その他"},{"anketto_no":"12","kaito_type":"2","kaito":"内容の割には高く感じる"},{"anketto_no":"13","kaito_type":"2","kaito":"入社4～6年目"},{"anketto_no":"14","kaito_type":"1","kaito":"特にありません"}]	2018-11-21 12:49:19.123116+07
33	819	3	特になし	[{"anketto_no":"1","kaito_type":"1","kaito":"上司や部下との付き合い方としての手法を学ぶことができた。"},{"anketto_no":"2","kaito_type":"1","kaito":"講師の話し方が雑談と重要内容が入り混じっていたため分からない部分が多々あった"},{"anketto_no":"3","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"4","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"5","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"だいたい理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"特に問題なし"},{"anketto_no":"12","kaito_type":"2","kaito":"内容の割には高く感じる"},{"anketto_no":"13","kaito_type":"2","kaito":"入社4～6年目"},{"anketto_no":"14","kaito_type":"1","kaito":"特になし"}]	2018-11-21 16:23:00.750731+07
34	822	3	いろいろな著名人のマネジメントを少しづつ幅広くやるため、\nコーチングなどもっと教えてほしい部分については\n深めることができなかった。\n講師の経験談についてはためになった。	[{"anketto_no":"1","kaito_type":"1","kaito":"マネジメントについて、深く学ぶことができた。"},{"anketto_no":"2","kaito_type":"1","kaito":"\\n演習が少なくディスカッションもテーマがあいまいなこともあったり\\n、物足りないところもあった。"},{"anketto_no":"3","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"4","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"5","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"6","kaito_type":"2","kaito":"よい"},{"anketto_no":"7","kaito_type":"2","kaito":"よい"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"だいたい理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"講義が間延びしていた"},{"anketto_no":"12","kaito_type":"2","kaito":"内容の割には高く感じる"},{"anketto_no":"13","kaito_type":"2","kaito":"入社4～6年目"},{"anketto_no":"14","kaito_type":"1","kaito":"もう少し演習があったほうが楽しめた。"}]	2018-11-21 20:13:59.239876+07
35	816	2	特になし	[{"anketto_no":"1","kaito_type":"1","kaito":"今までいろいろな書籍の内容の振り返りにはなり、再度考え直す機会になった"},{"anketto_no":"2","kaito_type":"1","kaito":"いろいろな書籍の内容などをまとめていた内容だったため、新たな気がつきは特になかった"},{"anketto_no":"3","kaito_type":"2","kaito":"やや悪い"},{"anketto_no":"4","kaito_type":"2","kaito":"やや悪い"},{"anketto_no":"5","kaito_type":"2","kaito":"やや悪い"},{"anketto_no":"6","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"7","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"8","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"9","kaito_type":"2","kaito":"だいたい理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"予想より簡単だった（受講が遅かった）"},{"anketto_no":"11","kaito_type":"2","kaito":"特に問題なし"},{"anketto_no":"12","kaito_type":"2","kaito":"内容の割には高く感じる"},{"anketto_no":"13","kaito_type":"2","kaito":"入社4～6年目"},{"anketto_no":"14","kaito_type":"1","kaito":"講師の話が自分の体験談について、話が脱線することが多かった。また、内容も講師の主観的な内容だった。"}]	2018-11-22 07:32:34.678013+07
36	817	2	特になし	[{"anketto_no":"1","kaito_type":"1","kaito":"日々感覚的に行っているマネージメントを振り返る機会があった点が良かった"},{"anketto_no":"2","kaito_type":"1","kaito":"特になし"},{"anketto_no":"3","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"4","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"5","kaito_type":"2","kaito":"やや悪い"},{"anketto_no":"6","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"7","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"8","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"9","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"特に問題なし"},{"anketto_no":"12","kaito_type":"2","kaito":"内容の割には高く感じる"},{"anketto_no":"13","kaito_type":"2","kaito":"入社7年目以上"},{"anketto_no":"14","kaito_type":"1","kaito":"特になし"}]	2018-11-22 15:52:47.76036+07
39	821	2	講師の方は物腰柔らかい感じで良かったが、世間話（自慢話）が多かったので、もう少しメリハリをつけて進めて頂けるとよかったと思います。\n	[{"anketto_no":"1","kaito_type":"1","kaito":"心理学的な手法は色々と学ぶことが出来た点は良かった。"},{"anketto_no":"2","kaito_type":"1","kaito":"講義をたくさんやられてる方だと思うので、他の失敗事例や成功事例などを説明した上で、グループワークを行うなどしてもよかったと思いますした。\\nテキストの内容が参考文献を用いすぎてた感がありました。"},{"anketto_no":"3","kaito_type":"2","kaito":"やや悪い"},{"anketto_no":"4","kaito_type":"2","kaito":"やや悪い"},{"anketto_no":"5","kaito_type":"2","kaito":"やや悪い"},{"anketto_no":"6","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"7","kaito_type":"2","kaito":"やや悪い"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"10","kaito_type":"2","kaito":"あまりよくなかった"},{"anketto_no":"11","kaito_type":"2","kaito":"特に問題なし"},{"anketto_no":"12","kaito_type":"2","kaito":"内容の割には高く感じる"},{"anketto_no":"13","kaito_type":"2","kaito":"入社7年目以上"},{"anketto_no":"14","kaito_type":"1","kaito":"キューブの社員が９割ぐらいで、私のグループも全員キューブであったため、社外講習の価値があったかという点について見直すべき課題と感じた。"}]	2018-11-27 22:38:50.076817+07
40	828	4	特にありません。	[{"anketto_no":"1","kaito_type":"1","kaito":"交渉前の準備作業として、交渉目的の設定・代替案の立案（準備）・妥協点の設定・強み／弱みの分析等を行うことで、スムーズに交渉を行うことができるという点は、非常に勉強になりました。また、それをロールプレイング形式で実践することにより、自身にしっかりインプットできたと思います。"},{"anketto_no":"2","kaito_type":"1","kaito":"特にありません。"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"だいたい理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"特に問題なし"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社7年目以上"},{"anketto_no":"14","kaito_type":"1","kaito":"他の受講者の年齢層は30～45歳くらいでした。"}]	2018-11-28 23:18:57.220697+07
41	813	4	特になし。	[{"anketto_no":"1","kaito_type":"1","kaito":"前職含めてリーダという立場になったのは初めてであったため、組織マネジメントの上ではさらに上の上司との付き合い方が大切という点や、部下のパフォーマンスを最大限に発揮させるための考え方、自分のタスクよりもプロジェクト全体を見渡す視点を持つという部分が参考になった。"},{"anketto_no":"2","kaito_type":"1","kaito":"特になし。"},{"anketto_no":"3","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"4","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"5","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"だいたい理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"特に問題なし"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社4～6年目"},{"anketto_no":"14","kaito_type":"1","kaito":"特になし。"}]	2018-11-29 20:55:18.157242+07
42	795	4	プロジェクトリーダやチームリーダ等、組織のトップに立つ立場の人は、顧客や部下との良い信頼関係を構築するためには\nとても参考になる研修だと感じた。	[{"anketto_no":"1","kaito_type":"1","kaito":"相手のタイプに合わせて、伝え方をどのように変えればいいか知ることができた。\\n"},{"anketto_no":"2","kaito_type":"1","kaito":"特になし。"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"適切な時間配分だった"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社7年目以上"},{"anketto_no":"14","kaito_type":"1","kaito":"話す相手によって伝え方を変えることで、今後仕事をする上で良い信頼関係を築くことができ、\\nお互いが会話によるストレスを感じることなく仕事に取り組むことができるようになると、グループワークを通して実感した。"}]	2018-12-04 17:06:02.353573+07
43	831	5	事前に受けるべき研修があったようです。\n一年目のVBA研修を理解していれば問題ないですが、周知してあると受講者は準備しやすいと思いました。	[{"anketto_no":"1","kaito_type":"1","kaito":"実践的な内容の講義であり、また演習が多い点"},{"anketto_no":"2","kaito_type":"1","kaito":"特になし"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"よい"},{"anketto_no":"7","kaito_type":"2","kaito":"よい"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"適切な時間配分だった"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社2～3年目"},{"anketto_no":"14","kaito_type":"1","kaito":"２人でのフォロー体制を組まれており、非常に質問はしやすかったですが、それでも理解度に差があり、一部のみ演習の進みが遅いと感じました。"}]	2018-12-05 17:25:33.99272+07
44	834	2	作業プランニングの考え方や方法のようなものは知っていて損はないと思った。\nしかし、時間の見積もりについてはどうしても経験によるところが多く、すぐには使えない部分もあると思う。\nまた、保守や運用よりも開発チームに配属されている人の方がためになると思った。\n	[{"anketto_no":"1","kaito_type":"1","kaito":"時間の使い方について自己分析できたことが良かった。\\n作業プランニングの考え方と方法を知ることができて良かった。"},{"anketto_no":"2","kaito_type":"1","kaito":"目的について考える重要性を学んだが、目的は相対的なもので他人と無理に合わせる必要がない部分もあると思った。"},{"anketto_no":"3","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"4","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"5","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"特に問題なし"},{"anketto_no":"12","kaito_type":"2","kaito":"内容の割には高く感じる"},{"anketto_no":"13","kaito_type":"2","kaito":"入社2～3年目"},{"anketto_no":"14","kaito_type":"1","kaito":"自分の時間の使い方についてよく考える機会になった。"}]	2018-12-11 13:45:50.822652+07
45	811	2	総評としてはあまりお勧めしないが、マネジメントについて一般知識を知りたいのであれば受ける意味もあると思う。	[{"anketto_no":"1","kaito_type":"1","kaito":"三つの視点（自分、チーム、上司）からマネジメントという話があり、様々な手法を聞けたこと。"},{"anketto_no":"2","kaito_type":"1","kaito":"グループワーク内容がやや退屈だった。もう少し考える興味がわく内容であればよかった。"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"5","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"6","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"7","kaito_type":"2","kaito":"やや悪い"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"講義が間延びしていた"},{"anketto_no":"12","kaito_type":"2","kaito":"内容の割には高く感じる"},{"anketto_no":"13","kaito_type":"2","kaito":"入社4～6年目"},{"anketto_no":"14","kaito_type":"1","kaito":"マネジメントといってもマネジメント層よりローワマネジメント層こそ必要な研修であると感じた。"}]	2018-12-12 16:21:54.502051+07
46	833	4	講師の話し方と研修の進め方が効率的で、必要以上に話すこともなく重要なポイントだけをおさえるような形でした。研修の進め方には無駄がないように思いました。	[{"anketto_no":"1","kaito_type":"1","kaito":"自己の作業プランニングを分析でき、「緊急度」「重要度」の軸に当てることによって、どういった作業に時間をかけているかが見えました。また、今の作業に時間対する時間配分を見て、改善すべき点を見出すこともできました。"},{"anketto_no":"2","kaito_type":"1","kaito":"チーム(他人と自分)のタスクを管理することよりも、自己のタスクを管理することに焦点を当てた研修なので、もうちょっと早めに受ければよかったと思いました(2年目)。"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"適切な時間配分だった"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社2～3年目"},{"anketto_no":"14","kaito_type":"1","kaito":"特にありません"}]	2018-12-17 10:07:19.517218+07
47	832	4	グループワークの中で自分が今後のためになることを実施できていないことが分かった。\n自分としては確保している認識でいたが、他の人と比較するとそうではなかったので、\n今後、意識的にもっと時間を確保しようと感じた。\nこういったことを1～3年目のうちに学べていれば良かったのに、と感じたので\nもし後輩を持つようになったら、本研修で学んだことを伝えていきたい。	[{"anketto_no":"1","kaito_type":"1","kaito":"作業プランニングのやり方を知ることができてよかった。\\n目の前の作業だけではなく、今後のためになることの時間を意識的に確保しようと思える研修だった。"},{"anketto_no":"2","kaito_type":"1","kaito":"既に実践できている内容も研修の中で話されていたため、その時間は少しもったいないと感じた。"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"適切な時間配分だった"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社2～3年目"},{"anketto_no":"14","kaito_type":"1","kaito":"特になし"}]	2018-12-19 15:40:15.872127+07
48	840	4	技法の勉強を身近なたとえでケーススタディが出来るので、若手にお勧めです。	[{"anketto_no":"1","kaito_type":"1","kaito":"問題への取り組み方・考え方を具体的に学ぶことが出来た。"},{"anketto_no":"2","kaito_type":"1","kaito":"講師のたとえ話が多くてまとまっていない部分が多かった。"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"5","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"6","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"7","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"だいたい理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"その他"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社4～6年目"},{"anketto_no":"14","kaito_type":"1","kaito":"SE PJの内容ではなく、一般的な内容でのケーススタディーだったため親しみやすかった。"}]	2018-12-19 16:14:14.859936+07
49	838	4	専門用語がかなり多いが、プロジェクトゲームで実際にやることで理解度は深まった。\n今回はプロジェクトマネージャの立場だけであったが、プロダクトオーナ、スクラムマスター、開発メンバで役割を振ってロールプレイング形式で開発を進めるプロジェクトゲームもあると良いと思った。\n	[{"anketto_no":"1","kaito_type":"1","kaito":"アジャイル開発について基礎的な知識が習得できた。前提の研修もあるが、当研修でアジャイル開発については一通り理解できる。"},{"anketto_no":"2","kaito_type":"1","kaito":"プロジェクトゲーム以外のディスカッション部分については議題が少し薄い気がした。意見の共有についてはそこまで時間取らなくても良いと感じた。"},{"anketto_no":"3","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"講義が間延びしていた"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社4～6年目"},{"anketto_no":"14","kaito_type":"1","kaito":"何でもアジャイルを適用すればよいということでは無く、仕様が固まっていない顧客に対しての1つのアプローチであるということが分かった。"}]	2018-12-20 14:53:13.558521+07
50	844	4	演習には、実際の開発現場での品質分析や評価に使える技術もあり、自身が全般的に習得したいと考えているスキルであると同時に実務にも繋がる内容だったと感じています。\n	[{"anketto_no":"1","kaito_type":"1","kaito":"以下のような内容について、具体的な演習を多くこなしながら学ぶことが出来てよかった。\\n・問題解決、分析、ファシリテーションについての一般的な手法のバリエーションや用語知識\\n・問題の整理の手法\\n・問題点をあぶりだす整理法\\n・ピラミッド構造図を使った分析\\n・解決案作成のコツ\\n・解決案の評価"},{"anketto_no":"2","kaito_type":"1","kaito":"・特に期待外れということはなかった"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"適切な時間配分だった"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社7年目以上"},{"anketto_no":"14","kaito_type":"1","kaito":"・慶応義塾大学ビジネススクールのケーススタディ教材を使用した演習もあり、ボリュームの多い内容だったが、無理をして詰め込んでいる感はなかった。\\n・演習はチームでのディスカッション、発表が主のため、ディスカッションの進行、板書、意見整理、チーム発表のスキルなども同時に磨く機会となった。\\n・対象年次は、４、５年目以上でも問題ないのではないかとも思いますが、適切なものが無かったため「７年目以上」にしました。"}]	2018-12-21 21:49:23.200791+07
51	843	4	講師の説明も非常に丁寧で、問題解決に限らず物事を整理するには、どのように情報を集め、分析してまとめるかが分かりやすく理解できる抗議だと感じた。	[{"anketto_no":"1","kaito_type":"1","kaito":"課題を整理する方法や、課題に対する解決策をどう導き出すかというプロセスを、具体的な事案を交えて分かりやすく説明してもらえた"},{"anketto_no":"2","kaito_type":"1","kaito":"特になし"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"適切な時間配分だった"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"誰でも可（年次関係なし）"},{"anketto_no":"14","kaito_type":"1","kaito":"特になし"}]	2018-12-25 12:56:27.441201+07
52	1226	4	Azureのサービスをいくつか触ることができたので、サービスの理解が深まりました。	[{"anketto_no":"1","kaito_type":"1","kaito":"Azureの概要や主なサービスに加え、AWSと同じようなサービスがあった場合、それぞれのサービスの違いやメリットの説明もあった。"},{"anketto_no":"2","kaito_type":"1","kaito":"主なサービスに絞っていたためか、多くのサービス、組み合わせの説明は薄かった。"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"6","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"7","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"8","kaito_type":"2","kaito":"ややよい"},{"anketto_no":"9","kaito_type":"2","kaito":"だいたい理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"特に問題なし"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社2～3年目"},{"anketto_no":"14","kaito_type":"1","kaito":"ある程度システム全体（クライアントサーバー型やWeb系など）の知識がある人の受講が望ましいと思いました。"}]	2019-02-19 19:18:23.353836+07
53	1227	2	メンバとしても知識として入れておく分にはいいと思うが、内容の割に費用は高いと感じる。当テキストにある、章ごとの内容に深堀した研修の方が受講する価値があるのかと思う。	[{"anketto_no":"1","kaito_type":"1","kaito":"プロジェクトマネジメントの技法として、どういったものがあるのか知ることができた。"},{"anketto_no":"2","kaito_type":"1","kaito":"技法１つ１つの事例が少なかったため、用いた場合の効果がどの程度のものなのか掴めなかった。すぐに業務で利用できる内容はなかった。"},{"anketto_no":"3","kaito_type":"2","kaito":"やや悪い"},{"anketto_no":"4","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"5","kaito_type":"2","kaito":"悪い"},{"anketto_no":"6","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"7","kaito_type":"2","kaito":"asdas"},{"anketto_no":"8","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"9","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"10","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"講義が間延びしていた"},{"anketto_no":"12","kaito_type":"2","kaito":"内容の割には高く感じる"},{"anketto_no":"13","kaito_type":"2","kaito":"入社4～6年目"},{"anketto_no":"14","kaito_type":"1","kaito":"プロジェクトリーダーとして、業務を行う前であったら、よりためになったと感じる。"}]	2019-02-27 11:59:20.98836+07
54	1223	4	説明が丁寧で分かりやすかった。\nまた、講義と演習の時間配分が適切だった	[{"anketto_no":"1","kaito_type":"1","kaito":"JDBCやJAVAAPIの役割の違いを理解することができた。\\nまた、JAVAを使ったデータベースへのアクセス方法を理解し、\\n実際にソースを書く経験を積むことができた"},{"anketto_no":"2","kaito_type":"1","kaito":"特にありません。"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"よい"},{"anketto_no":"7","kaito_type":"2","kaito":"よい"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"適切な時間配分だった"},{"anketto_no":"12","kaito_type":"2","kaito":"内容の割には高く感じる"},{"anketto_no":"13","kaito_type":"2","kaito":"誰でも可（年次関係なし）"},{"anketto_no":"14","kaito_type":"1","kaito":"実際に自宅でデータベースをインストールして試そうと思う。"}]	2019-03-15 08:13:19.568961+07
55	682	4	特になし	[{"anketto_no":"1","kaito_type":"1","kaito":"戦略があり、目的、ビジョンがある流れが理解できた。"},{"anketto_no":"2","kaito_type":"1","kaito":"他社（自動車、バッグ製造、千葉のIT運用会社）の方と同じチームとなり、多くユーザ側の立場や考え方が共有でき役になった。"},{"anketto_no":"3","kaito_type":"2","kaito":"よい"},{"anketto_no":"4","kaito_type":"2","kaito":"よい"},{"anketto_no":"5","kaito_type":"2","kaito":"よい"},{"anketto_no":"6","kaito_type":"2","kaito":"よい"},{"anketto_no":"7","kaito_type":"2","kaito":"よい"},{"anketto_no":"8","kaito_type":"2","kaito":"よい"},{"anketto_no":"9","kaito_type":"2","kaito":"理解できた"},{"anketto_no":"10","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"11","kaito_type":"2","kaito":"適切な時間配分だった"},{"anketto_no":"12","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"13","kaito_type":"2","kaito":"入社7年目以上"},{"anketto_no":"14","kaito_type":"1","kaito":"特になし"}]	2019-04-17 14:49:54.505913+07
56	837	3	おおむね内容は満足しているが、デメリットを理解した上で適用有無を判断したかったので1歩踏み込んだ内容があるともっとうれしかった。	[{"anketto_no":"1","kaito_type":"1","kaito":"現場の情報をふまえた適用方法を知ることができた"},{"anketto_no":"2","kaito_type":"1","kaito":"アジャイルを適用してのデメリット・メリットがもう1歩踏み込んだ情報がほしかった"},{"anketto_no":"3","kaito_type":"2","kaito":"概ね満足"},{"anketto_no":"4","kaito_type":"2","kaito":"概ね満足"},{"anketto_no":"5","kaito_type":"2","kaito":"だいたい理解できた"},{"anketto_no":"6","kaito_type":"2","kaito":"所々ためになった"},{"anketto_no":"7","kaito_type":"2","kaito":"内容の割には高く感じる"},{"anketto_no":"8","kaito_type":"2","kaito":"入社4～6年目"}]	2019-07-16 22:13:58.706729+07
57	1830	5	dddd	[{"anketto_no":"1","kaito_type":"1","kaito":"abcdefg"},{"anketto_no":"2","kaito_type":"1","kaito":"abcdefg"},{"anketto_no":"3","kaito_type":"2","kaito":"可もなく不可もなく"},{"anketto_no":"4","kaito_type":"2","kaito":"可もなく不可もなく"},{"anketto_no":"5","kaito_type":"2","kaito":"どちらともいえない"},{"anketto_no":"6","kaito_type":"2","kaito":"自分には早すぎた（難しかった）"},{"anketto_no":"7","kaito_type":"2","kaito":"内容の割には高く感じる"},{"anketto_no":"8","kaito_type":"2","kaito":"入社4～6年目"}]	2019-10-29 09:25:57.27537+07
58	1847	4	good	[{"anketto_no":"1","kaito_type":"1","kaito":"abdv"},{"anketto_no":"2","kaito_type":"1","kaito":"abc"},{"anketto_no":"3","kaito_type":"2","kaito":"非常に満足"},{"anketto_no":"4","kaito_type":"2","kaito":"可もなく不可もなく"},{"anketto_no":"5","kaito_type":"2","kaito":"あまり理解できなかった"},{"anketto_no":"6","kaito_type":"2","kaito":"自分には早すぎた（難しかった）"},{"anketto_no":"7","kaito_type":"2","kaito":"自分には判断できない"},{"anketto_no":"8","kaito_type":"2","kaito":"入社4～6年目"}]	2019-10-29 10:39:18.971455+07
59	1848	3	well	[{"anketto_no":"1","kaito_type":"1","kaito":"a"},{"anketto_no":"2","kaito_type":"1","kaito":"a"},{"anketto_no":"3","kaito_type":"2","kaito":"概ね満足"},{"anketto_no":"4","kaito_type":"2","kaito":"可もなく不可もなく"},{"anketto_no":"5","kaito_type":"2","kaito":"あまり理解できなかった"},{"anketto_no":"6","kaito_type":"2","kaito":"あまりよくなかった"},{"anketto_no":"7","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"8","kaito_type":"2","kaito":"誰でも可（年次関係なし）"}]	2019-10-29 10:40:36.343434+07
60	1849	2	not good	[{"anketto_no":"1","kaito_type":"1","kaito":"s"},{"anketto_no":"2","kaito_type":"1","kaito":"c"},{"anketto_no":"3","kaito_type":"2","kaito":"非常に満足"},{"anketto_no":"4","kaito_type":"2","kaito":"やや不満足"},{"anketto_no":"5","kaito_type":"2","kaito":"だいたい理解できた"},{"anketto_no":"6","kaito_type":"2","kaito":"自分には早すぎた（難しかった）"},{"anketto_no":"7","kaito_type":"2","kaito":"払う価値なし"},{"anketto_no":"8","kaito_type":"2","kaito":"入社2～3年目"}]	2019-10-29 10:42:27.326628+07
61	1850	1	bad	[{"anketto_no":"1","kaito_type":"1","kaito":"gbf"},{"anketto_no":"2","kaito_type":"1","kaito":"fhf"},{"anketto_no":"3","kaito_type":"2","kaito":"非常に不満足"},{"anketto_no":"4","kaito_type":"2","kaito":"概ね満足"},{"anketto_no":"5","kaito_type":"2","kaito":"だいたい理解できた"},{"anketto_no":"6","kaito_type":"2","kaito":"あまりよくなかった"},{"anketto_no":"7","kaito_type":"2","kaito":"払う価値なし"},{"anketto_no":"8","kaito_type":"2","kaito":"新入社員"}]	2019-10-29 10:44:51.906142+07
62	1861	1	so bad	[{"anketto_no":"1","kaito_type":"1","kaito":"cx"},{"anketto_no":"2","kaito_type":"1","kaito":"scda"},{"anketto_no":"3","kaito_type":"2","kaito":"概ね満足"},{"anketto_no":"4","kaito_type":"2","kaito":"可もなく不可もなく"},{"anketto_no":"5","kaito_type":"2","kaito":"あまり理解できなかった"},{"anketto_no":"6","kaito_type":"2","kaito":"非常にためになった"},{"anketto_no":"7","kaito_type":"2","kaito":"質・量ともに妥当な値段"},{"anketto_no":"8","kaito_type":"2","kaito":"新入社員"}]	2019-10-29 11:08:13.700692+07
\.


--
-- Data for Name: tbl_kensyuu_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_kensyuu_master (kensyuu_id, kensyuu_mei, kensyuu_category, skill_mg_flag, skill_hm_flag, skill_tc_flag, skill_oa_flag, kensyuu_gaiyou, taishosha_level, jyukouryou, shukankikan, bikou, anketto_id, tema_category, taishosha, flag, tags, sub_level, advance_level, tags_father) FROM stdin;
49651	Ky thuat moi danh cho moi nguoi	社内	0	0	1	0	Ky thuat AI nhan dien khuon mat, cu chi, hanh dong ma khong can co giong noi	J1	\N	技術戦略室	khong co ghi chu gi dac biet	\N	Nhung nguoi yeu thich ky thuat moi tren the gioi, co the tham gia va hoc hoi kien thuc o day	レベル1	1	{8,7}	null	null	{5}
48504	ＰＭ７つ道具使用手順	社内	1	0	0	0	ＰＭ７つ道具の使用手順説明および演習を通して、正しいツールの使用方法を学ぶことで、ゾーン分析やＰ－Ｂ曲線など、ＰＭ7つ道具ツールを使用できるようになります。\r\n募集人数が5名以上集まった時点で、開催日時を参加希望者と調整し て実施します。	全社員	\N	品質推進部		\N	もくもくワークショップ	レベル1～2	0	\N			\N
46606	ブロックチェーン大学校  BLOCK3 ブロックチェーン大学校 ブロックチェーン ブロンズ	社外	0	0	1	0	ブロックチェーンエンジニアの啓発・育成を目的とした体系的ブロックチェーン教育カリキュラム。\r\n（ご参考：http://bccc.global/blockchainuniversity）	JP-A以上	64800	一般社団法人 ブロックチェーン推進協会\r\n（社内事務局：技術戦略室）	・当社割引を適用するために、技術戦略室経由で申込を行ってください。\r\n・基本的に、平日19:00～21:00に開催（2h × 全8回）。\r\n・毎週課題有り／最終日テスト有り	－	オープン研修	レベル2～3	1	\N	\N	\N	\N
47210	データベース入門 (DB0037CG)	社外	0	0	1	0	データベースについて基礎から学習できるため、データベースをこれから学習する方には最適な研修。データベースを操作するSQL言語だけではなく、データベースが持っている基本的な機能に関して理解する。\r\n\r\n※初心者向けの内容。新人研修後の復習としてか、未経験の中途採用者向け。	J2～J1	58320.00000000001	トレノケート（株）	・当社価格は定価の10%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
48609	AWS管理者研修	社内	0	0	1	0	AWS管理者の必須研修です。ＡＷＳ管理者が習得しておくべき権限の操作方法とネットワークの作成方法をまとめています。	ＪＰ	\N	人材戦略室	\N	ー	浦出塾	レベル2～3	0	\N	\N	\N	\N
48102	新人研修／技術トレーニング	社内	0	1	1	0	エンジニアとしての土台形成を目的とする。すべてのITエンジニアにとって必要な基礎知識を身に着ける。基本用語理解（基本情報処理試験対策等）、IT業界・当社事業理解、SE業務全体像の理解、プログラミング入門、DB基礎（SQL実践）他。	第48期新卒入社者	\N	人材戦略室	受講必須	－	階層別研修	－	0	\N	\N	\N	\N
48103	新人フォローアップ研修	社内	1	1	0	0	新人研修で学んだことについて、習得度合いの確認と復習を行う。また同期同士で半年間の経験や悩みを共有し、新たな気持ちで明日からの業務に前向きに取り組む意識を持つことを目的とする。\r\n基本行動トレーニング（外部講師）、セキュリティ研修、ビジネスライン分析他。	第48期新卒入社者	\N	人材戦略室	受講必須	－	階層別研修	－	0	\N	\N	\N	\N
48104	入社3年目研修	社内	1	1	0	0	今後求められる役割の変化を認識し、そのために必要な自己理解と、今後求められる役割理解を目的とする。\r\n2年半の業務経験を棚卸しを行い、改めて自分の強み・弱みと、組織から求められる役割を照らし合わせることで自己理解を深める。また、担当者からプロジェクトやチームの責任者へと変わっていく過程において、組織ミッションを担う存在としての自律を促し、今後のビジョンを描く。	第46期新卒入社者	\N	人材戦略室	受講必須	－	階層別研修	－	0	\N	\N	\N	\N
48105	OJTトレーナー研修	社内	1	1	0	0	OJTトレーナーの役割や意義を通じて、人の成長支援が自らの大きな成長につながることを理解し、モチベーションの向上に繋げる。また指導方法やコミュニケーションスキル等を学ぶことで、トレーニーとの信頼関係を構築する知識を習得する。	OJTトレーナー	\N	人材戦略室	受講必須。\r\nただし直近３年以内に同研修を受講された方は欠席可とする。	－	特定対象層向け研修	－	0	\N	\N	\N	\N
48106	キャリア研修（30代向け）	社内	0	1	0	0	入社から約10年が経過し、求められる役割が変わっていく節目を迎えた中堅社員を対象とする。周囲の客観的視点も踏まえながら自分自身のこれまでと強み・弱みについて棚卸しした上で、会社組織の方向性と自身のベクトルを共有し、今後のキャリアの方向性を考える。	30代社員	\N	人材戦略室	受講必須。\r\n業務等で今年度受講不可の方は次年度の受講必須となる。	－	キャリア研修	－	0	\N	\N	\N	\N
48107	キャリア研修（40代向け）	社内	0	1	0	0	職業キャリアの中間地点を迎えたことを認識し、キャリア前半の振り返りによる自己の強み・弱みの棚卸しを行う。また自身を取り巻く環境（家族・価値観・業界・ライフイベント等）の状況変化を確認し、キャリア後半に向けたビジョンを構築する。仕事に関する能力開発をどう進めるかを計画し、次の飛躍・発展の契機にしていく。	40代社員	\N	人材戦略室	受講必須。\r\n業務等で今年度受講不可の方は次年度の受講必須となる。	－	キャリア研修	－	0	\N	\N	\N	\N
48108	新任JP-B研修（1回目）	社内	0	0	0	1	新任JP-Bとして必要な管理スキル習得と、社内ルール／法律の基本的な知識の習得を目的とする。発注業務研修／人事制度・労務管理基礎／PJ計画書作成研修等。	第49期新任JP-B	\N	人材戦略室	次年度JP-B昇格を目指す人で、同研修を未受講の方は、受講必須。	－	特定対象層向け研修	－	1	\N	\N	\N	\N
48109	新任管理職向け　コンプライアンス研修（外部）	社外	0	0	0	1	新任管理職の受講必須教育。\r\n\r\nコンプライアンスという言葉の定義を踏まえた上で、管理職としてコンプライアンスとどのように付き合うべきかを多角的に解説する。また、具体的なコンプライアンス問題を題材に、どのような点が問題でどのように対処すべきかを解説する。	第48期新任管理職\r\n・新任マネージャ	\N	（株）プロネクサス	対象者は事務局が一括申込みします。	－	特定対象層向け研修	－	0	\N	\N	\N	\N
48110	新任管理職研修	社内	0	0	0	1	新任管理職として必要な管理スキル習得と、社内ルール／法律の基本的な知識の習得を目的とする。組織管理職とは／収益認識／労務管理／人事制度・目標設定・評価について等。	第49期新任管理職\r\n・新任マネージャ	\N	人材戦略室	次年度、新任管理職(マネージャ)の内示が出た方は、受講必須。	－	特定対象層向け研修	－	0	\N	\N	\N	\N
48112	中途社員研修	社内	1	1	0	0	マネジメントゲームを通じて経営者の視点を持つ、また損益感覚を養う。また中途入社者間で共に学び、切磋琢磨することで、社員の横の繋がりを築くことを目的とする。	中途入社者	\N	人材戦略室	2018.11～2019.10 の期間中に入社した中途入社社員は受講必須。業務等で今年度受講不可の方は、次年度の受講必須となる。	－	特定対象層向け研修	－	0	\N	\N	\N	\N
48113	LS研究委員会	社内	1	1	1	0	経営戦略・先端的なテーマ・人材教育等を中心に共同で調査・研究すると共に、創造力あふれ個性豊かな人材を育成し、会員企業の業務改革に貢献するための研究会。特に研究分科会は、「先進的ICT適用」や「情報システム部門が抱える課題解決」等について、問題意識を持ったメンバーが集まり、Give&Takeの精神で共同研究し、 成果を創出する活動。1年間の研究活動を通じ、今後の情報システム部門を担う人材の育成も目的としている。	LS研究委員会	\N	人材戦略室	開催場所は参加企業での持ち回りとなる。\r\n活動期間は4月～翌年5月。活動日は毎月1回。FUJITSUファミリ会の会員であるユーザ企業同士で集まって活動を行う。	－	特定対象層向け研修	レベル3～	0	\N	\N	\N	\N
48116	ソフトウェア技術者のための論理思考の文書技術	社内	0	1	1	0	ITエンジニアであっても、高い文章作成能力は必要である。相手に正確に伝わる文書を作成できていないことによって、様々なトラブルが発生している。本講座では、Word や PowerPoint を活用し、情報と思考を論理的に整理して、相手に正確に伝わる文書を、早く作成する方法を学習する。	入社1～2年目	\N	人材戦略室	参加者は、部室長の推薦(承認)が必須。	－	部室長推薦研修	レベル2	1	\N	\N	\N	\N
48117	テスト品質管理 【基礎】	社内	0	0	1	0	開発メンバーとしてリーダの指示／テスト計画に基づいてテストを実施し、報告する立場を想定し、テスト品質の意味を理解した上で、しっかりテストし、きちんと結果を残すためにどうすればよいのかを学習する。\r\n※テスト工程の実務経験がある程度あった方が、理解促進に繋がる傾向あり。	入社2～3年目	\N	人材戦略室	参加者は、部室長の推薦(承認)が必須。	－	部室長推薦研修	レベル2	1	\N	\N	\N	\N
48118	テスト品質管理 【実践】	社内	1	0	1	0	テスト品質を評価・管理する立場、および、評価を自分の言葉で報告する立場を想定し、しっかりテストしてもらい、しっかりテストOKを出すためにどうすれば良いのか、テストの意味／品質へのこだわりを考える。テスト品質の意味を理解し、その評価を自分の言葉で報告できることを目的とする。	入社5～6年目	\N	人材戦略室	参加者は、部室長の推薦(承認)が必須。	－	部室長推薦研修	レベル2～3	1	\N	\N	\N	\N
48201	Excel VBA　による部門業務システムの構築（UUL79L）	社外	0	0	1	0	Excel VBA を使用して部門内の業務システムを構築するときに必要な開発手順、開発技術を、説明および実習を通して学習します。また、部門内で使用する業務システムとして、使いやすさやメンテナンスのしやすさを意識した実装パターンを紹介します。	J2～J1	\N	（株）富士通ラーニングメディア	・当社価格は定価の25%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
48202	プロジェクトマネジメントの技法 (UAQ41L) 	社外	0	0	1	0	プロジェクトを円滑に進めるために必要な各種マネジメント手法や技法の中で、特に重要な「プロジェクト選定」「WBS作成」「スケジュール作成」「コスト見積もり」「EVM」「品質管理」「チーム育成」「リスクマネジメント」などについて学習します。また、理論だけでなく、プロジェクトマネジメントの手法や技法を体得していただくために、計算問題も含め7種類の演習を行います。\r\n〔PDU対象コース：14PDU〕	J2～J1	\N	（株）富士通ラーニングメディア	・当社価格は定価の25%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
48203	プロジェクト実行管理（PM-003）	社外	0	0	1	0	ITプロジェクトにおける実行管理の基礎を学習する。ある架空のプロジェクトで生じるストーリーを題材に、実行管理において気をつけるべきポイント、押さえるべきポイント等を、グループでのディスカッションを通じて学習する。プロジェクトを取り囲むステークホルダーとの調整やコミュニケーションを図るための基礎的なスキルを学習する。\r\n\r\n※NRI 階層別研修と同一カリキュラム。これまでの受講者からの評価は総じて高い。	M4～M3	\N	（株）ナレッジトラスト	・当社価格は定価の35%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
48204	プロジェクト計画における見積技法（IS-003）	社外	0	0	1	0	複雑な見積技法をわかりやすく解説する。システム開発で用いられる様々の見積技法と、見積結果をプロジェクト計画に反映させる方法を体系的に学習する。演習については流通系のケーススタディによる疑似体験を行う。（見積～プロジェクト計画立案）\r\n※一般的に提唱される見積技法と算出方法について、講義＋ケース演習両面から実際に手を動かして学ぶことができるため、これまでの受講者からの評価は高い。見積もり技法をきちんと実践的に学びたい人向けのカリキュラム。	M3～	\N	（株）ナレッジトラスト	・当社価格は定価の35%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
48205	アジャイル開発手法によるシステム開発(UBS99L)	社外	0	0	1	0	スクラムをベースとしたアジャイル開発の進め方（スプリント計画ミーティング、開発作業、スプリントレビューミーティング、スプリント振返りなど）について演習を通して学習します。演習では、アジャイル開発手法（スクラム）の作業内容に基づき、システム開発プロジェクトを疑似体験します。	J1～	\N	（株）富士通ラーニングメディア	・当社価格は定価の25%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
48206	 SEに求められるヒアリングスキル～効果的な顧客要件の聞き取り～(UZE66L)	社外	0	0	1	0	システム構築プロジェクトにおいて、SEに求められるヒアリングスキルを、講義と演習を通して学習します。ヒアリングの準備、実施、フォローのシーンにおいて、顧客要件を引き出すためのスキル、顧客要件の整理、および顧客との調整を円滑にするためのスキルを修得します。演習では、業務要件定義のロールプレーイングなどにより実践力を高めます。\r\n[PDU対象コース：14PDU]	M4～M3	\N	（株）富士通ラーニングメディア	・当社価格は定価の25%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
48207	Pythonプログラミング1 基本文法編（PRC0103G）	社外	0	0	1	0	Pythonの基本文法や簡単なアプリケーション実装のための必須知識を習得できるコースです。Pythonの言語の特徴から環境設定、基礎文法など、Pythonによるアプリケーション開発のために必要な基礎知識を身につける事ができます。ただし、オブジェクト指向についてはこのコースでは触れません。\r\n講義と実習のサイクルを繰り返し、Pythonを体験しながら習得する事が可能です。また基本構文や変数についても扱いますので、プログラミング初心者の方でもスクリプトの書き方をしっかり学ぶことができます。	J2～	\N	トレノケート（株）	・当社価格は定価の10%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
48208	Javaデータベースプログラミング (JAC0083G)	社外	0	0	1	0	リレーショナルデータベースにアクセスする JDBC を用いた Java アプリケーションの作成方法について紹介する。また、POJO、DAOパターンを用いた実践的な開発手法も紹介する。\r\n※基本的なSQLステートメント（SELECT、INSERT、UPDATE、DELETE）によるデータ操作ができる方、リレーショナルデータベースに関する基本的な用語（テーブル、主キー、外部キー、列、行、カーソル）を理解している方向けの研修。	J2～J1	\N	トレノケート（株）	・当社価格は定価の10%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
46104	入社3年目研修	社内	1	1	0	0	今後求められる役割の変化を認識し、そのために必要な自己理解と、今後求められる役割理解を目的とする。\r\n2年半の業務経験を棚卸しを行い、改めて自分の強み・弱みと、組織から求められる役割を照らし合わせることで自己理解を深める。また、担当者からプロジェクトやチームの責任者へと変わっていく過程において、組織ミッションを担う存在としての自律を促し、今後のビジョンを描く。	第44期新卒入社者	\N	人材開発室	受講必須	－	階層別研修	－	0	\N	\N	\N	\N
46105	OJTトレーナー研修	社内	1	1	0	0	OJTトレーナーの役割や意義を通じて、人の成長支援が自らの大きな成長につながることを理解し、モチベーションの向上に繋げる。また指導方法やコミュニケーションスキル等を学ぶことで、トレーニーとの信頼関係を構築する知識を習得する。	OJTトレーナー	\N	人材開発室	受講必須。\r\nただし直近５年以内に同研修を受講された方は欠席可とする。	－	特定対象層向け研修	－	0	\N	\N	\N	\N
46106	新任JP-B研修	社内	0	0	0	1	新任JP-Bとして必要な管理スキル習得と、社内ルール／法律の基本的な知識の習得を目的とする。発注業務研修／人事制度・労務管理基礎／PJ計画書作成研修等。	第46期新任JP-B	\N	人材開発室	46期にJP-Bに着任した方が受講必須の研修。	－	階層別研修	－	1	\N	\N	\N	\N
46107	新任JP-B研修	社内	0	0	0	1	新任JP-Bとして必要な管理スキル習得と、社内ルール／法律の基本的な知識の習得を目的とする。発注業務研修／人事制度・労務管理基礎／PJ計画書作成研修等。	第47期新任JP-B	\N	人材開発室	次年度JP-B昇格を目指す人で、同研修を未受講の方は、受講必須。	－	階層別研修	－	1	\N	\N	\N	\N
46108	新任管理職研修	社内	0	0	0	1	新任管理職（新任マネージャ／新任部長代理）としての期待役割、必要な基本的知識の習得を目的とする。業務標準、収益認識、人事制度及び労務管理の基礎知識の確認、管理監督者としての責務・期待役割等。確認テストにより適切な知識を有しているか否かの判定を行う場合がある。	第47期新任管理職\r\n・新任マネージャ\r\n・新任部長代理	\N	人材開発室	次年度、新任マネージャまたは新任部長代理となる方は受講必須。	－	階層別研修	－	0	\N	\N	\N	\N
46109	マネージャ研修	社内	0	0	0	1	当社マネージャとしての期待役割、必要な基本的知識の習得を目的とする。また、時流に応じた強化テーマの知識習得／検討課題の抽出・ディスカッション等を実施する場合がある。	マネージャ	\N	人材開発室	マネージャ（部長代理）は受講必須。\r\nなおマネージャ／部門長を含めて「幹部研修」として開催する場合もある。	－	階層別研修	－	0	\N	\N	\N	\N
46110	幹部研修	社内	0	0	0	1	当社幹部社員としての期待役割、必要な基本的知識の習得を目的とする。また、時流に応じた強化テーマの知識習得／検討課題の抽出・ディスカッション等を実施する場合がある。	部門長以上	\N	人材開発室	部門長以上は受講必須。\r\nなおマネージャ／部門長を含めて「幹部研修」として開催する場合もある。	－	階層別研修	－	0	\N	\N	\N	\N
46111	中途社員研修	社内	1	1	0	0	マネジメントゲームを通じて経営者の視点を持つ、また損益感覚を養う。また中途入社者間で共に学び、切磋琢磨することで、社員の横の繋がりを築くことを目的とする。	中途入社者	\N	人材開発室	2016.11～2017.10 の期間中に入社した中途入社社員は受講必須。業務等で今年度受講不可の方は、次年度の受講必須となる。	－	特定対象層向け研修	－	0	\N	\N	\N	\N
46112	コンプライアンス研修	社内	0	1	0	0	コンプライアンスの重要性を再認識することを目的とする。\r\n社内のコンプライアンス意識を高め、キューブシステムの一員としての責務を自覚し、より高いレベルにおける社会的責任を果たしていくことを目指す。	全社員	\N	コンプライアンス委員会	受講必須。\r\n別途コンプライアンス委員会より案内される予定。	－	全社必須研修	－	0	\N	\N	\N	\N
48209	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G)	社外	0	0	1	0	ストリーム（ファイル入出力）、コレクション、マルチスレッドといったJavaの開発において使用頻度の高いAPIの使い方を学習します。また、これらを使用する上での前提となる機能を紹介します。\r\n「Javaによるオブジェクト指向プログラミング」を受講しているか、同等の知識を持つことが前提条件。	J2～	\N	トレノケート（株）	・当社価格は定価の10%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
48210	 サーブレット＆JSPプログラミング(JAC0084G)	社外	0	0	1	0	JavaでWebアプリケーションを構築するために必要なサーブレットとJSPを講義と演習を通して学習します。それぞれの基本事項を学習した後、典型的な設計パターンを用いてサーブレットとJSPを連携させたWebアプリケーションの実装方法を学習することでWebアプリケーションの全体像を把握することができます。\r\n前提条件は以下の通り。\r\n□Javaの基本文法を修得している\r\n□コレクションAPI（ArrayList, HashMapなど）の利用方法を修得している\r\n□簡単なHTMLページ（FORMを含む）を判読し、理解できる\r\n□JDBC APIを用いてデータベースアクセスを行う方法を修得していることが望ましい	J2～	\N	トレノケート（株）	・当社価格は定価の10%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
49101	Kiến thức cơ bản	社内	1	0	0	0	Training các kiến thức cơ bản khi mới vào công ty. 	第49期新任JP-B	\N	人材戦略室	Bắt buộc tham gia	－	階層別研修	－	0	\N	\N	\N	\N
49102	Hướng dẫn công việc	社外	0	1	0	0	Hướng dẫn cách thức thực hiện công việc.	第49期新任管理職 ・新任マネージャ	\N	人材戦略室	Bắt buộc tham gia	－	キャリア研修	－	0	\N	\N	\N	\N
49103	Huấn luyện kỹ năng OJT	社内	0	0	1	0	Nâng cao kỹ năng OJT	OJTトレーナー	\N	人材戦略室	Phải đăng ký trước	001	特定対象層向け研修	－	1	\N	\N	\N	\N
49111	Giới thiệu công ty	社外	0	0	0	1	Giới thiệu tổng quan về công ty	J1	\N	人材戦略室	Bắt buộc tham gia	－	－	レベル1	0	\N	\N	\N	\N
49205	Chia sẻ kinh nghiệm làm việc	社内	1	1	0	0	Chia sẻ kinh nghiệm về môi trường, đồng nghiệp,…	30代社員	\N	人材戦略室	Phải trên 30 tuổi	002	オープン研修	レベル2～3	1	\N	\N	\N	\N
49501	Cách tạo thiết kế của các project	社内	0	1	1	0	Hiểu được luồng thiết kế	全社員	\N	品質推進部	\N	003	もくもくワークショップ	レベル2～3	0	\N	\N	\N	\N
48211	Node.js + Express + MongoDB ～JavaScript によるｻｰﾊﾞｰｻｲﾄﾞWebｱﾌﾟﾘｹｰｼｮﾝ開発 (WSC0065R)	社外	0	0	1	0	サーバーサイド JavaScript の実行環境として注目されている Node.js と、Node.js 上で動作する Webアプリケーション・フレームワークとして広く利用されている Express を用いて、データベースアクセスを伴うWebアプリケーションの開発方法を演習を交えて学習する。なお、DBアクセスについては、JavaScript アプリケーションと親和性の高い MongoDB に加え、実績のある SQLデータベースについても扱う。\r\nまた、開発環境の構築方法や、JavaScript Webアプリケーションのテスト方法など、開発プロセスに関する内容についても紹介する。	J1～M4	\N	トレノケート（株）	・本研修の当社価格は定価	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
48212	Microsoft Azure入門 (UCV42L) 	社外	0	0	1	0	Microsoft Azure の概要や特徴、コンピューティングやデータ管理機能などの主な構成要素、Azure の関連サービスや Azure の代表的な利用シナリオについて学習する。	J2～J1	\N	（株）富士通ラーニングメディア	・当社価格は定価の25%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
48213	Microsoft Azure Web Apps と SQL Database によるアプリ開発入門 ～Visual Studio によるクラウド アプリケーション開発～(MSC0538G)	社外	0	0	1	0	Microsoft Azure による Web アプリケーション ホスティング機能の選択肢の中で、最も手軽に利用出来る「Web アプリ」の開発手法概要を学習したい方にお勧め。\r\nMicrosoft Azure上でアプリケーションを展開するための方法について学びます。本研修の演習では、Azure管理ポータルと呼ばれるWebサイトの管理機能は極力使用せずに、Visual Studioの Azure連携機能をフルに活用してWebアプリケーションを開発し、クラウドアプリケーションとして公開します。	J2～	\N	トレノケート（株）	・当社価格は定価の10%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
48214	 Microsoft Azure による LAMP 環境のホスティング ～Azure 新ポータル対応～(MSC0611G)	社外	0	0	1	0	Microsoft Azure上に LAMP ベースの仮想サーバーを構築したい方にお勧め。\r\nハンズオンを通じて、LAMP スタック ベースの Web システムを段階的にスケール アウトしながら、Microsoft Azure の主要サービスである Azure Virtual Machines、Azure BLOB ストレージ 、Azure MySQL、Azure Load Balancer の基本機能を学習します。\r\n前提条件は以下の通り。\r\n□クラウドに関する知識、および Azure の特徴やメリットについての知識をお持ちの方(必須)\r\n□Linux OSまたは、UNIX OSの導入,管理経験(推奨)\r\n□リレーショナルデータベース管理システム(RDBMS)の知識(推奨)\r\n□Webシステム構築・運用経験または知識(推奨)	J2～	\N	トレノケート（株）	・当社価格は定価の10%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
48215	 Microsoft AzureによるITインフラの拡張 ～基本から学ぶサーバー構築～(MSC0517V)	社外	0	0	1	0	Microsoft Azureで仮想マシンを構成する方にお勧め。\r\n当初PaaSとしてスタートしたMicrosoft Azureは、2014年からIaaS機能を備え、仮想マシンを簡単に作れるようになりました。本コースでは、Microsoft Azure上に仮想化マシンを構成する手順について学習し、仮想ネットワークや冗長化を構成します。なお、Express Routeについては概念のみ紹介します。	J2～	\N	トレノケート（株）	・当社価格は定価の10%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
49604	Docker và Dev/Ops	社外	0	0	1	1	Hiểu được kiến thức cơ bản của docker	J1～M3	\N	技術戦略室	Đăng ký trước	004	浦出塾	レベル1～2	0	{}			{}
48216	UNIX／Linux入門（UMI11L）	社外	0	0	1	0	UNIXおよびLinuxシステムの概要、基本的な使用方法（基本コマンド、ファイル操作、ネットワークコマンド、シェルの利用法など）を学習する。	J2～J1	\N	（株）富士通ラーニングメディア	・当社価格は定価の25%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
46113	情報セキュリティ研修	社内	0	1	0	0	実際に発生した事象をケーススタディ等を用いて振り返ることで、より一歩先を行くセキュリティ意識を持つことを目的とする。情報セキュリティに対する取り組みと成果、企業の情報セキュリティ対策、５つの行動原則について他。	全社員	\N	セキュリティ推進委員会	受講必須。\r\n別途セキュリティ推進委員会より案内される予定。	－	全社必須研修	－	0	\N	\N	\N	\N
46114	ビジョナリー・ウーマン研修	社内	0	1	0	0	働く女性が「仕事も人生も楽しく、自分らしく、やりがいを持って取り組む」ための意識醸成を図る。	女性社員	\N	人材開発室	対象者は別途連絡予定。\r\nまた業務等で今年度受講不可の方は、次年度の受講必須となる。	－	特定対象層向け研修	－	0	\N	\N	\N	\N
46115	ソフトウェア技術者のための論理思考の文書技術	社内	0	1	1	0	ITエンジニアであっても、高い文章作成能力は必要である。相手に正確に伝わる文書を作成できていないことによって、様々なトラブルが発生している。本講座では、Word や PowerPoint を活用し、情報と思考を論理的に整理して、相手に正確に伝わる文書を、早く作成する方法を学習する。	入社1～2年目	\N	（株）ナレッジトラスト	参加者は、部門長の推薦(承認)が必須。	003	部門長推薦研修	レベル2	1	\N	\N	\N	\N
46116	テスト品質管理 【基礎】	社内	0	0	1	0	開発メンバーとしてリーダの指示／テスト計画に基づいてテストを実施し、報告する立場を想定し、テスト品質の意味を理解した上で、しっかりテストし、きちんと結果を残すためにどうすればよいのかを学習する。\r\n※テスト工程の実務経験がある程度あった方が、理解促進に繋がる傾向あり。	入社2～3年目	\N	（株）ナレッジトラスト	参加者は、部門長の推薦(承認)が必須。	003	部門長推薦研修	レベル2	1	\N	\N	\N	\N
46117	テスト品質管理　【実践】	社内	1	0	1	0	テスト品質を評価・管理する立場、および、評価を自分の言葉で報告する立場を想定し、しっかりテストしてもらい、しっかりテストOKを出すためにどうすれば良いのか、テストの意味／品質へのこだわりを考える。テスト品質の意味を理解し、その評価を自分の言葉で報告できることを目的とする。	入社3年目以上	\N	（株）ナレッジトラスト	参加者は、部門長の推薦(承認)が必須。	003	部門長推薦研修	レベル2～3	1	\N	\N	\N	\N
46118	要件定義と議事録作成	社内	0	0	1	0	「まだ経験していない要件定義工程を身に着ける方法」として「議事録」を活用する。\r\n最上流の要件定義工程に、議事録担当者として参画することを想定し、後工程（要件定義工程）で必要となる情報は何か、議事録に何を残せば良いか、どう書けば良いか等、ケースを用いて上流工程を生々しく体験しながら、今後、実際に現場で上流工程を経験するときの糧となるような、スキル習得を目的とする。\r\n\r\n※現在開発中。	入社4年目以上	\N	（株）ナレッジトラスト	参加者は、部門長の推薦(承認)が必須。\r\n※開催中止となりました。	003	部門長推薦研修	レベル2～3	1	\N	\N	\N	\N
46119	プレゼンテーション研修	社内	0	1	0	0	システムエンジニアとして、顧客からの要望をヒアリングした上で仮説の構築を行い、何を伝える部分として抽出するのか、伝えるために資料をどう構築して作成するのか、また当日はどのようにそれを伝えるのか等、より実践的なプレゼンテーションスキルの向上を図る。	JP-B以上	\N	マーキュリッチ（株）	参加者は、部門長の推薦(承認)が必須。\r\n※隔日2日間で1セットの研修となります。	003	部門長推薦研修	レベル2～3	1	\N	\N	\N	\N
46120	見積と交渉	社内	0	1	1	0	見積と交渉に焦点を当てながら、標準的な見積技法を学び、かつ、リスク分析を踏まえたプロジェクト計画への反映の仕方を理解する。\r\nIT企業で働く社員が使える交渉テクニックや交渉スタイルを理解する。また交渉プロセスと各段階で行う内容を理解する。\r\nお客様先で「見積り」を用いて、研修で得た知識・技法を現場プロジェクトに活かすことを目的とする。\r\n\r\n※今後、お客様とお見積りで交渉機会のある社員が望ましい。	JP-A以上	\N	（株）ナレッジトラスト	参加者は、部門長の推薦(承認)が必須。	003	部門長推薦研修	レベル3	1	\N	\N	\N	\N
46121	FUJITSUファミリ会　LS研究委員会	社外	1	1	1	0	先進コンセプト・技術の適用方法や企画部門・情報システム部門が抱えている課題をテーマに、ファミリ会に属する複数の企業から、手を挙げたメンバが集い、１年間自主研究を実施する。	JP-B以上	\N	FUJITSUファミリ会\r\n（社内事務局：人材開発室）	・活動期間は1年間。\r\n・月1～2回の活動参加が必須。\r\n・2018年度の申込は締切済。	－	特定対象層向け研修	－	1	\N	\N	\N	\N
46122	新任管理職向け　コンプライアンス研修（外部）	社外	0	0	0	1	新任管理職の受講必須教育。\r\n\r\nコンプライアンスという言葉の定義を踏まえた上で、管理職としてコンプライアンスとどのように付き合うべきかを多角的に解説する。また、具体的なコンプライアンス問題を題材に、どのような点が問題でどのように対処すべきかを解説する。	第47期新任管理職\r\n・新任マネージャ\r\n・新任部長代理	\N	（株）プロネクサス	・対象者は事務局が一括申込みします。	－	特定対象層向け研修	－	0	\N	\N	\N	\N
46201	基礎から学ぶ！Excelマクロ機能による業務の自動化（UUF09L）	社外	0	0	1	0	Excelを使用した日常の繰り返し作業を自動化することのできる「マクロ機能」について基礎から学習します。マクロ記録機能を利用することで、一からプログラムを書くことなく作業を自動化することができます。本コースでは、マクロ記録機能の基本的な使用方法と、様々な活用シーンを想定した演習を通して、日常作業の自動化を実現するポイントを学習します。また記録したマクロの一部を編集し、作業を自動化する方法も紹介します。	J2～J1	24948	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
49151	Huong dan tao testcase/Test	社内	0	1	0	1	Huong dan tao testcase/Test cho nhan vien moi	入社1～2年目	\N	e-learning		001		レベル1	0	\N	null	null	\N
46202	基礎から学ぶ！Excel VBA による業務の自動化（UUL80L）	社外	0	0	1	0	ExcelVBAを業務で活用するためのプログラミング要素（コレクション、オブジェクト、イベント、プロパティ、メソッド）や基本文法（変数、制御文、プロシージャ、スコープなど）について、講義および実習を通して学習します。実習では、ExcelVBAの特徴であるイベント駆動型プログラミングを活用し、簡単なアプリケーションを作成します。	J2～J1	22680	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
46203	Excel VBA　による部門業務システムの構築（UUL79L）	社外	0	0	1	0	Excel VBA を使用して部門内の業務システムを構築するときに必要な開発手順、開発技術を、説明および実習を通して学習します。また、部門内で使用する業務システムとして、使いやすさやメンテナンスのしやすさを意識した実装パターンを紹介します。	J2～J1	40824	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
48217	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）	社外	0	0	1	0	UNIX または Linux 環境におけるシェルの機能とシェルスクリプトの作成方法を中心に講義と実習で学習する。講義では、Bourne シェル、Korn シェル、Bash の特徴を理解して、コマンドラインでの操作が便利になるような方法や定型処理を一括で実行できるようにするシェルスクリプトを制御文も含め修得する。また、基本的な sed コマンド、awk コマンドを使用したテキストファイルのデータ加工方法も修得する。	J2～J1	\N	（株）富士通ラーニングメディア	・当社価格は定価の25%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
46215	AWS　Technical Essencials 1（UBU05L）	社外	0	0	1	0	「AWS Technical Essentials1」では、AWS の製品、サービス、および一般的なソリューションについてご紹介します。このコースでは AWS のサービスの理解を深めるための基本知識が説明され、受講者が自身のビジネス要件に応じて、IT ソリューションに関する情報に基づいた決定を下し、AWS の使用を始めるのに役立ちます。\r\n（旧：Amazon Web Services 実践入門１）	J2～M4	52920	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
46204	C#プログラミング基礎（UUM13L）	社外	0	0	1	0	C# を使用して.NET Framework 対応アプリケーションを開発する際に必須の基本文法（変数、定数、配列、制御構文）に加え、オブジェクト指向プログラミングに必要な文法（継承、インターフェイス、オーバーライドなど）を講義と実習を通して学習します。実習は、理解度やレベルに合わせて自分のペースで進められるように、学習テーマごとの実習問題を豊富に用意しています。実習問題は、フローチャートを掲載し、アルゴリズムを苦手とする方にも理解しやすいようにプログラムの流れを可視化しています。	J2～J1	77112	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
46205	Visual Studio によるWebアプリの開発（Webフォーム基礎編）（UUM14L）	社外	0	0	1	0	Visual Studioの機能や操作方法、ASP.NET Webフォームのユーザーインターフェイス作成から、ASP.NETによるビジネスロジックの作成方法、ADO.NETを利用したデータベース連携方法を、説明と実習によって学習します。実習では、ASP.NET WebフォームによるオンラインショッピングのWebサイトを構築することで、Visual Studioを使用したWebアプリケーションの作成方法を学びます。	J2～J1	81648	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
46206	Visual Studio によるWebアプリの開発（Webフォーム応用編）（UUM15L）	社外	0	0	1	0	ASP.NET Webフォームを使用してWebアプリケーションを構築する際に必要となるセキュリティ、ロギング、ASP.NET Web APIなどの技術を説明と実習によって学習します。またセッション利用時の注意点やURLルーティングなど、Webアプリケーション構築時のテクニックを学習します。	J2～J1	46116	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
46207	Javaによるデータ構造とアルゴリズム（JAC0080G）	社外	0	0	1	0	プログラミング言語にはじめて触れる方を対象に、Java言語を用いてデータ構造やアルゴリズムを学習します。また、Javaの統合開発環境として広く利用されているEclipseの使い方も学習します。ただし、オブジェクト指向についてはこのコースでは触れません。	J2～J1	66096	トレノケート(株)	・当社価格は定価の10%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
46208	Javaによるオブジェクト指向プログラミング（JAC0081G）	社外	0	0	1	0	オブジェクト指向の重要概念（インスタンスの生成と利用、カプセル化、継承、例外処理など）を理解し、Java言語で実現する方法を学習します。それによりオブジェクト指向のメリットを体感し、理解します。	J2～J1	102060	トレノケート(株)	・当社価格は定価の10%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
46209	サーブレット／JSP／JDBCプログラミング　～Eclipseによる開発～（UFN06L）	社外	0	0	1	0	JavaでWebアプリを実装するために必要なサーブレット/JSP、DBアクセスに必要なJDBCといった、開発現場で必須となるJava要素技術を講義と実習で学習します。要素技術ごとに基本事項を講義と実習で理解していき、最後に、サーブレット、JSP、JDBCを連携させた一つのWebアプリケーションを実装することで、Javaで作成するWebアプリケーションの全体像とその実装方法を修得できます。JavaでWebアプリを開発する際に押さえておくべき要素技術の主要ポイントを重点的にまとめたコースです。	J2～J1	73332	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
46210	ソフトウェア開発者のためのモデリング（初級）（UAV86L）	社外	0	0	1	0	問題の対象を理解し、モデリングするとはどういうことか具体例を使って学びます。また、演習では、オブジェクト指向によるモデリングの基本を理解します。	J2～J1	30240.000000000004	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
46211	実習で学ぶ3層Webｼｽﾃﾑ入門(Web/AP/DB)（UBI31L）	社外	0	0	1	0	Webシステムは、3つの役割を持つサーバ（Web/AP/DB）によって構成される。本コースでは、各サーバの役割や動作の概要を学習し、実習ではサーバの起動停止や連携設定を体験する。また、Webシステムを実現するための技術（名前解決、負荷分散、ファイアウォール、SSL通信など）の概要も学習し、Webシステムの全体像を把握する。新入社員を始め、これからWebシステムに関わる仕事に従事される方へ向けた入門コース。	J2～J1	49140	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
46101	新人研修／基本コンテンツ	社内	1	1	0	0	社会人としての土台形成、および、自立したビジネスパーソンになるための土台形成を目的とする。経営理念・基本方針（役員講話、ワークショップ）、ビジネスマナー、コンプライアンス、情報セキュリティ、マネジメントゲーム、情報処理試験対策他。	第46期新卒入社者	\N	人材開発室	受講必須	－	階層別研修	－	0	\N	\N	\N	\N
48218	作業プランニング／タイムマネジメント（BS-001）	社外	1	0	0	0	現在の自分自身の業務における時間配分状況を分析し、改めて自分の時間の使い方について学習する。また、タイムマネジメントの前提となる自律的なワークスタイル、および作業プランニングの方法を学ぶ。分析結果と学習内容から、あるべき時間配分に向けたアクションプランを導き出す。	J2～J1	\N	（株）ナレッジトラスト	・当社価格は定価の35%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
48219	業務の生産性を高める！改善のポイント（UUF05L）	社外	1	0	0	0	業務における「改善」の重要性はますます高まっていますが、「どこから改善してよいのか分からない」、「長続きしない」などといった悩みがつきものです。本コースでは、仕事の生産性を着実に高めるために、無駄を見出す着眼点、生産性の考え方、納得性・継続性を高めるポイント、効果的なITツールの使い方、効果測定の尺度となるKPI（Key Performance Indicators）の設定の仕方など、一連の改善活動の進め方を学習します。また、実際の事例に基づいた演習を通じ、自社における改善活動のアクションプランを作成し、実践力を高める。\r\n〔PDU対象コース：14PDU〕	J1～	\N	（株）富士通ラーニングメディア	・当社価格は定価の25%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
48220	オペレーショナルマネジャーから戦略的マネジャーへ（AMC0024V）	社外	1	0	0	0	マネージャに求められる役割にも大きな変化が生じ、これまでシニア層のみ必要とされていた戦略的思考が、今日ではマネジャー層にも求められる能力となっている。\r\n様々な変化を敏速にキャッチし、自らの“働き方”を変えることが出来るマネジャーの存在こそが、今後組織やチームに好影響を与えていく。従来のオペレーションマネジメントだけでなく戦略的な思考で変化に対応しながらチームをリードできるマネジャーを育成する。	JP-A以上	\N	トレノケート（株）	・1年以上マネジャー経験のある方で、より戦略的に仕事を遂行したいと考えている方\r\n・本研修の当社価格は定価	001	オープン研修	レベル3	1	\N	\N	\N	\N
48221	組織を強くする問題解決の技術(BS-006)	社外	1	1	0	0	問題解決のプロセス全般とファシリテーションから構成した研修カリキュラム。\r\n問題解決のプロセス全般を学習することで、部分に偏った解決策でなく、全体最適を考慮した解決策が作成できるようになる。また、ファシリテーションでは、チームでの討論をコントロールする技術を修得し、シナジーを生かした解決策を作成できるようになる。	J1～	\N	（株）ナレッジトラスト	・当社価格は定価の35%割引\r\n・システム開発、運用に携わる方だけでなく、スタッフの方も受講できる内容です。	001	オープン研修	レベル2	1	\N	\N	\N	\N
48222	組織力を高めるマネジメントの技術(BS-007)	社外	1	1	0	0	組織で成果を出していくマネージャになるためには、進捗、予算、品質を管理していく以外に何が必要かを学習する。また、メンバーのマネジメントも内容に含まれているため、部下をうまく指導できるようになる。研修を通して自己成長のためのポイントを押さえることができることを目指す。	M3～	\N	（株）ナレッジトラスト	・当社価格は定価の35%割引\r\n・システム開発、運用に携わる方だけでなく、スタッフの方も受講できる内容です。	001	オープン研修	レベル2	1	\N	\N	\N	\N
48223	プロジェクトリーダーのための戦略的交渉術 ～交渉戦略の立案と実践スキル～(UZE88L) 	社外	1	1	0	0	プロジェクトを効果的に進める上で必要な戦略的交渉術について、講義と演習を通して学習する。交渉の場で活用できる多様な交渉スキルだけでなく、事前に必要な戦略的思考について学ぶ。また、心理学の知見と、プロジェクトの実事例に基づいたPBL（Project Based Learning）の手法を取り入れ、より実践的なスキルを修得する。\r\n〔PDU対象コース：14PDU〕	M2～M1	\N	（株）富士通ラーニングメディア	・当社価格は定価の25%割引	001	オープン研修	レベル3	1	\N	\N	\N	\N
48224	コミュニケーション基礎研修（BS-002）	社外	0	1	0	0	ビジネスコミュニケーションに求められるマインドや言葉によるバーバルコミュニケーション、言葉によらないノンバーバルコミュニケーションを含めた包括的なコミュニケーション力向上を目指します。\r\n自ら組織に主体的に働きかけ、組織・現場を活性化し、円滑なコミュニケーションを図るためのマインド、コミュニケーションスキルを養います。	J2～J1	\N	（株）ナレッジトラスト	・当社価格は定価の35%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
48225	リーダーコミュニケーション研修（BS-003）	社外	0	1	0	0	組織を活性化し、業績向上につなげていくうえで欠かすことのできないコミュニケーション力向上を目指します。\r\n組織・現場を活性化し、業務を円滑に進めていくためのリーダーマインド、指導・育成のためのスタンス・スキル、コミュニケーションスキルを養います。	J1～	\N	（株）ナレッジトラスト	・当社価格は定価の35%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
46212	データベース入門（DB0037CG）	社外	0	0	1	0	データベースについて基礎から学習できるため、データベースをこれから学習する方には最適な研修です。データベースを操作するSQL言語だけではなく、データベースが持っている基本的な機能に関して理解することができます。テクニカルエンジニア(データベース)試験の基礎知識修得にも役立つ内容になっています。	J2～J1	58320.00000000001	トレノケート(株)	・当社価格は定価の10%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
46213	データベース設計（基礎編）（UBD20L）	社外	0	0	1	0	データベース設計に必要な知識・手法を、講義と演習によって学習します。前半では、要素技術としてER図の書き方、正規化の概念を学び、後半は、概念設計から物理設計までの個々のタスクを机上演習を通して学びます。	J1～M4	49896	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
48226	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A)	社外	0	1	0	0	ビジネスに必要な思考力を身につけたい ITエンジニアにお勧め。\r\n今日では、ビジネスにおいてITは欠くことができない要素であり、ビジネスモデルの多くは、ITを前提として構築されています。そうした中で、ITエンジニアをはじめとしたITプロフェッショナルには、IT分野の知識・スキルだけでなく、論理的思考力や問題解決力などのビジネススキルが求められます。\r\n本コースでは、ITエンジニアに求められるビジネススキルのうち、問題解決力やビジネス・コミュニケーションのベースとなる思考力の習得、向上を目的としています。具体的には、ビジネスの場面で必要な論理的思考、創造的思考、批判的思考の3つの思考方法を、演習を交えながら、理解し、習得していきます。\r\n〔PDU対象コース：13PDU〕	J2～	\N	トレノケート（株）	・当社価格は定価の10%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
48227	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L）	社外	0	1	0	0	明るく元気な職場の実現には、メンバーの努力だけでなく、リーダー、幹部社員が果たす役割が重要です。リーダー、幹部社員は、メンバーが直面しているストレスを理解し、率先してストレスの軽減や職場環境の整備につとめるなど適切にマネジメントする必要があります。本コースでは、リーダー、幹部社員として知っておきたいストレスに関する現状、基礎知識、マネジメントのポイントを、講義と演習を通して学習します。	M4～M1	\N	（株）富士通ラーニングメディア	・当社価格は定価の25%割引	001	オープン研修	レベル2～3	1	\N	\N	\N	\N
48501	SI型PJ計画書の作り方と リスク判定シートの活用方法	社内	1	0	0	0	ＳＩ型ＰＪにおいて必要な管理要素を学び、ＰＪ運営に有効なＰＪ計画の立案ができるようになります。またＰＪ実行時にＰＭが日頃注視すべき“ＰＪ変動要素４０項目”を知り、リスクの定量化手法と活用方法を学びます。\r\n募集人数が5名以上集まった時点で、開催日時を参加希望者と調整し て実施します。	全社員	\N	品質推進部	\N	\N	もくもくワークショップ	レベル2～3	0	\N	\N	\N	\N
48502	ＥＮ型ＰＪ計画書の作り方とリスク判定シートの活用方法	社内	1	0	0	0	ＥＮ型ＰＪにおけるＫＰＩや必要な管理要素を学び、ＰＪ運営に有効なＰＪ計画の立案ができるようになります。またＰＪ実行時にＰＭが日頃注視すべき“ＰＪ変動要素４０項目”を知り、リスクの定量化手法と活用方法を学びます。\r\n募集人数が5名以上集まった時点で、開催日時を参加希望者と調整し て実施します。	全社員	\N	品質推進部	\N	\N	もくもくワークショップ	レベル2～3	0	\N	\N	\N	\N
46214	クラウド技術の基礎（UBS34L）	社外	0	0	1	0	クラウドサービスを提案したり、導入したり、アプリケーション開発で利用したりするには、クラウドサービスの背後で使用されている技術についても正しく理解している必要があります。本コースではクラウド時代に知っておくべき代表的なクラウドサービスの要素技術やクラウド基盤関連技術について学習します。\r\n※全て講義スタイル。受講対象者は「クラウドを初めて学ぶ」という層が望ましい。	J2～J1	31751.999999999996	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
46216	AWS　Technical Essencials 2 （UBU06L）	社外	0	0	1	0	「AWS Technical Essentials2」はAWS Technical Essentials1で習得した知識を使い、実際にAWSでシステムを構築、運用する演習（ラボ）中心のコースとなります。このコースでは、AWSのコアサービスを使ったWebシステムを構築および運用するための基本的な操作を、実際に行う能力を身につけることができます。このコースはAWSを利用する技術者、すなわちソリューションアークテクト、システム運用管理者、デベロッパーの方を対象にデザインされています。（旧：Amazon Web Services 実践入門２）	J2～M4	52920	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
46217	UNIX／Linux入門（UMI11L）	社外	0	0	1	0	UNIXおよびLinuxシステムの概要、基本的な使用方法（基本コマンド、ファイル操作、ネットワークコマンド、シェルの利用法など）を学習します。	J2～J1	57456.00000000001	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
46102	新人研修／技術トレーニング	社内	0	1	1	0	エンジニアとしての土台形成を目的とする。すべてのITエンジニアにとって必要な基礎知識を身に着ける。基本用語理解（基本情報処理試験対策等）、IT業界・当社事業理解、SE業務全体像の理解、プログラミング入門、Java基礎、DB基礎（SQL実践）、IT講演他。	第46期新卒入社者	\N	人材開発室	受講必須	－	階層別研修	－	0	\N	\N	\N	\N
46103	新人フォローアップ研修	社内	1	1	0	0	新人研修で学んだことについて、習得度合いの確認と復習を行う。また同期同士で半年間の経験や悩みを共有し、新たな気持ちで明日からの業務に前向きに取り組む意識を持つことを目的とする。\r\n基本行動トレーニング（外部講師）、セキュリティ研修、ビジネスライン分析他。	第46期新卒入社者	\N	人材開発室	受講必須	－	階層別研修	－	0	\N	\N	\N	\N
48606	アジャイル・スクラム体験ワークショップ	社内	0	0	1	0	アジャイル入門、および、アジャイル開発方法論である「Scrum（スクラム）」のプロジェクトを体験します。	J2～	\N	技術戦略室	\N	\N	杉崎塾	レベル1	0	\N	\N	\N	\N
48503	品質分析手法【設計製造編、テスト編】	社内	1	0	0	0	レビュー記録票や障害記録票から集計した品質データを用いて品質評価の演習を実施します。\r\n設計・製造工程とテスト工程における品質管理の重要性と分析手法を学び、分析観点を習得します。\r\n募集人数が5名以上集まった時点で、開催日時を参加希望者と調整し て実施します。	全社員	\N	品質推進部	\N	\N	もくもくワークショップ	レベル2	0	\N	\N	\N	\N
46502	PM7つ道具　使用手順	社内	0	0	1	0	VBAで動くPM７つ道具の使用手順説明および演習を通し、正しくツールを使用できるようになる。	J1～M4	\N	品質推進部	開催日程は、品質推進部より、四半期毎に案内される。	－	もくもくワークショップ	レベル1～2	0	\N	\N	\N	\N
48607	イーサリアム・スマートコントラクト体験ワークショップ	社内	0	0	1	0	Cubecoinのベースになっているブロックチェーン基盤のひとつである「Ethereum（イーサリアム）」を手順通りに進め、ノードの構築を体験します。	M4～	\N	技術戦略室	\N	\N	大槻塾	レベル2	0	\N	\N	\N	\N
46218	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）	社外	0	0	1	0	UNIXまたはLinux 環境におけるシェルの機能とシェルスクリプトの作成方法を中心に講義と実習で学習します。講義では、Bourneシェル、Kornシェル、Bashの特徴を理解して、コマンドラインでの操作が便利になるような方法や定型処理を一括で実行できるようにするシェルスクリプトを制御文も含め修得します。また、基本的なsedコマンド、awkコマンドを使用したテキストファイルのデータ加工方法も修得します。実習では、講義で修得した内容を、Linuxサーバを使用して確認できます。	J2～J1	46116	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
46219	システム運用におけるSLAの作成（UAW52L）	社外	0	0	1	0	システム運用のアウトソーシングにおけるSLAの作成方法や改定方法を、説明と演習によって学習する。演習では、小売業のシステム運用管理の事例を題材とし、作成途中のSLAの修正や、SLAに従って測定されたシステム運用管理状況の分析についてグループ討議を行い、SLAの作成、利用に関する理解を深める。以下スキル習得を目的とする。\r\n・SLAを導入する目的／手順を理解する。 \r\n・要件に合わせてSLAを作成し、要件変更や問題対応などのためSLAを改定する。 	M4～M1	32659.199999999997	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル2～3	1	\N	\N	\N	\N
46220	システム障害対策と対応、障害管理の勘所（UAW58L）	社外	0	0	1	0	障害発生時の業務への影響を最小限にとどめるために、システム開発プロジェクトの各工程でおこなうべきシステム障害対策と、システム稼動開始後の障害対応におけるポイントを、説明と演習によって学習します。演習では、サービス業を題材としたシステム運用管理事例の分析を行い、システム障害対策や障害発生時の活動に対する理解を深めます。	J2～M3	68947.2	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
46221	フレームワークの仕組みと活用（JAC0040G）	社外	0	0	1	0	Javaを用いてWebアプリケーションを開発する際に、フレームワークを利用すると高い生産性と品質を確保しやすくなります。本コースでは、普及しているフレームワーク（Struts、iBATIS、Spring）について、その概要と仕組み、使い方を紹介しながら、フレームワークを利用することで得られるメリットを説明します。\r\nあわせて、組織としてフレームワークを利用する場合の注意点を挙げます。	J2～M4	91368	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
46222	プロジェクトマネジメントの技法（UAQ41L）	社外	0	0	1	0	プロジェクトを円滑に進めるために必要な各種マネジメント手法や技法の中で、特に重要な「プロジェクト選定」「WBS作成」「スケジュール作成」「コスト見積もり」「EVM」「品質管理」「チーム育成」「リスクマネジメント」などについて学習します。また、理論だけでなく、プロジェクトマネジメントの手法や技法を体得していただくために、計算問題も含め7種類の演習を行います。〔PDU対象コース：14PDU〕	M4～M3	52920	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
46223	プロジェクトマネジメント技法の実践　～品質分析、進捗分析、対策編～（UAQ42L）	社外	0	0	1	0	プロジェクトを推進する際に重要となる「品質分析」「進捗分析」といった分析力向上のための技法や、「ファシリテーション」「コンフリクト」といった問題解決力向上のための技法について、具体的な活用方法を学習します。〔PDU対象コース:14PDU〕\r\n※これまでの受講者からの評価は総じて高め。特に演習の評価が高い。	M4～M3	60480.00000000001	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
46224	SEに求められるヒアリングスキル－効果的な顧客要件の聞き取り－（UZE66L）	社外	0	0	1	0	システム構築プロジェクトにおいて、SEに求められるヒアリングスキルを、講義と演習を通して学習します。ヒアリングの準備、実施、フォローのシーンにおいて、顧客要件を引き出すためのスキル、顧客要件の整理、および顧客との調整を円滑にするためのスキルを修得します。演習では、業務要件定義のロールプレーイングなどにより実践力を高めます。[PDU対象コース：14PDU]	M4～M3	68947.2	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
46225	プロジェクト計画策定スキル（PM-002）	社外	0	0	1	0	ＩＴプロジェクトにおける計画策定の基礎を学習する。「計画策定」の作業を単なる「計画書作成」と捉えず、プロジェクトの計画段階で何を検討すべきかについて学ぶ。また、計画策定に必要なインプット、計画として検討するポイント、検討の結果としてアウトプットされるものについての理解を深める。	M4～M3	35100	（株）ナレッジトラスト	・当社価格は定価の35%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
46226	プロジェクト実行管理（PM-003）	社外	0	0	1	0	ITプロジェクトにおける実行管理の基礎を学習する。ある架空のプロジェクトで生じるストーリーを題材に、実行管理において気をつけるべきポイント、押さえるべきポイント等を、グループでのディスカッションを通じて学習する。プロジェクトを取り囲むステークホルダーとの調整やコミュニケーションを図るための基礎的なスキルを学習する。\r\n※NRI 階層別研修と同一カリキュラム。これまでの受講者からの評価は総じて高い。	M4～M3	70200	（株）ナレッジトラスト	・当社価格は定価の35%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
48903	テスト研修TD03	社内	0	0	1	0	受入テスト用の研修。	全社員	\N	人材戦略室	テスト	ー	テスト用研修	レベル1	0	\N	\N	\N	\N
46227	プロジェクト計画における見積技法（IS-001）	社外	0	0	1	0	複雑な見積技法をわかりやすく解説する。システム開発で用いられる様々の見積技法と、見積結果をプロジェクト計画に反映させる方法を体系的に学習する。演習については流通系のケーススタディによる疑似体験を行う。（見積～プロジェクト計画立案）\r\n※一般的に提唱される見積技法と算出方法について、講義＋ケース演習両面から実際に手を動かして学ぶことができるため、これまでの受講者からの評価は高い。見積もり技法をきちんと実践的に学びたい人向けのカリキュラム。	M3	53352	（株）ナレッジトラスト	・当社価格は定価の35%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
46228	失敗しないプロジェクト立ち上げ（UAP64L）	社外	0	0	1	0	発注者と受注者が協力して推進していくITプロジェクトでは、両者の立場の違いや力関係から、さまざまな問題（納期遅延、コストオーバーなど）が発生します。本コースではプロジェクトの立ち上げフェーズにフォーカスし、両者のギャップを埋め、WIN-WINの関係を結ぶための考え方やポイントを学習します。〔PDU対象コース：14PDU〕\r\n※演習の難易度はそれなりに高い。	M3	68947.2	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
46229	ビジネスコミュニケーション 【basic】（BS-002）	社外	0	1	0	0	ビジネスコミュニケーションに求められるマインドや言葉によるバーバルコミュニケーション、言葉によらないノンバーバルコミュニケーションを含めた包括的なコミュニケーション力向上を目指します。\r\n自ら組織に主体的に働きかけ、組織・現場を活性化し、円滑なコミュニケーションを図るためのマインド、コミュニケーションスキルを養います。	J2～J1	35100	（株）ナレッジトラスト	・当社価格は定価の35%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
46230	ビジネスコミュニケーション 【advance】（BS-003）	社外	0	1	0	0	組織を活性化し、業績向上につなげていくうえで欠かすことのできないコミュニケーション力向上を目指します。\r\n組織・現場を活性化し、業務を円滑に進めていくためのリーダーマインド、指導・育成のためのスタンス・スキル、コミュニケーションスキルを養います。	J1	35100	（株）ナレッジトラスト	・当社価格は定価の35%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
46231	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L）	社外	0	1	0	0	明るく元気な職場の実現には、メンバーの努力だけでなく、リーダー、幹部社員が果たす役割が重要です。リーダー、幹部社員は、メンバーが直面しているストレスを理解し、率先してストレスの軽減や職場環境の整備につとめるなど適切にマネジメントする必要があります。本コースでは、リーダー、幹部社員として知っておきたいストレスに関する現状、基礎知識、マネジメントのポイントを、講義と演習を通して学習します。	M4～M1	31751.999999999996	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル2～3	1	\N	\N	\N	\N
46232	作業プランニング／タイムマネジメント（BS-001）	社外	1	0	0	0	現在の自分自身の業務における時間配分状況を分析し、改めて自分の時間の使い方について学習する。また、タイムマネジメントの前提となる自律的なワークスタイル、および作業プランニングの方法を学ぶ。分析結果と学習内容から、あるべき時間配分に向けたアクションプランを導き出す。	J2～J1	35100	（株）ナレッジトラスト	・当社価格は定価の35%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
46233	業務の生産性を高める！改善のポイント（UUF05L）	社外	1	0	0	0	業務における「改善」の重要性はますます高まっていますが、「どこから改善してよいのか分からない」、「長続きしない」などといった悩みがつきものです。本コースでは、仕事の生産性を着実に高めるために、無駄を見出す着眼点、生産性の考え方、納得性・継続性を高めるポイント、効果的なITツールの使い方、効果測定の尺度となるKPI（Key Performance Indicators）の設定の仕方など、一連の改善活動の進め方を学習します。また、実際の事例に基づいた演習を通じ、自社における改善活動のアクションプランを作成し、実践力を高めます。〔ＰＤＵ対象コース：１４ＰＤＵ〕	J1	57456.00000000001	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
46234	アサーティブ・コミュニケーション実践～業務の目的を達成するためのアプローチ～（UAF06L）	社外	1	1	0	0	個人が業務に対する思いや考えを一人で抱えこむことは、本人ばかりでなく、組織にとっても不利益につながる可能性があります。本コースでは業務上の目的を達成するために、相手の立場や目的を尊重した上で、自分の思いや要求を伝える戦略的なアプローチを、ロールプレイを通して学びます。〔PDU対象コース：7PDU〕	M4～M1	31751.999999999996	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル2～3	1	\N	\N	\N	\N
46235	組織力を高めるマネジメントの技術（BS-005）	社外	1	1	0	0	組織で成果を出していくマネージャになるためには、進捗、予算、品質を管理していく以外に何が必要なのかを学ぶ。これにより、部下をうまく指導したり、自己成長のためのポイントを押さえることができるようになる。\r\nマネージャの役割／上司との関係構築／メンバーの主体性を導く指導／仕事を任せるとは／組織の要望と個人の要求のマッチングについて　等。	M4～M1	53352	（株）ナレッジトラスト	・当社価格は定価の35%割引	001	オープン研修	レベル2～3	1	\N	\N	\N	\N
46236	PJリーダのための戦略的交渉術 ～交渉戦略の立案と実践スキル～(UZE88L) 	社外	1	1	0	0	プロジェクトを効果的に進める上で必要な戦略的交渉術について、講義と演習を通して学習する。交渉の場で活用できる多様な交渉スキルだけでなく、事前に必要な戦略的思考について学ぶ。また、心理学の知見と、プロジェクトの実事例に基づいたPBL（Project Based Learning）の手法を取り入れ、より実践的なスキルを修得する。	M2～M1	57456.00000000001	(株)富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル3	1	\N	\N	\N	\N
46237	オペレーショナルマネジャーから戦略的マネジャーへ（AMC0024V）	社外	1	0	0	0	マネジャーに求められる役割りにも大きな変化が生じ、これまでシニア層のみ必要とされていた戦略的思考が、今日ではマネジャー層にも求められる能力となりました。\r\n様々な変化を敏速にキャッチし、自らの“働き方”を変えることが出来るマネジャーの存在こそが、今後組織やチームに好影響を与えていきます。本セミナーでは、従来のオペレーションマネジメントだけでなく戦略的な思考で変化に対応しながらチームをリードできるマネジャーを育成します。	M2～M1	70000	トレノケート(株)	・当社価格は定価の10%割引	001	オープン研修	レベル3	1	\N	\N	\N	\N
46238	リーダーのための経営知識と企業財務 (BS-006）	社外	1	0	0	0	本講座は、経営戦略、マーケティング、会計・財務で構成されている。本講座を受講することで、経営全般の知識を得ることができる。顧客のビジネスを理解することができ、ニーズに合ったソリューションを提案することができるようになる。\r\n※会計・財務基礎（PL/BS/CF）、経営戦略（ﾌﾚｰﾑﾜｰｸ・分析手法）、マーケティング（損益分岐点）等。\r\n※役職者推奨	M2～S3	35100	（株）ナレッジトラスト	・当社価格は定価の35%割引	001	オープン研修	レベル3～4	1	\N	\N	\N	\N
46501	技術者のための分かりやすい文書の書き方	社内	0	0	1	0	正しく伝わる分かりやすい文章を書くことは、技術者にとって必要不可欠なスキル。\r\n講義と演習を通じて正しく伝わる書き方を学ぶ。	J4～J1	\N	品質推進部	開催日程は、品質推進部より、四半期毎に案内される。	－	もくもくワークショップ	レベル1～2	0	\N	\N	\N	\N
46503	品質分析手法（テスト工程編）	社内	0	0	1	0	ＰＭ７つ道具を活用し、テスト密度、障害密度および障害分類の品質評価演習を通して、テスト工程の品質分析手法を習得する。	M4～M3	\N	品質推進部	開催日程は、品質推進部より、四半期毎に案内される。	－	もくもくワークショップ	レベル2	0	\N	\N	\N	\N
46504	品質分析手法（設計・製造工程編）	社内	0	0	1	0	ＰＭ７つ道具を活用し、レビュー密度や指摘密度、指摘分類の品質評価演習を通し、設計・製造工程の品質分析手法を習得する。	M4～M3	\N	品質推進部	開催日程は、品質推進部より、四半期毎に案内される。	－	もくもくワークショップ	レベル2	0	\N	\N	\N	\N
46505	エンハンスセルフアセスメントの活用方法	社内	0	0	1	0	エンハンスＰＪのＰＭが管理すべき”８つの管理項目”の状況を自己診断し、ＰＪ改善に活用する方法を学ぶ。	M4～M3	\N	品質推進部	開催日程は、品質推進部より、四半期毎に案内される。	－	もくもくワークショップ	レベル2	0	\N	\N	\N	\N
46506	SIリスク判定シートの活用方法	社内	0	0	1	0	ＳＩＰＪで、日頃ＰＭが注視すべき“ＰＪ変動要素40項目”を知り、リスクの定量化手法と活用方法を学ぶ。	M4～M3	\N	品質推進部	開催日程は、品質推進部より、四半期毎に案内される。	－	もくもくワークショップ	レベル2	0	\N	\N	\N	\N
46507	PJ計画書の作り方（En版）	社内	0	0	1	0	エンハンスＰＪにおけるＫＰＩや必要な管理要素を学び、ＰＪ運営に有効なＰＪ計画の立案ができるようになる。	M4～M1	\N	品質推進部	開催日程は、品質推進部より、四半期毎に案内される。	－	もくもくワークショップ	レベル2～3	0	\N	\N	\N	\N
46508	PJ計画書の作り方（SI版）	社内	0	0	1	0	ＳＩＰＪにおけるマネジメントで必要な管理要素を学び、ＰＪ運営に有効なＰＪ計画の立案ができるようになる。	M4～M1	\N	品質推進部	開催日程は、品質推進部より、四半期毎に案内される。	－	もくもくワークショップ	レベル2～3	0	\N	\N	\N	\N
46509	発注業務のお作法	社内	1	0	0	0	ＢＰとの取引における法律、当社ルール、実務の手法を学び、ＰＪ責任者として正しい業務の理解とオペレーションができるようになる。	M4～M1	\N	品質推進部	開催日程は、品質推進部より、四半期毎に案内される。	－	もくもくワークショップ	レベル2～3	0	\N	\N	\N	\N
46510	CSリスクアセスメントの活用方法	社内	1	0	0	0	CS調査結果に対する自分たちの行動レベルのアセスメントを行い、お客様評価の真の意味、今後自分たちがとるべき行動は何かを学ぶ。	M2～M1	\N	品質推進部	開催日程は、品質推進部より、四半期毎に案内される。	－	もくもくワークショップ	レベル3	0	\N	\N	\N	\N
46511	なぜなぜ分析	社内	1	1	0	0	原因を正しく掘り下げ、真の原因を導く「なぜなぜ分析」。そのポイントの理解と実践を通じて、ＰＪに役立つスキルを学ぶ。	M4～M1	\N	品質推進部	開催日程は、品質推進部より、四半期毎に案内される。	－	もくもくワークショップ	レベル2～3	0	\N	\N	\N	\N
46601	システム設計・実装の基礎【基礎編】	社内	0	0	1	0	在庫管理システムをＬＡＭＰ（Linux、Apache、MySQL、PHP）で構築する。\r\n要件定義～外部設計～内部設計～コーディング～ミドルウェア設定～AWSでの実行まで、一通り上流から下流までを個人ワーク／グループワーク織り交ぜながら、実践する。\r\n※システム構築を通して、Webシステムの基本と概要について理解を深める。	入社2～3年目	\N	技術戦略室	開催日程は、技術戦略室より都度案内される。	－	ITスキルアップ研修	レベル1～2	0	\N	\N	\N	\N
46602	システム設計・実装の基礎【応用編】	社内	0	0	1	0	在庫管理システムをＬＡＭＰ（Linux、Apache、MySQL、PHP）で構築する。\r\n要件定義～外部設計～内部設計～コーディング～ミドルウェア設定～AWSでの実行まで、一通り上流から下流までを個人ワーク／グループワーク織り交ぜながら、実践する。\r\n※システムの上流から下流まで俯瞰で見つつ、システム全体の構成・設計について、より横断的なスキルを習得する。	入社4年目以上	\N	技術戦略室	開催日程は、技術戦略室より都度案内される。	－	ITスキルアップ研修	レベル1～2	0	\N	\N	\N	\N
46603	業務SE・インフラSE共通研修　AWS編	社内	0	0	1	0	システムの負荷に応じて仮想サーバの数を自動的に増減させるシステムの構築方法を理解する。\r\n仮想サーバの障害を監視し、障害が発生したときのメール連携の方法を理解する。	M4～	\N	技術戦略室	開催日程は、技術戦略室より都度案内される。	－	ITスキルアップ研修	レベル2～3	0	\N	\N	\N	\N
46604	業務SE・インフラSE共通研修　システム性能編	社内	0	0	1	0	※現在設計構築中。\r\n　詳細が決まり次第、ご案内致します。	M4～	\N	技術戦略室	開催日程は、技術戦略室より都度案内される。	－	ITスキルアップ研修	レベル2～3	0	\N	\N	\N	\N
46605	COBOL技術者専用のJAVAスキル研修	社内	0	0	1	0	COBOL言語を習得してきた開発経験者を対象とした、Java言語習得研修。\r\n経験者であればこそ、根幹の仕組みが理解できているため、環境／言語の習得に力点を置く。COBOLと Javaを比較しながら、短期間でJava言語を習得する。	M4～	\N	技術戦略室	2017年度下期以降に実施予定。	－	ITスキルアップ研修	レベル2～3	0	\N	\N	\N	\N
47211	体験！Androidプログラミング (UFN15L) 	社外	0	0	1	0	Androidプラットフォーム上で動作するJavaアプリケーションの開発の全体像を理解するコース。開発作業の中のアプリケーションの作成から動作確認については、実際に体験する。開発環境として「Android Studio」と、Android 実機端末を使用する。 \r\n※前提条件：Javaの基本文法を理解していること。\r\n※まずは体験してみたいという方向け。	J2～J1	25704	（株）富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
47212	速習　Swiftプログラミング言語 (UFN45L) 	社外	0	0	1	0	Swift言語の文法を学習し、特徴を理解する。学習は、主にインタラクティブにコードを書いて実行結果を確認できる Playground 上で行う（iOSアプリの開発方法は含まない）。	J2～J1	43200	（株）富士通ラーニングメディア	・本研修の当社価格は定価となります。	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
47213	Androidアプリ開発－WebAPI、非同期処理、サービス－ (UFN51L)	社外	0	0	1	0	アプリの開発で必要となる技術の中からより実践的なものをピックアップした内容。特に、WebAPIとの連携は多くの場面で利用されるため、HTTP通信とJSONの解析方法を学習する。演習を通じて、マルチスクリーンの対応方法、バックグラウンド処理や非同期処理を利用したアプリの開発方法を学習する。演習の随所で、必要となるセキュリティも学習する。\r\n作成したAndroidアプリは実機(タブレット端末)上で動作確認可能。	J1～M4	145800	（株）富士通ラーニングメディア	・本研修の当社価格は定価となります。	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
47214	Javaによるデータ構造とアルゴリズム（JAC0080G）	社外	0	0	1	0	プログラミング言語にはじめて触れる方を対象に、Java言語を用いてデータ構造やアルゴリズムを学習する。また、Javaの統合開発環境として広く利用されているEclipseの使い方も学習する。（オブジェクト指向については触れない）	J2～J1	66096	トレノケート（株）	・当社価格は定価の10%割引\r\n※本研修は一貫した学びとスキルアップ機会提供の観点から、「Javaによるオブジェクト指向プログラミング」 と併せての受講を推奨しています。是非セットでの受講をご検討ください。	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
47215	Javaによるオブジェクト指向プログラミング（JAC0081G）	社外	0	0	1	0	オブジェクト指向の重要概念（インスタンスの生成と利用、カプセル化、継承、例外処理など）を理解し、Java言語で実現する方法を学習する。オブジェクト指向のメリットを体感し、理解する。	J2～J1	102060	トレノケート（株）	・当社価格は定価の10%割引\r\n・本研修は一貫した学びとスキルアップ機会提供の観点から、「Javaによるデータ構造とアルゴリズム」 と併せての受講を推奨しています。是非セットでの受講をご検討ください。	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
47216	Javaデータベースプログラミング (JAC0083G)	社外	0	0	1	0	リレーショナルデータベースにアクセスする JDBC を用いた Java アプリケーションの作成方法について紹介する。また、POJO、DAOパターンを用いた実践的な開発手法も紹介する。\r\n※基本的なSQLステートメント（SELECT、INSERT、UPDATE、DELETE）によるデータ操作ができる方、リレーショナルデータベースに関する基本的な用語（テーブル、主キー、外部キー、列、行、カーソル）を理解している方向けの研修。	J2～J1	77760	トレノケート（株）	・当社価格は定価の10%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
47217	JavaScriptプログラミング基礎 (UJS36L)	社外	0	0	1	0	Webアプリケーションを実装する際に使用する JavaScript の基本文法を学習する。\r\n制御文、関数、イベント処理といった JavaScript の文法に加え、オブジェクトを使用して、文字列操作、ウィンドウ操作、フォームの入力チェックなどを実装する方法について、説明と実習によって学習する。	J2～J1	46116	（株）富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
47101	新人研修／基本コンテンツ	社内	1	1	0	0	社会人としての土台形成、および、自立したビジネスパーソンになるための土台形成を目的とする。経営理念・基本方針（役員講話、ワークショップ）、ビジネスマナー、コンプライアンス、情報セキュリティ、マネジメントゲーム、情報処理試験対策他。	第47期新卒入社者	\N	人材開発室	受講必須	－	階層別研修	－	0	\N	\N	\N	\N
47102	新人研修／技術トレーニング	社内	0	1	1	0	エンジニアとしての土台形成を目的とする。すべてのITエンジニアにとって必要な基礎知識を身に着ける。基本用語理解（基本情報処理試験対策等）、IT業界・当社事業理解、SE業務全体像の理解、プログラミング入門、Java基礎、DB基礎（SQL実践）、IT講演他。	第47期新卒入社者	\N	人材開発室	受講必須	－	階層別研修	－	0	\N	\N	\N	\N
47103	新人フォローアップ研修	社内	1	1	0	0	新人研修で学んだことについて、習得度合いの確認と復習を行う。また同期同士で半年間の経験や悩みを共有し、新たな気持ちで明日からの業務に前向きに取り組む意識を持つことを目的とする。\r\n基本行動トレーニング（外部講師）、セキュリティ研修、ビジネスライン分析他。	第47期新卒入社者	\N	人材開発室	受講必須	－	階層別研修	－	0	\N	\N	\N	\N
47104	入社3年目研修	社内	1	1	0	0	今後求められる役割の変化を認識し、そのために必要な自己理解と、今後求められる役割理解を目的とする。\r\n2年半の業務経験を棚卸しを行い、改めて自分の強み・弱みと、組織から求められる役割を照らし合わせることで自己理解を深める。また、担当者からプロジェクトやチームの責任者へと変わっていく過程において、組織ミッションを担う存在としての自律を促し、今後のビジョンを描く。	第45期新卒入社者	\N	人材開発室	受講必須	－	階層別研修	－	0	\N	\N	\N	\N
48608	AWS利用者ハンズオン	社内	0	0	1	0	社内でAWSを利用する人の必須研修です。ＡＷＳのセキュリティとネットワークの基本的な仕組みとキューブのルールを学習します。また、実際に演習でインスタンス（ＡＷＳの仮想サーバ）を作成します。キューブのルールに則った安全なＡＷＳの利用方法を身に着けることができます。	全社員	\N	人材戦略室	\N	ー	浦出塾	レベル1～2	0	\N	\N	\N	\N
47105	OJTトレーナー研修	社内	1	1	0	0	OJTトレーナーの役割や意義を通じて、人の成長支援が自らの大きな成長につながることを理解し、モチベーションの向上に繋げる。また指導方法やコミュニケーションスキル等を学ぶことで、トレーニーとの信頼関係を構築する知識を習得する。	OJTトレーナー	\N	人材開発室	受講必須。\r\nただし直近５年以内に同研修を受講された方は欠席可とする。	－	特定対象層向け研修	－	0	\N	\N	\N	\N
47106	キャリア研修（30代向け）	社内	0	1	0	0	入社から約10年が経過し、求められる役割が変わっていく節目を迎えた中堅社員を対象とする。周囲の客観的視点も踏まえながら自分自身のこれまでと強み・弱みについて棚卸しした上で、会社組織の方向性と自身のベクトルを共有し、今後のキャリアの方向性を考える。	30代社員	\N	人材開発室	受講必須。\r\n業務等で今年度受講不可の方は次年度の受講必須となる。	－	キャリア研修	－	0	\N	\N	\N	\N
47107	キャリア研修（40代向け）	社内	0	1	0	0	職業キャリアの中間地点を迎えたことを認識し、キャリア前半の振り返りによる自己の強み・弱みの棚卸しを行う。また自身を取り巻く環境（家族・価値観・業界・ライフイベント等）の状況変化を確認し、キャリア後半に向けたビジョンを構築する。仕事に関する能力開発をどう進めるかを計画し、次の飛躍・発展の契機にしていく。	40代社員	\N	人材開発室	受講必須。\r\n業務等で今年度受講不可の方は次年度の受講必須となる。	－	キャリア研修	－	0	\N	\N	\N	\N
47108	新任JP-B研修	社内	0	0	0	1	新任JP-Bとして必要な管理スキル習得と、社内ルール／法律の基本的な知識の習得を目的とする。発注業務研修／人事制度・労務管理基礎／PJ計画書作成研修等。	第48期新任JP-B	\N	人材開発室	次年度JP-B昇格を目指す人で、同研修を未受講の方は、受講必須。	－	階層別研修	－	1	\N	\N	\N	\N
47109	新任マネージャ研修	社内	0	0	0	1	管理職としての期待役割、必要な基本的知識の習得を目的とする。業務標準、収益認識、人事制度及び労務管理の基礎知識の確認、管理監督者としての責務・期待役割等。確認テストにより適切な知識を有しているか否かの判定を行う場合がある。	新任マネージャ研修	\N	人材開発室	次年度、新任マネージャとして着任の内示が出た方は、受講必須。	－	階層別研修	－	1	\N	\N	\N	\N
47112	中途社員研修	社内	1	1	0	0	マネジメントゲームを通じて経営者の視点を持つ、また損益感覚を養う。また中途入社者間で共に学び、切磋琢磨することで、社員の横の繋がりを築くことを目的とする。	中途入社者	\N	人材開発室	2017.11～2018.10 の期間中に入社した中途入社社員は受講必須。業務等で今年度受講不可の方は、次年度の受講必須となる。	－	特定対象層向け研修	－	0	\N	\N	\N	\N
48505	品質記録の書き方	社内	1	0	0	0	レビュー記録票と障害管理表の書き方演習を通して、品質記録の重要性と品質確保に向けた自身の意識向上を図ります。\r\n募集人数が5名以上集まった時点で、開催日時を参加希望者と調整し て実施します。	全社員	\N	品質推進部	\N	\N	もくもくワークショップ	レベル1	0	\N	\N	\N	\N
48506	２９９の施策から紐解く業務カイゼン５つのポイント	社内	1	0	0	0	業務革新活動の２９９のカイゼン施策をもとに、プロジェクトで抱える悩み・モヤモヤを業務改善につなげていくための、進め方を解説します。\r\n募集人数が5名以上集まった時点で、開催日時を参加希望者と調整し て実施します。	全社員	\N	品質推進部	\N	\N	もくもくワークショップ	レベル3	0	\N	\N	\N	\N
48601	システム設計・実装　　【基礎編】 （前編）	社内	0	0	1	0	システム設計・実装　　【基礎編】 の前編です。\r\n在庫管理システムをＬＡＭＰ（Linux、Apache、MySQL、PHP）で構築します。\r\n要件定義～外部設計～内部設計～コーディング～ミドルウェア設定～実行まで、一通り上流から下流までを、個人ワーク／グループワーク織り交ぜながら、実践します。	J2～	\N	人材戦略室	定員７名	\N	浦出塾	レベル1	0	\N	\N	\N	\N
47115	ビジョナリー・ウーマン研修	社内	0	1	0	0	働く女性が「仕事も人生も楽しく、自分らしく、やりがいを持って取り組む」ための意識醸成を図る。	女性社員	\N	人材開発室	対象者は別途連絡予定。\r\nまた業務等で今年度受講不可の方は、次年度の受講必須となる。	－	特定対象層向け研修	－	0	\N	\N	\N	\N
48602	ＡＷＳ-Ⅰ　システム自動拡張とメール連携編	社内	0	0	1	0	スケーラブルで可用性の高いWebシステムの構築方法とシステム監視の方法を学びます。	J1～	\N	人材戦略室	定員７名	\N	浦出塾	レベル1～2	0	\N	\N	\N	\N
48603	ＡＷＳ-Ⅱ　サーバレスアーキテクチャとマイクロサービス	社内	0	0	1	0	AWS におけるサーバレス・アーキテクチャと、マイクロサービスの基本的な概念を理解し、運用負担の少ないシステムを構築する方法を学びます。	J1～M3	\N	人材戦略室	【定員】７名\r\n【研修時間】10:00～17:00	\N	浦出塾	レベル1～2	0	\N	\N	\N	\N
48604	Docker　コンテナと　Dev/Ops	社内	0	0	1	0	docker によるコンテナ技術の基本的な概念を理解し、コンテナを使ってDev/Opsを回す方法を習得します。	J1～M3	\N	人材戦略室	【研修時間】10:00～17:00\r\n【前提知識】\r\nWEBの知識があること\r\nアプリケーション開発を理解していること	ー	浦出塾	レベル1～2	0	\N	\N	\N	\N
47116	ソフトウェア技術者のための論理思考の文書技術	社内	0	1	1	0	ITエンジニアであっても、高い文章作成能力は必要である。相手に正確に伝わる文書を作成できていないことによって、様々なトラブルが発生している。本講座では、Word や PowerPoint を活用し、情報と思考を論理的に整理して、相手に正確に伝わる文書を、早く作成する方法を学習する。	入社1～2年目	\N	（株）ナレッジトラスト	参加者は、部門長の推薦(承認)が必須。	003	部門長推薦研修	レベル2	1	\N	\N	\N	\N
48605	Kubernetes 【基礎】	社内	0	0	1	0	コンテナを使って本格的なシステムを構築（オーケストレーション）するためのツールである kubernetes の基本的な概念とその使い方を習得します。	J1～M3	\N	人材戦略室	\N	\N	浦出塾	レベル1～2	0	\N	\N	\N	\N
48610	システム設計・実装　　【基礎編】 （後編）	社内	0	0	1	0	システム設計・実装　　【基礎編】 の後編です。\r\n在庫管理システムをＬＡＭＰ（Linux、Apache、MySQL、PHP）で構築します。\r\n要件定義～外部設計～内部設計～コーディング～ミドルウェア設定～実行まで、一通り上流から下流までを、個人ワーク／グループワーク織り交ぜながら、実践します。	J2～	\N	人材戦略室	【定員】７名\r\n【研修時間】13:30～17:30	\N	浦出塾	レベル1	0	\N	\N	\N	\N
48651	Python初心者コース（PMLF）	社外	0	0	1	0	人工知能、機械学習に興味はあるが、最初のとっかかりがわからない方や、これからプログラミングを始めようという方、独学でプログラミング技術を身につけるのはハードルが高いと感じている方にお勧め。\r\nAI・機械学習のプログラミングに最適なPythonを学べるコースです。5日間登校と自己復習の反復により比較的短期間でプログラミングができるようになります。\r\n概要は以下の通り。\r\nPythonとは　／　変数と型　／　制御文　／　配列処理　／　関数　／　ライブラリ　／　クラス　／　画像処理　／　修了課題	J2～	\N	技術戦略室	（株）トリプルアイズ様提供研修「CSEA(シー)」（Computer Science & Engineering Academy）。\r\n人工知能を体系的に学べるAIスクールです。\r\n\r\n※申込方法については技術戦略室にお問い合わせください。	\N	オープン研修	レベル1	1	\N	\N	\N	\N
48652	機械学習プログラミングコース（PMLI）	社外	0	0	1	0	機械学習を行うためにこれからプログラミングを始めようという方、独学で機械学習を学ぼうと思ったけど挫折してしまった方、ディープラーニングにチャレンジしてみたい方にお勧め。\r\n実際のAIプロジェクトを想定し、データ取得・前処理～モデル学習・評価まで、PoCを体験できるコースです。\r\n週一度で一ヵ月という比較的短期間でプログラミングができるようになります。\r\n概要は以下の通り。\r\n数学基礎（行列・回帰分析とは）　／　機械学習ハンズオン（Python速習・単回帰・重回帰）　／　ディープラーニングハンズオン（機械学習フレームワーク・ニューラルネットワークを使った分析）　	J1～	\N	技術戦略室	（株）トリプルアイズ様提供研修「CSEA(シー)」（Computer Science & Engineering Academy）。\r\n人工知能を体系的に学べるAIスクールです。\r\n\r\n※申込方法については技術戦略室にお問い合わせください。	\N	オープン研修	レベル1～2	1	\N	\N	\N	\N
48653	AI構築コース（MLAP）	社外	0	0	1	0	とにかくAIで動く成果物を作成したい方、現在AIプロジェクトに参画されている方、AI導入を検討しているがどこから始めたら良いのか明確でない方にお勧め。\r\nAIシステムの構築・提案ができるようになるコースです。AIをシステムに導入・組み込みを検討している方やとにかくAIを組み込んだ環境を作成したい方を対象としています。\r\n概要は以下の通り。\r\nAI市場の理解　／　GPU環境構築　／　アプリケーション実装（データベース連携・分散処理）　／　システム統合（既存システムへの学習済みAIモデルの組込み・WebAPIの実装）　／　運用（アンサンブル学習・ラベル付工程の半自動化・学習済みAIモデルのアップデート方法）	M3～	\N	技術戦略室	（株）トリプルアイズ様提供研修「CSEA(シー)」（Computer Science & Engineering Academy）。\r\n人工知能を体系的に学べるAIスクールです。\r\n\r\n※申込方法については技術戦略室にお問い合わせください。	\N	オープン研修	レベル2～3	1	\N	\N	\N	\N
48901	テスト研修TD01	社内	0	0	1	0	受入テスト用の研修。	全社員	\N	人材戦略室	テスト	ー	テスト用研修	レベル1	0	\N	\N	\N	\N
48902	テスト研修TD02	社内	0	0	1	0	受入テスト用の研修。	全社員	\N	人材戦略室	テスト	ー	テスト用研修	レベル1	0	\N	\N	\N	\N
48904	テスト研修TD04	社内	0	0	1	0	受入テスト用の研修。	全社員	\N	人材戦略室	テスト	ー	テスト用研修	レベル1	0	\N	\N	\N	\N
48905	テスト研修TD05	社内	0	0	1	0	受入テスト用の研修。	全社員	\N	人材戦略室	テスト	ー	テスト用研修	レベル1	0	\N	\N	\N	\N
47117	テスト品質管理 【基礎】	社内	0	0	1	0	開発メンバーとしてリーダの指示／テスト計画に基づいてテストを実施し、報告する立場を想定し、テスト品質の意味を理解した上で、しっかりテストし、きちんと結果を残すためにどうすればよいのかを学習する。\r\n※テスト工程の実務経験がある程度あった方が、理解促進に繋がる傾向あり。	入社2～3年目	\N	（株）ナレッジトラスト	参加者は、部門長の推薦(承認)が必須。	003	部門長推薦研修	レベル2	1	\N	\N	\N	\N
47118	テスト品質管理　【実践】	社内	1	0	1	0	テスト品質を評価・管理する立場、および、評価を自分の言葉で報告する立場を想定し、しっかりテストしてもらい、しっかりテストOKを出すためにどうすれば良いのか、テストの意味／品質へのこだわりを考える。テスト品質の意味を理解し、その評価を自分の言葉で報告できることを目的とする。	入社3年目以上	\N	（株）ナレッジトラスト	参加者は、部門長の推薦(承認)が必須。	003	部門長推薦研修	レベル2～3	1	\N	\N	\N	\N
47119	要件定義	社内	1	0	1	0	知識だけではなく、演習を通してインタビューによる要件の引き出し方、問題・課題やニーズの分析、機能要件のモデリング、業務分析、非機能要件の整理の仕方、プレゼンテーションによる要件の伝え方などヒューマンスキルにも重点を置いている。3年以上の開発経験者を対象とし、上流の要件定義・提案スキルを身に付けることを目的とする。	入社4年目以上	\N	（株）ナレッジトラスト	参加者は、部門長の推薦(承認)が必須。	003	部門長推薦研修	レベル2～3	1	\N	\N	\N	\N
47121	新任管理職向け　コンプライアンス研修（外部）	社外	0	0	0	1	新任管理職の受講必須教育。\r\n\r\nコンプライアンスという言葉の定義を踏まえた上で、管理職としてコンプライアンスとどのように付き合うべきかを多角的に解説する。また、具体的なコンプライアンス問題を題材に、どのような点が問題でどのように対処すべきかを解説する。	第47期新任管理職\r\n・新任マネージャ\r\n・新任部長代理	\N	（株）プロネクサス	・対象者は事務局が一括申込みします。	－	特定対象層向け研修	－	0	\N	\N	\N	\N
47151	SQLトレーニング 【e-learning】	社外	0	0	1	0	現場で実際にSQLを書けるエンジニアを育成するための、訓練用 e-learning ツール。資格取得に向けたSQL理解促進のため、または、現場で実際に SQLを組める（書ける）スキル育成を目指すためなどに活用可能。ただし、資格取得のためのツールではないので注意。\r\n※学習期間は最長3カ月間\r\n※学習期間中であれば一通りコース修了後も、トレーニング用ステージや、テストステージ等が用意されており利用可能。様々なトレーニングを楽しみながら積むことで、現場で通用する実践力をつけることが可能。	J2～	43200	（株）イテレイティブ	・申込は人材開発室がとりまとめて行う。\r\n・受講期間中の学習進捗や成績、偏差値等は本人および上席者に報告予定。\r\n・受講可能期間はアカウント発行後、最長３カ月間。	001	e-Learning	レベル1	1	\N	\N	\N	\N
47152	プログラム育成コースfor Java  【e-learning】	社外	0	0	1	0	初心者から、スキルチェンジを目的とする中堅層まで、Javaプログラマー育成のための e-learning ツール。\r\nプログラミング作法、テスト技術など開発技術を中心に１０単元の課題演習、各種テストを通して学習する。\r\n※学習期間は最長12カ月間\r\n※テキスト学習／プログラミング演習／各種確認テスト有り\r\n※これまで当社受講者の修了率は３割と、修了難易度は比較的高め。「必ず修了すること」 が申込条件。	J2～	86400	富士通アプリケーションズ（株）	・スキルチェンジを図りたい中堅層以上にもおすすめ。\r\n・申込は人材開発室がとりまとめて行う。\r\n・受講期間中の学習進捗や成績等は本人および上席者にフィードバック報告予定。\r\n・受講可能期間はアカウント発行後、最長１年間。	001	e-Learning	レベル1～3	1	\N	\N	\N	\N
47201	基礎から学ぶ！Excelマクロ機能による業務の自動化 (UUF09L)	社外	0	0	1	0	Excelを使用した日常の繰り返し作業を自動化することのできる「マクロ機能」について基礎から学習します。マクロ記録機能を利用することで、一からプログラムを書くことなく作業を自動化することができます。本コースでは、マクロ記録機能の基本的な使用方法と、様々な活用シーンを想定した演習を通して、日常作業の自動化を実現するポイントを学習します。また記録したマクロの一部を編集し、作業を自動化する方法も紹介します。	J2～J1	24948	（株）富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
47218	イマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G)	社外	0	0	1	0	クライアントサイドスクリプトで有名な 「jQuery」 というライブラリーの特徴や動作を中心に、レスポンシブWebデザインに効果的な 「Bootstrap」、AngularJS や Node.js といった大規模な開発向きのライブラリーやサーバーサイドスクリプトの動作を確認し、JavaScriptの利用範囲や実現できる動作の体験を行う。	J2～J1	48600	トレノケート（株）	・当社価格は定価の10%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
47202	基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L)	社外	0	0	1	0	ExcelVBAを業務で活用するためのプログラミング要素（コレクション、オブジェクト、イベント、プロパティ、メソッド）や基本文法（変数、制御文、プロシージャ、スコープなど）について、講義および実習を通して学習します。実習では、ExcelVBAの特徴であるイベント駆動型プログラミングを活用し、簡単なアプリケーションを作成します。	J2～J1	22680	（株）富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
47203	Excel VBA　による部門業務システムの構築（UUL79L）	社外	0	0	1	0	Excel VBA を使用して部門内の業務システムを構築するときに必要な開発手順、開発技術を、説明および実習を通して学習します。また、部門内で使用する業務システムとして、使いやすさやメンテナンスのしやすさを意識した実装パターンを紹介します。	J2～J1	40824	（株）富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
47204	プロジェクトマネジメントの技法 (UAQ41L) 	社外	0	0	1	0	プロジェクトを円滑に進めるために必要な各種マネジメント手法や技法の中で、特に重要な「プロジェクト選定」「WBS作成」「スケジュール作成」「コスト見積もり」「EVM」「品質管理」「チーム育成」「リスクマネジメント」などについて学習します。また、理論だけでなく、プロジェクトマネジメントの手法や技法を体得していただくために、計算問題も含め7種類の演習を行います。\r\n〔PDU対象コース：14PDU〕	J2～J1	52920	（株）富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
47205	プロジェクト実行管理（PM-004）	社外	0	0	1	0	ITプロジェクトにおける実行管理の基礎を学習する。ある架空のプロジェクトで生じるストーリーを題材に、実行管理において気をつけるべきポイント、押さえるべきポイント等を、グループでのディスカッションを通じて学習する。プロジェクトを取り囲むステークホルダーとの調整やコミュニケーションを図るための基礎的なスキルを学習する。\r\n\r\n※NRI 階層別研修と同一カリキュラム。これまでの受講者からの評価は総じて高い。	M4～M3	70200	（株）ナレッジトラスト	・当社価格は定価の35%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
47206	プロジェクト計画における見積技法（IS-003）	社外	0	0	1	0	複雑な見積技法をわかりやすく解説する。システム開発で用いられる様々の見積技法と、見積結果をプロジェクト計画に反映させる方法を体系的に学習する。演習については流通系のケーススタディによる疑似体験を行う。（見積～プロジェクト計画立案）\r\n※一般的に提唱される見積技法と算出方法について、講義＋ケース演習両面から実際に手を動かして学ぶことができるため、これまでの受講者からの評価は高い。見積もり技法をきちんと実践的に学びたい人向けのカリキュラム。	M3～	53352	（株）ナレッジトラスト	・当社価格は定価の35%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
47207	アジャイル開発手法によるシステム開発(UBS99L)	社外	0	0	1	0	スクラムをベースとしたアジャイル開発の進め方（スプリント計画ミーティング、開発作業、スプリントレビューミーティング、スプリント振返りなど）について演習を通して学習します。演習では、アジャイル開発手法（スクラム）の作業内容に基づき、システム開発プロジェクトを疑似体験します。	J1～	81648	（株）富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
47208	事例から学ぶ　アジャイル開発のプロジェクトマネジメント(UBS79L)	社外	0	0	1	0	アジャイル開発プロジェクトを遂行するために必要な、アジャイル開発の特徴的な考え方を理解します。 また、富士通が担当したアジャイル開発プロジェクトをモデルとして、プロジェクトマネジメントのポイントを学ぶ。\r\n〔PDU対象コース：7PDU〕	M4～M3	37800	（株）富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
47209	ＳＥに求められるヒアリングスキル(UZE66L)	社外	0	0	1	0	システム構築プロジェクトにおいて、SEに求められるヒアリングスキルを、講義と演習を通して学習します。ヒアリングの準備、実施、フォローのシーンにおいて、顧客要件を引き出すためのスキル、顧客要件の整理、および顧客との調整を円滑にするためのスキルを修得します。演習では、業務要件定義のロールプレーイングなどにより実践力を高めます。\r\n[PDU対象コース：14PDU]	M4～M3	68947.2	（株）富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
47219	Node.js + Express + MongoDB ～JavaScript によるｻｰﾊﾞｰｻｲﾄﾞWebｱﾌﾟﾘｹｰｼｮﾝ開発 (WSC0065R)	社外	0	0	1	0	サーバーサイド JavaScript の実行環境として注目されている Node.js と、Node.js 上で動作する Webアプリケーション・フレームワークとして広く利用されている Express を用いて、データベースアクセスを伴うWebアプリケーションの開発方法を演習を交えて学習する。なお、DBアクセスについては、JavaScript アプリケーションと親和性の高い MongoDB に加え、実績のある SQLデータベースについても扱う。\r\nまた、開発環境の構築方法や、JavaScript Webアプリケーションのテスト方法など、開発プロセスに関する内容についても紹介する。	J1～M4	97200	トレノケート（株）	・本研修の当社価格は定価	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
47220	UNIX／Linux入門（UMI11L）	社外	0	0	1	0	UNIXおよびLinuxシステムの概要、基本的な使用方法（基本コマンド、ファイル操作、ネットワークコマンド、シェルの利用法など）を学習する。	J2～J1	57456.00000000001	（株）富士通ラーニングメディア	・当社価格は定価の30%割引\r\n・本研修は一貫した学びとスキルアップ機会提供の観点から、「シェルの機能とプログラミング　～UNIX/Linux の効率的使用を目指して」 と併せての受講を推奨しています。是非セットでの受講をご検討ください。	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
47231	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L）	社外	0	1	0	0	明るく元気な職場の実現には、メンバーの努力だけでなく、リーダー、幹部社員が果たす役割が重要です。リーダー、幹部社員は、メンバーが直面しているストレスを理解し、率先してストレスの軽減や職場環境の整備につとめるなど適切にマネジメントする必要があります。本コースでは、リーダー、幹部社員として知っておきたいストレスに関する現状、基礎知識、マネジメントのポイントを、講義と演習を通して学習します。	M4～M1	31751.999999999996	（株）富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル2～3	1	\N	\N	\N	\N
47221	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）	社外	0	0	1	0	UNIX または Linux 環境におけるシェルの機能とシェルスクリプトの作成方法を中心に講義と実習で学習する。講義では、Bourne シェル、Korn シェル、Bash の特徴を理解して、コマンドラインでの操作が便利になるような方法や定型処理を一括で実行できるようにするシェルスクリプトを制御文も含め修得する。また、基本的な sed コマンド、awk コマンドを使用したテキストファイルのデータ加工方法も修得する。	J2～J1	46116	（株）富士通ラーニングメディア	・当社価格は定価の30%割引\r\n・本研修は一貫した学びとスキルアップ機会提供の観点から、「シェルの機能とプログラミング　～UNIX/Linux の効率的使用を目指して」 と併せての受講を推奨しています。是非セットでの受講をご検討ください。	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
47222	Microsoft Azure入門 (UCV42L) 	社外	0	0	1	0	Microsoft Azure の概要や特徴、コンピューティングやデータ管理機能などの主な構成要素、Azure の関連サービスや Azure の代表的な利用シナリオについて学習する。	J2～J1	33264	（株）富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
47223	作業プランニング／タイムマネジメント（BS-001）	社外	1	0	0	0	現在の自分自身の業務における時間配分状況を分析し、改めて自分の時間の使い方について学習する。また、タイムマネジメントの前提となる自律的なワークスタイル、および作業プランニングの方法を学ぶ。分析結果と学習内容から、あるべき時間配分に向けたアクションプランを導き出す。	J2～J1	35100	（株）ナレッジトラスト	・当社価格は定価の35%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
47224	業務の生産性を高める！改善のポイント（UUF05L）	社外	1	0	0	0	業務における「改善」の重要性はますます高まっていますが、「どこから改善してよいのか分からない」、「長続きしない」などといった悩みがつきものです。本コースでは、仕事の生産性を着実に高めるために、無駄を見出す着眼点、生産性の考え方、納得性・継続性を高めるポイント、効果的なITツールの使い方、効果測定の尺度となるKPI（Key Performance Indicators）の設定の仕方など、一連の改善活動の進め方を学習します。また、実際の事例に基づいた演習を通じ、自社における改善活動のアクションプランを作成し、実践力を高める。\r\n〔PDU対象コース：14PDU〕	J1～	57456	（株）富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
47225	オペレーショナルマネジャーから戦略的マネジャーへ（AMC0024V）	社外	1	0	0	0	マネージャに求められる役割にも大きな変化が生じ、これまでシニア層のみ必要とされていた戦略的思考が、今日ではマネジャー層にも求められる能力となっている。\r\n様々な変化を敏速にキャッチし、自らの“働き方”を変えることが出来るマネジャーの存在こそが、今後組織やチームに好影響を与えていく。従来のオペレーションマネジメントだけでなく戦略的な思考で変化に対応しながらチームをリードできるマネジャーを育成する。	JP-A以上	75600	トレノケート（株）	・1年以上マネジャー経験のある方で、より戦略的に仕事を遂行したいと考えている方\r\n・本研修の当社価格は定価となります。	001	オープン研修	レベル3	1	\N	\N	\N	\N
47226	組織を強くする問題解決の技術(BS-007)	社外	1	1	0	0	問題解決のプロセス全般とファシリテーションから構成した研修カリキュラム。\r\n問題解決のプロセス全般を学習することで、部分に偏った解決策でなく、全体最適を考慮した解決策が作成できるようになる。また、ファシリテーションでは、チームでの討論をコントロールする技術を修得し、シナジーを生かした解決策を作成できるようになる。	J1～	53352	（株）ナレッジトラスト	・当社価格は定価の35%割引\r\n・システム開発、運用に携わる方だけでなく、スタッフの方も受講できる内容です。	001	オープン研修	レベル2	1	\N	\N	\N	\N
47227	組織力を高めるマネジメントの技術(BS-008)	社外	1	1	0	0	組織で成果を出していくマネージャになるためには、進捗、予算、品質を管理していく以外に何が必要かを学習する。また、メンバーのマネジメントも内容に含まれているため、部下をうまく指導できるようになる。研修を通して自己成長のためのポイントを押さえることができることを目指す。	M3～	53352	（株）ナレッジトラスト	・当社価格は定価の35%割引\r\n・システム開発、運用に携わる方だけでなく、スタッフの方も受講できる内容です。	001	オープン研修	レベル2	1	\N	\N	\N	\N
47228	PJリーダのための戦略的交渉術 ～交渉戦略の立案と実践スキル～(UZE88L) 	社外	1	1	0	0	プロジェクトを効果的に進める上で必要な戦略的交渉術について、講義と演習を通して学習する。交渉の場で活用できる多様な交渉スキルだけでなく、事前に必要な戦略的思考について学ぶ。また、心理学の知見と、プロジェクトの実事例に基づいたPBL（Project Based Learning）の手法を取り入れ、より実践的なスキルを修得する。〔PDU対象コース：2PDU〕	M2～M1	57456.00000000001	（株）富士通ラーニングメディア	・当社価格は定価の30%割引	001	オープン研修	レベル3	1	\N	\N	\N	\N
47229	ビジネスコミュニケーション 【basic】（BS-002）	社外	0	1	0	0	ビジネスコミュニケーションに求められるマインドや言葉によるバーバルコミュニケーション、言葉によらないノンバーバルコミュニケーションを含めた包括的なコミュニケーション力向上を目指します。\r\n自ら組織に主体的に働きかけ、組織・現場を活性化し、円滑なコミュニケーションを図るためのマインド、コミュニケーションスキルを養います。	J2～J1	35100	（株）ナレッジトラスト	・当社価格は定価の35%割引	001	オープン研修	レベル1～2	1	\N	\N	\N	\N
47230	ビジネスコミュニケーション 【advance】（BS-004）	社外	0	1	0	0	組織を活性化し、業績向上につなげていくうえで欠かすことのできないコミュニケーション力向上を目指します。\r\n組織・現場を活性化し、業務を円滑に進めていくためのリーダーマインド、指導・育成のためのスタンス・スキル、コミュニケーションスキルを養います。	J1～	35100	（株）ナレッジトラスト	・当社価格は定価の35%割引	001	オープン研修	レベル2	1	\N	\N	\N	\N
48101	新人研修／基本コンテンツ	社内	1	1	0	0	社会人としての土台形成、および、自立したビジネスパーソンになるための土台形成を目的とする。経営理念・基本方針（役員講話、ワークショップ）、ビジネスマナー、コンプライアンス、情報セキュリティ、マネジメントゲーム、情報処理試験対策他。	第48期新卒入社者	\N	人材戦略室	受講必須	－	階層別研修	－	0	{23}			{6}
\.


--
-- Data for Name: tbl_kensyuu_nittei_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_kensyuu_nittei_master (nittei_id, kensyuu_id, kensyuu_sub_id, basho, toukyou_oosaka_flag, nittei_from, nittei_to, moushikomikigen, cancel_date, jikan, bun, kansan_jikan, cancelpolicy, jukou_jouhou, nissuu, ninzuu, jyukouryou) FROM stdin;
16240	48103	001	[東京地区]大崎本社 	1	2020-02-01	2020-02-29	2020-01-30	2020-01-30	\N	\N	\N	キャンセル不可。	\N	2	0	5000
9780	47101	001	[東京地区]大崎本社 	1	2018-04-02	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	20	0	\N
16555	49101	002	[Miền Bắc] Hà Nội	9	2020-05-17	2020-05-17	2020-05-13	2020-05-14	\N	\N	\N	không có	\N	1	10	0
16556	49102	002	asbdotnet	2	2020-05-31	2020-05-31	2020-05-24	2020-05-28	\N	\N	\N		\N	1	2	1000
7298	46109	001	[東京地区]大崎本社 	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	2	0	\N
7299	46110	001	[東京地区]大崎本社 	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	1	0	\N
16554	48101	002	大阪	2	2020-03-03	2020-03-07	2020-03-02	2020-03-02	\N	\N	\N	No policy	\N	5	5	1000
16557	49604	002	123456	9	2020-06-02	2020-06-05	2020-05-26	2020-05-30	\N	\N	\N	ko dc huy	\N	2	5	0
15017	49102	001	[MiềnNam]HCM	1	2020-05-07	2020-05-31	\N	\N	\N	\N	\N	\N	\N	2時間	0	\N
15018	49103	001	[MiềnNam]HCM	1	2020-11-12	2020-11-15	2020-11-07	2020-11-09	\N	\N	\N	Hủy mất phí	\N	2	0	1234
15019	49111	001	[MiềnBắc]Hà Nội	2	2020-11-12	2020-11-15	\N	\N	\N	\N	\N	\N	\N	－	0	\N
15020	49205	001	[MiềnBắc]Hà Nội	2	2020-02-12	2020-06-12	\N	\N	\N	\N	\N	\N	\N	1時間	0	\N
15021	49501	001	[MiềnTrung]Đà Nẵng	5	2020-02-12	2020-06-12	\N	\N	\N	\N	\N	\N	\N	4時間	0	\N
15022	49604	001	[MiềnTrung]Đà Nẵng	5	2020-12-15	2020-12-18	2020-12-12	2020-12-14	\N	\N	\N	Trường hợp vắng mặt thì sẽ phải liên lạc với người quản lý	\N	1	0	10000
15016	49101	001	[MiềnNam]HCM	1	2020-04-01	2020-04-26	2020-03-25	2020-03-27	\N	\N	\N	無料	\N	1	0	
15071	49151	001	ABC Building	1	2020-03-01	2020-03-07	2020-02-25	2020-02-27	\N	\N	\N	No Policy	\N	7	10	1000
7308	46119	001	[東京地区]大崎本社 	1	2017-10-13	2017-09-03	2017-09-13	2017-09-13	\N	\N	\N	研修開催日1ヶ月前までキャンセル可能です。\r\nまたキャンセルにあたっては、部門長の承認を得る必要があります。	\N	2	0	\N
7309	46120	001	[東京地区]大崎本社 	1	2017-10-19	2017-09-03	2017-09-19	2017-09-19	\N	\N	\N	研修開催日1ヶ月前までキャンセル可能です。\r\nまたキャンセルにあたっては、部門長の承認を得る必要があります。	\N	2	0	\N
7311	46122	001	[東京地区]汐留	1	2017-04-20	2017-09-03	2017-03-31	\N	\N	\N	\N	キャンセル不可です。	\N	0.5	0	\N
16238	48101	001	[東京地区]大崎本社 	1	2019-04-01	2019-04-26	\N	\N	\N	\N	\N	キャンセル不可。	\N	20	0	\N
16239	48102	001	[東京地区]大崎本社 	1	2019-05-07	2019-05-31	\N	\N	\N	\N	\N	キャンセル不可。	\N	19	0	\N
7623	46602	001	[東京地区]大崎本社 	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	開催日３日前までキャンセル可能です。	\N	4\r\n×\r\n2日	0	\N
7622	46601	001	[東京地区]大崎本社 	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	開催日３日前までキャンセル可能です。	\N	4\r\n×\r\n2日	0	\N
7612	46502	001	[東京地区]大崎本社 	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	開催日３日前までキャンセル可能です。	\N	0.5	0	\N
7613	46503	001	[東京地区]大崎本社 	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	開催日３日前までキャンセル可能です。	\N	0.5	0	\N
9786	47107	001	[東京地区]大崎本社 	1	2019-01-10	2017-09-03	\N	\N	\N	\N	\N	やむを得ない事情で欠席の場合は、次年度の受講が必須となりますのでご認識ください。	\N	1	0	\N
9787	47108	002	[東京地区]大崎本社 	1	2019-01-18	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	1	0	\N
9788	47108	001	[東京地区]大崎本社 	1	2018-12-21	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	1	0	\N
7289	46101	001	[東京地区]大崎本社 	1	2017-04-03	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	20	0	\N
7290	46102	001	[東京地区]大崎本社 	1	2017-05-01	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	22	0	\N
7291	46103	001	[東京地区]大崎本社 	1	2017-10-05	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	2	0	\N
7292	46104	001	[東京地区]大崎本社 	1	2017-10-26	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	2	0	\N
7293	46105	001	[東京地区]大崎本社 	1	2017-06-09	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	1	0	\N
7294	46106	001	[東京地区]大崎本社 	1	2017-07-20	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	1	0	\N
7295	46107	001	[東京地区]大崎本社 	1	2017-12-15	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	1	0	\N
7296	46107	002	[東京地区]大崎本社 	1	2018-01-26	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	1	0	\N
7297	46108	001	[東京地区]大崎本社 	1	2018-03-23	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	1	0	\N
7300	46111	001	[東京地区]大崎本社 	1	2017-11-16	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	2	0	\N
7303	46114	001	[東京地区]大崎本社 	1	2017-12-14	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	1	0	\N
7304	46115	001	[東京地区]大崎本社 	1	2017-08-03	2017-09-03	2017-07-03	2017-07-04	\N	\N	\N	研修開催日1ヶ月前までキャンセル可能です。\r\nまたキャンセルにあたっては、部門長の承認を得る必要があります。	\N	2	0	\N
7305	46116	001	[東京地区]大崎本社 	1	2017-09-07	2017-09-03	2017-08-07	2017-08-08	\N	\N	\N	研修開催日1ヶ月前までキャンセル可能です。\r\nまたキャンセルにあたっては、部門長の承認を得る必要があります。	\N	2	0	\N
7306	46117	001	[東京地区]大崎本社 	1	2017-12-07	2017-09-03	2017-11-07	2017-11-07	\N	\N	\N	研修開催日1ヶ月前までキャンセル可能です。\r\nまたキャンセルにあたっては、部門長の承認を得る必要があります。	\N	2	0	\N
9781	47102	001	[東京地区]大崎本社 	1	2018-05-01	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	22	0	\N
9782	47103	001	[東京地区]大崎本社 	1	2018-10-04	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	2	0	\N
9783	47104	001	[東京地区]大崎本社 	1	2018-10-25	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	2	0	\N
9784	47105	001	[東京地区]大崎本社 	1	2018-06-08	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	1	0	\N
9785	47106	001	[東京地区]大崎本社 	1	2018-08-23	2017-09-03	\N	\N	\N	\N	\N	やむを得ない事情で欠席の場合は、次年度の受講が必須となりますのでご認識ください。	\N	2	0	\N
7312	46201	005	[東京地区]品川	1	2017-09-19	2017-09-03	2017-09-05	2017-09-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
7313	46201	003	[東京地区]品川	1	2017-08-14	2017-09-03	2017-07-31	2017-08-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
7314	46201	002	[東京地区]品川	1	2017-07-24	2017-09-03	2017-07-10	2017-07-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
7315	46201	001	[東京地区]品川	1	2017-07-03	2017-09-03	2017-06-19	2017-06-29	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
7316	46201	020	[大阪地区]京橋	2	2018-03-23	2017-09-03	2018-03-09	2018-03-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
7317	46201	019	[大阪地区]京橋	2	2018-01-12	2017-09-03	2017-12-29	2018-01-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
7301	46112	001	未定	1	2017-10-02	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	0.5	0	\N
7302	46113	001	未定	1	2017-10-02	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	0.5	0	\N
7307	46118	001	[東京地区]大崎本社 	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	－	\N	2	0	\N
7310	46121	001	適宜	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	365	0	\N
7624	46603	001	[東京地区]大崎本社 	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	開催日３日前までキャンセル可能です。	\N	2	0	\N
7318	46201	018	[大阪地区]京橋	2	2017-10-27	2017-09-03	2017-10-13	2017-10-23	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
7319	46201	017	[大阪地区]京橋	2	2017-09-13	2017-09-03	2017-08-30	2017-09-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
7320	46201	016	[大阪地区]京橋	2	2017-07-13	2017-09-03	2017-06-29	2017-07-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
7321	46201	015	[東京地区]品川	1	2018-03-28	2017-09-03	2018-03-14	2018-03-24	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
7322	46201	014	[東京地区]品川	1	2018-03-13	2017-09-03	2018-02-27	2018-03-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
7323	46201	013	[東京地区]品川	1	2018-02-19	2017-09-03	2018-02-05	2018-02-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
7324	46201	012	[東京地区]品川	1	2018-01-25	2017-09-03	2018-01-11	2018-01-21	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
7325	46201	011	[東京地区]品川	1	2018-01-09	2017-09-03	2017-12-26	2018-01-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
7326	46201	010	[東京地区]品川	1	2017-12-14	2017-09-03	2017-11-30	2017-12-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
7327	46201	009	[東京地区]品川	1	2017-11-27	2017-09-03	2017-11-13	2017-11-23	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
7328	46201	008	[東京地区]品川	1	2017-11-06	2017-09-03	2017-10-23	2017-11-02	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
7329	46201	007	[東京地区]品川	1	2017-10-23	2017-09-03	2017-10-09	2017-10-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
7330	46201	006	[東京地区]品川	1	2017-10-10	2017-09-03	2017-09-26	2017-10-06	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
7331	46201	004	[東京地区]品川	1	2017-08-28	2017-09-03	2017-08-14	2017-08-24	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9796	47121	001	[東京地区]汐留	1	2018-04-19	2017-09-03	2018-03-31	\N	\N	\N	\N	キャンセル不可です。	\N	0.5	0	\N
7618	46508	001	[東京地区]大崎本社 	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	開催日３日前までキャンセル可能です。	\N	0.5	0	\N
7332	46202	002	[東京地区]品川	1	2017-07-25	2017-09-03	2017-07-11	2017-07-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
7333	46202	016	[大阪地区]京橋	2	2017-11-10	2017-09-03	2017-10-27	2017-11-06	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
7334	46202	015	[大阪地区]京橋	2	2017-09-14	2017-09-03	2017-08-31	2017-09-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
7335	46202	014	[東京地区]品川	1	2018-03-14	2017-09-03	2018-02-28	2018-03-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
7336	46202	013	[東京地区]品川	1	2018-02-20	2017-09-03	2018-02-06	2018-02-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
7337	46202	012	[東京地区]品川	1	2018-01-26	2017-09-03	2018-01-12	2018-01-22	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
7338	46202	011	[東京地区]品川	1	2018-01-10	2017-09-03	2017-12-27	2018-01-04	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
7339	46202	010	[東京地区]品川	1	2017-12-15	2017-09-03	2017-12-01	2017-12-11	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
7340	46202	009	[東京地区]品川	1	2017-11-28	2017-09-03	2017-11-14	2017-11-22	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
7341	46202	008	[東京地区]品川	1	2017-11-07	2017-09-03	2017-10-24	2017-11-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
7342	46202	007	[東京地区]品川	1	2017-10-24	2017-09-03	2017-10-10	2017-10-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
7343	46202	006	[東京地区]品川	1	2017-10-11	2017-09-03	2017-09-27	2017-10-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
7344	46202	005	[東京地区]品川	1	2017-09-29	2017-09-03	2017-09-15	2017-09-25	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
7345	46202	004	[東京地区]品川	1	2017-08-29	2017-09-03	2017-08-15	2017-08-23	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
7625	46604	001	[東京地区]大崎本社 	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	開催日３日前までキャンセル可能です。	\N	2	0	\N
16241	48104	001	[東京地区]大崎本社 	1	2019-10-24	2019-10-25	\N	\N	\N	\N	\N	キャンセル不可。	\N	2	0	\N
7346	46202	003	[東京地区]品川	1	2017-08-15	2017-09-03	2017-08-01	2017-08-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
7347	46202	018	[大阪地区]京橋	2	2018-03-02	2017-09-03	2018-02-16	2018-02-26	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
7348	46202	001	[東京地区]品川	1	2017-07-04	2017-09-03	2017-06-20	2017-06-28	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
7349	46202	017	[大阪地区]京橋	2	2018-01-29	2017-09-03	2018-01-15	2018-01-23	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
7350	46203	003	[東京地区]品川	1	2017-10-12	2017-09-03	2017-09-28	2017-10-06	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	40824
7351	46203	004	[東京地区]品川	1	2017-11-29	2017-09-03	2017-11-15	2017-11-23	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	40824
7352	46203	001	[東京地区]品川	1	2017-08-03	2017-09-03	2017-07-20	2017-07-28	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	40824
7353	46203	009	[大阪地区]京橋	2	2018-03-19	2017-09-03	2018-03-05	2018-03-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	40824
7354	46203	008	[大阪地区]京橋	2	2017-12-18	2017-09-03	2017-12-04	2017-12-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	40824
7355	46203	007	[大阪地区]京橋	2	2017-09-27	2017-09-03	2017-09-13	2017-09-21	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	40824
7356	46203	006	[東京地区]品川	1	2018-03-15	2017-09-03	2018-03-01	2018-03-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	40824
7357	46203	005	[東京地区]品川	1	2018-02-21	2017-09-03	2018-02-07	2018-02-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	40824
7358	46203	002	[東京地区]品川	1	2017-09-07	2017-09-03	2017-08-24	2017-09-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	40824
7359	46204	004	[東京地区]品川	1	2017-11-29	2017-09-03	2017-11-15	2017-11-23	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	77112
16242	48105	002	[東京地区]大崎本社 	1	2019-06-07	2019-06-07	\N	\N	\N	\N	\N	キャンセル不可。	\N	1	0	\N
16243	48105	001	[関西地区]西日本事業所 	2	2019-06-06	2019-06-06	\N	\N	\N	\N	\N	キャンセル不可。	\N	1	0	\N
16244	48106	001	[東京地区]大崎本社 	1	2019-08-22	2019-08-23	\N	\N	\N	\N	\N	やむを得ない事情で欠席の場合は、次年度の受講が必須となりますのでご認識ください。	\N	2	0	\N
7360	46204	005	[東京地区]品川	1	2018-01-22	2017-09-03	2018-01-08	2018-01-16	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	77112
7361	46204	006	[東京地区]品川	1	2018-03-12	2017-09-03	2018-02-26	2018-03-06	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	77112
7362	46204	007	[大阪地区]京橋	2	2017-08-21	2017-09-03	2017-08-07	2017-08-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	77112
7363	46204	008	[大阪地区]京橋	2	2017-10-16	2017-09-03	2017-10-02	2017-10-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	77112
7364	46204	010	[大阪地区]京橋	2	2018-03-05	2017-09-03	2018-02-19	2018-02-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	77112
7365	46204	001	[東京地区]品川	1	2017-07-05	2017-09-03	2017-06-21	2017-06-29	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	77112
7366	46204	009	[大阪地区]京橋	2	2018-01-15	2017-09-03	2018-01-01	2018-01-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	77112
7367	46204	003	[東京地区]品川	1	2017-10-23	2017-09-03	2017-10-09	2017-10-17	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	77112
7368	46204	002	[東京地区]品川	1	2017-08-14	2017-09-03	2017-07-31	2017-08-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	77112
7369	46205	004	[大阪地区]京橋	2	2017-07-24	2017-09-03	2017-07-10	2017-07-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	81648
7370	46205	002	[東京地区]品川	1	2017-11-13	2017-09-03	2017-10-30	2017-11-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	81648
7371	46205	003	[東京地区]品川	1	2018-02-14	2017-09-03	2018-01-31	2018-02-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	81648
7372	46205	005	[大阪地区]京橋	2	2017-09-19	2017-09-03	2017-09-05	2017-09-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	81648
7373	46205	006	[大阪地区]京橋	2	2017-11-20	2017-09-03	2017-11-06	2017-11-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	81648
16245	48107	001	[東京地区]大崎本社 	1	2020-01-09	2020-01-10	\N	\N	\N	\N	\N	やむを得ない事情で欠席の場合は、次年度の受講が必須となりますのでご認識ください。	\N	2	0	\N
16246	48108	001	[東京地区]大崎本社 	1	2020-01-17	2020-01-17	\N	\N	\N	\N	\N	\N	\N	1	0	\N
16247	48108	002	[東京地区]大崎本社 	1	2020-01-24	2020-01-24	\N	\N	\N	\N	\N	\N	\N	1	0	\N
7374	46205	007	[大阪地区]京橋	2	2018-01-31	2017-09-03	2018-01-17	2018-01-25	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	81648
7375	46205	008	[大阪地区]京橋	2	2018-03-14	2017-09-03	2018-02-28	2018-03-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	81648
7376	46205	001	[東京地区]品川	1	2017-09-06	2017-09-03	2017-08-23	2017-08-31	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	81648
7377	46206	005	[大阪地区]京橋	2	2018-02-22	2017-09-03	2018-02-08	2018-02-16	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
7378	46206	001	[東京地区]品川	1	2017-08-30	2017-09-03	2017-08-16	2017-08-24	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
7379	46206	003	[東京地区]品川	1	2018-03-08	2017-09-03	2018-02-22	2018-03-02	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
7380	46206	002	[東京地区]品川	1	2017-11-27	2017-09-03	2017-11-13	2017-11-21	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
7381	46206	004	[大阪地区]京橋	2	2017-09-25	2017-09-03	2017-09-11	2017-09-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
7382	46207	005	[大阪地区]中之島	2	2017-07-31	2017-09-03	2017-07-17	2017-07-10	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	66096
7383	46207	001	[東京地区]西新宿	1	2017-07-20	2017-09-03	2017-07-06	2017-06-28	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	66096
7384	46207	003	[東京地区]西新宿	1	2017-10-12	2017-09-03	2017-09-28	2017-09-21	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	66096
7385	46207	002	[東京地区]西新宿	1	2017-09-11	2017-09-03	2017-08-28	2017-08-21	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	66096
7386	46207	006	[大阪地区]中之島	2	2017-10-23	2017-09-03	2017-10-09	2017-10-02	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	66096
7387	46207	004	[東京地区]西新宿	1	2017-11-27	2017-09-03	2017-11-13	2017-11-06	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	66096
16248	48109	001	[東京地区]汐留	1	2019-05-13	2019-05-13	2019-03-31	\N	\N	\N	\N	キャンセル不可。	\N	0.5	0	\N
16249	48110	001	[東京地区]大崎本社 	1	2020-03-19	2020-03-19	\N	\N	\N	\N	\N	キャンセル不可。	\N	1	0	\N
16250	48112	001	[東京地区]大崎本社 	1	2019-11-14	2019-11-15	\N	\N	\N	\N	\N	キャンセル不可。	\N	2	0	\N
7388	46208	001	[東京地区]西新宿	1	2017-07-24	2017-09-03	2017-07-10	2017-06-30	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	102060
7389	46208	002	[東京地区]西新宿	1	2017-09-13	2017-09-03	2017-08-30	2017-08-23	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	102060
7390	46208	003	[東京地区]西新宿	1	2017-10-16	2017-09-03	2017-10-02	2017-09-25	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	102060
7391	46208	004	[東京地区]西新宿	1	2017-11-29	2017-09-03	2017-11-15	2017-11-08	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	102060
7392	46208	005	[大阪地区]中之島	2	2017-08-02	2017-09-03	2017-07-19	2017-07-12	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	102060
7393	46208	006	[大阪地区]中之島	2	2017-10-25	2017-09-03	2017-10-11	2017-10-04	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	102060
7394	46209	001	[東京地区]品川	1	2017-07-19	2017-09-03	2017-07-05	2017-07-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	73332
7395	46209	002	[東京地区]品川	1	2017-08-16	2017-09-03	2017-08-02	2017-08-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	73332
7396	46209	003	[東京地区]品川	1	2017-09-27	2017-09-03	2017-09-13	2017-09-21	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	73332
7397	46209	004	[東京地区]品川	1	2017-10-16	2017-09-03	2017-10-02	2017-10-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	73332
7398	46209	006	[東京地区]品川	1	2018-01-10	2017-09-03	2017-12-27	2018-01-04	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	73332
7399	46209	007	[東京地区]品川	1	2018-03-12	2017-09-03	2018-02-26	2018-03-06	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	73332
7400	46209	009	[大阪地区]京橋	2	2018-02-21	2017-09-03	2018-02-07	2018-02-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	73332
7401	46209	005	[東京地区]品川	1	2017-11-20	2017-09-03	2017-11-06	2017-11-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	73332
16251	48113	001	－	1	2019-04-01	2020-05-31	2019-04-01	\N	\N	\N	\N	※2019年度の申込は終了しました。	\N	365	0	\N
16252	48116	001	[東京地区]大崎本社 	1	2019-08-01	2019-08-02	2019-07-24	2019-07-29	\N	\N	\N	研修開催日1ヶ月前までキャンセル可能です。\r\nまたキャンセルにあたっては、部室長の承認を得る必要があります。	\N	2	0	\N
7402	46209	008	[大阪地区]京橋	2	2017-07-26	2017-09-03	2017-07-12	2017-07-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	73332
7403	46210	001	[東京地区]品川	1	2017-07-26	2017-09-03	2017-07-12	2017-07-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	30240.000000000004
7404	46211	011	[東京地区]品川	1	2017-11-27	2017-09-03	2017-11-13	2017-11-21	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49140
7405	46211	001	[東京地区]品川	1	2017-07-13	2017-09-03	2017-06-29	2017-07-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49140
7406	46211	002	[東京地区]品川	1	2017-08-03	2017-09-03	2017-07-20	2017-07-28	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49140
7407	46211	003	[東京地区]品川	1	2017-08-28	2017-09-03	2017-08-14	2017-08-22	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49140
7408	46211	004	[東京地区]品川	1	2017-09-11	2017-09-03	2017-08-28	2017-09-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49140
7409	46211	005	[東京地区]品川	1	2017-10-19	2017-09-03	2017-10-05	2017-10-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49140
7410	46211	006	[東京地区]品川	1	2017-11-16	2017-09-03	2017-11-02	2017-11-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49140
7411	46211	007	[東京地区]品川	1	2017-12-25	2017-09-03	2017-12-11	2017-12-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49140
7412	46211	008	[東京地区]品川	1	2018-02-01	2017-09-03	2018-01-18	2018-01-26	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49140
7413	46211	009	[東京地区]品川	1	2018-03-15	2017-09-03	2018-03-01	2018-03-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49140
7414	46211	010	[東京地区]品川	1	2017-07-27	2017-09-03	2017-07-13	2017-07-21	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49140
7415	46211	012	[東京地区]品川	1	2018-01-25	2017-09-03	2018-01-11	2018-01-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49140
16253	48117	001	[東京地区]大崎本社 	1	2019-07-18	2019-07-19	2019-07-12	2019-07-12	\N	\N	\N	研修開催日1ヶ月前までキャンセル可能です。\r\nまたキャンセルにあたっては、部室長の承認を得る必要があります。	\N	2	0	\N
7416	46212	001	[東京地区]西新宿	1	2017-07-10	2017-09-03	2017-06-26	2017-06-19	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
7417	46212	002	[東京地区]西新宿	1	2017-08-07	2017-09-03	2017-07-24	2017-07-17	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
7418	46212	004	[東京地区]西新宿	1	2017-10-02	2017-09-03	2017-09-18	2017-09-11	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
7419	46212	005	[東京地区]西新宿	1	2017-11-06	2017-09-03	2017-10-23	2017-10-16	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
7420	46212	006	[東京地区]西新宿	1	2017-12-04	2017-09-03	2017-11-20	2017-11-13	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
7421	46212	007	[東京地区]西新宿	1	2017-07-03	2017-09-03	2017-06-19	2017-06-12	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
7422	46212	008	[東京地区]西新宿	1	2017-08-28	2017-09-03	2017-08-14	2017-08-07	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
7423	46212	009	[東京地区]西新宿	1	2017-10-10	2017-09-03	2017-09-26	2017-09-19	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
7424	46212	010	[東京地区]西新宿	1	2017-12-05	2017-09-03	2017-11-21	2017-11-14	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
7425	46212	003	[東京地区]西新宿	1	2017-09-04	2017-09-03	2017-08-21	2017-08-14	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
7426	46213	011	[大阪地区]京橋	2	2017-07-27	2017-09-03	2017-07-13	2017-07-21	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49896
7427	46213	001	[東京地区]品川	1	2017-07-06	2017-09-03	2017-06-22	2017-06-30	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49896
7428	46213	013	[大阪地区]京橋	2	2018-01-15	2017-09-03	2018-01-01	2018-01-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49896
7429	46213	012	[大阪地区]京橋	2	2017-10-12	2017-09-03	2017-09-28	2017-10-06	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49896
16254	48118	001	[東京地区]大崎本社 	1	2019-09-12	2019-09-13	2019-09-06	2019-09-06	\N	\N	\N	研修開催日1ヶ月前までキャンセル可能です。\r\nまたキャンセルにあたっては、部室長の承認を得る必要があります。	\N	2	0	\N
7430	46213	010	[東京地区]品川	1	2018-03-22	2017-09-03	2018-03-08	2018-03-16	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49896
7431	46213	009	[東京地区]品川	1	2018-02-22	2017-09-03	2018-02-08	2018-02-16	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49896
7432	46213	008	[東京地区]品川	1	2018-01-18	2017-09-03	2018-01-04	2018-01-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49896
7433	46213	007	[東京地区]品川	1	2017-12-18	2017-09-03	2017-12-04	2017-12-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49896
7434	46213	006	[東京地区]品川	1	2017-11-09	2017-09-03	2017-10-26	2017-11-03	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49896
7435	46213	005	[東京地区]品川	1	2017-10-16	2017-09-03	2017-10-02	2017-10-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49896
7436	46213	004	[東京地区]品川	1	2017-09-26	2017-09-03	2017-09-12	2017-09-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49896
7437	46213	003	[東京地区]品川	1	2017-08-14	2017-09-03	2017-07-31	2017-08-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49896
7438	46213	002	[東京地区]品川	1	2017-07-18	2017-09-03	2017-07-04	2017-07-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49896
7439	46214	002	[東京地区]品川	1	2017-08-10	2017-09-03	2017-07-27	2017-08-04	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7440	46214	010	[大阪地区]京橋	2	2017-09-22	2017-09-03	2017-09-08	2017-09-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7441	46214	008	[東京地区]品川	1	2018-03-07	2017-09-03	2018-02-21	2018-03-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7442	46214	007	[東京地区]品川	1	2018-01-24	2017-09-03	2018-01-10	2018-01-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7443	46214	006	[東京地区]品川	1	2017-12-20	2017-09-03	2017-12-06	2017-12-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7444	46214	005	[東京地区]品川	1	2017-11-24	2017-09-03	2017-11-10	2017-11-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7445	46214	004	[東京地区]品川	1	2017-10-25	2017-09-03	2017-10-11	2017-10-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7446	46214	003	[東京地区]品川	1	2017-09-25	2017-09-03	2017-09-11	2017-09-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7447	46214	011	[大阪地区]京橋	2	2017-11-02	2017-09-03	2017-10-19	2017-10-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7448	46214	012	[大阪地区]京橋	2	2018-01-12	2017-09-03	2017-12-29	2018-01-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7449	46214	013	[大阪地区]京橋	2	2018-03-09	2017-09-03	2018-02-23	2018-03-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7450	46214	009	[大阪地区]京橋	2	2017-07-06	2017-09-03	2017-06-22	2017-06-30	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7451	46214	001	[東京地区]品川	1	2017-07-21	2017-09-03	2017-07-07	2017-07-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
9789	47109	001	[東京地区]大崎本社 	1	2019-03-22	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	1	0	\N
9790	47112	001	[東京地区]大崎本社 	1	2018-11-15	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	2	0	\N
9791	47115	001	[東京地区]大崎本社 	1	2018-11-02	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	1	0	\N
9792	47116	001	[東京地区]大崎本社 	1	2018-07-12	2017-09-03	2018-06-11	2018-06-11	\N	\N	\N	研修開催日1ヶ月前までキャンセル可能です。\r\nまたキャンセルにあたっては、部門長の承認を得る必要があります。	\N	2	0	\N
9793	47117	001	[東京地区]大崎本社 	1	2018-08-02	2017-09-03	2018-07-02	2018-07-02	\N	\N	\N	研修開催日1ヶ月前までキャンセル可能です。\r\nまたキャンセルにあたっては、部門長の承認を得る必要があります。	\N	2	0	\N
7452	46215	003	[東京地区]品川	1	2017-08-09	2017-09-03	2017-07-26	2017-08-03	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	52920
7453	46215	004	[東京地区]品川	1	2017-09-07	2017-09-03	2017-08-24	2017-09-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	52920
7621	46511	001	[東京地区]大崎本社 	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	開催日３日前までキャンセル可能です。	\N	0.5	0	\N
9794	47118	001	[東京地区]大崎本社 	1	2018-09-06	2017-09-03	2018-08-06	2018-08-06	\N	\N	\N	研修開催日1ヶ月前までキャンセル可能です。\r\nまたキャンセルにあたっては、部門長の承認を得る必要があります。	\N	2	0	\N
9795	47119	001	[東京地区]大崎本社 	1	2018-10-11	2017-09-03	2018-09-10	2018-09-10	\N	\N	\N	研修開催日1ヶ月前までキャンセル可能です。\r\nまたキャンセルにあたっては、部門長の承認を得る必要があります。	\N	2	0	\N
7611	46501	001	[東京地区]大崎本社 	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	開催日３日前までキャンセル可能です。	\N	0.5	0	\N
9797	47151	001	－	3	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	90	0	43200
9798	47152	001	－	3	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	キャンセル不可です。	\N	365	0	86400
7454	46215	002	[東京地区]品川	1	2017-07-20	2017-09-03	2017-07-06	2017-07-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	52920
7510	46221	001	[東京地区]品川	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	91368
9799	47201	015	[東京地区]品川	1	2018-12-25	2017-09-03	2018-12-04	2018-12-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
7626	46605	001	[東京地区]大崎本社 	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	開催日３日前までキャンセル可能です。	\N	9	0	\N
7627	46606	001	[東京地区]北品川	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	－	\N	8	0	64800
9800	47201	014	[東京地区]品川	1	2018-11-27	2017-09-03	2018-11-06	2018-11-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9801	47201	013	[東京地区]品川	1	2018-11-05	2017-09-03	2018-10-16	2018-10-30	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9802	47201	012	[東京地区]品川	1	2018-10-25	2017-09-03	2018-10-04	2018-10-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9803	47201	001	[東京地区]品川	1	2018-06-04	2017-09-03	2018-05-15	2018-05-31	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9804	47201	022	[大阪地区]京橋	2	2018-11-20	2017-09-03	2018-10-31	2018-11-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9805	47201	002	[東京地区]品川	1	2018-07-05	2017-09-03	2018-06-15	2018-06-29	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9806	47201	003	[東京地区]品川	1	2018-07-17	2017-09-03	2018-06-26	2018-07-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9807	47201	004	[東京地区]品川	1	2018-08-01	2017-09-03	2018-07-11	2018-07-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9808	47201	005	[東京地区]品川	1	2018-08-16	2017-09-03	2018-07-27	2018-08-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9809	47201	006	[東京地区]品川	1	2018-09-03	2017-09-03	2018-08-14	2018-08-30	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9810	47201	007	[東京地区]品川	1	2018-09-20	2017-09-03	2018-08-30	2018-09-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9811	47201	008	[大阪地区]京橋	2	2018-05-21	2017-09-03	2018-04-26	2018-05-17	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9812	47201	010	[大阪地区]京橋	2	2018-08-30	2017-09-03	2018-08-10	2018-08-24	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9813	47201	011	[東京地区]品川	1	2018-10-04	2017-09-03	2018-09-12	2018-09-28	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9815	47201	009	[大阪地区]京橋	2	2018-07-24	2017-09-03	2018-07-03	2018-07-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9816	47201	018	[大阪地区]京橋	2	2019-03-11	2017-09-03	2019-02-19	2019-03-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9817	47201	023	[大阪地区]京橋	2	2019-01-31	2017-09-03	2019-01-10	2019-01-25	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9818	47201	021	[大阪地区]京橋	2	2018-10-23	2017-09-03	2018-10-02	2018-10-17	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9819	47201	019	[東京地区]品川	1	2019-03-22	2017-09-03	2019-03-01	2019-03-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9820	47201	017	[東京地区]品川	1	2019-02-04	2017-09-03	2019-01-15	2019-01-29	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9821	47201	016	[東京地区]品川	1	2019-01-17	2017-09-03	2018-12-20	2019-01-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	24948
9822	47202	012	[東京地区]品川	1	2018-10-05	2017-09-03	2018-09-13	2018-10-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9823	47202	005	[東京地区]品川	1	2018-08-02	2017-09-03	2018-07-12	2018-07-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9824	47202	006	[東京地区]品川	1	2018-08-17	2017-09-03	2018-07-30	2018-08-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9825	47202	007	[東京地区]品川	1	2018-09-04	2017-09-03	2018-08-15	2018-08-31	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9826	47202	008	[東京地区]品川	1	2018-09-21	2017-09-03	2018-08-31	2018-09-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9827	47202	009	[大阪地区]京橋	2	2018-05-22	2017-09-03	2018-04-27	2018-05-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9828	47202	010	[大阪地区]京橋	2	2018-07-25	2017-09-03	2018-07-04	2018-07-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9829	47202	011	[大阪地区]京橋	2	2018-08-31	2017-09-03	2018-08-13	2018-08-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9830	47202	013	[東京地区]品川	1	2018-10-26	2017-09-03	2018-10-05	2018-10-22	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9831	47202	014	[東京地区]品川	1	2018-11-06	2017-09-03	2018-10-17	2018-10-31	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9832	47202	015	[東京地区]品川	1	2018-11-28	2017-09-03	2018-11-07	2018-11-21	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9833	47202	016	[東京地区]品川	1	2018-12-26	2017-09-03	2018-12-05	2018-12-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9834	47202	017	[東京地区]品川	1	2019-01-18	2017-09-03	2018-12-21	2019-01-11	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9835	47202	018	[東京地区]品川	1	2019-02-05	2017-09-03	2019-01-16	2019-01-30	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9836	47202	019	[東京地区]品川	1	2019-02-22	2017-09-03	2019-02-01	2019-02-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9837	47202	020	[大阪地区]京橋	2	2018-10-24	2017-09-03	2018-10-03	2018-10-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9838	47202	021	[大阪地区]京橋	2	2018-11-21	2017-09-03	2018-11-01	2018-11-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9839	47202	022	[大阪地区]京橋	2	2019-02-01	2017-09-03	2019-01-11	2019-01-28	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9840	47202	023	[大阪地区]京橋	2	2018-03-12	2017-09-03	2018-02-20	2018-03-06	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9841	47202	001	[東京地区]品川	1	2018-05-15	2017-09-03	2018-04-20	2018-05-11	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9842	47202	003	[東京地区]品川	1	2018-07-06	2017-09-03	2018-06-18	2018-07-02	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9843	47202	002	[東京地区]品川	1	2018-06-05	2017-09-03	2018-05-16	2018-06-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9844	47202	004	[東京地区]品川	1	2018-07-18	2017-09-03	2018-06-27	2018-07-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	22680
9845	47203	001	[東京地区]品川	1	2018-06-06	2017-09-03	2018-05-17	2018-06-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	40824
9846	47203	002	[東京地区]品川	1	2018-08-07	2017-09-03	2018-07-18	2018-08-03	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	40824
9847	47203	003	[東京地区]品川	1	2018-09-05	2017-09-03	2018-08-16	2018-08-31	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	40824
9848	47203	004	[大阪地区]京橋	2	2018-05-23	2017-09-03	2018-05-01	2018-05-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	40824
9849	47203	010	[大阪地区]京橋	2	2019-03-25	2017-09-03	2019-03-04	2019-03-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	40824
9850	47203	009	[大阪地区]京橋	2	2018-12-17	2017-09-03	2018-11-27	2018-12-11	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	40824
9851	47203	008	[東京地区]品川	1	2019-02-25	2017-09-03	2019-02-04	2019-02-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	40824
9852	47203	007	[東京地区]品川	1	2019-01-28	2017-09-03	2019-01-07	2019-01-22	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	40824
9853	47203	006	[東京地区]品川	1	2018-11-29	2017-09-03	2018-11-08	2018-11-22	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	40824
9854	47203	005	[大阪地区]京橋	2	2018-09-25	2017-09-03	2018-09-03	2018-09-21	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	40824
9855	47204	006	[東京地区]品川	1	2018-08-06	2017-09-03	2018-07-17	2018-08-02	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9856	47204	007	[東京地区]品川	1	2018-08-22	2017-09-03	2018-08-02	2018-08-17	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9857	47204	009	[東京地区]品川	1	2018-09-20	2017-09-03	2018-08-30	2018-09-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9858	47204	020	[東京地区]品川	1	2019-01-28	2017-09-03	2019-01-07	2019-01-22	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9859	47204	027	[大阪地区]京橋	2	2019-02-25	2017-09-03	2019-02-04	2019-02-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9860	47204	026	[大阪地区]京橋	2	2019-01-24	2017-09-03	2019-01-03	2019-01-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9861	47204	025	[大阪地区]京橋	2	2018-11-19	2017-09-03	2018-10-30	2018-11-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9862	47204	024	[東京地区]品川	1	2018-03-28	2017-09-03	2018-03-08	2018-03-22	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9863	47204	023	[東京地区]品川	1	2019-03-18	2017-09-03	2019-02-26	2019-03-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9864	47204	022	[東京地区]品川	1	2019-03-07	2017-09-03	2019-02-15	2019-03-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9865	47204	014	[東京地区]品川	1	2018-10-18	2017-09-03	2018-09-27	2018-10-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9866	47204	015	[東京地区]品川	1	2018-11-08	2017-09-03	2018-10-19	2018-11-02	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9867	47204	016	[東京地区]品川	1	2018-11-29	2017-09-03	2018-11-08	2018-11-22	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9868	47204	017	[東京地区]品川	1	2018-12-10	2017-09-03	2018-11-19	2018-12-04	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9869	47204	018	[東京地区]品川	1	2018-12-25	2017-09-03	2018-12-04	2018-12-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9870	47204	019	[東京地区]品川	1	2019-01-10	2017-09-03	2018-12-13	2019-01-04	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9871	47204	021	[東京地区]品川	1	2019-02-12	2017-09-03	2019-01-22	2019-02-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9872	47204	001	[東京地区]品川	1	2018-05-22	2017-09-03	2018-04-27	2018-05-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9873	47204	002	[東京地区]品川	1	2018-06-13	2017-09-03	2018-05-24	2018-06-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9874	47204	003	[東京地区]品川	1	2018-07-02	2017-09-03	2018-06-12	2018-06-28	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9875	47204	004	[東京地区]品川	1	2018-07-17	2017-09-03	2018-06-26	2018-07-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9876	47204	005	[東京地区]品川	1	2018-07-30	2017-09-03	2018-07-09	2018-07-26	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9877	47204	008	[東京地区]品川	1	2018-09-11	2017-09-03	2018-08-22	2018-09-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9878	47204	010	[大阪地区]京橋	2	2018-05-14	2017-09-03	2018-04-19	2018-05-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9879	47204	011	[大阪地区]京橋	2	2018-07-09	2017-09-03	2018-06-19	2018-07-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9880	47204	012	[大阪地区]京橋	2	2018-09-03	2017-09-03	2018-08-14	2018-08-30	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9881	47204	013	[東京地区]品川	1	2018-10-04	2017-09-03	2018-09-12	2018-09-28	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
9882	47205	002	[東京地区]浜松町	1	2018-11-13	2017-09-03	2018-10-29	2018-10-29	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	2	0	70200
9897	47209	001	[大阪地区]京橋	2	2018-06-12	2017-09-03	2018-05-23	2018-06-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
9883	47205	001	[東京地区]浜松町	1	2018-08-07	2017-09-03	2018-07-23	2018-07-23	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	2	0	70200
9884	47206	001	[東京地区]浜松町	1	2018-08-02	2017-09-03	2018-07-18	2018-07-18	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	2	0	53352
9885	47207	004	[東京地区]品川	1	2019-01-28	2017-09-03	2019-01-07	2019-01-22	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	81648
9886	47207	002	[東京地区]品川	1	2018-09-10	2017-09-03	2018-08-21	2018-09-06	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	81648
9887	47207	003	[東京地区]品川	1	2018-11-14	2017-09-03	2018-10-25	2018-11-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	81648
9888	47207	001	[東京地区]品川	1	2018-07-25	2017-09-03	2018-07-04	2018-07-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	81648
9889	47208	003	[東京地区]品川	1	2018-10-30	2017-09-03	2018-10-10	2018-10-24	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	37800
9890	47208	004	[東京地区]品川	1	2018-12-14	2017-09-03	2018-11-26	2018-12-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	37800
9891	47208	002	[東京地区]品川	1	2018-09-14	2017-09-03	2018-08-27	2018-09-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	37800
9892	47208	001	[東京地区]品川	1	2018-06-13	2017-09-03	2018-05-24	2018-06-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	37800
9893	47208	005	[東京地区]品川	1	2019-03-15	2017-09-03	2019-02-25	2019-03-11	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	37800
9894	47209	002	[東京地区]品川	1	2018-06-18	2017-09-03	2018-05-29	2018-06-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
9895	47209	003	[東京地区]品川	1	2018-07-26	2017-09-03	2018-07-05	2018-07-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
9896	47209	004	[東京地区]品川	1	2018-08-23	2017-09-03	2018-08-03	2018-08-17	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
9898	47209	011	[大阪地区]京橋	2	2018-12-04	2017-09-03	2018-11-13	2018-11-28	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
9899	47209	008	[東京地区]品川	1	2019-01-28	2017-09-03	2019-01-07	2019-01-22	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
9900	47209	007	[東京地区]品川	1	2018-12-13	2017-09-03	2018-11-22	2018-12-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
9901	47209	006	[東京地区]品川	1	2018-11-01	2017-09-03	2018-10-12	2018-10-26	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
9902	47209	009	[東京地区]品川	1	2019-02-21	2017-09-03	2019-01-31	2019-02-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
9903	47209	005	[東京地区]品川	1	2018-09-25	2017-09-03	2018-09-03	2018-09-21	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
9904	47209	010	[東京地区]品川	1	2019-03-28	2017-09-03	2019-03-07	2019-03-22	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
9905	47210	004	[東京地区]西新宿	1	2018-08-13	2017-09-03	2018-07-24	2018-07-27	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
9906	47210	008	[東京地区]西新宿	1	2018-10-09	2017-09-03	2018-09-14	2018-09-21	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
9907	47210	010	[東京地区]西新宿	1	2018-12-03	2017-09-03	2018-11-12	2018-11-16	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
9908	47210	011	[東京地区]西新宿	1	2019-01-15	2017-09-03	2018-12-17	2018-12-31	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
9909	47210	012	[東京地区]西新宿	1	2019-02-12	2017-09-03	2019-01-22	2019-01-28	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
9910	47210	013	[東京地区]西新宿	1	2019-03-11	2017-09-03	2019-02-19	2019-02-22	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
9911	47210	014	[大阪地区]中之島	2	2018-10-22	2017-09-03	2018-10-03	2018-10-05	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
9912	47210	015	[大阪地区]中之島	2	2019-02-18	2017-09-03	2019-01-28	2019-02-01	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
9913	47210	001	[東京地区]西新宿	1	2018-05-14	2017-09-03	2018-04-19	2018-04-27	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
9914	47210	002	[東京地区]西新宿	1	2018-06-04	2017-09-03	2018-05-15	2018-05-18	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
9915	47210	003	[東京地区]西新宿	1	2018-07-02	2017-09-03	2018-06-12	2018-06-15	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
9916	47210	005	[東京地区]西新宿	1	2018-09-18	2017-09-03	2018-08-28	2018-09-03	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
9917	47210	006	[大阪地区]中之島	2	2018-06-12	2017-09-03	2018-05-23	2018-05-28	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
9918	47210	007	[大阪地区]中之島	2	2018-07-03	2017-09-03	2018-06-13	2018-06-18	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
9919	47210	009	[東京地区]西新宿	1	2018-11-05	2017-09-03	2018-10-16	2018-10-19	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	58320.00000000001
9920	47211	004	[大阪地区]京橋	2	2018-06-20	2017-09-03	2018-05-31	2018-06-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	25704
9921	47211	005	[大阪地区]京橋	2	2018-09-21	2017-09-03	2018-08-31	2018-09-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	25704
9922	47211	006	[東京地区]品川	1	2018-11-02	2017-09-03	2018-10-15	2018-10-29	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	25704
9923	47211	007	[東京地区]品川	1	2019-01-30	2017-09-03	2019-01-09	2019-01-24	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	25704
9924	47211	009	[大阪地区]京橋	2	2018-12-03	2017-09-03	2018-11-12	2018-11-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	25704
9925	47211	010	[大阪地区]京橋	2	2019-03-04	2017-09-03	2019-02-12	2019-02-26	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	25704
9926	47211	008	[東京地区]品川	1	2019-03-14	2017-09-03	2019-02-22	2019-03-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	25704
9927	47211	003	[東京地区]品川	1	2018-09-06	2017-09-03	2018-08-17	2018-08-31	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	25704
9928	47211	002	[東京地区]品川	1	2018-07-04	2017-09-03	2018-06-14	2018-06-29	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	25704
9929	47211	001	[東京地区]品川	1	2018-05-21	2017-09-03	2018-04-26	2018-05-17	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	25704
9930	47212	005	[東京地区]品川	1	2018-10-03	2017-09-03	2018-09-11	2018-09-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	43200
9931	47212	006	[東京地区]品川	1	2018-11-05	2017-09-03	2018-10-16	2018-10-30	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	43200
9932	47212	008	[東京地区]品川	1	2019-01-18	2017-09-03	2018-12-21	2019-01-11	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	43200
9933	47212	009	[東京地区]品川	1	2019-02-01	2017-09-03	2019-01-11	2019-01-28	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	43200
9934	47212	010	[東京地区]品川	1	2019-03-04	2017-09-03	2019-02-12	2019-02-26	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	43200
9935	47212	001	[東京地区]品川	1	2018-05-11	2017-09-03	2018-04-18	2018-05-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	43200
9936	47212	002	[東京地区]品川	1	2018-07-02	2017-09-03	2018-06-12	2018-06-28	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	43200
9937	47212	003	[東京地区]品川	1	2018-08-01	2017-09-03	2018-07-11	2018-07-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	43200
9938	47212	004	[東京地区]品川	1	2018-09-05	2017-09-03	2018-08-16	2018-08-31	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	43200
9939	47212	007	[東京地区]品川	1	2018-11-19	2017-09-03	2018-10-30	2018-11-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	43200
9940	47213	002	[東京地区]泉岳寺	1	2018-10-15	2017-09-03	2018-09-25	2018-10-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	145800
9941	47213	001	[東京地区]泉岳寺	1	2018-09-10	2017-09-03	2018-08-20	2018-09-04	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	145800
9942	47214	004	[大阪地区]中之島	2	2018-07-09	2017-09-03	2018-06-19	2018-06-22	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	66096
9943	47214	008	[東京地区]西新宿	1	2018-11-12	2017-09-03	2018-10-23	2018-10-26	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	66096
9944	47214	001	[東京地区]西新宿	1	2018-05-31	2017-09-03	2018-05-11	2018-05-16	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	66096
9945	47214	007	[東京地区]西新宿	1	2019-02-21	2017-09-03	2019-01-31	2019-02-06	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	66096
9946	47214	003	[東京地区]西新宿	1	2018-08-16	2017-09-03	2018-07-27	2018-08-01	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	66096
9947	47214	002	[東京地区]西新宿	1	2018-07-09	2017-09-03	2018-06-19	2018-06-22	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	66096
9948	47214	005	[東京地区]西新宿	1	2018-10-18	2017-09-03	2018-09-27	2018-10-03	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	66096
9949	47214	006	[東京地区]西新宿	1	2018-11-29	2017-09-03	2018-11-08	2018-11-14	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	66096
9950	47214	009	[東京地区]西新宿	1	2019-03-04	2017-09-03	2019-02-12	2019-02-15	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	66096
9951	47215	004	[大阪地区]中之島	2	2018-07-11	2017-09-03	2018-06-21	2018-06-26	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	102060
9952	47215	003	[東京地区]西新宿	1	2018-08-20	2017-09-03	2018-07-31	2018-08-03	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	102060
9953	47215	005	[東京地区]西新宿	1	2018-10-18	2017-09-03	2018-09-27	2018-10-03	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	102060
9954	47215	008	[大阪地区]中之島	2	2018-11-14	2017-09-03	2018-10-25	2018-10-30	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	102060
9955	47215	009	[大阪地区]中之島	2	2019-03-06	2017-09-03	2019-02-14	2019-02-19	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	102060
9956	47215	007	[東京地区]西新宿	1	2019-02-25	2017-09-03	2019-02-04	2019-02-08	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	102060
9957	47215	006	[東京地区]西新宿	1	2018-12-03	2017-09-03	2018-11-12	2018-11-16	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	102060
9958	47215	001	[東京地区]西新宿	1	2018-06-04	2017-09-03	2018-05-15	2018-05-18	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	102060
9959	47215	002	[東京地区]西新宿	1	2018-07-11	2017-09-03	2018-06-21	2018-06-26	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	102060
9960	47216	009	[大阪地区]中之島	2	2019-03-13	2017-09-03	2019-02-21	2019-02-26	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
9961	47216	001	[東京地区]西新宿	1	2018-06-11	2017-09-03	2018-05-22	2018-05-25	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
9962	47216	002	[東京地区]西新宿	1	2018-07-19	2017-09-03	2018-06-28	2018-07-04	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
9963	47216	003	[東京地区]西新宿	1	2018-08-27	2017-09-03	2018-08-07	2018-08-10	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
9964	47216	004	[大阪地区]中之島	2	2018-07-19	2017-09-03	2018-06-28	2018-07-04	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
9965	47216	005	[東京地区]西新宿	1	2018-10-29	2017-09-03	2018-10-09	2018-10-12	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
9966	47216	006	[東京地区]西新宿	1	2018-12-10	2017-09-03	2018-11-19	2018-11-22	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
9967	47216	007	[東京地区]西新宿	1	2019-03-04	2017-09-03	2019-02-12	2019-02-15	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
9968	47216	008	[大阪地区]中之島	2	2018-11-21	2017-09-03	2018-11-01	2018-11-06	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
9969	47217	004	[東京地区]品川	1	2018-09-03	2017-09-03	2018-08-14	2018-08-30	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
9970	47217	005	[東京地区]品川	1	2018-10-11	2017-09-03	2018-09-19	2018-10-04	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
9971	47217	006	[東京地区]品川	1	2018-11-19	2017-09-03	2018-10-30	2018-11-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
9972	47217	009	[大阪地区]京橋	2	2018-12-13	2017-09-03	2018-11-22	2018-12-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
9973	47217	007	[東京地区]品川	1	2018-12-25	2017-09-03	2018-12-04	2018-12-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
9974	47217	008	[東京地区]品川	1	2019-02-14	2017-09-03	2019-01-24	2019-02-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
9975	47217	001	[東京地区]品川	1	2018-05-23	2017-09-03	2018-05-01	2018-05-17	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
9976	47217	002	[東京地区]品川	1	2018-06-28	2017-09-03	2018-06-08	2018-06-22	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
9977	47217	003	[東京地区]品川	1	2018-07-30	2017-09-03	2018-07-09	2018-07-26	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
9978	47218	005	[東京地区]西新宿	1	2018-12-07	2017-09-03	2018-11-16	2018-11-22	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	48600
9979	47218	003	[東京地区]西新宿	1	2018-08-24	2017-09-03	2018-08-06	2018-08-09	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	48600
9980	47218	004	[東京地区]西新宿	1	2018-10-18	2017-09-03	2018-09-27	2018-10-03	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	48600
9981	47218	006	[東京地区]西新宿	1	2019-01-16	2017-09-03	2018-12-20	2018-12-28	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	48600
9982	47218	007	[東京地区]西新宿	1	2019-02-20	2017-09-03	2019-01-30	2019-02-05	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	48600
9983	47218	001	[東京地区]西新宿	1	2018-06-11	2017-09-03	2018-05-22	2018-05-25	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	48600
9984	47218	002	[東京地区]西新宿	1	2018-07-27	2017-09-03	2018-07-06	2018-07-12	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	48600
9985	47219	007	[東京地区]西新宿	1	2018-02-12	2017-09-03	2018-01-23	2018-01-26	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	97200
9986	47219	001	[東京地区]西新宿	1	2018-06-11	2017-09-03	2018-05-22	2018-05-25	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	97200
9987	47219	003	[東京地区]西新宿	1	2018-10-22	2017-09-03	\N	2018-10-05	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	97200
9988	47219	002	[東京地区]西新宿	1	2018-08-09	2017-09-03	2018-07-20	2018-07-25	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	97200
9989	47219	006	[東京地区]西新宿	1	2019-01-28	2017-09-03	2018-12-28	2019-01-11	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	97200
9990	47219	005	[東京地区]西新宿	1	2019-01-17	2017-09-03	2018-12-26	2019-01-02	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	97200
9991	47219	004	[東京地区]西新宿	1	2018-11-19	2017-09-03	2018-10-30	2018-11-02	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	97200
9992	47220	004	[東京地区]品川	1	2018-06-13	2017-09-03	2018-05-24	2018-06-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
9993	47220	005	[東京地区]品川	1	2018-07-09	2017-09-03	2018-06-19	2018-07-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
9994	47220	006	[東京地区]品川	1	2018-07-23	2017-09-03	2018-07-02	2018-07-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
9995	47220	007	[東京地区]品川	1	2018-08-01	2017-09-03	2018-07-11	2018-07-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
9996	47220	008	[東京地区]品川	1	2018-08-13	2017-09-03	2018-07-24	2018-08-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
9997	47220	009	[東京地区]品川	1	2018-09-10	2017-09-03	2018-08-21	2018-09-06	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
9998	47220	010	[東京地区]品川	1	2018-09-26	2017-09-03	2018-09-04	2018-09-21	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
9999	47220	011	[大阪地区]京橋	2	2018-05-14	2017-09-03	2018-04-19	2018-05-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
10000	47220	012	[大阪地区]京橋	2	2018-08-06	2017-09-03	2018-07-17	2018-08-02	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
10001	47220	013	[東京地区]品川	1	2018-10-10	2017-09-03	2018-09-18	2018-10-03	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
10002	47220	015	[東京地区]品川	1	2018-11-20	2017-09-03	2018-10-31	2018-11-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
10003	47220	016	[東京地区]品川	1	2018-12-03	2017-09-03	2018-11-12	2018-11-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
10004	47220	017	[東京地区]品川	1	2019-01-09	2017-09-03	2018-12-13	2018-12-28	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
10005	47220	018	[東京地区]品川	1	2019-02-04	2017-09-03	2019-01-15	2019-01-29	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
10006	47220	019	[東京地区]品川	1	2019-02-25	2017-09-03	2019-02-04	2019-02-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
10007	47220	020	[東京地区]品川	1	2019-03-06	2017-09-03	2019-02-14	2019-02-28	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
10008	47220	021	[東京地区]品川	1	2019-03-18	2017-09-03	2019-02-26	2019-03-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
10009	47220	022	[大阪地区]京橋	2	2018-10-15	2017-09-03	2018-09-21	2018-10-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
10010	47220	023	[大阪地区]京橋	2	2019-01-21	2017-09-03	2018-12-25	2019-01-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
10011	47220	014	[東京地区]品川	1	2018-10-29	2017-09-03	2018-10-09	2018-10-23	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
10012	47220	001	[東京地区]品川	1	2018-05-07	2017-09-03	2018-04-12	2018-04-26	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
10013	47220	002	[東京地区]品川	1	2018-05-21	2017-09-03	2018-04-26	2018-05-17	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
10014	47220	003	[東京地区]品川	1	2018-06-04	2017-09-03	2018-05-15	2018-05-31	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
10015	47221	005	[東京地区]品川	1	2018-08-16	2017-09-03	2018-07-27	2018-08-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
10016	47221	018	[大阪地区]京橋	2	2019-02-21	2017-09-03	2019-01-31	2019-02-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
10017	47221	013	[東京地区]品川	1	2019-01-15	2017-09-03	2018-12-17	2019-01-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
10018	47221	004	[東京地区]品川	1	2018-07-26	2017-09-03	2018-07-05	2018-07-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
10019	47221	006	[東京地区]品川	1	2018-09-03	2017-09-03	2018-08-14	2018-08-30	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
10020	47221	007	[大阪地区]京橋	2	2018-05-17	2017-09-03	2018-04-24	2018-05-11	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
10021	47221	008	[大阪地区]京橋	2	2018-08-23	2017-09-03	2018-08-03	2018-08-17	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
10022	47221	009	[東京地区]品川	1	2018-10-18	2017-09-03	2018-09-27	2018-10-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
10023	47221	010	[東京地区]品川	1	2018-11-01	2017-09-03	2018-10-12	2018-10-26	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
10024	47221	011	[東京地区]品川	1	2018-11-15	2017-09-03	2018-10-26	2018-11-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
10025	47221	012	[東京地区]品川	1	2018-12-13	2017-09-03	2018-11-22	2018-12-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
10026	47221	014	[東京地区]品川	1	2019-02-07	2017-09-03	2019-01-18	2019-02-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
10027	47221	015	[東京地区]品川	1	2019-02-28	2017-09-03	2019-02-07	2019-02-22	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
10028	47221	016	[東京地区]品川	1	2019-03-25	2017-09-03	2019-03-04	2019-03-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
10029	47221	017	[大阪地区]京橋	2	2018-11-12	2017-09-03	2018-10-23	2018-11-06	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
10030	47221	001	[東京地区]品川	1	2018-05-10	2017-09-03	2018-04-17	2018-05-02	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
10031	47221	002	[東京地区]品川	1	2018-05-24	2017-09-03	2018-05-02	2018-05-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
10032	47221	003	[東京地区]品川	1	2018-06-07	2017-09-03	2018-05-18	2018-06-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
10033	47222	001	[東京地区]品川	1	2018-06-15	2017-09-03	2018-05-28	2018-06-11	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	33264
10034	47222	011	[東京地区]品川	1	2019-03-18	2017-09-03	2019-02-26	2019-03-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	33264
10035	47222	010	[東京地区]品川	1	2019-02-12	2017-09-03	2019-01-22	2019-02-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	33264
10036	47222	009	[東京地区]品川	1	2019-01-17	2017-09-03	2018-12-20	2019-01-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	33264
10037	47222	008	[東京地区]品川	1	2018-12-17	2017-09-03	2018-11-27	2018-12-11	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	33264
10038	47222	007	[東京地区]品川	1	2018-11-21	2017-09-03	2018-11-01	2018-11-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	33264
10039	47222	006	[東京地区]品川	1	2018-10-10	2017-09-03	2018-09-18	2018-10-03	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	33264
10040	47222	002	[東京地区]品川	1	2018-07-17	2017-09-03	2018-06-26	2018-07-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	33264
10041	47222	005	[大阪地区]京橋	2	2018-09-04	2017-09-03	2018-08-15	2018-08-31	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	33264
10042	47222	003	[東京地区]品川	1	2018-08-24	2017-09-03	2018-08-06	2018-08-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	33264
10043	47222	004	[東京地区]品川	1	2018-09-10	2017-09-03	2018-08-21	2018-09-06	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	33264
10044	47222	012	[大阪地区]京橋	2	2019-02-14	2017-09-03	2019-01-24	2019-02-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	33264
10045	47223	001	[東京地区]浜松町	1	2018-09-13	2017-09-03	2018-08-29	2018-08-29	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	35100
10074	47228	008	[東京地区]品川	1	2018-10-29	2017-09-03	2018-10-09	2018-10-23	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
10046	47223	002	[東京地区]浜松町	1	2018-12-10	2017-09-03	2018-11-25	2018-11-22	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	35100
10047	47224	011	[大阪地区]京橋	2	2019-01-29	2017-09-03	2019-01-08	2019-01-23	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456
10048	47224	005	[大阪地区]京橋	2	2018-09-18	2017-09-03	2018-08-28	2018-09-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456
10049	47224	003	[東京地区]品川	1	2018-08-27	2017-09-03	2018-08-07	2018-08-23	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456
10050	47224	010	[大阪地区]京橋	2	2018-11-01	2017-09-03	2018-10-12	2018-10-26	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456
10051	47224	009	[東京地区]品川	1	2019-02-25	2017-09-03	2019-02-04	2019-02-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456
10052	47224	008	[東京地区]品川	1	2019-01-08	2017-09-03	2018-12-12	2018-12-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456
10053	47224	002	[東京地区]品川	1	2018-07-12	2017-09-03	2018-06-22	2018-07-06	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456
10054	47224	001	[東京地区]品川	1	2018-06-11	2017-09-03	2018-05-22	2018-06-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456
10055	47224	004	[大阪地区]京橋	2	2018-06-06	2017-09-03	2018-05-17	2018-06-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456
10056	47224	007	[東京地区]品川	1	2018-12-03	2017-09-03	2018-11-12	2018-11-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456
10057	47224	006	[東京地区]品川	1	2018-10-25	2017-09-03	2018-10-04	2018-10-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456
10058	47225	002	[東京地区]西新宿	1	2018-08-06	2017-09-03	2018-07-17	2018-07-20	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	75600
10059	47225	003	[東京地区]西新宿	1	2018-10-11	2017-09-03	2018-09-19	2018-09-26	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	75600
10060	47225	001	[東京地区]西新宿	1	2018-05-09	2017-09-03	2018-04-16	2018-04-24	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	75600
10061	47225	005	[東京地区]西新宿	1	2019-02-13	2017-09-03	2019-01-23	2019-01-29	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	75600
10062	47225	004	[東京地区]西新宿	1	2018-12-05	2017-09-03	2018-11-14	2018-11-20	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	75600
10063	47226	001	[東京地区]浜松町	1	2018-08-21	2017-09-03	2018-08-06	2018-08-06	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	2	0	53352
10064	47226	002	[東京地区]浜松町	1	2018-12-17	2017-09-03	2018-12-02	2018-11-30	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	2	0	53352
10065	47227	001	[東京地区]浜松町	1	2018-07-23	2017-09-03	2018-07-08	2018-07-06	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	2	0	53352
10066	47227	002	[東京地区]浜松町	1	2018-11-15	2017-09-03	2018-10-31	2018-10-31	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	2	0	53352
10067	47228	015	[大阪地区]京橋	2	2019-03-26	2017-09-03	2019-03-05	2019-03-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
10068	47228	001	[東京地区]品川	1	2018-05-17	2017-09-03	2018-04-24	2018-05-11	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
10069	47228	002	[東京地区]品川	1	2018-06-07	2017-09-03	2018-05-18	2018-06-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
10070	47228	013	[東京地区]品川	1	2019-03-11	2017-09-03	2019-02-19	2019-03-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
10071	47228	005	[東京地区]品川	1	2018-09-03	2017-09-03	2018-08-14	2018-08-30	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
10072	47228	006	[大阪地区]京橋	2	2018-06-14	2017-09-03	2018-05-25	2018-06-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
10073	47228	007	[大阪地区]京橋	2	2018-09-13	2017-09-03	2018-08-24	2018-09-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
10075	47228	004	[東京地区]品川	1	2018-08-13	2017-09-03	2018-07-24	2018-08-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
10076	47228	009	[東京地区]品川	1	2018-11-19	2017-09-03	2018-10-30	2018-11-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
10077	47228	003	[東京地区]品川	1	2018-07-09	2017-09-03	2018-06-19	2018-07-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
10078	47228	011	[東京地区]品川	1	2019-01-17	2017-09-03	2018-12-20	2019-01-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
10079	47228	012	[東京地区]品川	1	2019-02-14	2017-09-03	2019-01-24	2019-02-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
10080	47228	014	[大阪地区]京橋	2	2018-11-26	2017-09-03	2018-11-05	2018-11-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
10081	47228	010	[東京地区]品川	1	2018-12-25	2017-09-03	2018-12-04	2018-12-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
10082	47229	001	[東京地区]浜松町	1	2018-07-26	2017-09-03	2018-07-11	2018-07-11	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	35100
10083	47229	002	[東京地区]浜松町	1	2018-11-06	2017-09-03	2018-10-22	2018-10-22	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	35100
10084	47230	002	[東京地区]浜松町	1	2018-11-07	2017-09-03	2018-10-23	2018-10-23	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	35100
10085	47230	001	[東京地区]浜松町	1	2018-07-27	2017-09-03	2018-07-12	2018-07-12	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	35100
10086	47231	002	[大阪地区]京橋	2	2018-06-29	2017-09-03	2018-06-11	2018-06-25	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
10087	47231	003	[東京地区]品川	1	2019-01-23	2017-09-03	2018-12-28	2019-01-17	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
10088	47231	004	[大阪地区]京橋	2	2018-12-14	2017-09-03	2018-11-26	2018-12-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
10089	47231	001	[東京地区]品川	1	2018-09-07	2017-09-03	2018-08-20	2018-08-23	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7455	46215	005	[東京地区]品川	1	2017-09-25	2017-09-03	2017-09-11	2017-09-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	52920
7456	46215	006	[大阪地区]京橋	2	2017-07-18	2017-09-03	2017-07-04	2017-07-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	52920
7457	46215	007	[大阪地区]京橋	2	2017-09-13	2017-09-03	2017-08-30	2017-09-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	52920
7458	46215	001	[東京地区]品川	1	2017-07-03	2017-09-03	2017-06-19	2017-06-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	52920
7459	46216	002	[東京地区]品川	1	2017-07-21	2017-09-03	2017-07-07	2017-07-17	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	52920
7460	46216	001	[東京地区]品川	1	2017-07-04	2017-09-03	2017-06-20	2017-06-28	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	52920
7461	46216	003	[東京地区]品川	1	2017-08-10	2017-09-03	2017-07-27	2017-08-04	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	52920
7462	46216	004	[東京地区]品川	1	2017-09-08	2017-09-03	2017-08-25	2017-09-04	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	52920
7463	46216	005	[東京地区]品川	1	2017-09-26	2017-09-03	2017-09-12	2017-09-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	52920
7464	46216	006	[大阪地区]京橋	2	2017-07-19	2017-09-03	2017-07-05	2017-07-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	52920
7465	46216	007	[大阪地区]京橋	2	2017-09-14	2017-09-03	2017-08-31	2017-09-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	52920
7466	46217	013	[東京地区]品川	1	2018-01-29	2017-09-03	2018-01-15	2018-01-23	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
7467	46217	012	[東京地区]品川	1	2018-01-09	2017-09-03	2017-12-26	2018-01-03	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
7468	46217	002	[東京地区]品川	1	2017-07-10	2017-09-03	2017-06-26	2017-07-04	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
7469	46217	007	[東京地区]品川	1	2017-10-04	2017-09-03	2017-09-20	2017-09-28	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
7470	46217	001	[東京地区]品川	1	2017-07-05	2017-09-03	2017-06-21	2017-06-29	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
7471	46217	018	[東京地区]品川	2	2018-01-15	2017-09-03	2018-01-01	2018-01-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
7472	46217	006	[東京地区]品川	1	2017-09-06	2017-09-03	2017-08-23	2017-08-31	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
7473	46217	005	[東京地区]品川	1	2017-08-21	2017-09-03	2017-08-07	2017-08-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
7474	46217	004	[東京地区]品川	1	2017-08-07	2017-09-03	2017-07-24	2017-08-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
7475	46217	003	[東京地区]品川	1	2017-07-19	2017-09-03	2017-07-05	2017-07-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
7476	46217	008	[東京地区]品川	1	2017-10-16	2017-09-03	2017-10-02	2017-10-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
7477	46217	009	[東京地区]品川	1	2017-10-30	2017-09-03	2017-10-16	2017-10-24	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
7478	46217	011	[東京地区]品川	1	2017-12-18	2017-09-03	2017-12-04	2017-12-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
7479	46217	010	[東京地区]品川	1	2017-11-27	2017-09-03	2017-11-13	2017-11-21	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
7480	46217	015	[東京地区]品川	1	2018-03-05	2017-09-03	2018-02-19	2018-02-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
7481	46217	016	[東京地区]品川	2	2017-07-12	2017-09-03	2017-06-28	2017-07-06	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
7482	46217	017	[東京地区]品川	2	2017-10-10	2017-09-03	2017-09-26	2017-10-04	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
7483	46217	014	[東京地区]品川	1	2018-02-07	2017-09-03	2018-01-24	2018-02-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	57456.00000000001
7484	46218	008	[東京地区]品川	1	2018-01-22	2017-09-03	2018-01-08	2018-01-16	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
7485	46218	002	[東京地区]品川	1	2017-08-14	2017-09-03	2017-07-31	2017-08-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
7486	46218	003	[東京地区]品川	1	2017-09-19	2017-09-03	2017-09-05	2017-09-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
7487	46218	004	[東京地区]品川	1	2017-10-19	2017-09-03	2017-10-05	2017-10-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
7488	46218	005	[東京地区]品川	1	2017-11-06	2017-09-03	2017-10-23	2017-10-31	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
7489	46218	006	[東京地区]品川	1	2017-11-21	2017-09-03	2017-11-07	2017-11-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
7490	46218	007	[東京地区]品川	1	2017-11-30	2017-09-03	2017-11-16	2017-11-24	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
7491	46218	009	[東京地区]品川	1	2018-02-01	2017-09-03	2018-01-18	2018-01-26	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
7492	46218	010	[東京地区]品川	1	2018-02-15	2017-09-03	2018-02-01	2018-02-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
7493	46218	011	[東京地区]品川	1	2018-03-08	2017-09-03	2018-02-22	2018-03-02	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
7494	46218	012	[大阪地区]京橋	2	2017-07-31	2017-09-03	2017-07-17	2017-07-25	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
7495	46218	013	[大阪地区]京橋	2	2017-11-13	2017-09-03	2017-10-30	2017-11-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
7496	46218	014	[大阪地区]京橋	2	2018-01-18	2017-09-03	2018-01-04	2018-01-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
7497	46218	001	[東京地区]品川	1	2017-07-13	2017-09-03	2017-06-29	2017-07-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	46116
7498	46219	002	[東京地区]品川	1	2017-11-08	2017-09-03	2017-10-25	2017-11-02	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	32659.199999999997
7499	46219	001	[東京地区]品川	1	2017-08-23	2017-09-03	2017-08-09	2017-08-17	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	32659.199999999997
7500	46219	004	[大阪地区]京橋	2	2017-11-22	2017-09-03	2017-11-08	2017-11-16	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	32659.199999999997
7501	46219	003	[東京地区]品川	1	2018-02-15	2017-09-03	2018-02-01	2018-02-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	32659.199999999997
7502	46220	005	[東京地区]品川	1	2018-02-05	2017-09-03	2018-01-22	2018-01-30	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7503	46220	002	[東京地区]品川	1	2017-09-07	2017-09-03	2017-08-24	2017-09-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7504	46220	006	[東京地区]品川	1	2018-03-15	2017-09-03	2018-03-01	2018-03-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7505	46220	007	[大阪地区]京橋	2	2017-08-24	2017-09-03	2017-08-10	2017-08-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7506	46220	003	[東京地区]品川	1	2017-10-26	2017-09-03	2017-10-12	2017-10-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7507	46220	004	[東京地区]品川	1	2017-12-18	2017-09-03	2017-12-04	2017-12-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7508	46220	008	[大阪地区]京橋	2	2017-10-23	2017-09-03	2017-10-09	2017-10-17	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7509	46220	001	[東京地区]品川	1	2017-07-18	2017-09-03	2017-07-04	2017-07-11	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7511	46222	023	[大阪地区]京橋	2	2017-09-07	2017-09-03	2017-08-24	2017-09-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7512	46222	001	[東京地区]品川	1	2017-07-03	2017-09-03	2017-06-19	2017-06-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7513	46222	026	[大阪地区]京橋	2	2018-03-05	2017-09-03	2018-02-19	2018-02-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7514	46222	025	[大阪地区]京橋	2	2018-01-25	2017-09-03	2018-01-11	2018-01-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7515	46222	002	[東京地区]品川	1	2017-07-18	2017-09-03	2017-07-04	2017-07-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7516	46222	003	[東京地区]品川	1	2017-07-27	2017-09-03	2017-07-13	2017-07-21	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7517	46222	004	[東京地区]品川	1	2017-08-03	2017-09-03	2017-07-20	2017-07-28	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7518	46222	005	[東京地区]品川	1	2017-08-17	2017-09-03	2017-08-03	2017-08-11	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7519	46222	006	[東京地区]品川	1	2017-08-28	2017-09-03	2017-08-14	2017-08-22	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7520	46222	007	[東京地区]品川	1	2017-09-21	2017-09-03	2017-09-07	2017-09-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7521	46222	008	[東京地区]品川	1	2017-10-05	2017-09-03	2017-09-21	2017-09-29	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7522	46222	009	[東京地区]品川	1	2017-10-16	2017-09-03	2017-10-02	2017-10-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7523	46222	010	[東京地区]品川	1	2017-11-01	2017-09-03	2017-10-18	2017-10-26	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7524	46222	011	[東京地区]品川	1	2017-11-13	2017-09-03	2017-10-30	2017-11-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7525	46222	012	[東京地区]品川	1	2017-11-28	2017-09-03	2017-11-14	2017-11-22	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7526	46222	013	[東京地区]品川	1	2017-12-11	2017-09-03	2017-11-27	2017-12-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7527	46222	014	[東京地区]品川	1	2017-12-26	2017-09-03	2017-12-12	2017-12-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7528	46222	015	[東京地区]品川	1	2018-01-11	2017-09-03	2017-12-28	2018-01-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7529	46222	016	[東京地区]品川	1	2018-01-22	2017-09-03	2018-01-08	2018-01-16	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7530	46222	017	[東京地区]品川	1	2018-02-01	2017-09-03	2018-01-18	2018-01-26	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7531	46222	018	[東京地区]品川	1	2018-02-13	2017-09-03	2018-01-30	2018-02-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7532	46222	019	[東京地区]品川	1	2018-02-26	2017-09-03	2018-02-12	2018-02-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7533	46222	020	[東京地区]品川	1	2018-03-08	2017-09-03	2018-02-22	2018-03-02	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7534	46222	021	[東京地区]品川	1	2018-03-22	2017-09-03	2018-03-08	2018-03-16	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7535	46222	022	[大阪地区]京橋	2	2017-07-13	2017-09-03	2017-06-29	2017-07-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7536	46222	024	[大阪地区]京橋	2	2017-11-20	2017-09-03	2017-11-06	2017-11-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	52920
7537	46223	009	[東京地区]品川	1	2017-12-21	2017-09-03	2017-12-07	2017-12-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	60480.00000000001
7538	46223	010	[東京地区]品川	1	2018-01-18	2017-09-03	2018-01-04	2018-01-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	60480.00000000001
7539	46223	014	[大阪地区]京橋	2	2017-09-19	2017-09-03	2017-09-05	2017-09-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	60480.00000000001
7540	46223	001	[東京地区]品川	1	2017-07-20	2017-09-03	2017-07-06	2017-07-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	60480.00000000001
7541	46223	015	[大阪地区]京橋	2	2018-03-15	2017-09-03	2018-03-01	2018-03-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	60480.00000000001
7542	46223	013	[東京地区]品川	1	2018-03-27	2017-09-03	2018-03-13	2018-03-21	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	60480.00000000001
7543	46223	012	[東京地区]品川	1	2018-02-19	2017-09-03	2018-02-05	2018-02-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	60480.00000000001
7544	46223	011	[東京地区]品川	1	2018-02-08	2017-09-03	2018-01-25	2018-02-02	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	60480.00000000001
7545	46223	002	[東京地区]品川	1	2017-08-07	2017-09-03	2017-07-24	2017-08-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	60480.00000000001
7546	46223	003	[東京地区]品川	1	2017-08-31	2017-09-03	2017-08-17	2017-08-25	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	60480.00000000001
7547	46223	004	[東京地区]品川	1	2017-09-25	2017-09-03	2017-09-11	2017-09-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	60480.00000000001
7548	46223	005	[東京地区]品川	1	2017-10-12	2017-09-03	2017-09-28	2017-10-06	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	60480.00000000001
7549	46223	006	[東京地区]品川	1	2017-10-30	2017-09-03	2017-10-16	2017-10-24	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	60480.00000000001
7550	46223	007	[東京地区]品川	1	2017-11-16	2017-09-03	2017-11-02	2017-11-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	60480.00000000001
7551	46223	008	[東京地区]品川	1	2017-12-07	2017-09-03	2017-11-23	2017-12-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	60480.00000000001
7552	46224	009	[大阪地区]京橋	2	2017-07-18	2017-09-03	2017-07-04	2017-07-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7553	46224	001	[東京地区]品川	1	2017-07-27	2017-09-03	2017-07-13	2017-07-21	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7554	46224	005	[東京地区]品川	1	2017-12-11	2017-09-03	2017-11-27	2017-12-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7555	46224	006	[東京地区]品川	1	2018-01-18	2017-09-03	2018-01-04	2018-01-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7556	46224	007	[東京地区]品川	1	2018-02-15	2017-09-03	2018-02-01	2018-02-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7557	46224	008	[東京地区]品川	1	2018-03-26	2017-09-03	2018-03-12	2018-03-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7558	46224	010	[大阪地区]京橋	2	2017-11-20	2017-09-03	2017-11-06	2017-11-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7559	46224	002	[東京地区]品川	1	2017-08-17	2017-09-03	2017-08-03	2017-08-11	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7560	46224	003	[東京地区]品川	1	2017-09-11	2017-09-03	2017-08-28	2017-09-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7561	46224	004	[東京地区]品川	1	2017-11-09	2017-09-03	2017-10-26	2017-11-03	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7562	46225	001	[東京地区]浜松町	1	2017-07-21	2017-09-03	2017-07-07	2017-06-29	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	35100
7576	46231	003	[東京地区]品川	1	2018-02-21	2017-09-03	2018-02-07	2018-02-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7592	46234	001	[東京地区]品川	1	2017-08-03	2017-09-03	2017-07-20	2017-07-28	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7563	46225	002	[東京地区]浜松町	1	2017-11-17	2017-09-03	2017-11-03	2017-10-27	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	35100
7564	46226	001	[東京地区]浜松町	1	2017-08-23	2017-09-03	2017-08-09	2017-08-01	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	2	0	70200
7565	46226	002	[東京地区]浜松町	1	2017-12-05	2017-09-03	2017-11-21	2017-11-14	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	2	0	70200
7566	46227	001	[東京地区]浜松町	1	2017-09-07	2017-09-03	2017-08-24	2017-08-17	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	2	0	53352
7567	46228	001	[東京地区]品川	1	2017-09-07	2017-09-03	2017-08-24	2017-09-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7568	46228	002	[東京地区]品川	1	2017-11-27	2017-09-03	2017-11-13	2017-11-21	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7569	46228	003	[東京地区]品川	1	2018-02-26	2017-09-03	2018-02-12	2018-02-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7570	46228	004	[大阪地区]京橋	2	2017-11-09	2017-09-03	2017-10-26	2017-11-03	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	68947.2
7571	46229	001	[東京地区]浜松町	1	2017-07-06	2017-09-03	2017-06-22	2017-06-15	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	35100
7572	46229	002	[東京地区]浜松町	1	2017-11-15	2017-09-03	2017-11-01	2017-10-25	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	35100
7573	46230	001	[東京地区]浜松町	1	2017-10-17	2017-09-03	2017-10-03	2017-09-25	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	35100
7574	46230	002	[東京地区]浜松町	1	2017-12-05	2017-09-03	2017-11-21	2017-11-14	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	35100
7575	46231	002	[東京地区]品川	1	2017-11-29	2017-09-03	2017-11-15	2017-11-23	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7577	46231	001	[東京地区]品川	1	2017-08-18	2017-09-03	2017-08-04	2017-08-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7578	46232	001	[東京地区]浜松町	1	2017-09-13	2017-09-03	2017-08-30	2017-08-23	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	35100
7579	46232	002	[東京地区]浜松町	1	2017-02-08	2017-09-03	2017-01-25	2017-01-18	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	35100
7580	46233	006	[東京地区]品川	1	2018-01-25	2017-09-03	2018-01-11	2018-01-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
7581	46233	005	[東京地区]品川	1	2017-12-04	2017-09-03	2017-11-20	2017-11-28	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
7582	46233	004	[東京地区]品川	1	2017-10-26	2017-09-03	2017-10-12	2017-10-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
7583	46233	003	[東京地区]品川	1	2017-09-19	2017-09-03	2017-09-05	2017-09-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
7584	46233	002	[東京地区]品川	1	2017-08-28	2017-09-03	2017-08-14	2017-08-22	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
7585	46233	001	[東京地区]品川	1	2017-07-24	2017-09-03	2017-07-10	2017-07-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
7586	46233	011	[大阪地区]京橋	2	2018-03-19	2017-09-03	2018-03-05	2018-03-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
7587	46233	010	[大阪地区]京橋	2	2017-12-21	2017-09-03	2017-12-07	2017-12-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
7588	46233	008	[大阪地区]京橋	2	2017-07-10	2017-09-03	2017-06-26	2017-07-04	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
7589	46233	009	[大阪地区]京橋	2	2017-09-27	2017-09-03	2017-09-13	2017-09-21	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
7590	46233	007	[東京地区]品川	1	2018-03-05	2017-09-03	2018-02-19	2018-02-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
7591	46234	007	[大阪地区]京橋	2	2017-12-18	2017-09-03	2017-12-04	2017-12-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7593	46234	006	[大阪地区]京橋	2	2017-07-26	2017-09-03	2017-07-12	2017-07-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7594	46234	005	[東京地区]品川	1	2018-03-09	2017-09-03	2018-02-23	2018-03-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7595	46234	004	[東京地区]品川	1	2018-01-18	2017-09-03	2018-01-04	2018-01-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7596	46234	003	[東京地区]品川	1	2017-11-20	2017-09-03	2017-11-06	2017-11-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7597	46234	002	[東京地区]品川	1	2017-09-20	2017-09-03	2017-09-06	2017-09-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	31751.999999999996
7598	46235	001	[東京地区]浜松町	1	2017-07-24	2017-09-03	2017-07-10	2017-06-30	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	2	0	53352
7599	46235	002	[東京地区]浜松町	1	2017-12-18	2017-09-03	2017-12-04	2017-11-27	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	2	0	53352
7600	46236	008	[大阪地区]京橋	2	2018-02-22	2017-09-03	2018-02-08	2018-02-16	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
7601	46236	006	[東京地区]品川	1	2018-03-12	2017-09-03	2018-02-26	2018-03-06	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
7602	46236	005	[東京地区]品川	1	2018-01-11	2017-09-03	2017-12-28	2018-01-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
7603	46236	004	[東京地区]品川	1	2017-12-07	2017-09-03	2017-11-23	2017-12-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
7604	46236	003	[東京地区]品川	1	2017-10-23	2017-09-03	2017-10-09	2017-10-17	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
7605	46236	002	[東京地区]品川	1	2017-09-07	2017-09-03	2017-08-24	2017-09-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
7606	46236	001	[東京地区]品川	1	2017-07-31	2017-09-03	2017-07-17	2017-07-25	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
7607	46236	007	[大阪地区]京橋	2	2017-08-21	2017-09-03	2017-08-07	2017-08-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	57456.00000000001
7608	46237	002	[東京地区]未定	1	2017-11-06	2017-09-03	2017-10-23	2017-10-16	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	70000
7609	46237	001	[東京地区]未定	1	2017-10-03	2017-09-03	2017-09-19	2017-09-11	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	70000
7610	46238	001	[東京地区]浜松町	1	2017-10-19	2017-09-03	2017-10-05	2017-09-27	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	2	0	35100
7614	46504	001	[東京地区]大崎本社 	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	開催日３日前までキャンセル可能です。	\N	0.5	0	\N
7615	46505	001	[東京地区]大崎本社 	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	開催日３日前までキャンセル可能です。	\N	0.5	0	\N
7617	46507	001	[東京地区]大崎本社 	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	開催日３日前までキャンセル可能です。	\N	0.5	0	\N
7620	46510	001	[東京地区]大崎本社 	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	開催日３日前までキャンセル可能です。	\N	0.5	0	\N
7616	46506	001	[東京地区]大崎本社 	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	開催日３日前までキャンセル可能です。	\N	0.5	0	\N
7619	46509	001	[東京地区]大崎本社 	1	2017-06-01	2017-09-03	\N	\N	\N	\N	\N	開催日３日前までキャンセル可能です。	\N	0.5	0	\N
16255	48201	001	[東京地区]品川	1	2019-06-10	2019-06-11	2019-06-03	2019-05-26	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	43740
16256	48201	002	[東京地区]品川	1	2019-07-16	2019-07-17	2019-07-08	2019-07-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	43740
16257	48201	003	[東京地区]品川	1	2019-08-08	2019-08-09	2019-08-01	2019-07-24	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	43740
16258	48201	004	[東京地区]品川	1	2019-09-11	2019-09-12	2019-09-04	2019-08-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	43740
16259	48201	005	[東京地区]品川	1	2019-10-09	2019-10-10	2019-09-29	2019-09-24	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	43740
16260	48201	006	[東京地区]品川	1	2019-12-03	2019-12-04	2019-11-23	2019-11-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	43740
16261	48201	007	[東京地区]品川	1	2020-01-22	2020-01-23	2020-01-12	2020-01-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	43740
16262	48201	008	[東京地区]品川	1	2020-03-18	2020-03-19	2020-03-08	2020-03-03	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	43740
16263	48201	009	[東海地区]名古屋	5	2019-08-26	2019-08-27	2019-08-19	2019-08-11	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	43740
16264	48201	010	[東海地区]名古屋	5	2020-01-16	2020-01-17	2020-01-06	2020-01-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	43740
16265	48201	011	[関西地区]大阪	2	2019-06-24	2019-06-25	2019-06-17	2019-06-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	43740
16266	48201	012	[関西地区]大阪	2	2019-09-26	2019-09-27	2019-09-18	2019-09-11	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	43740
16267	48201	013	[関西地区]大阪	2	2019-12-19	2019-12-20	2019-12-09	2019-12-04	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	43740
16268	48201	014	[関西地区]大阪	2	2020-03-30	2020-03-31	2020-03-20	2020-03-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	43740
16269	48202	012	[東京地区]品川	1	2019-12-02	2019-12-03	2019-11-22	2019-11-17	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16270	48202	001	[東京地区]品川	1	2019-06-24	2019-06-25	2019-06-17	2019-06-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16271	48202	002	[東京地区]品川	1	2019-07-09	2019-07-10	2019-07-02	2019-06-24	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16272	48202	003	[東京地区]品川	1	2019-07-30	2019-07-31	2019-07-23	2019-07-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16273	48202	004	[東京地区]品川	1	2019-08-15	2019-08-16	2019-08-07	2019-07-31	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16274	48202	005	[東京地区]品川	1	2019-08-26	2019-08-27	2019-08-19	2019-08-11	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16275	48202	006	[東京地区]品川	1	2019-09-09	2019-09-10	2019-09-02	2019-08-25	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16276	48202	007	[東京地区]品川	1	2019-09-25	2019-09-26	2019-09-17	2019-09-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16277	48202	008	[東京地区]品川	1	2019-10-10	2019-10-11	2019-09-30	2019-09-25	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16278	48202	009	[東京地区]品川	1	2019-10-31	2019-11-01	2019-10-21	2019-10-16	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16279	48202	010	[東京地区]品川	1	2019-11-11	2019-11-12	2019-11-01	2019-10-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16280	48202	011	[東京地区]品川	1	2019-11-26	2019-11-27	2019-11-16	2019-11-11	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16281	48202	013	[東京地区]品川	1	2019-12-10	2019-12-11	2019-11-30	2019-11-25	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16282	48202	014	[東京地区]品川	1	2019-12-25	2019-12-26	2019-12-15	2019-12-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16283	48202	015	[東京地区]品川	1	2020-01-09	2020-01-10	2019-12-30	2019-12-25	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16284	48202	016	[東京地区]品川	1	2020-01-21	2020-01-22	2020-01-11	2020-01-06	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16285	48202	017	[東京地区]品川	1	2020-02-13	2020-02-14	2020-02-03	2020-01-29	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16286	48202	018	[東京地区]品川	1	2020-03-11	2020-03-12	2020-03-01	2020-02-25	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16287	48202	019	[東京地区]品川	1	2020-03-24	2020-03-25	2020-03-14	2020-03-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16288	48202	020	[東海地区]名古屋	5	2019-07-22	2019-07-23	2019-07-12	2019-07-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16289	48202	021	[東海地区]名古屋	5	2019-12-19	2019-12-20	2019-12-09	2019-12-04	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16290	48202	022	[東海地区]名古屋	5	2020-01-28	2020-01-29	2020-01-18	2020-01-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16291	48202	023	[東海地区]名古屋	5	2020-03-16	2020-03-17	2020-03-06	2020-03-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16292	48202	024	[関西地区]大阪	2	2019-09-02	2019-09-03	2019-08-26	2019-08-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16293	48202	025	[関西地区]大阪	2	2019-11-18	2019-11-19	2019-11-08	2019-11-03	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16294	48202	026	[関西地区]大阪	2	2020-03-02	2020-03-03	2020-02-21	2020-02-16	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	56700.00000000001
16295	48203	001	[東京地区]浜松町	1	2019-10-28	2019-10-29	2019-10-10	2019-10-13	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	2	0	71500
16296	48203	002	[東京地区]浜松町	1	2019-12-17	2019-12-18	2019-11-29	2019-12-02	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	2	0	71500
16297	48204	001	[東京地区]浜松町	1	2019-09-09	2019-09-10	2019-08-22	2019-08-25	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	2	0	53352
16298	48205	001	[東京地区]品川	1	2019-08-28	2019-08-30	2019-08-21	2019-08-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	87480
16299	48205	002	[東京地区]品川	1	2019-09-17	2019-09-19	2019-09-09	2019-09-02	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	87480
16300	48205	003	[東海地区]名古屋	5	2019-09-24	2019-09-26	2019-09-13	2019-09-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	87480
16301	48205	004	[関西地区]大阪	2	2019-08-21	2019-08-23	2019-08-14	2019-08-06	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	87480
16302	48205	005	[東京地区]品川	1	2019-12-02	2019-12-04	2019-11-22	2019-11-17	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	87480
16303	48205	006	[東京地区]品川	1	2020-02-03	2020-02-05	2020-01-24	2020-01-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	87480
16304	48205	007	[東京地区]品川	1	2020-03-25	2020-03-27	2020-03-15	2020-03-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	87480
16305	48205	008	[東海地区]名古屋	5	2020-02-12	2020-02-14	2020-02-02	2020-01-28	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	87480
16306	48205	009	[関西地区]大阪	2	2020-03-11	2020-03-13	2020-03-01	2020-02-25	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	87480
16307	48206	008	[東海地区]名古屋	5	2019-12-09	2019-12-10	2019-11-29	2019-11-24	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	73872
16308	48206	001	[東京地区]品川	1	2019-07-29	2019-07-30	2019-07-22	2019-07-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	73872
16309	48206	002	[東京地区]品川	1	2019-08-19	2019-08-20	2019-08-09	2019-08-04	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	73872
16310	48206	003	[東京地区]品川	1	2019-09-03	2019-09-04	2019-08-27	2019-08-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	73872
16311	48206	004	[東京地区]品川	1	2019-11-11	2019-11-12	2019-11-01	2019-10-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	73872
16312	48206	005	[東京地区]品川	1	2019-12-17	2019-12-18	2019-12-07	2019-12-02	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	73872
16313	48206	006	[東京地区]品川	1	2020-02-12	2020-02-13	2020-02-02	2020-01-28	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	73872
16314	48206	007	[東海地区]名古屋	5	2019-08-29	2019-08-30	2019-08-21	2019-08-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	73872
16315	48206	009	[関西地区]大阪	2	2020-01-27	2020-01-28	2020-01-17	2020-01-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	73872
16316	48207	001	[東京地区]新宿	1	2019-06-10	2019-06-11	2019-05-26	2019-05-26	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16317	48207	002	[東京地区]新宿	1	2019-07-29	2019-07-30	2019-07-14	2019-07-14	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16318	48207	003	[東京地区]新宿	1	2019-08-28	2019-08-29	2019-08-13	2019-08-13	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16319	48207	004	[関西地区]大阪	2	2019-08-07	2019-08-08	2019-07-23	2019-07-23	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16320	48207	004	[東京地区]新宿	1	2019-09-25	2019-09-26	2019-09-10	2019-09-10	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16321	48207	005	[東京地区]新宿	1	2019-10-30	2019-10-31	2019-10-23	2019-10-09	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16322	48207	006	[東海地区]名古屋	5	2019-09-02	2019-09-03	2019-08-18	2019-08-18	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16323	48207	006	[東京地区]新宿	1	2019-11-27	2019-11-28	2019-11-20	2019-11-06	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16324	48207	007	[東京地区]新宿	1	2019-12-18	2019-12-19	2019-12-11	2019-11-27	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16325	48207	008	[東海地区]名古屋	5	2019-10-16	2019-10-17	2019-10-09	2019-09-25	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16326	48207	009	[東京地区]新宿	1	2019-10-30	2019-10-31	2019-10-23	2019-10-09	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16327	48207	010	[東京地区]新宿	1	2019-11-27	2019-11-28	2019-11-20	2019-11-06	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16328	48207	011	[関西地区]大阪	2	2019-12-04	2019-12-05	2019-11-27	2019-11-13	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16329	48207	012	[東京地区]新宿	1	2020-01-22	2020-01-23	2020-01-15	2020-01-01	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16330	48207	013	[関西地区]大阪	2	2020-01-29	2020-01-30	2020-01-22	2020-01-08	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16331	48207	014	[東京地区]新宿	1	2020-02-12	2020-02-13	2020-02-05	2020-01-22	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16332	48207	015	[東京地区]新宿	1	2020-03-16	2020-03-17	2020-03-09	2020-02-24	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16333	48207	016	[東海地区]名古屋	5	2020-03-25	2020-03-26	2020-03-18	2020-03-04	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16334	48208	001	[東京地区]新宿	1	2019-07-29	2019-07-30	2019-07-14	2019-07-14	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16335	48208	002	[東海地区]名古屋	5	2019-08-15	2019-08-16	2019-07-31	2019-07-31	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16336	48208	003	[関西地区]大阪	2	2019-09-09	2019-09-10	2019-08-25	2019-08-25	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16337	48208	004	[東京地区]新宿	1	2019-09-19	2019-09-20	2019-09-04	2019-09-04	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16338	48208	005	[東京地区]新宿	1	2019-10-17	2019-10-18	2019-10-10	2019-09-26	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16339	48208	006	[関西地区]大阪	2	2019-11-07	2019-11-08	2019-10-31	2019-10-17	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16340	48208	007	[東京地区]新宿	1	2019-12-16	2019-12-17	2019-12-09	2019-11-25	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16341	48208	008	[東京地区]新宿	1	2020-02-03	2020-02-04	2020-01-27	2020-01-13	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16342	48208	009	[関西地区]大阪	2	2020-02-27	2020-02-28	2020-02-20	2020-02-06	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16343	48208	010	[東京地区]新宿	1	2020-03-09	2020-03-10	2020-03-02	2020-02-17	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	77760
16344	48209	001	[東京地区]新宿	1	2019-07-25	2019-07-26	2019-07-10	2019-07-10	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	75816
16345	48209	002	[東海地区]名古屋	5	2019-08-13	2019-08-14	2019-07-29	2019-07-29	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	75816
16346	48209	003	[関西地区]大阪	2	2019-09-05	2019-09-06	2019-08-21	2019-08-21	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	75816
16347	48209	004	[東京地区]新宿	1	2019-09-17	2019-09-18	2019-09-02	2019-09-02	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	75816
16348	48209	005	[東京地区]新宿	1	2019-10-15	2019-10-16	2019-10-08	2019-09-24	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	75816
16349	48209	006	[関西地区]大阪	2	2019-11-05	2019-11-06	2019-10-29	2019-10-15	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	75816
16350	48209	007	[東京地区]新宿	1	2019-12-12	2019-12-13	2019-12-05	2019-11-21	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	75816
16351	48209	008	[東京地区]新宿	1	2020-01-30	2020-01-31	2020-01-23	2020-01-09	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	75816
16352	48209	009	[関西地区]大阪	2	2020-02-25	2020-02-26	2020-02-18	2020-02-04	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	75816
16353	48209	010	[東京地区]新宿	1	2020-03-05	2020-03-06	2020-02-27	2020-02-13	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	75816
16354	48210	001	[東京地区]新宿	1	2019-08-05	2019-08-07	2019-07-21	2019-07-21	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	116640.00000000001
16355	48210	002	[東海地区]名古屋	5	2019-08-19	2019-08-21	2019-08-04	2019-08-04	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	116640.00000000001
16356	48210	003	[関西地区]大阪	2	2019-09-11	2019-09-13	2019-08-27	2019-08-27	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	116640.00000000001
16357	48210	004	[東京地区]新宿	1	2019-09-24	2019-09-26	2019-09-09	2019-09-09	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	116640.00000000001
16358	48210	005	[東京地区]新宿	1	2019-10-28	2019-10-30	2019-10-21	2019-10-07	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	116640.00000000001
16359	48210	006	[関西地区]大阪	2	2019-11-11	2019-11-13	2019-11-04	2019-10-21	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	116640.00000000001
16360	48210	007	[東京地区]新宿	1	2019-12-18	2019-12-20	2019-12-11	2019-11-27	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	116640.00000000001
16361	48210	008	[東京地区]新宿	1	2020-02-05	2020-02-07	2020-01-29	2020-01-15	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	116640.00000000001
16362	48210	009	[関西地区]大阪	2	2020-03-02	2020-03-04	2020-02-24	2020-02-10	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	116640.00000000001
16363	48210	010	[東京地区]新宿	1	2020-03-11	2020-03-13	2020-03-04	2020-02-19	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	116640.00000000001
16364	48211	001	[東京地区]泉岳寺	1	2019-07-08	2019-07-09	2019-06-23	2019-06-23	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	97200
16365	48211	002	[東京地区]泉岳寺	1	2019-08-13	2019-08-14	2019-07-29	2019-07-29	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	97200
16366	48211	003	[東京地区]泉岳寺	1	2019-09-05	2019-09-06	2019-08-21	2019-08-21	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	97200
16367	48211	004	[東京地区]泉岳寺	1	2019-11-11	2019-11-12	2019-11-04	2019-10-21	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	97200
16368	48211	005	[東京地区]泉岳寺	1	2019-12-19	2019-12-20	2019-12-12	2019-11-28	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	97200
16369	48211	006	[東京地区]泉岳寺	1	2020-01-27	2020-01-28	2020-01-20	2020-01-06	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	97200
16370	48211	007	[東京地区]泉岳寺	1	2020-02-17	2020-02-18	2020-02-10	2020-01-27	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	97200
16371	48211	008	[東京地区]泉岳寺	1	2020-03-17	2020-03-18	2020-03-10	2020-02-25	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	97200
16372	48212	001	[東京地区]品川	1	2019-06-28	2019-06-28	2019-06-21	2019-06-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	35640
16373	48212	002	[東京地区]品川	1	2019-07-23	2019-07-23	2019-07-16	2019-07-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	35640
16374	48212	003	[東京地区]品川	1	2019-08-07	2019-08-07	2019-07-31	2019-07-23	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	35640
16375	48212	004	[東京地区]品川	1	2019-08-30	2019-08-30	2019-08-23	2019-08-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	35640
16376	48212	005	[東京地区]品川	1	2019-09-26	2019-09-26	2019-09-18	2019-09-11	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	35640
16377	48212	006	[東海地区]名古屋	5	2019-09-04	2019-09-04	2019-08-28	2019-08-20	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	35640
16378	48212	007	[関西地区]大阪	2	2019-07-31	2019-07-31	2019-07-24	2019-07-16	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	35640
16379	48212	008	[東京地区]品川	1	2019-10-23	2019-10-23	2019-10-13	2019-10-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	35640
16380	48212	009	[東京地区]品川	1	2019-11-11	2019-11-11	2019-11-01	2019-10-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	35640
16381	48212	010	[東京地区]品川	1	2019-12-04	2019-12-04	2019-11-24	2019-11-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	35640
16382	48212	011	[東京地区]品川	1	2020-01-09	2020-01-09	2019-12-30	2019-12-25	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	35640
16383	48212	012	[東京地区]品川	1	2020-02-07	2020-02-07	2020-01-28	2020-01-23	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	35640
16384	48212	013	[東京地区]品川	1	2020-03-09	2020-03-09	2020-02-28	2020-02-23	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	35640
16385	48212	014	[東京地区]品川	1	2020-03-25	2020-03-25	2020-03-15	2020-03-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	35640
16386	48212	015	[東海地区]名古屋	5	2020-03-17	2020-03-17	2020-03-07	2020-03-02	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	35640
16387	48212	016	[関西地区]大阪	2	2020-01-17	2020-01-17	2020-01-07	2020-01-02	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	35640
16388	48213	001	[東京地区]新宿	1	2019-10-23	2019-10-24	2019-10-16	2019-10-02	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	65340.00000000001
16389	48213	002	[東京地区]新宿	1	2019-12-16	2019-12-17	2019-12-09	2019-11-25	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	65340.00000000001
16390	48214	004	[東京地区]新宿	1	2020-02-12	2020-02-12	2020-02-05	2020-01-22	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16391	48214	002	[東京地区]新宿	1	2019-10-16	2019-10-16	2019-10-09	2019-09-25	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16392	48214	003	[東京地区]新宿	1	2020-01-14	2020-01-14	2020-01-07	2019-12-24	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16393	48214	001	[東京地区]新宿	1	2019-07-17	2019-07-17	2019-07-02	2019-07-02	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16394	48215	002	[関西地区]大阪	2	2019-06-26	2019-06-26	2019-06-11	2019-06-11	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16395	48215	003	[東京地区]新宿	1	2019-07-01	2019-07-01	2019-06-16	2019-06-16	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16396	48215	004	[関西地区]大阪	2	2019-07-08	2019-07-08	2019-06-23	2019-06-23	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16397	48215	005	[東京地区]新宿	1	2019-07-29	2019-07-29	2019-07-14	2019-07-14	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16398	48215	006	[関西地区]大阪	2	2019-08-07	2019-08-07	2019-07-23	2019-07-23	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16399	48215	007	[東京地区]新宿	1	2019-08-27	2019-08-27	2019-08-12	2019-08-12	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16400	48215	008	[関西地区]大阪	2	2019-09-09	2019-09-09	2019-08-25	2019-08-25	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16401	48215	009	[東京地区]新宿	1	2019-09-25	2019-09-25	2019-09-10	2019-09-10	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16402	48215	010	[東京地区]新宿	1	2019-10-02	2019-10-02	2019-09-25	2019-09-11	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16403	48215	001	[東京地区]新宿	1	2019-06-05	2019-06-05	2019-05-21	2019-05-21	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16404	48215	011	[東京地区]新宿	1	2019-10-23	2019-10-23	2019-10-16	2019-10-02	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16405	48215	012	[関西地区]大阪	2	2019-10-31	2019-10-31	2019-10-24	2019-10-10	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16406	48215	013	[東京地区]新宿	1	2019-11-13	2019-11-13	2019-11-06	2019-10-23	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16407	48215	014	[東海地区]名古屋	5	2019-11-13	2019-11-13	2019-11-06	2019-10-23	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16408	48215	015	[関西地区]大阪	2	2019-11-27	2019-11-27	2019-11-20	2019-11-06	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16409	48215	016	[東京地区]新宿	1	2019-12-04	2019-12-04	2019-11-27	2019-11-13	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16410	48215	016	[東京地区]新宿	1	2020-01-08	2020-01-08	2020-01-01	2019-12-18	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16411	48215	016	[関西地区]大阪	2	2020-01-15	2020-01-15	2020-01-08	2019-12-25	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16412	48215	016	[東京地区]新宿	1	2020-01-29	2020-01-29	2020-01-22	2020-01-08	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16413	48215	016	[東海地区]名古屋	5	2020-02-05	2020-02-05	2020-01-29	2020-01-15	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16414	48215	016	[東京地区]新宿	1	2020-02-19	2020-02-19	2020-02-12	2020-01-29	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16415	48215	016	[関西地区]大阪	2	2020-02-26	2020-02-26	2020-02-19	2020-02-05	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16416	48215	016	[東京地区]新宿	1	2020-03-09	2020-03-09	2020-03-02	2020-02-17	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16417	48215	016	[東京地区]新宿	1	2020-03-30	2020-03-30	2020-03-23	2020-03-09	\N	\N	\N	日程変更およびキャンセルは、開催日の15営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	58320.00000000001
16418	48216	001	[東京地区]品川	1	2019-06-24	2019-06-26	2019-06-17	2019-06-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16419	48216	002	[東京地区]品川	1	2019-07-03	2019-07-05	2019-06-26	2019-06-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16420	48216	003	[東京地区]品川	1	2019-07-22	2019-07-24	2019-07-12	2019-07-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16421	48216	004	[東京地区]品川	1	2019-08-05	2019-08-07	2019-07-29	2019-07-21	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16422	48216	005	[東京地区]品川	1	2019-08-21	2019-08-23	2019-08-14	2019-08-06	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16423	48216	006	[東京地区]品川	1	2019-09-09	2019-09-11	2019-09-02	2019-08-25	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16424	48216	007	[東京地区]品川	1	2019-09-18	2019-09-20	2019-09-10	2019-09-03	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16425	48216	008	[東京地区]品川	1	2019-10-02	2019-10-04	2019-09-22	2019-09-17	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16426	48216	009	[東京地区]品川	1	2019-10-23	2019-10-25	2019-10-13	2019-10-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16427	48216	010	[東京地区]品川	1	2019-11-18	2019-11-20	2019-11-08	2019-11-03	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16428	48216	011	[東京地区]品川	1	2019-12-04	2019-12-06	2019-11-24	2019-11-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16429	48216	012	[東京地区]品川	1	2019-12-16	2019-12-18	2019-12-06	2019-12-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16430	48216	013	[東京地区]品川	1	2020-01-08	2020-01-10	2019-12-29	2019-12-24	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16431	48216	014	[東京地区]品川	1	2020-01-29	2020-01-31	2020-01-19	2020-01-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16432	48216	015	[東京地区]品川	1	2020-02-12	2020-02-14	2020-02-02	2020-01-28	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16433	48216	016	[東京地区]品川	1	2020-03-04	2020-03-06	2020-02-23	2020-02-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16434	48216	017	[東海地区]名古屋	5	2019-07-29	2019-07-31	2019-07-22	2019-07-14	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16435	48216	018	[東海地区]名古屋	5	2019-11-05	2019-11-07	2019-10-26	2019-10-21	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16436	48216	019	[東海地区]名古屋	5	2020-02-03	2020-02-05	2020-01-24	2020-01-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16437	48216	020	[関西地区]大阪	2	2019-06-17	2019-06-19	2019-06-10	2019-06-02	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16438	48216	021	[関西地区]大阪	2	2019-09-02	2019-09-04	2019-08-26	2019-08-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16439	48216	022	[関西地区]大阪	2	2019-10-09	2019-10-11	2019-09-29	2019-09-24	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16440	48216	023	[関西地区]大阪	2	2020-01-20	2020-01-22	2020-01-10	2020-01-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	3	0	61560.00000000001
16441	48217	001	[東京地区]品川	1	2019-07-08	2019-07-09	2019-07-01	2019-06-23	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49410
16442	48217	002	[東京地区]品川	1	2019-07-25	2019-07-26	2019-07-18	2019-07-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49410
16443	48217	003	[東京地区]品川	1	2019-08-15	2019-08-16	2019-08-07	2019-07-31	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49410
16444	48217	004	[東京地区]品川	1	2019-09-02	2019-09-03	2019-08-26	2019-08-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49410
16445	48217	005	[東京地区]品川	1	2019-10-17	2019-10-18	2019-10-07	2019-10-02	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49410
16446	48217	006	[東京地区]品川	1	2019-11-13	2019-11-14	2019-11-03	2019-10-29	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49410
16447	48217	007	[東京地区]品川	1	2019-11-28	2019-11-29	2019-11-18	2019-11-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49410
16448	48217	008	[東京地区]品川	1	2019-12-09	2019-12-10	2019-11-29	2019-11-24	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49410
16449	48217	009	[東京地区]品川	1	2020-01-16	2020-01-17	2020-01-06	2020-01-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49410
16450	48217	010	[東京地区]品川	1	2020-02-03	2020-02-04	2020-01-24	2020-01-19	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49410
16451	48217	011	[東京地区]品川	1	2020-02-20	2020-02-21	2020-02-10	2020-02-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49410
16452	48217	012	[東京地区]品川	1	2020-03-18	2020-03-19	2020-03-08	2020-03-03	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49410
16453	48217	013	[東海地区]名古屋	5	2019-08-20	2019-08-21	2019-08-13	2019-08-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49410
16454	48217	014	[東海地区]名古屋	5	2019-12-02	2019-12-03	2019-11-22	2019-11-17	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49410
16455	48217	015	[東海地区]名古屋	5	2020-03-02	2020-03-03	2020-02-21	2020-02-16	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49410
16456	48217	016	[関西地区]大阪	2	2019-06-20	2019-06-21	2019-06-13	2019-06-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49410
16457	48217	017	[関西地区]大阪	2	2019-09-05	2019-09-06	2019-08-29	2019-08-21	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49410
16458	48217	018	[関西地区]大阪	2	2019-10-30	2019-10-31	2019-10-20	2019-10-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49410
16459	48217	019	[関西地区]大阪	2	2020-03-09	2020-03-10	2020-02-28	2020-02-23	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	49410
16460	48218	001	[東京地区]浜松町	1	2019-09-18	2019-09-18	2019-09-02	2019-09-03	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	35100
16461	48218	002	[東京地区]浜松町	1	2019-12-04	2019-12-04	2019-11-18	2019-11-19	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	35100
16462	48219	010	[関西地区]大阪	2	2019-10-24	2019-10-25	2019-10-14	2019-10-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16463	48219	003	[東京地区]品川	1	2019-09-02	2019-09-03	2019-08-26	2019-08-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16464	48219	001	[東京地区]品川	1	2019-06-20	2019-06-21	2019-06-13	2019-06-05	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16465	48219	002	[東京地区]品川	1	2019-08-01	2019-08-02	2019-07-25	2019-07-17	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16466	48219	004	[東京地区]品川	1	2019-10-31	2019-11-01	2019-10-21	2019-10-16	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16467	48219	005	[東京地区]品川	1	2019-12-12	2019-12-13	2019-12-02	2019-11-27	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16468	48219	006	[東京地区]品川	1	2019-02-19	2019-02-20	2019-02-12	2019-02-04	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16469	48219	007	[東海地区]名古屋	5	2019-07-18	2019-07-19	2019-07-10	2019-07-03	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16470	48219	008	[東海地区]名古屋	5	2020-03-24	2020-03-25	2020-03-14	2020-03-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16471	48219	009	[関西地区]大阪	2	2019-08-15	2019-08-16	2019-08-07	2019-07-31	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16472	48219	011	[関西地区]大阪	2	2020-01-16	2020-01-17	2020-01-06	2020-01-01	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16473	48219	012	[東京地区]品川	1	2020-01-09	2020-01-10	2019-12-30	2019-12-25	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16474	48219	013	[東京地区]品川	1	2020-02-19	2020-02-20	2020-02-09	2020-02-04	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16475	48220	003	[東京地区]新宿	1	2019-09-11	2019-09-11	2019-08-27	2019-08-27	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	75600
16476	48220	001	[東京地区]未定	1	2019-07-24	2019-07-24	\N	2019-07-09	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	75600
16477	48220	004	[東京地区]新宿	1	2019-10-09	2019-10-09	2019-10-02	2019-09-18	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	75600
16478	48220	005	[東京地区]新宿	1	2019-11-08	2019-11-08	2019-11-01	2019-10-18	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	75600
16479	48220	006	[東京地区]新宿	1	2019-12-04	2019-12-04	2019-11-27	2019-11-13	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	75600
16480	48220	007	[東京地区]新宿	1	2020-02-05	2020-02-05	2020-01-29	2020-01-15	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	75600
16481	48220	002	[東京地区]未定	1	2019-08-14	2019-08-14	2019-07-30	2019-07-30	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	75600
16482	48221	001	[東京地区]浜松町	1	2019-10-17	2019-10-18	2019-10-01	2019-10-02	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	2	0	54340
16483	48221	002	[東京地区]浜松町	1	2019-12-05	2019-12-06	2019-11-19	2019-11-20	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	2	0	54340
16484	48222	002	[東京地区]浜松町	1	2019-11-21	2019-11-22	2019-11-05	2019-11-06	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	2	0	54340
16485	48222	001	[東京地区]浜松町	1	2019-09-03	2019-09-04	2019-08-16	2019-08-19	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	2	0	54340
16486	48223	006	[東京地区]品川	1	2019-12-11	2019-12-12	2019-12-01	2019-11-26	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16487	48223	007	[東京地区]品川	1	2020-01-07	2020-01-08	2019-12-28	2019-12-23	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16488	48223	008	[東京地区]品川	1	2020-01-30	2020-01-31	2020-01-20	2020-01-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16489	48223	010	[東海地区]名古屋	5	2019-07-23	2019-07-24	2019-07-16	2019-07-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16490	48223	009	[東京地区]品川	1	2020-02-25	2020-02-26	2020-02-15	2020-02-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16491	48223	011	[東海地区]名古屋	5	2019-12-25	2019-12-26	2019-12-15	2019-12-10	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16492	48223	012	[関西地区]大阪	2	2019-06-13	2019-06-14	2019-06-06	2019-05-29	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16493	48223	014	[関西地区]大阪	2	2019-10-15	2019-10-16	2019-10-05	2019-09-30	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16494	48223	015	[関西地区]大阪	2	2020-01-22	2020-01-23	2020-01-12	2020-01-07	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16495	48223	004	[東京地区]品川	1	2019-10-28	2019-10-29	2019-10-18	2019-10-13	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16496	48223	013	[関西地区]大阪	2	2019-08-13	2019-08-14	2019-08-05	2019-07-29	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16497	48223	001	[東京地区]品川	1	2019-07-10	2019-07-11	2019-07-03	2019-06-25	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16498	48223	002	[東京地区]品川	1	2019-08-08	2019-08-09	2019-08-01	2019-07-24	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16499	48223	003	[東京地区]品川	1	2019-09-02	2019-09-03	2019-08-26	2019-08-18	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16500	48223	005	[東京地区]品川	1	2019-11-27	2019-11-28	2019-11-17	2019-11-12	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	61560.00000000001
16501	48224	001	[東京地区]浜松町	1	2019-08-07	2019-08-07	2019-07-22	2019-07-23	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	35100
16502	48224	002	[東京地区]浜松町	1	2019-10-16	2019-10-16	2019-09-30	2019-10-01	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	35100
16503	48225	001	[東京地区]浜松町	1	2019-09-11	2019-09-11	2019-08-26	2019-08-27	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	35100
16504	48225	002	[東京地区]浜松町	1	2019-11-13	2019-11-13	2019-09-30	2019-10-29	\N	\N	\N	日程変更およびキャンセルは、開催日の前日まで可能ですが、キャンセルした日によってキャンセル費用がかかりますのでご注意ください。\r\n　・15営業日前迄であれば、無償キャンセル\r\n　・14営業日前～前日であれば、受講料の50%がキャンセル料金\r\n　・当日欠席の場合は、受講料100%がキャンセル料金\r\nなお、日程変更は14営業日前までであれば可能となります。	\N	1	0	35100
16505	48226	007	[東京地区]新宿	1	2020-01-30	2020-01-31	2020-01-23	2020-01-09	\N	\N	\N	日程変更およびキャンセルは、開催日の21営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	111780.00000000001
16506	48226	003	[関西地区]大阪	2	2019-08-19	2019-08-20	2019-08-04	2019-08-04	\N	\N	\N	日程変更およびキャンセルは、開催日の21営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	111780.00000000001
16507	48226	001	[東京地区]新宿	1	2019-06-20	2019-06-21	2019-06-05	2019-06-05	\N	\N	\N	日程変更およびキャンセルは、開催日の21営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	111780.00000000001
16508	48226	002	[東海地区]名古屋	5	2019-07-16	2019-07-17	2019-07-01	2019-07-01	\N	\N	\N	日程変更およびキャンセルは、開催日の21営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	111780.00000000001
16509	48226	004	[東京地区]新宿	1	2019-09-17	2019-09-18	2019-09-02	2019-09-02	\N	\N	\N	日程変更およびキャンセルは、開催日の21営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	111780.00000000001
16510	48226	005	[関西地区]大阪	2	2019-11-14	2019-11-15	2019-11-07	2019-10-24	\N	\N	\N	日程変更およびキャンセルは、開催日の21営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	111780.00000000001
16511	48226	006	[東京地区]新宿	1	2019-12-12	2019-12-13	2019-12-05	2019-11-21	\N	\N	\N	日程変更およびキャンセルは、開催日の21営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	111780.00000000001
16512	48226	008	[関西地区]大阪	2	2020-03-05	2020-03-06	2020-02-27	2020-02-13	\N	\N	\N	日程変更およびキャンセルは、開催日の21営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	111780.00000000001
16513	48226	009	[東京地区]新宿	1	2020-03-23	2020-03-24	2020-03-16	2020-03-02	\N	\N	\N	日程変更およびキャンセルは、開催日の21営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	2	0	111780.00000000001
16514	48227	006	[東海地区]名古屋	5	2020-02-26	2020-02-26	2020-02-16	2020-02-11	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	34020
16515	48227	001	[東京地区]品川	1	2019-07-09	2019-07-09	2019-07-02	2019-06-24	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	34020
16516	48227	002	[東京地区]品川	1	2019-09-06	2019-09-06	2019-08-30	2019-08-22	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	34020
16517	48227	003	[東京地区]品川	1	2019-12-11	2019-12-11	2019-12-01	2019-11-26	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	34020
16518	48227	004	[東京地区]品川	1	2020-03-02	2020-03-02	2020-02-21	2020-02-16	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	34020
16519	48227	005	[東海地区]名古屋	5	2019-09-30	2019-09-30	2019-09-20	2019-09-15	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	34020
16520	48227	007	[関西地区]大阪	2	2019-07-23	2019-07-23	2019-07-16	2019-07-08	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	34020
16521	48227	008	[関西地区]大阪	2	2020-01-24	2020-01-24	2020-01-14	2020-01-09	\N	\N	\N	日程変更およびキャンセルは、開催日の4営業日前まで可能です。\r\n締切日を過ぎている場合、日程変更またはキャンセルは出来ず、受講料は全額発生いたしますので、ご認識ください。\r\nなお、日程変更は1回のみです。1度でも、同研修で日程変更を行っている場合は重ねての日程変更やキャンセル自体が不可となります。	\N	1	0	34020
16522	48501	001	大崎本社	1	2019-12-31	2020-03-31	2020-03-31	2020-03-31	\N	\N	\N	\N	\N	4時間	0	\N
16523	48502	001	大崎本社	1	2019-12-31	2020-03-31	2020-03-31	2020-03-31	\N	\N	\N	\N	\N	4時間	0	\N
16524	48503	001	大崎本社	1	2019-12-31	2020-03-31	2020-03-31	2020-03-31	\N	\N	\N	\N	\N	4時間	0	\N
16526	48505	001	大崎本社	1	2019-12-31	2020-03-31	2020-03-31	2020-03-31	\N	\N	\N	\N	\N	2時間	0	\N
16527	48506	001	大崎本社	1	2019-12-31	2020-03-31	2020-03-31	2020-03-31	\N	\N	\N	\N	\N	2時間	0	\N
16528	48601	002	[東京地区]大崎本社	1	2019-09-20	2019-09-20	2019-09-19	2019-09-19	\N	\N	\N	\N	\N	1	0	\N
16529	48601	001	[東京地区]大崎本社	1	2019-09-13	2019-09-13	2019-09-12	2019-09-12	\N	\N	\N	\N	\N	1	0	\N
16530	48601	003	[東京地区]大崎本社	1	2020-01-17	2020-01-17	2020-01-17	2020-01-16	\N	\N	\N	\N	\N	1	0	\N
16531	48601	004	西日本	2	2020-02-07	2020-02-07	2020-02-05	2020-02-07	\N	\N	\N	\N	\N	1	0	\N
16532	48602	001	[東京地区]大崎本社 	1	2019-08-23	2019-08-23	2019-08-22	2019-08-22	\N	\N	\N	\N	\N	1	0	\N
16533	48602	002	[東京地区]大崎本社 	1	2020-01-31	2020-01-31	2020-01-31	2020-01-30	\N	\N	\N	\N	\N	1	0	\N
16534	48603	001	[東京地区]大崎本社 	1	2019-08-30	2019-08-30	2019-08-29	2019-08-29	\N	\N	\N	\N	\N	1	0	\N
16535	48603	002	[東京地区]大崎本社 	1	2020-02-14	2020-02-14	2020-02-14	2020-02-13	\N	\N	\N	\N	\N	1	0	\N
16536	48604	001	[関西地区]西日本事業所 	2	2019-08-02	2019-08-02	2019-08-01	2019-08-01	\N	\N	\N	欠席するときは事前連絡すること	\N	1	0	\N
16537	48605	001	[東京地区]大崎本社 	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	0	\N
16538	48606	001	[東京地区]大崎本社 	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	0	\N
16539	48607	001	[東京地区]大崎本社 	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	0	\N
16540	48608	001	[東京地区]大崎本社 	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	1	0	\N
16541	48609	001	[東京地区]大崎本社 	1	2019-11-29	2019-11-29	2019-11-29	\N	\N	\N	\N	\N	\N	1	0	\N
16542	48609	002	[東京地区]大崎本社 	1	2019-12-13	2019-12-13	2019-12-13	\N	\N	\N	\N	\N	\N	1	0	\N
16543	48609	003	[東京地区]大崎本社 	1	2019-12-20	2019-12-20	2019-12-20	\N	\N	\N	\N	\N	\N	1	0	\N
16544	48610	001	[東京地区]大崎本社	1	2020-01-23	2020-01-23	2020-01-23	2020-01-22	\N	\N	\N	\N	\N	1	0	\N
16545	48610	002	西日本	2	2020-03-06	2020-03-06	2020-03-06	2020-03-06	\N	\N	\N	\N	\N	1	0	\N
16547	48652	001	[東京地区]神田	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	0	200000
16548	48653	001	[東京地区]神田	1	\N	\N	\N	\N	\N	\N	\N	\N	\N	2	0	300000
16549	48901	001	[東京地区]大崎本社 	1	2020-03-01	2020-03-03	2020-02-28	2020-03-01	\N	\N	\N	テスト	\N	1	0	\N
16550	48902	001	[東京地区]大崎本社 	1	2020-03-01	2020-03-03	2020-02-28	2020-03-01	\N	\N	\N	テスト	\N	1	0	\N
16551	48903	001	[東京地区]大崎本社 	1	2020-03-01	2020-03-03	2020-02-28	2020-03-01	\N	\N	\N	テスト	\N	1	0	\N
16552	48904	001	[東京地区]大崎本社 	1	2020-03-01	2020-03-03	2020-02-28	2020-03-01	\N	\N	\N	テスト	\N	1	0	\N
16553	48905	001	[東京地区]大崎本社 	1	2020-03-01	2020-03-03	2020-02-28	2020-03-01	\N	\N	\N	テスト	\N	1	0	\N
16525	48504	001	大崎本社	1	2020-02-26	2020-03-31	2020-03-31	2020-03-31	\N	\N	\N		\N	1.5時間	0	
\.


--
-- Data for Name: tbl_kyouiku_shukankikan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_kyouiku_shukankikan (id_kyouiku_shukankikan, name_shukankikan, mail_shukankikan, create_day, default_mail) FROM stdin;
21		\N	2020-02-17 13:25:34.052337+07	ngocanh@vn-cubesystem.com
20	Test Null	\N	2019-11-07 09:40:36.448305+07	ngocanh@vn-cubesystem.com
1	（株）イテレイティブ	\N	2019-08-09 09:36:18.354382+07	ngocanh@vn-cubesystem.com
2	（株）ナレッジトラスト	\N	2019-08-09 09:36:18.354382+07	ngocanh@vn-cubesystem.com
3	（株）プロネクサス	\N	2019-08-09 09:36:18.354382+07	ngocanh@vn-cubesystem.com
4	(株)富士通ラーニングメディア	\N	2019-08-09 09:36:18.354382+07	ngocanh@vn-cubesystem.com
5	（株）富士通ラーニングメディア	\N	2019-08-09 09:36:18.354382+07	ngocanh@vn-cubesystem.com
6	FUJITSUファミリ会\r\n（社内事務局：人材開発室）	\N	2019-08-09 09:36:18.354382+07	ngocanh@vn-cubesystem.com
7	コンプライアンス委員会	\N	2019-08-09 09:36:18.354382+07	ngocanh@vn-cubesystem.com
8	セキュリティ推進委員会	\N	2019-08-09 09:36:18.354382+07	ngocanh@vn-cubesystem.com
9	トレノケート(株)	\N	2019-08-09 09:36:18.354382+07	ngocanh@vn-cubesystem.com
10	トレノケート（株）	\N	2019-08-09 09:36:18.354382+07	ngocanh@vn-cubesystem.com
11	マーキュリッチ（株）	\N	2019-08-09 09:36:18.354382+07	ngocanh@vn-cubesystem.com
12	一般社団法人 ブロックチェーン推進協会\r\n（社内事務局：技術戦略室）	\N	2019-08-09 09:36:18.354382+07	ngocanh@vn-cubesystem.com
22	e-learning	\N	2020-02-17 14:19:50.230908+07	ngocanh@vn-cubesystem.com
13	人材戦略室	\N	2019-08-09 09:36:18.354382+07	ngocanh@vn-cubesystem.com
14	人材開発室	\N	2019-08-09 09:36:18.354382+07	ngocanh@vn-cubesystem.com
15	品質推進部	\N	2019-08-09 09:36:18.354382+07	ngocanh@vn-cubesystem.com
16	富士通アプリケーションズ（株）	\N	2019-08-09 09:36:18.354382+07	ngocanh@vn-cubesystem.com
17	技術戦略室	\N	2019-08-09 09:36:18.354382+07	ngocanh@vn-cubesystem.com
18	Testinng	\N	2019-08-13 17:42:26.852203+07	ngocanh@vn-cubesystem.com
19	ABC会社	\N	2019-10-23 09:11:52.219114+07	ngocanh@vn-cubesystem.com
\.


--
-- Data for Name: tbl_mail_config; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_mail_config (id, host, port, secure, usermail_auth, passmail_auth) FROM stdin;
1	smtp3.gmoserver.jp	587	f	kenshuukanri@vn-cubesystem.com	Csv#0202
\.


--
-- Data for Name: tbl_mail_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_mail_log (id, mail_from, mail_to, mail_html, mail_query, mail_result, create_time, decode_text) FROM stdin;
\.


--
-- Data for Name: tbl_mail_template; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_mail_template (template_id, template_from, template_from_naiyou, template_to, template_to_naiyou, template_cc, template_cc_naiyou, template_subject, template_subject_naiyou, template_auto_string, template_moushikomi_string, template_moushikomi_date, template_kensyuu_id, template_kensyuu_mei, template_shukankikan, template_start, template_end, template_fee, template_receiver_string, template_shain_cd, template_shain_name, template_mail, template_honbu, template_bumon, template_group, template_note, template_note_naiyou, template_start_regist, template_end_regist, template_policy_regist, template_cancel_day_regist, template_moushikomi_string_value) FROM stdin;
cancel_shain	t	toransu_home@cubesystem.co.jp	t	kyouiku@cubesystem.co.jp	t	\N	t	【とらんすふぉーむ】　キャンセル	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	\N	t	t	t	t	下記の通り、キャンセルがありました。
cancel_boss	t	toransu_home@cubesystem.co.jp	t	kyouiku@cubesystem.co.jp	t	\N	t	【とらんすふぉーむ】　キャンセル	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	\N	t	t	t	t	下記の通り、キャンセルがありました。
cancel_kyouiku	t	toransu_home@cubesystem.co.jp	t	kyouiku@cubesystem.co.jp	t	\N	t	【とらんすふぉーむ】　キャンセル	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	\N	t	t	t	t	下記の通り、キャンセルがありました。
early_kyouiku	t	toransu_home@cubesystem.co.jp	t	kyouiku@cubesystem.co.jp	t	\N	t	【とらんす・ほーむ】リマインド	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	\N	t	t	t	f	下記の通り、研修を受講予定です。
moushikomi_shain	t	toransu_home@cubesystem.co.jp	t	kyouiku@cubesystem.co.jp	t	\N	t	【とらんすふぉーむ】　申込	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	\N	t	t	t	f	下記の通り、申請がありました。
moushikomi_boss	t	toransu_home@cubesystem.co.jp	t	kyouiku@cubesystem.co.jp	t	\N	t	【とらんすふぉーむ】　申込	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	\N	t	t	t	f	下記の通り、申請がありました。
moushikomi_kyouiku	t	toransu_home@cubesystem.co.jp	t	kyouiku@cubesystem.co.jp	t	\N	t	【とらんすふぉーむ】　申込	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	\N	t	t	t	f	下記の通り、申請がありました。
end_nittei	t	toransu_home@cubesystem.co.jp	f	\N	t	\N	t	【とらんす・ほーむ】不承認	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	\N	f	f	f	f	下記の研修は申込ができませんでした。\n詳細は別途お問い合わせください。
start_nittei	t	toransu_home@cubesystem.co.jp	f	\N	t	\N	t	【とらんす・ほーむ】承認	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	t	\N	f	t	t	f	下記研修の申込が受理されました。
\.


--
-- Data for Name: tbl_moushikomi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_moushikomi (moushikomi_id, shain_cd, kensyuu_id, kensyuu_sub_id, moushikomi_date, status, koushinsha, koushinbi, checked_in) FROM stdin;
656	460049	47152	001	2018-06-15 09:00:00	3	360055	2018-06-15 07:00:00+07	f
657	450054	47152	003	2018-06-15 09:00:00	3	360055	2018-06-15 07:00:00+07	f
658	450021	47210	003	2018-06-22 09:00:00	6	280031	2018-06-22 07:00:00+07	f
659	460062	47201	003	2018-06-26 09:00:00	4	280031	2018-06-26 07:00:00+07	f
660	420043	47201	003	2018-06-28 09:00:00	6	430048	2018-06-28 07:00:00+07	f
661	460002	47204	004	2018-07-04 09:00:00	6	280031	2018-07-04 07:00:00+07	f
662	460062	47202	004	2018-06-26 09:00:00	4	280031	2018-06-26 07:00:00+07	f
663	410003	47202	004	2018-06-28 09:00:00	6	430048	2018-06-28 07:00:00+07	f
664	430042	47227	001	2018-07-04 09:00:00	6	280028	2018-07-04 07:00:00+07	f
665	450044	47207	001	2018-07-04 09:00:00	6	280031	2018-07-04 07:00:00+07	f
666	350002	47207	001	2018-07-04 09:00:00	6	280031	2018-07-04 07:00:00+07	f
667	440045	47207	001	2018-07-04 09:00:00	4	280005	2018-07-04 07:00:00+07	f
668	470008	47221	004	2018-07-04 09:00:00	6	280028	2018-07-04 07:00:00+07	f
669	460005	47230	001	2018-07-04 09:00:00	6	280028	2018-07-04 07:00:00+07	f
670	460064	47220	007	2018-07-04 09:00:00	8	280031	2018-07-04 07:00:00+07	f
671	460033	47152	001	2018-07-13 09:00:00	3	360055	2018-07-13 07:00:00+07	f
672	460012	47152	001	2018-07-13 09:00:00	3	360055	2018-07-13 07:00:00+07	f
673	460051	47152	001	2018-07-13 09:00:00	3	260004	2018-07-13 07:00:00+07	f
674	460035	47152	001	2018-07-13 09:00:00	3	260004	2018-07-13 07:00:00+07	f
675	460052	47152	001	2018-07-17 09:00:00	3	280031	2018-07-17 07:00:00+07	f
676	440002	47206	001	2018-07-04 09:00:00	4	330045	2018-07-04 07:00:00+07	f
677	420034	47206	001	2018-07-19 09:00:00	6	280031	2018-07-19 07:00:00+07	f
678	410028	47206	001	2018-07-19 09:00:00	6	280005	2018-07-19 07:00:00+07	f
679	450002	47204	006	2018-07-04 09:00:00	6	280031	2018-07-04 07:00:00+07	f
680	450023	47220	012	2018-07-13 09:00:00	6	360055	2018-07-13 07:00:00+07	f
681	330007	47225	002	2018-07-13 09:00:00	6	300001	2018-07-13 07:00:00+07	f
683	330038	47225	002	2018-07-13 09:00:00	6	300001	2018-07-13 07:00:00+07	f
684	330015	47225	002	2018-07-13 09:00:00	6	300001	2018-07-13 07:00:00+07	f
685	320034	47225	002	2018-07-13 09:00:00	4	300001	2018-07-13 07:00:00+07	f
686	290042	47205	001	2018-07-04 09:00:00	4	280028	2018-07-04 07:00:00+07	f
687	370022	47205	001	2018-07-04 09:00:00	6	280028	2018-07-04 07:00:00+07	f
688	430049	47205	001	2018-07-04 09:00:00	6	280005	2018-07-04 07:00:00+07	f
690	390029	47205	001	2018-07-13 09:00:00	6	300001	2018-07-13 07:00:00+07	f
691	350034	47219	002	2018-07-13 09:00:00	6	360055	2018-07-13 07:00:00+07	f
692	360030	47228	004	2018-07-05 09:00:00	6	280005	2018-07-05 07:00:00+07	f
693	450039	47221	005	2018-07-04 09:00:00	6	330045	2018-07-04 07:00:00+07	f
694	460064	47221	005	2018-07-04 09:00:00	6	280031	2018-07-04 07:00:00+07	f
695	460041	47214	003	2018-07-04 09:00:00	4	280005	2018-07-04 07:00:00+07	f
696	460040	47214	003	2018-07-04 09:00:00	6	280005	2018-07-04 07:00:00+07	f
697	460047	47202	006	2018-07-04 09:00:00	6	280028	2018-07-04 07:00:00+07	f
698	470026	47215	003	2018-07-04 09:00:00	6	280028	2018-07-04 07:00:00+07	f
699	460034	47204	007	2018-06-22 09:00:00	6	280031	2018-06-22 07:00:00+07	f
700	420002	47204	007	2018-07-04 09:00:00	4	280028	2018-07-04 07:00:00+07	f
701	450004	47204	007	2018-08-09 09:00:00	6	250010	2018-08-09 07:00:00+07	f
702	470057	47209	004	2018-07-04 09:00:00	6	280031	2018-07-04 07:00:00+07	f
703	380031	47209	004	2018-07-04 09:00:00	4	280028	2018-07-04 07:00:00+07	f
704	420017	47209	004	2018-07-13 09:00:00	6	300001	2018-07-13 07:00:00+07	f
705	430008	47209	004	2018-07-13 09:00:00	6	280026	2018-07-13 07:00:00+07	f
706	440023	47209	004	2018-07-13 09:00:00	6	280026	2018-07-13 07:00:00+07	f
707	420041	47222	003	2018-07-09 09:00:00	4	330045	2018-07-09 07:00:00+07	f
708	350007	47218	003	2018-07-21 09:00:00	4	280005	2018-07-21 07:00:00+07	f
709	390011	47218	003	2018-08-09 09:00:00	6	250010	2018-08-09 07:00:00+07	f
710	360048	47224	003	2018-07-04 09:00:00	4	280003	2018-07-04 07:00:00+07	f
711	460013	47216	003	2018-07-04 09:00:00	6	330045	2018-07-04 07:00:00+07	f
712	370019	47224	003	2018-07-04 09:00:00	8	280031	2018-07-04 07:00:00+07	f
713	460066	47224	003	2018-07-04 09:00:00	6	280031	2018-07-04 07:00:00+07	f
714	460020	47216	003	2018-07-04 09:00:00	9	280028	2018-07-04 07:00:00+07	f
715	440015	47224	003	2018-07-04 09:00:00	4	280028	2018-07-04 07:00:00+07	f
716	450006	47216	003	2018-07-04 09:00:00	6	280028	2018-07-04 07:00:00+07	f
717	260015	47202	011	2018-07-13 09:00:00	4	360055	2018-07-13 07:00:00+07	f
718	460021	47202	011	2018-07-13 09:00:00	4	360055	2018-07-13 07:00:00+07	f
719	450041	47202	011	2018-07-13 09:00:00	4	360055	2018-07-13 07:00:00+07	f
720	450044	47221	006	2018-08-03 09:00:00	4	280031	2018-08-03 07:00:00+07	f
735	440048	47212	004	2018-07-19 09:00:00	9	280031	2018-07-19 07:00:00+07	f
736	450019	47211	003	2018-07-04 09:00:00	8	330045	2018-07-04 07:00:00+07	f
739	450062	47231	001	2018-07-04 09:00:00	6	280028	2018-07-04 07:00:00+07	f
743	430035	47207	002	2018-07-04 09:00:00	8	280031	2018-07-04 07:00:00+07	f
749	460053	47207	002	2018-07-13 09:00:00	6	360055	2018-07-13 07:00:00+07	f
725	450019	47201	006	2018-07-17 09:00:00	4	430050	2018-10-29 06:43:08.99503+07	f
682	290037	47225	002	2018-07-13 09:00:00	6	300001	2019-04-17 14:49:54.505913+07	f
721	420041	47201	006	2018-07-04 09:00:00	4	430050	2018-10-29 06:43:22.091211+07	f
750	270015	47222	004	2018-07-19 09:00:00	6	430050	2018-12-18 08:14:25.215538+07	f
724	440044	47204	012	2018-07-13 09:00:00	8	430050	2018-12-26 07:15:25.950929+07	f
727	450029	47202	007	2018-07-04 09:00:00	4	430050	2018-10-29 06:43:45.916352+07	f
726	420041	47202	007	2018-07-04 09:00:00	4	430050	2018-10-29 06:43:50.368559+07	f
729	430013	47222	005	2018-07-13 09:00:00	8	430050	2018-12-26 07:13:42.961252+07	f
734	370019	47203	003	2018-07-13 09:00:00	4	430050	2018-10-29 06:44:01.416994+07	f
732	460047	47203	003	2018-07-13 09:00:00	4	430050	2018-10-29 06:44:04.8647+07	f
731	370020	47212	004	2018-07-04 09:00:00	4	430050	2018-10-29 06:44:08.140371+07	f
733	380053	47212	004	2018-07-13 09:00:00	4	430050	2018-10-29 06:44:11.538143+07	f
737	460025	47211	003	2018-07-05 09:00:00	4	430050	2018-10-29 06:44:15.5272+07	f
740	330004	47231	001	2018-07-19 09:00:00	4	430050	2018-10-29 06:44:25.831201+07	f
738	450067	47231	001	2018-07-04 09:00:00	4	430050	2018-10-29 06:44:27.121837+07	f
746	420028	47207	002	2018-07-04 09:00:00	4	430050	2018-10-29 06:44:31.830667+07	f
752	430040	47204	008	2018-07-04 09:00:00	6	430050	2018-12-18 08:16:23.901612+07	f
741	380038	47222	004	2018-07-05 09:00:00	6	430050	2018-12-18 08:15:49.17681+07	f
751	350013	47213	001	2018-07-23 09:00:00	6	430050	2018-12-18 08:14:43.833064+07	f
747	460028	47220	009	2018-07-04 09:00:00	6	430050	2018-12-18 08:15:00.539488+07	f
745	460036	47220	009	2018-07-04 09:00:00	6	430050	2018-12-18 08:16:08.888032+07	f
748	460024	47220	009	2018-07-04 09:00:00	6	430050	2018-12-18 08:15:17.262323+07	f
689	320004	47205	001	2018-07-13 09:00:00	6	430050	2018-12-18 08:19:29.046368+07	f
742	470001	47222	004	2018-07-04 09:00:00	6	330045	2018-11-01 15:15:59.127362+07	f
722	450003	47217	004	2018-07-04 09:00:00	6	430050	2018-12-18 08:10:30.563546+07	f
728	360053	47222	005	2018-07-13 09:00:00	8	430050	2018-12-26 07:12:13.152257+07	f
756	470049	47223	001	2018-07-04 09:00:00	6	330045	2018-07-04 07:00:00+07	f
766	400028	47208	002	2018-07-20 09:00:00	4	360055	2018-07-20 07:00:00+07	f
771	460007	47204	009	2018-07-04 09:00:00	8	280031	2018-07-04 07:00:00+07	f
773	340024	47204	009	2018-07-13 09:00:00	8	280026	2018-07-13 07:00:00+07	f
774	380046	47204	009	2018-07-13 09:00:00	8	310012	2018-07-13 07:00:00+07	f
846	450038	47208	005	2018-07-19 09:00:00	3	280031	2018-07-19 07:00:00+07	f
847	460013	47117	001	2018-09-28 00:00:00	6	330045	2018-09-27 22:00:00+07	f
848	450009	47117	001	2018-09-28 00:00:00	6	330045	2018-09-27 22:00:00+07	f
849	460022	47117	001	2018-09-28 00:00:00	6	330045	2018-09-27 22:00:00+07	f
781	390036	47209	005	2018-07-04 09:00:00	4	430050	2018-10-03 13:11:08.286744+07	f
780	340031	47209	005	2018-07-13 09:00:00	4	430050	2018-10-03 13:11:13.903756+07	f
800	400035	47205	002	2018-07-04 09:00:00	6	430050	2018-12-18 08:20:33.091806+07	f
784	410049	47209	005	2018-07-19 09:00:00	6	430050	2018-12-18 08:19:57.593774+07	f
785	440007	47220	010	2018-07-04 09:00:00	4	430050	2018-10-03 13:11:30.232245+07	f
803	370023	47205	002	2018-07-13 09:00:00	8	430050	2018-10-04 14:32:15.697243+07	f
788	360039	47228	008	2018-07-19 09:00:00	4	430050	2018-10-31 12:54:39.803867+07	f
779	450041	47211	005	2018-07-13 09:00:00	4	430050	2018-10-16 07:15:05.36117+07	f
767	410034	47208	002	2018-08-21 09:00:00	6	430050	2018-12-18 08:11:44.445619+07	f
754	420011	47204	008	2018-07-13 09:00:00	6	430050	2018-12-18 08:11:20.894952+07	f
761	460018	47223	001	2018-07-19 09:00:00	4	430050	2018-10-29 06:45:40.728425+07	f
763	450040	47223	001	2018-08-09 09:00:00	4	430050	2018-10-29 06:45:46.131466+07	f
758	370033	47223	001	2018-07-04 09:00:00	6	430050	2018-12-18 08:17:26.976894+07	f
762	470044	47223	001	2018-07-19 09:00:00	6	430050	2018-12-18 08:17:49.939578+07	f
759	460001	47223	001	2018-07-04 09:00:00	4	430050	2018-10-29 06:45:58.18464+07	f
753	280014	47204	008	2018-07-13 09:00:00	6	430050	2018-12-18 08:16:49.307478+07	f
775	470044	47201	007	2018-07-19 09:00:00	6	430050	2018-12-18 08:17:53.087758+07	f
760	470015	47223	001	2018-07-04 09:00:00	6	430050	2018-12-18 08:12:52.258343+07	f
764	420020	47208	002	2018-07-04 09:00:00	4	430050	2018-10-29 06:46:12.211956+07	f
782	320013	47209	005	2018-07-13 09:00:00	6	430050	2018-12-18 08:19:42.712474+07	f
768	440005	47224	005	2018-07-13 09:00:00	4	430050	2018-10-29 06:46:18.647711+07	f
769	420051	47210	005	2018-07-17 09:00:00	4	430050	2018-10-29 06:46:24.736646+07	f
772	410032	47204	009	2018-07-04 09:00:00	4	430050	2018-10-29 06:46:28.068944+07	f
798	360026	47205	002	2018-07-13 09:00:00	6	430050	2018-11-20 16:16:07.141349+07	f
765	320038	47208	002	2018-07-04 09:00:00	6	430050	2018-12-18 08:18:10.441211+07	f
776	470008	47202	008	2018-07-04 09:00:00	4	430050	2018-10-29 06:46:41.528448+07	f
778	450043	47211	005	2018-07-13 09:00:00	4	430050	2018-10-29 06:46:47.958992+07	f
787	430017	47221	009	2018-08-02 09:00:00	6	430050	2018-10-31 08:31:04.79308+07	f
796	450033	47230	002	2018-07-04 09:00:00	6	430050	2018-11-10 18:42:27.74475+07	f
789	440052	47228	008	2018-07-18 09:00:00	6	430050	2018-10-31 13:00:55.051476+07	f
840	420015	47226	002	2018-07-04 09:00:00	6	430050	2018-12-19 16:14:14.859936+07	f
790	420051	47211	006	2018-07-17 09:00:00	6	430050	2018-11-09 13:43:51.064396+07	f
791	460027	47229	002	2018-07-04 09:00:00	6	430050	2018-11-07 14:17:33.856992+07	f
808	430010	47207	003	2018-07-23 09:00:00	9	280019	2018-11-13 13:27:58.496233+07	f
793	470001	47229	002	2018-07-04 09:00:00	6	430050	2018-11-07 08:50:03.859199+07	f
794	450034	47229	002	2018-07-04 09:00:00	6	430050	2018-11-12 09:37:01.219133+07	f
792	470049	47229	002	2018-07-04 09:00:00	6	430050	2018-11-09 07:56:13.937291+07	f
770	450039	47204	009	2018-07-04 09:00:00	6	430050	2018-11-15 16:51:53.303229+07	f
806	430022	47205	002	2018-08-09 09:00:00	6	430050	2018-11-20 19:30:34.691962+07	f
804	380017	47205	002	2018-07-13 09:00:00	4	430050	2018-11-19 06:15:23.919854+07	f
829	460031	47220	015	2018-07-23 09:00:00	4	430050	2018-11-26 08:32:53.558281+07	f
814	370081	47227	002	2018-07-04 09:00:00	6	430050	2018-11-21 12:49:19.123116+07	f
818	370057	47227	002	2018-07-13 09:00:00	6	430050	2018-11-20 12:21:00.858394+07	f
830	450052	47220	015	2018-07-23 09:00:00	4	430050	2018-11-21 06:57:51.269793+07	f
799	440022	47205	002	2018-07-04 09:00:00	4	430050	2018-11-19 06:15:49.247274+07	f
809	430033	47207	003	2018-07-13 09:00:00	4	430050	2018-11-19 06:16:00.248887+07	f
805	430002	47205	002	2018-07-13 09:00:00	6	430050	2018-11-20 08:52:46.276063+07	f
820	340037	47227	002	2018-07-13 09:00:00	6	430050	2018-11-19 08:23:48.724825+07	f
825	470054	47227	002	2018-07-13 09:00:00	6	430050	2018-11-19 08:01:35.078108+07	f
824	330018	47227	002	2018-07-13 09:00:00	9	280019	2018-11-19 06:56:29.491042+07	f
816	350017	47227	002	2018-07-13 09:00:00	6	430050	2018-11-22 07:32:34.678013+07	f
813	440068	47227	002	2018-07-04 09:00:00	6	430050	2018-11-29 20:55:18.157242+07	f
812	360014	47227	002	2018-07-04 09:00:00	6	430050	2018-11-19 16:48:44.511335+07	f
822	360056	47227	002	2018-07-13 09:00:00	6	430050	2018-11-21 20:13:59.239876+07	f
807	430041	47205	002	2018-08-09 09:00:00	6	430050	2018-11-20 15:58:15.192511+07	f
802	410009	47205	002	2018-07-13 09:00:00	6	430050	2018-11-26 01:43:13.386718+07	f
817	400015	47227	002	2018-07-13 09:00:00	6	430050	2018-11-22 15:52:47.76036+07	f
815	340057	47227	002	2018-07-13 09:00:00	4	430050	2018-11-19 06:17:44.019146+07	f
819	350001	47227	002	2018-07-13 09:00:00	6	430050	2018-11-21 16:23:00.750731+07	f
841	430019	47226	002	2018-07-04 09:00:00	8	430050	2018-12-03 12:09:15.903032+07	f
832	440014	47223	002	2018-07-04 09:00:00	6	430050	2018-12-19 15:40:15.872127+07	f
844	260018	47226	002	2018-07-13 09:00:00	6	430050	2018-12-21 21:49:23.200791+07	f
810	370042	47227	002	2018-07-04 09:00:00	4	430050	2018-11-19 06:18:06.900544+07	f
823	240020	47227	002	2018-07-13 09:00:00	9	280019	2018-11-19 06:56:12.01765+07	f
821	290009	47227	002	2018-07-13 09:00:00	6	430050	2018-11-27 22:38:50.076817+07	f
826	370040	47227	002	2018-07-19 09:00:00	6	430050	2018-11-20 08:45:06.474714+07	f
801	410011	47205	002	2018-07-13 09:00:00	6	430050	2018-11-21 12:08:19.915049+07	f
827	400009	47219	004	2018-07-13 09:00:00	6	430050	2018-11-26 17:26:18.470893+07	f
795	430029	47230	002	2018-07-04 09:00:00	6	430050	2018-12-04 17:06:02.353573+07	f
831	460042	47203	006	2018-07-09 09:00:00	6	430050	2018-12-05 17:25:33.99272+07	f
836	380066	47208	004	2018-07-25 09:00:00	4	430050	2018-12-18 07:58:25.314618+07	f
811	450039	47227	002	2018-07-04 09:00:00	6	430050	2018-12-12 16:21:54.502051+07	f
835	460029	47223	002	2018-08-28 09:00:00	4	430050	2018-12-10 06:09:42.218861+07	f
834	460046	47223	002	2018-08-28 09:00:00	6	430050	2018-12-11 13:45:50.822652+07	f
839	420025	47226	002	2018-07-04 09:00:00	4	430050	2018-12-17 07:03:18.318419+07	f
845	410018	47226	002	2018-07-19 09:00:00	4	430050	2018-12-17 07:03:22.627542+07	f
843	310017	47226	002	2018-07-04 09:00:00	6	430050	2018-12-25 12:56:27.441201+07	f
837	320020	47208	004	2018-07-25 09:00:00	6	430050	2019-07-16 22:13:58.706729+07	f
842	440017	47226	002	2018-07-04 09:00:00	4	430050	2018-12-17 07:03:44.851935+07	f
838	420014	47208	004	2018-07-20 09:00:00	6	430050	2018-12-20 14:53:13.558521+07	f
833	450045	47223	002	2018-07-13 09:00:00	6	430050	2018-12-17 10:07:19.517218+07	f
755	460070	47204	008	2018-07-19 09:00:00	6	430050	2018-12-18 08:08:25.881202+07	f
757	460008	47223	001	2018-07-04 09:00:00	6	430050	2018-12-18 08:17:11.738173+07	f
850	460023	47117	001	2018-09-28 00:00:00	6	330045	2018-09-27 22:00:00+07	f
851	460044	47117	001	2018-09-28 00:00:00	6	330045	2018-09-27 22:00:00+07	f
852	460069	47117	001	2018-09-28 00:00:00	6	330045	2018-09-27 22:00:00+07	f
853	450029	47117	001	2018-09-28 00:00:00	6	280031	2018-09-27 22:00:00+07	f
854	430005	47117	001	2018-09-28 00:00:00	6	250010	2018-09-27 22:00:00+07	f
855	440054	47117	001	2018-09-28 00:00:00	6	250010	2018-09-27 22:00:00+07	f
856	460006	47117	001	2018-09-28 00:00:00	6	250010	2018-09-27 22:00:00+07	f
857	450005	47117	001	2018-09-28 00:00:00	6	280003	2018-09-27 22:00:00+07	f
858	460048	47117	001	2018-09-28 00:00:00	6	280003	2018-09-27 22:00:00+07	f
859	450011	47117	001	2018-09-28 00:00:00	6	280003	2018-09-27 22:00:00+07	f
860	460051	47117	001	2018-09-28 00:00:00	6	260004	2018-09-27 22:00:00+07	f
861	460021	47117	001	2018-09-28 00:00:00	6	360055	2018-09-27 22:00:00+07	f
862	460063	47117	001	2018-09-28 00:00:00	6	360055	2018-09-27 22:00:00+07	f
863	450010	47117	001	2018-09-28 00:00:00	6	290016	2018-09-27 22:00:00+07	f
865	470008	47116	001	2018-09-28 00:00:00	6	280028	2018-09-27 22:00:00+07	f
866	470011	47116	001	2018-09-28 00:00:00	6	280028	2018-09-27 22:00:00+07	f
867	460017	47116	001	2018-09-28 00:00:00	6	280003	2018-09-27 22:00:00+07	f
868	460048	47116	001	2018-09-28 00:00:00	6	280003	2018-09-27 22:00:00+07	f
869	450011	47116	001	2018-09-28 00:00:00	6	280003	2018-09-27 22:00:00+07	f
870	450034	47116	001	2018-09-28 00:00:00	6	280005	2018-09-27 22:00:00+07	f
871	450037	47116	001	2018-09-28 00:00:00	6	280005	2018-09-27 22:00:00+07	f
872	460028	47116	001	2018-09-28 00:00:00	6	280005	2018-09-27 22:00:00+07	f
873	470015	47116	001	2018-09-28 00:00:00	6	280005	2018-09-27 22:00:00+07	f
874	460033	47116	001	2018-09-28 00:00:00	6	360055	2018-09-27 22:00:00+07	f
875	460063	47116	001	2018-09-28 00:00:00	6	360055	2018-09-27 22:00:00+07	f
876	470027	47116	001	2018-09-28 00:00:00	6	360055	2018-09-27 22:00:00+07	f
877	470040	47116	001	2018-09-28 00:00:00	6	360055	2018-09-27 22:00:00+07	f
878	470050	47116	001	2018-09-28 00:00:00	6	360055	2018-09-27 22:00:00+07	f
879	410014	47116	001	2018-09-28 00:00:00	8	260004	2018-09-27 22:00:00+07	f
880	440042	47118	001	2018-09-28 00:00:00	6	330045	2018-09-27 22:00:00+07	f
881	440019	47118	001	2018-09-28 00:00:00	6	280031	2018-09-27 22:00:00+07	f
882	440040	47118	001	2018-09-28 00:00:00	6	280031	2018-09-27 22:00:00+07	f
883	470055	47118	001	2018-09-28 00:00:00	6	320011	2018-09-27 22:00:00+07	f
884	440054	47118	001	2018-09-28 00:00:00	6	250010	2018-09-27 22:00:00+07	f
885	430041	47118	001	2018-09-28 00:00:00	6	250010	2018-09-27 22:00:00+07	f
886	440025	47118	001	2018-09-28 00:00:00	6	250010	2018-09-27 22:00:00+07	f
887	450052	47118	001	2018-09-28 00:00:00	8	280005	2018-09-27 22:00:00+07	f
888	450048	47118	001	2018-09-28 00:00:00	8	280005	2018-09-27 22:00:00+07	f
889	420025	47118	001	2018-09-28 00:00:00	6	280005	2018-09-27 22:00:00+07	f
890	450037	47118	001	2018-09-28 00:00:00	6	280005	2018-09-27 22:00:00+07	f
891	450025	47118	001	2018-09-28 00:00:00	6	260004	2018-09-27 22:00:00+07	f
892	440041	47118	001	2018-09-28 00:00:00	6	360055	2018-09-27 22:00:00+07	f
893	260015	47118	001	2018-09-28 00:00:00	6	360055	2018-09-27 22:00:00+07	f
894	420014	47118	001	2018-09-28 00:00:00	6	360055	2018-09-27 22:00:00+07	f
895	450045	47118	001	2018-09-28 00:00:00	6	360055	2018-09-27 22:00:00+07	f
896	420041	47118	001	2018-09-28 00:00:00	8	330045	2018-09-27 22:00:00+07	f
897	430029	47118	001	2018-09-28 00:00:00	8	330045	2018-09-27 22:00:00+07	f
908	370043	47106	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
909	370042	47106	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
910	370019	47106	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
911	370033	47106	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
912	370038	47106	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
913	460070	47106	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
914	370003	47106	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
915	370022	47106	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
916	460061	47106	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
917	370040	47106	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
918	370039	47106	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
919	370023	47106	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
920	370046	47106	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
921	430052	47106	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
922	370009	47106	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
923	450061	47106	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
924	460059	47106	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
925	370002	47106	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
926	370045	47106	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
927	370027	47106	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
928	370041	47106	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
929	370017	47106	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
930	440062	47106	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
931	370020	47106	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
932	370056	47106	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
933	370016	47106	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
934	370083	47106	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
935	430047	47106	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
936	370010	47106	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
941	340034	47115	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
907	400022	47119	001	2018-09-28 00:00:00	6	430050	2018-10-15 12:52:26.044193+07	f
906	450068	47119	001	2018-09-28 00:00:00	6	430050	2018-10-15 12:52:31.593784+07	f
905	400037	47119	001	2018-09-28 00:00:00	6	430050	2018-10-15 12:52:34.542462+07	f
904	430022	47119	001	2018-09-28 00:00:00	6	430050	2018-10-15 12:52:45.689977+07	f
903	470055	47119	001	2018-09-28 00:00:00	6	430050	2018-10-15 12:52:53.912113+07	f
900	420019	47119	001	2018-09-28 00:00:00	6	430050	2018-10-15 12:55:27.600839+07	f
902	390012	47119	001	2018-09-28 00:00:00	6	430050	2018-10-15 12:55:13.384981+07	f
898	430027	47119	001	2018-09-28 00:00:00	6	430050	2018-10-15 12:55:32.923303+07	f
945	370039	47115	001	2018-09-28 00:00:00	8	280019	2018-10-17 07:03:18.997937+07	f
940	440022	47115	001	2018-09-28 00:00:00	8	280019	2018-10-17 07:03:30.824986+07	f
937	360012	47115	001	2018-09-28 00:00:00	8	280019	2018-10-17 07:03:56.600261+07	f
938	440042	47115	001	2018-09-28 00:00:00	8	280019	2018-10-19 09:30:36.988101+07	f
949	440028	47115	001	2018-09-28 00:00:00	8	280019	2018-10-31 14:08:54.504279+07	f
943	330004	47115	001	2018-09-28 00:00:00	8	280019	2018-11-02 15:15:47.336831+07	f
950	440070	47115	001	2018-09-28 00:00:00	6	280019	2018-11-02 15:16:18.739188+07	f
947	440003	47115	001	2018-09-28 00:00:00	6	280019	2018-11-02 15:16:21.918724+07	f
946	430012	47115	001	2018-09-28 00:00:00	6	280019	2018-11-02 15:16:23.187571+07	f
944	440014	47115	001	2018-09-28 00:00:00	6	280019	2018-11-02 15:16:24.762974+07	f
942	440040	47115	001	2018-09-28 00:00:00	6	280019	2018-11-02 15:16:26.317172+07	f
939	370019	47115	001	2018-09-28 00:00:00	6	280019	2018-11-02 15:17:10.950998+07	f
960	470001	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
961	470002	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
962	470003	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
963	470004	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
964	470005	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
965	470006	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
966	470007	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
967	470008	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
968	470009	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
969	470010	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
970	470011	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
971	470012	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
972	470013	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
973	470014	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
974	470015	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
975	470016	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
976	470017	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
977	470018	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
978	470019	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
979	470021	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
980	470022	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
981	470023	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
982	470024	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
983	470025	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
984	470026	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
985	470027	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
986	470028	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
987	470029	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
988	470030	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
989	470031	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
990	470032	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
991	470033	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
992	470034	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
993	470035	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
994	470036	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
995	470037	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
996	470038	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
997	470039	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
998	470040	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
999	470041	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1000	470042	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1001	470043	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1002	470044	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1003	470045	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1004	470046	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1005	470047	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1006	470048	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1007	470049	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1008	470050	47101	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1010	470001	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1011	470002	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1012	470003	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1013	470004	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1014	470005	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1015	470006	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1016	470007	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1017	470008	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1018	470009	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1019	470010	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1020	470011	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1021	470012	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1022	470013	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1023	470014	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1024	470015	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1025	470016	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1026	470017	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1027	470018	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1028	470019	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1029	470021	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1030	470022	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1031	470023	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1032	470024	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1033	470025	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1034	470026	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1035	470027	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1036	470028	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1037	470029	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1038	470030	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1039	470031	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1040	470032	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1041	470033	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1042	470034	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1043	470035	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1044	470036	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1045	470037	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1046	470038	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1047	470039	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1048	470040	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1049	470041	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1050	470042	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1051	470043	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1052	470044	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1053	470045	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1054	470046	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1055	470047	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1056	470048	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1057	470049	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
954	440071	47115	001	2018-09-28 00:00:00	6	280019	2018-11-02 15:16:55.843285+07	f
955	450056	47115	001	2018-09-28 00:00:00	6	280019	2018-11-02 15:16:57.393588+07	f
957	410044	47115	001	2018-09-28 00:00:00	6	280019	2018-11-02 15:17:02.51705+07	f
958	450061	47115	001	2018-09-28 00:00:00	6	280019	2018-11-02 15:17:05.178549+07	f
959	440050	47115	001	2018-09-28 00:00:00	6	280019	2018-11-02 15:17:07.172928+07	f
952	440039	47115	001	2018-09-28 00:00:00	6	280019	2018-11-02 15:17:09.120053+07	f
953	440005	47115	001	2018-09-28 00:00:00	6	280019	2018-11-02 15:17:13.290759+07	f
1009	430050	47204	006	2018-06-22 09:00:00	9	430050	2018-11-28 09:19:18.154895+07	f
1058	470050	47102	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1079	470022	47103	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
1150	430029	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1151	450019	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1152	440002	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1153	440021	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1154	440024	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1155	450035	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1156	440019	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1157	450002	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1158	440040	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1159	380006	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1160	440048	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1161	450038	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1162	370051	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1163	450062	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1164	350015	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1067	470009	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:44:27.225687+07	f
1066	470008	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:44:32.025086+07	f
1065	470007	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:44:38.667967+07	f
1063	470005	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:44:53.113271+07	f
1062	470004	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:45:01.769997+07	f
1061	470003	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:45:05.834938+07	f
1060	470002	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:45:10.317891+07	f
1059	470001	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:45:18.571408+07	f
1083	470026	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:45:26.690922+07	f
1075	470017	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:45:41.924186+07	f
1077	470019	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:46:02.631115+07	f
1076	470018	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:45:50.399993+07	f
1078	470021	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:46:09.645382+07	f
1073	470015	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:46:21.644174+07	f
1080	470023	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:46:50.027028+07	f
1081	470024	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:46:57.399921+07	f
1082	470025	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:47:05.649281+07	f
1084	470027	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:47:14.001741+07	f
1085	470028	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:47:21.0765+07	f
1086	470029	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:47:29.434228+07	f
1087	470030	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:47:36.840131+07	f
1089	470032	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:47:51.624145+07	f
1091	470034	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:48:09.278174+07	f
1090	470033	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:47:58.948223+07	f
1092	470035	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:48:21.530439+07	f
1093	470036	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:48:26.212432+07	f
1094	470037	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:48:31.32783+07	f
1096	470039	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:48:51.492072+07	f
1097	470040	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:48:56.371895+07	f
1098	470041	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:49:01.844572+07	f
1099	470042	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:49:07.282096+07	f
1100	470043	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:49:22.014166+07	f
1101	470044	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:49:27.225778+07	f
1103	470046	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:49:38.026653+07	f
1104	470047	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:49:43.385136+07	f
1105	470048	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:49:54.845926+07	f
1106	470049	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:49:58.6179+07	f
1107	470050	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:50:03.324195+07	f
1071	470013	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:50:16.444064+07	f
1069	470011	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:50:28.083699+07	f
1116	450038	47104	001	2018-09-28 00:00:00	8	280019	2018-10-24 07:21:25.227465+07	f
1123	450001	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:36:41.696857+07	f
1122	450033	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:36:46.080123+07	f
1121	450012	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:36:51.292801+07	f
1120	450003	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:37:12.315188+07	f
1118	450051	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:37:21.077579+07	f
1117	450004	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:37:25.732592+07	f
1115	450029	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:37:32.219852+07	f
1138	450014	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:37:38.427955+07	f
1114	450044	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:37:41.694541+07	f
1113	450021	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:37:47.284122+07	f
1112	450002	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:37:55.519447+07	f
1111	450035	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:38:00.91521+07	f
1110	450009	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:38:23.46414+07	f
1109	450039	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:38:27.257037+07	f
1108	450019	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:38:30.601542+07	f
1140	450047	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:38:36.503648+07	f
1131	450034	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:38:46.49372+07	f
1141	450026	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:38:58.101231+07	f
1133	450017	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:38:59.174946+07	f
1142	450023	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:39:05.664443+07	f
1143	450043	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:39:10.080991+07	f
1144	450041	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:39:22.442401+07	f
1135	450030	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:39:35.662201+07	f
1136	450049	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:39:40.268597+07	f
1137	450042	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:39:50.254589+07	f
1145	450045	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:39:54.703058+07	f
1146	450054	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:39:59.490927+07	f
1147	450050	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:40:03.7677+07	f
1149	450022	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:40:17.325585+07	f
1125	450006	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:40:22.569617+07	f
1126	450005	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:40:27.780654+07	f
1124	450028	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:40:30.872273+07	f
1130	450048	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:40:36.097912+07	f
1129	450032	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:40:39.769138+07	f
1127	450011	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:40:57.164248+07	f
1165	440031	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1166	430010	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1167	430019	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1168	350017	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1169	390029	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1170	350001	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1171	440023	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1172	360056	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1173	410009	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1174	440070	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1175	450071	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1176	440037	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1177	450041	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1178	460021	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1179	440065	47105	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1180	440029	47105	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
1181	400037	47105	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
1182	440049	47105	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
1183	300007	47105	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
1184	420049	47105	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
1185	380005	47105	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
1186	420002	47105	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
1187	440027	47105	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
1188	380046	47105	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
1189	440052	47105	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
1190	370023	47105	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
1191	440041	47105	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
1192	290001	47105	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
1193	340010	47105	001	2018-09-28 00:00:00	8		2018-09-27 22:00:00+07	f
1194	340043	47121	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1195	410022	47121	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1196	320034	47121	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1197	330007	47121	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1198	390040	47121	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1199	360053	47121	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
1200	260011	47121	001	2018-09-28 00:00:00	6		2018-09-27 22:00:00+07	f
786	460013	47220	010	2018-07-04 09:00:00	4	430050	2018-10-03 13:11:35.316716+07	f
1068	470010	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:44:22.049237+07	f
1064	470006	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:44:48.800975+07	f
1074	470016	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:45:30.49715+07	f
1072	470014	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:46:44.666862+07	f
1088	470031	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:47:47.64315+07	f
1095	470038	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:48:42.970689+07	f
1102	470045	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:49:32.398959+07	f
1070	470012	47103	001	2018-09-28 00:00:00	6	430050	2018-10-09 08:50:20.384142+07	f
899	390025	47119	001	2018-09-28 00:00:00	6	430050	2018-10-15 12:52:21.665635+07	f
901	360011	47119	001	2018-09-28 00:00:00	6	430050	2018-10-15 12:55:20.315938+07	f
951	360049	47115	001	2018-09-28 00:00:00	8	280019	2018-10-18 16:47:38.134232+07	f
1201	458003	47219	003	2018-10-19 10:45:40.606981	10	280019	2018-10-19 08:50:50.832404+07	f
1202	460068	47112	001	2018-10-19 13:48:00.389587	6	430050	2018-11-19 06:18:15.729829+07	f
1203	460067	47112	001	2018-10-19 13:49:38.786166	6	430050	2018-11-19 06:18:19.309915+07	f
1204	460069	47112	001	2018-10-19 13:50:52.021969	6	430050	2018-11-19 06:18:23.63822+07	f
1216	470060	47112	001	2018-10-19 13:58:56.258581	6	430050	2018-11-19 06:18:26.464355+07	f
1212	470056	47112	001	2018-10-19 13:55:21.309518	6	430050	2018-11-19 06:18:39.406438+07	f
1221	450071	47205	002	2018-10-24 15:41:03.767026	6	430050	2018-11-19 21:39:25.794316+07	f
783	420004	47209	005	2018-07-13 09:00:00	6	430050	2018-12-18 08:18:51.731076+07	f
1214	430050	47112	001	2018-10-19 13:56:31.755831	8	430050	2018-10-19 13:25:38.798612+07	f
1223	470002	47216	007	2018-11-09 09:04:24.799063	6	430050	2019-03-15 08:13:19.568961+07	f
1215	470059	47112	001	2018-10-19 13:57:54.917468	6	430050	2018-11-19 06:18:30.918918+07	f
1213	470057	47112	001	2018-10-19 13:55:46.423473	6	430050	2018-11-19 06:18:36.110576+07	f
1210	470054	47112	001	2018-10-19 13:54:19.747958	8	430050	2018-11-19 06:16:32.979653+07	f
1211	470055	47112	001	2018-10-19 13:55:03.395113	6	430050	2018-11-19 06:16:37.171492+07	f
1220	470064	47112	001	2018-10-19 14:01:08.410296	6	430050	2018-11-19 06:16:39.937487+07	f
1219	470063	47112	001	2018-10-19 14:00:55.214892	6	430050	2018-11-19 06:16:44.293946+07	f
1218	470062	47112	001	2018-10-19 14:00:38.991684	6	430050	2018-11-19 06:16:47.454969+07	f
1224	430050	47226	002	2018-11-28 11:13:37.068973	4	430050	2018-12-19 07:23:51.989185+07	f
1217	470061	47112	001	2018-10-19 14:00:11.565612	6	430050	2018-11-19 06:16:51.895575+07	f
1119	450040	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:37:17.496263+07	f
1139	450025	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:37:50.858497+07	f
1132	450037	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:38:42.700779+07	f
1134	450015	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:39:29.290562+07	f
1148	450010	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:40:12.199076+07	f
1128	450052	47104	001	2018-09-28 00:00:00	6	430050	2018-10-29 06:40:46.547923+07	f
723	440047	47217	004	2018-07-13 09:00:00	4	430050	2018-10-29 06:43:04.240682+07	f
730	450019	47202	007	2018-07-17 09:00:00	4	430050	2018-10-29 06:43:41.377935+07	f
777	370046	47211	005	2018-07-13 09:00:00	4	430050	2018-10-29 06:46:37.613498+07	f
948	440073	47115	001	2018-09-28 00:00:00	6	280019	2018-11-02 15:16:20.60906+07	f
956	440036	47115	001	2018-09-28 00:00:00	6	280019	2018-11-02 15:16:59.283026+07	f
797	370045	47205	002	2018-07-13 09:00:00	9	430050	2018-11-19 06:15:54.486772+07	f
1205	460070	47112	001	2018-10-19 13:51:35.889569	6	430050	2018-11-19 06:16:07.457779+07	f
1222	270009	47202	016	2018-11-08 18:21:10.62724	10	430050	2018-11-08 16:22:47.461797+07	f
828	430009	47228	009	2018-07-19 09:00:00	6	430050	2018-11-28 23:18:57.220697+07	f
1206	460071	47112	001	2018-10-19 13:52:04.10246	6	430050	2018-11-19 06:16:11.870292+07	f
1207	460072	47112	001	2018-10-19 13:52:21.505035	8	430050	2018-11-19 06:16:18.781487+07	f
1208	470052	47112	001	2018-10-19 13:52:45.407229	8	430050	2018-11-19 06:16:22.058572+07	f
1209	470053	47112	001	2018-10-19 13:53:53.359293	6	430050	2018-11-19 06:16:26.810221+07	f
744	460010	47220	009	2018-07-04 09:00:00	6	430050	2018-12-18 08:14:01.255774+07	f
1226	430013	47222	012	2018-12-26 09:14:25.778976	6	450061	2019-02-19 19:18:23.353836+07	f
1227	440044	47204	027	2018-12-26 09:16:25.577643	6	450061	2019-02-27 11:59:20.98836+07	f
1228	450061	47202	018	2019-01-15 15:36:55.859628	8	430050	2019-01-15 13:38:08.399063+07	f
1229	430050	47108	003	2019-01-18 11:12:59.489743	10	450061	2019-01-18 09:22:04.851456+07	f
1235	350054	47107	001	2019-01-21 13:56:15.595767	6	450061	2019-01-21 12:01:56.97998+07	f
1234	270015	47107	001	2019-01-21 13:56:03.716739	6	450061	2019-01-21 12:02:03.678423+07	f
1233	270004	47107	001	2019-01-21 13:55:51.511257	6	450061	2019-01-21 12:02:08.966737+07	f
1231	340051	47107	001	2019-01-21 13:55:03.554459	6	450061	2019-01-21 12:02:20.436794+07	f
1230	270009	47107	001	2019-01-21 13:49:00.019201	6	450061	2019-01-21 12:02:26.010232+07	f
1225	360053	47222	012	2018-12-26 09:13:09.946848	8	450061	2019-02-01 12:38:08.502731+07	f
1248	470054	47107	001	2019-01-21 13:59:38.675127	8	450061	2019-01-21 12:00:15.259727+07	f
1247	270013	47107	001	2019-01-21 13:59:26.046475	8	450061	2019-01-21 12:00:30.940204+07	f
1246	270014	47107	001	2019-01-21 13:59:12.204672	8	450061	2019-01-21 12:00:37.186085+07	f
1245	380061	47107	001	2019-01-21 13:58:53.681502	8	450061	2019-01-21 12:00:43.109354+07	f
1244	270005	47107	001	2019-01-21 13:58:35.873095	8	450061	2019-01-21 12:00:51.743024+07	f
1243	340054	47107	001	2019-01-21 13:58:13.792975	6	450061	2019-01-21 12:00:58.074926+07	f
1242	380053	47107	001	2019-01-21 13:58:00.493061	6	450061	2019-01-21 12:01:07.36914+07	f
1241	270023	47107	001	2019-01-21 13:57:46.118793	6	450061	2019-01-21 12:01:14.171032+07	f
1240	360056	47107	001	2019-01-21 13:57:32.28717	6	450061	2019-01-21 12:01:20.895822+07	f
1239	470052	47107	001	2019-01-21 13:57:19.209092	6	450061	2019-01-21 12:01:31.890551+07	f
1238	410045	47107	001	2019-01-21 13:57:00.331939	6	450061	2019-01-21 12:01:38.635775+07	f
1237	390038	47107	001	2019-01-21 13:56:38.433353	6	450061	2019-01-21 12:01:44.847168+07	f
1236	370051	47107	001	2019-01-21 13:56:26.766906	6	450061	2019-01-21 12:01:51.629177+07	f
1232	270011	47107	001	2019-01-21 13:55:34.245141	6	450061	2019-01-21 12:02:12.295371+07	f
1250	370022	47108	001	2019-01-21 14:05:20.444013	6	450061	2019-01-21 12:06:50.597065+07	f
1255	460070	47108	001	2019-01-21 14:06:26.338584	6	450061	2019-01-21 12:06:59.894819+07	f
1249	440045	47108	001	2019-01-21 14:05:04.762804	6	450061	2019-01-21 12:07:07.19946+07	f
1251	420002	47108	001	2019-01-21 14:05:38.323894	6	450061	2019-01-21 12:07:13.770261+07	f
1253	440021	47108	001	2019-01-21 14:06:00.989657	6	450061	2019-01-21 12:07:22.367939+07	f
1254	430029	47108	001	2019-01-21 14:06:12.54466	6	450061	2019-01-21 12:07:36.501462+07	f
1252	460054	47108	001	2019-01-21 14:05:49.366982	6	450061	2019-01-21 12:07:44.338014+07	f
1256	450019	47108	002	2019-01-21 14:09:01.136197	6	450061	2019-01-21 12:18:02.466822+07	f
1285	430013	47108	002	2019-01-21 14:15:50.91603	6	450061	2019-01-21 12:18:21.703258+07	f
1284	430027	47108	002	2019-01-21 14:15:38.794148	6	450061	2019-01-21 12:18:29.394106+07	f
1283	430018	47108	002	2019-01-21 14:15:24.433085	6	450061	2019-01-21 12:18:43.134667+07	f
1282	440070	47108	002	2019-01-21 14:15:04.093512	6	450061	2019-01-21 12:18:50.040736+07	f
1281	440008	47108	002	2019-01-21 14:14:47.684653	6	450061	2019-01-21 12:19:18.017466+07	f
1280	430033	47108	002	2019-01-21 14:14:33.928767	6	450061	2019-01-21 12:19:24.406626+07	f
1279	460067	47108	002	2019-01-21 14:14:13.267819	6	450061	2019-01-21 12:19:31.846263+07	f
1278	370083	47108	002	2019-01-21 14:13:59.696173	6	450061	2019-01-21 12:19:38.851282+07	f
1277	440013	47108	002	2019-01-21 14:13:47.732346	6	450061	2019-01-21 12:19:44.145822+07	f
1276	380060	47108	002	2019-01-21 14:13:31.68587	6	450061	2019-01-21 12:19:53.608351+07	f
1275	430030	47108	002	2019-01-21 14:13:12.70021	6	450061	2019-01-21 12:20:00.809064+07	f
1274	440035	47108	002	2019-01-21 14:13:00.446503	6	450061	2019-01-21 12:20:08.036611+07	f
1273	440017	47108	002	2019-01-21 14:12:42.456417	6	450061	2019-01-21 12:20:14.217694+07	f
1272	460061	47108	002	2019-01-21 14:12:30.578922	6	450061	2019-01-21 12:20:20.556274+07	f
1271	410028	47108	002	2019-01-21 14:12:16.809671	6	450061	2019-01-21 12:20:27.967894+07	f
1270	450005	47108	002	2019-01-21 14:12:03.377152	6	450061	2019-01-21 12:20:34.659027+07	f
1269	440026	47108	002	2019-01-21 14:11:50.198155	6	450061	2019-01-21 12:20:43.030025+07	f
1268	390036	47108	002	2019-01-21 14:11:36.185145	6	450061	2019-01-21 12:20:49.835424+07	f
1267	450033	47108	002	2019-01-21 14:11:21.787523	6	450061	2019-01-21 12:20:56.546281+07	f
1266	450004	47108	002	2019-01-21 14:11:06.438725	6	450061	2019-01-21 12:21:04.596559+07	f
1265	440051	47108	002	2019-01-21 14:10:53.67225	6	450061	2019-01-21 12:21:11.983942+07	f
1264	440040	47108	002	2019-01-21 14:10:42.464721	6	450061	2019-01-21 12:21:17.083931+07	f
1263	460064	47108	002	2019-01-21 14:10:26.766193	6	450061	2019-01-21 12:21:23.30568+07	f
1262	460034	47108	002	2019-01-21 14:10:16.28392	6	450061	2019-01-21 12:21:29.173522+07	f
1261	450002	47108	002	2019-01-21 14:10:05.707985	6	450061	2019-01-21 12:21:35.184918+07	f
1260	440019	47108	002	2019-01-21 14:09:54.309673	6	450061	2019-01-21 12:21:43.15049+07	f
1259	430017	47108	002	2019-01-21 14:09:40.498174	6	450061	2019-01-21 12:21:49.363545+07	f
1258	440049	47108	002	2019-01-21 14:09:27.531082	6	450061	2019-01-21 12:21:55.361271+07	f
1257	450039	47108	002	2019-01-21 14:09:14.986924	6	450061	2019-01-21 12:22:00.593283+07	f
1293	410044	47108	002	2019-01-21 14:17:40.334428	6	450061	2019-01-21 12:22:09.83807+07	f
1292	450056	47108	002	2019-01-21 14:17:25.033178	6	450061	2019-01-21 12:22:16.94155+07	f
1291	380066	47108	002	2019-01-21 14:17:07.095716	6	450061	2019-01-21 12:22:22.211367+07	f
1290	440044	47108	002	2019-01-21 14:16:54.345602	6	450061	2019-01-21 12:22:29.156892+07	f
1289	460053	47108	002	2019-01-21 14:16:43.117672	6	450061	2019-01-21 12:22:35.002842+07	f
1288	440041	47108	002	2019-01-21 14:16:31.510687	6	450061	2019-01-21 12:22:40.686269+07	f
1287	440037	47108	002	2019-01-21 14:16:18.134535	6	450061	2019-01-21 12:22:47.195948+07	f
1286	450071	47108	002	2019-01-21 14:16:05.773725	6	450061	2019-01-21 12:22:52.304841+07	f
1294	290011	46110	001	2019-04-17 10:11:22.251569	11	290011	2019-04-17 08:15:12.582134+07	f
1295	290011	48599	001	2019-04-17 10:29:00.328548	8	290011	2019-04-17 08:29:08.199333+07	f
1296	290011	48599	001	2019-04-17 10:33:12.015545	3	290011	2019-04-17 08:33:12.015545+07	f
1297	390032	48501	001	2019-04-17 11:23:06.962957	8	390032	2019-04-17 09:28:19.260653+07	f
1298	390032	48505	001	2019-04-17 11:29:05.543798	8	390032	2019-04-17 09:29:26.969693+07	f
1300	290011	48504	001	2019-04-17 14:14:40.059218	3	290011	2019-04-17 12:14:40.059218+07	f
1301	290011	47151	001	2019-04-17 14:15:57.471188	0	290011	2019-04-17 12:15:57.471188+07	f
1302	360015	48503	001	2019-04-17 14:49:11.375658	8	360015	2019-04-17 12:50:37.609628+07	f
1304	290016	48501	001	2019-04-17 14:51:35.992694	8	290016	2019-04-17 12:52:08.177621+07	f
1303	450010	48501	001	2019-04-17 14:49:57.794483	8	450010	2019-04-17 12:52:11.08367+07	f
1299	340051	48501	001	2019-04-17 13:16:19.135739	8	390032	2019-04-17 12:52:31.604369+07	f
1305	290016	48501	001	2019-04-17 14:52:38.710857	8	290016	2019-04-17 12:52:45.138756+07	f
1306	450010	48501	001	2019-04-17 14:52:44.849924	8	450010	2019-04-17 12:52:57.858545+07	f
1307	460069	48504	001	2019-04-18 11:20:12.628156	3	460069	2019-04-18 09:20:12.628156+07	f
1308	460055	48504	001	2019-04-18 11:56:02.453313	3	460055	2019-04-18 09:56:02.453313+07	f
1309	460055	48503	001	2019-04-18 11:57:59.197894	3	460055	2019-04-18 09:57:59.197894+07	f
1310	380060	48506	001	2019-04-24 23:40:17.227689	3	380060	2019-04-24 21:40:17.227689+07	f
1311	320056	48502	001	2019-05-27 13:14:28.580146	8	320056	2019-05-27 11:14:47.430797+07	f
1312	480001	48101	001	2019-06-12 13:12:40.025124	6	280019	2019-06-12 11:13:09.489641+07	f
1313	450025	48105	001	2019-06-12 13:18:41.799008	6	280019	2019-06-12 11:21:53.972859+07	f
1314	450047	48105	001	2019-06-12 13:19:04.342886	6	280019	2019-06-12 11:21:58.762225+07	f
1315	470010	48105	001	2019-06-12 13:19:22.811496	6	280019	2019-06-12 11:22:03.643516+07	f
1316	470062	48105	001	2019-06-12 13:19:38.211041	6	280019	2019-06-12 11:22:09.53792+07	f
1317	450023	48105	001	2019-06-12 13:20:01.009323	6	280019	2019-06-12 11:22:15.102916+07	f
1318	450045	48105	001	2019-06-12 13:20:20.270837	6	280019	2019-06-12 11:22:22.020142+07	f
1319	470027	48105	001	2019-06-12 13:20:39.810588	6	280019	2019-06-12 11:22:28.235576+07	f
1320	450054	48105	001	2019-06-12 13:21:04.416884	6	280019	2019-06-12 11:22:35.294653+07	f
1321	460021	48105	001	2019-06-12 13:21:28.597578	8	280019	2019-06-12 11:22:57.294544+07	f
1323	470061	48105	002	2019-06-12 13:24:32.159008	6	280019	2019-06-12 11:55:04.061381+07	f
1324	460055	48105	002	2019-06-12 13:24:58.859876	6	280019	2019-06-12 11:55:06.139014+07	f
1325	440049	48105	002	2019-06-12 13:25:12.390926	6	280019	2019-06-12 11:55:08.431898+07	f
1326	460002	48105	002	2019-06-12 13:25:34.083148	6	280019	2019-06-12 11:55:10.712611+07	f
1327	460066	48105	002	2019-06-12 13:25:50.881385	6	280019	2019-06-12 11:56:52.332542+07	f
1365	420019	48105	002	2019-06-12 13:53:12.687213	8	280019	2019-06-12 11:54:18.569418+07	f
1356	380005	48105	002	2019-06-12 13:50:38.139505	8	280019	2019-06-12 11:54:20.57917+07	f
1357	430009	48105	002	2019-06-12 13:50:50.944888	8	280019	2019-06-12 11:54:22.881079+07	f
1358	460059	48105	002	2019-06-12 13:51:06.462979	8	280019	2019-06-12 11:54:25.223552+07	f
1359	210010	48105	002	2019-06-12 13:51:39.569819	8	280019	2019-06-12 11:54:27.526392+07	f
1360	460044	48105	002	2019-06-12 13:51:54.481393	8	280019	2019-06-12 11:54:31.300761+07	f
1361	460041	48105	002	2019-06-12 13:52:13.67169	8	280019	2019-06-12 11:54:34.287289+07	f
1362	460017	48105	002	2019-06-12 13:52:29.305928	8	280019	2019-06-12 11:54:36.176215+07	f
1363	460007	48105	002	2019-06-12 13:52:45.50345	8	280019	2019-06-12 11:54:38.001431+07	f
1364	460034	48105	002	2019-06-12 13:52:58.998032	8	280019	2019-06-12 11:54:40.024221+07	f
1322	470049	48105	002	2019-06-12 13:24:19.727393	6	280019	2019-06-12 11:55:02.043678+07	f
1328	460052	48105	002	2019-06-12 13:26:26.87736	6	280019	2019-06-12 11:56:54.650377+07	f
1329	470064	48105	002	2019-06-12 13:26:53.966004	6	280019	2019-06-12 11:56:56.647838+07	f
1330	450029	48105	002	2019-06-12 13:27:11.336758	6	280019	2019-06-12 11:56:58.681893+07	f
1331	460072	48105	002	2019-06-12 13:27:38.270134	6	280019	2019-06-12 11:57:00.799065+07	f
1332	460070	48105	002	2019-06-12 13:27:57.58218	6	280019	2019-06-12 11:57:02.737379+07	f
1333	360034	48105	002	2019-06-12 13:28:15.099024	6	280019	2019-06-12 11:57:04.989234+07	f
1334	460036	48105	002	2019-06-12 13:28:32.033638	6	280019	2019-06-12 11:58:04.886957+07	f
1335	460005	48105	002	2019-06-12 13:28:47.797929	6	280019	2019-06-12 11:58:07.116486+07	f
1336	450028	48105	002	2019-06-12 13:29:02.031294	6	280019	2019-06-12 11:58:09.550107+07	f
1337	460024	48105	002	2019-06-12 13:29:19.797481	6	280019	2019-06-12 11:58:11.786659+07	f
1338	460048	48105	002	2019-06-12 13:29:35.726774	6	280019	2019-06-12 11:58:13.742525+07	f
1339	450017	48105	002	2019-06-12 13:29:53.183406	6	280019	2019-06-12 11:58:15.7757+07	f
1340	460026	48105	002	2019-06-12 13:30:11.947998	6	280019	2019-06-12 11:58:17.767626+07	f
1341	470014	48105	002	2019-06-12 13:30:28.999897	6	280019	2019-06-12 11:58:21.077702+07	f
1342	450030	48105	002	2019-06-12 13:30:44.080966	6	280019	2019-06-12 11:58:23.359843+07	f
1343	460019	48105	002	2019-06-12 13:30:59.304213	6	280019	2019-06-12 11:58:25.256642+07	f
1344	470012	48105	002	2019-06-12 13:31:18.133776	6	280019	2019-06-12 11:58:27.2105+07	f
1345	460038	48105	002	2019-06-12 13:31:33.343954	6	280019	2019-06-12 11:58:29.101776+07	f
1346	470018	48105	002	2019-06-12 13:31:47.930377	6	280019	2019-06-12 11:58:31.342426+07	f
1347	470046	48105	002	2019-06-12 13:31:59.926401	6	280019	2019-06-12 11:58:34.902517+07	f
1348	450014	48105	002	2019-06-12 13:32:13.933846	6	280019	2019-06-12 11:58:37.318127+07	f
1349	470032	48105	002	2019-06-12 13:32:27.897445	6	280019	2019-06-12 11:58:39.454689+07	f
1350	470016	48105	002	2019-06-12 13:32:40.176542	6	280019	2019-06-12 11:58:41.747817+07	f
1351	450010	48105	002	2019-06-12 13:32:52.83015	6	280019	2019-06-12 11:58:43.71273+07	f
1352	460037	48105	002	2019-06-12 13:34:17.943517	6	280019	2019-06-12 11:59:04.588131+07	f
1353	330026	48105	002	2019-06-12 13:34:30.741519	6	280019	2019-06-12 11:59:06.560679+07	f
1354	450002	48105	002	2019-06-12 13:49:53.789841	8	280019	2019-06-12 11:59:08.705228+07	f
1355	430019	48105	002	2019-06-12 13:50:20.713932	8	280019	2019-06-12 11:59:10.511094+07	f
1411	450047	48502	001	2019-06-14 11:20:05.686477	3	450047	2019-06-14 09:20:05.686477+07	f
1420	480008	48103	001	2019-06-19 15:49:09.884526	3	280019	2019-06-19 15:21:23.043391+07	f
1419	480007	48103	001	2019-06-19 15:48:59.685932	3	280019	2019-06-19 15:21:24.773677+07	f
1418	480006	48103	001	2019-06-19 15:48:49.596754	3	280019	2019-06-19 15:21:26.344318+07	f
1417	480005	48103	001	2019-06-19 15:48:32.280461	3	280019	2019-06-19 15:21:27.917656+07	f
1416	480004	48103	001	2019-06-19 15:48:21.553741	3	280019	2019-06-19 15:21:30.512605+07	f
1415	480003	48103	001	2019-06-19 15:48:06.53337	3	280019	2019-06-19 15:21:31.856443+07	f
1414	480002	48103	001	2019-06-19 15:47:52.427412	3	280019	2019-06-19 15:21:33.523282+07	f
1413	480001	48103	001	2019-06-19 15:47:39.328822	3	280019	2019-06-19 15:21:35.38676+07	f
1410	460037	48104	001	2019-06-12 16:05:09.847582	3	280019	2019-06-19 15:24:02.384016+07	f
1408	460039	48104	001	2019-06-12 16:04:49.171038	3	280019	2019-06-19 15:24:06.128248+07	f
1407	460012	48104	001	2019-06-12 16:04:37.507614	3	280019	2019-06-19 15:24:08.023721+07	f
1406	460033	48104	001	2019-06-12 16:04:22.260503	3	280019	2019-06-19 15:24:09.740998+07	f
1405	460021	48104	001	2019-06-12 16:04:00.65967	3	280019	2019-06-19 15:24:12.350665+07	f
1404	460049	48104	001	2019-06-12 16:03:51.426431	3	280019	2019-06-19 15:24:14.040005+07	f
1403	460011	48104	001	2019-06-12 16:03:38.28115	3	280019	2019-06-19 15:24:15.98946+07	f
1402	460035	48104	001	2019-06-12 16:03:26.734577	3	280019	2019-06-19 15:24:17.742056+07	f
1401	460032	48104	001	2019-06-12 16:03:15.28703	3	280019	2019-06-19 15:24:19.448731+07	f
1400	460038	48104	001	2019-06-12 16:03:02.860223	3	280019	2019-06-19 15:24:22.995353+07	f
1399	460019	48104	001	2019-06-12 16:02:52.295591	3	280019	2019-06-19 15:24:24.859433+07	f
1398	460015	48104	001	2019-06-12 16:02:41.730983	3	280019	2019-06-19 15:24:26.494695+07	f
1397	460050	48104	001	2019-06-12 16:02:30.345663	3	280019	2019-06-19 15:24:28.519314+07	f
1396	460026	48104	001	2019-06-12 16:02:20.193554	3	280019	2019-06-19 15:24:30.308853+07	f
1395	460020	48104	001	2019-06-12 16:02:05.034604	3	280019	2019-06-19 15:24:32.009112+07	f
1394	460005	48104	001	2019-06-12 16:01:54.22663	3	280019	2019-06-19 15:24:33.509168+07	f
1393	460047	48104	001	2019-06-12 16:01:43.566395	3	280019	2019-06-19 15:24:35.078605+07	f
1392	460036	48104	001	2019-06-12 16:01:30.140235	3	280019	2019-06-19 15:24:36.555378+07	f
1391	460048	48104	001	2019-06-12 16:01:14.021611	3	280019	2019-06-19 15:24:38.893008+07	f
1390	460017	48104	001	2019-06-12 16:01:02.834625	3	280019	2019-06-19 15:24:40.572425+07	f
1389	460041	48104	001	2019-06-12 16:00:51.173526	3	280019	2019-06-19 15:24:42.06927+07	f
1387	460024	48104	001	2019-06-12 16:00:09.69979	3	280019	2019-06-19 15:24:46.813792+07	f
1386	460010	48104	001	2019-06-12 15:59:58.124226	3	280019	2019-06-19 15:24:48.600892+07	f
1385	460031	48104	001	2019-06-12 15:59:44.129105	3	280019	2019-06-19 15:24:49.983688+07	f
1384	460046	48104	001	2019-06-12 15:59:32.630739	3	280019	2019-06-19 15:24:51.639269+07	f
1383	460006	48104	001	2019-06-12 15:59:15.532746	3	280019	2019-06-19 15:24:53.287789+07	f
1382	460029	48104	001	2019-06-12 15:59:01.211596	3	280019	2019-06-19 15:24:55.424359+07	f
1381	460014	48104	001	2019-06-12 15:58:50.273991	3	280019	2019-06-19 15:24:57.083615+07	f
1380	460018	48104	001	2019-06-12 15:58:36.922806	3	280019	2019-06-19 15:24:58.736888+07	f
1379	460001	48104	001	2019-06-12 15:58:24.672349	3	280019	2019-06-19 15:25:00.386579+07	f
1378	460034	48104	001	2019-06-12 15:58:12.470119	3	280019	2019-06-19 15:25:02.214062+07	f
1377	460052	48104	001	2019-06-12 15:57:53.612693	3	280019	2019-06-19 15:25:21.445752+07	f
1376	460008	48104	001	2019-06-12 15:57:40.089489	3	280019	2019-06-19 15:25:23.441423+07	f
1375	460007	48104	001	2019-06-12 15:57:24.796891	3	280019	2019-06-19 15:25:26.819546+07	f
1373	460004	48104	001	2019-06-12 15:56:57.177593	3	280019	2019-06-19 15:25:29.395632+07	f
1374	460002	48104	001	2019-06-12 15:57:10.66429	3	280019	2019-06-19 15:25:30.842006+07	f
1372	460023	48104	001	2019-06-12 15:56:38.555294	3	280019	2019-06-19 15:25:32.196893+07	f
1371	460044	48104	001	2019-06-12 15:55:54.512703	3	280019	2019-06-19 15:25:34.212831+07	f
1370	460022	48104	001	2019-06-12 15:55:33.637828	3	280019	2019-06-19 15:25:35.549188+07	f
1369	460027	48104	001	2019-06-12 15:55:18.853262	3	280019	2019-06-19 15:25:36.82675+07	f
1368	460025	48104	001	2019-06-12 15:54:55.479642	3	280019	2019-06-19 15:25:38.25309+07	f
1412	480048	48116	001	2019-06-18 14:03:36.746154	6	280019	2019-08-02 07:49:13.819708+07	f
1501	470063	48106	001	2019-06-19 16:30:23.963701	3	280019	2019-06-19 15:16:32.914154+07	f
1487	380046	48106	001	2019-06-19 16:23:53.059378	11	280019	2019-07-10 11:41:01.132424+07	f
1499	430047	48106	001	2019-06-19 16:29:57.259563	3	280019	2019-06-19 15:16:37.19499+07	f
1498	370083	48106	001	2019-06-19 16:29:44.019664	3	280019	2019-06-19 15:16:39.004443+07	f
1496	370056	48106	001	2019-06-19 16:29:17.891907	8	280019	2019-08-05 15:23:42.79713+07	f
1495	370020	48106	001	2019-06-19 16:29:05.676686	3	280019	2019-06-19 15:16:47.299015+07	f
1494	370041	48106	001	2019-06-19 16:28:50.886432	3	280019	2019-06-19 15:16:49.446068+07	f
1493	370027	48106	001	2019-06-19 16:28:29.748406	3	280019	2019-06-19 15:16:51.567901+07	f
1492	370045	48106	001	2019-06-19 16:28:17.112116	3	280019	2019-06-19 15:16:53.312841+07	f
1491	370002	48106	001	2019-06-19 16:24:41.470682	3	280019	2019-06-19 15:16:57.668254+07	f
1490	380034	48106	001	2019-06-19 16:24:32.138225	3	280019	2019-06-19 15:16:59.492832+07	f
1489	380007	48106	001	2019-06-19 16:24:20.287834	3	280019	2019-06-19 15:17:01.718781+07	f
1488	380017	48106	001	2019-06-19 16:24:05.046381	3	280019	2019-06-19 15:17:03.636584+07	f
1497	370016	48106	001	2019-06-19 16:29:29.979919	8	280019	2019-08-05 15:23:35.580535+07	f
1486	380039	48106	001	2019-06-19 16:23:42.796395	3	280019	2019-06-19 15:17:09.07608+07	f
1485	380008	48106	001	2019-06-19 16:23:30.560802	3	280019	2019-06-19 15:17:10.70073+07	f
1484	380002	48106	001	2019-06-19 16:21:19.366942	3	280019	2019-06-19 15:17:12.355714+07	f
1483	380005	48106	001	2019-06-19 16:21:06.685265	3	280019	2019-06-19 15:17:14.12691+07	f
1482	380031	48106	001	2019-06-19 16:20:54.386585	3	280019	2019-06-19 15:17:17.088202+07	f
1481	380022	48106	001	2019-06-19 16:20:45.893439	3	280019	2019-06-19 15:17:18.682145+07	f
1480	380006	48106	001	2019-06-19 16:20:30.21306	3	280019	2019-06-19 15:17:20.468982+07	f
1479	380038	48106	001	2019-06-19 16:20:21.319971	3	280019	2019-06-19 15:17:22.233621+07	f
1478	380029	48106	001	2019-06-19 16:20:07.69595	3	280019	2019-06-19 15:17:23.66517+07	f
1477	380042	48106	001	2019-06-19 16:19:49.016444	3	280019	2019-06-19 15:17:25.334453+07	f
1476	380044	48106	001	2019-06-19 16:19:34.806884	3	280019	2019-06-19 15:17:27.851604+07	f
1464	480052	48103	001	2019-06-19 16:11:37.281298	3	280019	2019-06-19 15:19:50.678108+07	f
1462	480050	48103	001	2019-06-19 16:07:51.328266	3	280019	2019-06-19 15:19:54.764152+07	f
1461	480049	48103	001	2019-06-19 16:07:40.875797	3	280019	2019-06-19 15:19:56.539418+07	f
1460	480048	48103	001	2019-06-19 16:07:29.44277	3	280019	2019-06-19 15:19:58.421749+07	f
1459	480047	48103	001	2019-06-19 16:07:13.299579	3	280019	2019-06-19 15:20:00.327981+07	f
1458	480046	48103	001	2019-06-19 16:07:03.772382	3	280019	2019-06-19 15:20:02.09486+07	f
1457	480045	48103	001	2019-06-19 16:06:51.340793	3	280019	2019-06-19 15:20:03.811685+07	f
1456	480044	48103	001	2019-06-19 16:06:40.619071	3	280019	2019-06-19 15:20:05.382918+07	f
1455	480043	48103	001	2019-06-19 15:56:32.597423	3	280019	2019-06-19 15:20:07.196422+07	f
1453	480041	48103	001	2019-06-19 15:56:04.623368	3	280019	2019-06-19 15:20:15.466938+07	f
1454	480042	48103	001	2019-06-19 15:56:22.805206	3	280019	2019-06-19 15:20:13.622435+07	f
1452	480040	48103	001	2019-06-19 15:55:50.010935	3	280019	2019-06-19 15:20:17.279335+07	f
1451	480039	48103	001	2019-06-19 15:55:38.164159	3	280019	2019-06-19 15:20:18.905825+07	f
1450	480038	48103	001	2019-06-19 15:55:27.899427	3	280019	2019-06-19 15:20:20.488873+07	f
1449	480037	48103	001	2019-06-19 15:55:15.064763	3	280019	2019-06-19 15:20:22.066704+07	f
1448	480036	48103	001	2019-06-19 15:55:05.156086	3	280019	2019-06-19 15:20:23.676576+07	f
1447	480035	48103	001	2019-06-19 15:54:55.74382	3	280019	2019-06-19 15:20:26.740745+07	f
1446	480034	48103	001	2019-06-19 15:54:45.211205	3	280019	2019-06-19 15:20:28.668205+07	f
1445	480033	48103	001	2019-06-19 15:54:35.115441	3	280019	2019-06-19 15:20:30.412003+07	f
1444	480032	48103	001	2019-06-19 15:54:25.81495	3	280019	2019-06-19 15:20:31.902878+07	f
1443	480031	48103	001	2019-06-19 15:54:15.67977	3	280019	2019-06-19 15:20:33.505373+07	f
1441	480029	48103	001	2019-06-19 15:53:53.036898	3	280019	2019-06-19 15:20:37.809958+07	f
1440	480028	48103	001	2019-06-19 15:53:35.741623	3	280019	2019-06-19 15:20:39.420487+07	f
1439	480027	48103	001	2019-06-19 15:53:25.432187	3	280019	2019-06-19 15:20:42.541544+07	f
1438	480026	48103	001	2019-06-19 15:53:15.591555	3	280019	2019-06-19 15:20:45.906242+07	f
1437	480025	48103	001	2019-06-19 15:53:03.935326	3	280019	2019-06-19 15:20:47.864684+07	f
1436	480024	48103	001	2019-06-19 15:52:53.951681	3	280019	2019-06-19 15:20:49.435003+07	f
1435	480023	48103	001	2019-06-19 15:52:44.979985	3	280019	2019-06-19 15:20:50.829025+07	f
1434	480022	48103	001	2019-06-19 15:52:33.682666	3	280019	2019-06-19 15:20:53.626699+07	f
1433	480021	48103	001	2019-06-19 15:52:10.365639	3	280019	2019-06-19 15:20:55.263643+07	f
1432	480020	48103	001	2019-06-19 15:51:59.893599	3	280019	2019-06-19 15:20:56.841944+07	f
1431	480019	48103	001	2019-06-19 15:51:48.655603	3	280019	2019-06-19 15:20:58.350571+07	f
1430	480018	48103	001	2019-06-19 15:51:37.369126	3	280019	2019-06-19 15:20:59.823207+07	f
1429	480017	48103	001	2019-06-19 15:51:25.4711	3	280019	2019-06-19 15:21:01.337054+07	f
1428	480016	48103	001	2019-06-19 15:50:47.577088	3	280019	2019-06-19 15:21:03.8371+07	f
1427	480015	48103	001	2019-06-19 15:50:34.891363	3	280019	2019-06-19 15:21:07.045787+07	f
1426	480014	48103	001	2019-06-19 15:50:25.591436	3	280019	2019-06-19 15:21:08.369295+07	f
1425	480013	48103	001	2019-06-19 15:50:16.267126	3	280019	2019-06-19 15:21:10.938585+07	f
1424	480012	48103	001	2019-06-19 15:50:06.304659	3	280019	2019-06-19 15:21:14.829109+07	f
1423	480011	48103	001	2019-06-19 15:49:56.624177	3	280019	2019-06-19 15:21:16.458616+07	f
1422	480010	48103	001	2019-06-19 15:49:35.175056	3	280019	2019-06-19 15:21:18.362939+07	f
1474	480054	48112	001	2019-06-19 16:17:57.963593	3	280019	2019-06-19 16:00:13.785688+07	f
1473	480053	48112	001	2019-06-19 16:17:49.643434	3	280019	2019-06-19 16:00:15.844844+07	f
1472	470070	48112	001	2019-06-19 16:17:35.692485	3	280019	2019-06-19 16:00:18.294788+07	f
1471	470069	48112	001	2019-06-19 16:17:26.902548	3	280019	2019-06-19 16:00:20.095368+07	f
1470	470068	48112	001	2019-06-19 16:17:13.04393	3	280019	2019-06-19 16:00:21.873424+07	f
1469	470067	48112	001	2019-06-19 16:17:05.420256	3	280019	2019-06-19 16:00:23.771142+07	f
1468	460060	48112	001	2019-06-19 16:16:52.610104	3	280019	2019-06-19 16:00:25.291782+07	f
1467	470054	48112	001	2019-06-19 16:16:41.188265	3	280019	2019-06-19 16:00:27.130108+07	f
1466	470052	48112	001	2019-06-19 16:16:31.855492	3	280019	2019-06-19 16:01:09.786335+07	f
1465	460072	48112	001	2019-06-19 16:16:14.720904	3	280019	2019-06-19 16:01:12.330927+07	f
1516	470054	48107	001	2019-06-19 16:35:31.249711	3	280019	2019-06-19 16:02:28.418907+07	f
1515	420049	48107	001	2019-06-19 16:34:01.894377	3	280019	2019-06-19 16:02:29.943873+07	f
1514	380061	48107	001	2019-06-19 16:33:40.276557	3	280019	2019-06-19 16:02:31.781022+07	f
1513	280019	48107	001	2019-06-19 16:33:26.120298	3	280019	2019-06-19 16:02:33.67214+07	f
1512	280021	48107	001	2019-06-19 16:33:11.725165	3	280019	2019-06-19 16:02:35.363456+07	f
1511	280014	48107	001	2019-06-19 16:33:01.124568	3	280019	2019-06-19 16:02:39.190721+07	f
1510	280026	48107	001	2019-06-19 16:32:47.636149	3	280019	2019-06-19 16:02:41.978161+07	f
1509	280028	48107	001	2019-06-19 16:32:38.758338	3	280019	2019-06-19 16:02:44.007252+07	f
1508	280010	48107	001	2019-06-19 16:32:25.517011	3	280019	2019-06-19 16:02:45.530924+07	f
1507	280002	48107	001	2019-06-19 16:32:13.363188	3	280019	2019-06-19 16:02:47.117992+07	f
1505	280005	48107	001	2019-06-19 16:31:47.619332	3	280019	2019-06-19 16:02:51.938536+07	f
1504	280020	48107	001	2019-06-19 16:31:34.478107	3	280019	2019-06-19 16:02:53.956929+07	f
1503	280003	48107	001	2019-06-19 16:31:25.893905	3	280019	2019-06-19 16:02:56.492591+07	f
1502	280031	48107	001	2019-06-19 16:31:16.752798	3	280019	2019-06-19 16:02:57.909047+07	f
1500	370010	48106	001	2019-06-19 16:30:09.553774	11	280019	2019-07-10 11:40:47.589924+07	f
1463	480051	48103	001	2019-06-19 16:11:27.151834	3	280019	2019-06-19 15:19:52.596492+07	f
1442	480030	48103	001	2019-06-19 15:54:05.579943	3	280019	2019-06-19 15:20:34.986274+07	f
1421	480009	48103	001	2019-06-19 15:49:19.795591	3	280019	2019-06-19 15:21:21.502472+07	f
1409	460009	48104	001	2019-06-12 16:04:56.941822	3	280019	2019-06-19 15:24:04.171277+07	f
1388	460040	48104	001	2019-06-12 16:00:36.20965	3	280019	2019-06-19 15:24:44.772052+07	f
1367	460013	48104	001	2019-06-12 15:54:40.276967	3	280019	2019-06-19 15:25:40.041889+07	f
1475	480055	48112	001	2019-06-19 16:18:12.399078	3	280019	2019-06-19 16:00:12.047223+07	f
1506	280025	48107	001	2019-06-19 16:32:00.510723	3	280019	2019-06-19 16:02:50.404898+07	f
1517	280019	48117	001	2019-06-28 16:16:47.045962	11	280019	2019-06-28 14:16:50.86854+07	f
1558	470009	48208	003	2019-07-18 21:05:05.218956	3	280019	2019-07-24 09:41:41.22297+07	f
1569	480056	48112	001	2019-08-05 17:32:11.185737	0	280019	2019-08-05 15:32:11.185737+07	f
1552	460053	48604	001	2019-07-16 09:27:36.887251	6	230002	2019-08-05 15:32:31.677034+07	f
1557	370027	48604	001	2019-07-18 20:30:59.953277	6	230002	2019-08-05 15:32:49.142245+07	f
1566	440041	48219	004	2019-07-25 09:20:34.676041	8	440041	2019-07-25 14:37:45.198979+07	f
1531	480055	48604	001	2019-07-05 15:31:05.006656	6	230002	2019-08-05 15:33:24.302894+07	f
1519	470049	48217	003	2019-07-01 16:20:57.116767	3	280019	2019-07-03 11:41:06.554597+07	f
1567	440041	48219	005	2019-07-25 16:47:57.654634	8	440041	2019-07-25 15:00:03.167861+07	f
1568	420014	48206	002	2019-07-26 14:32:14.102356	3	230002	2019-07-26 14:42:57.694536+07	f
1529	230002	48604	001	2019-07-04 14:21:12.559344	11	280019	2019-07-04 12:32:10.412189+07	f
1530	280019	48604	001	2019-07-04 14:28:23.673086	11	280019	2019-07-04 12:32:12.002327+07	f
1533	480044	48116	001	2019-07-05 17:02:12.330138	8	280019	2019-07-31 09:16:41.554535+07	f
1570	470002	48217	004	2019-08-06 15:16:24.377701	2	280019	2019-08-07 07:48:56.998689+07	f
1537	470044	48116	001	2019-07-08 16:14:32.902074	6	280019	2019-08-02 07:49:08.808689+07	f
1571	460008	48207	004	2019-08-06 15:29:43.728172	2	280019	2019-08-07 08:02:10.673351+07	f
1572	460008	48207	003	2019-08-07 09:58:15.282032	10	280019	2019-08-07 08:13:58.739793+07	f
1549	470029	48116	001	2019-07-11 14:09:43.531439	6	280019	2019-08-02 07:49:11.66706+07	f
1546	460018	48116	001	2019-07-10 17:08:39.746954	6	280019	2019-08-02 07:49:15.854437+07	f
1541	470023	48116	001	2019-07-09 20:14:02.009464	6	280019	2019-08-02 07:49:18.03197+07	f
1540	460058	48217	005	2019-07-09 18:51:32.668929	3	230002	2019-07-11 07:42:59.851303+07	f
1526	470069	48116	001	2019-07-03 11:15:55.847184	6	280019	2019-08-02 07:49:20.015354+07	f
1573	460060	48118	001	2019-08-07 10:59:00.467052	3	280019	2019-08-07 09:41:32.717313+07	f
1538	470013	48116	001	2019-07-08 18:14:43.663052	6	280019	2019-08-02 07:49:22.081116+07	f
1551	250028	48118	001	2019-07-12 22:18:06.980182	3	280019	2019-07-16 07:21:45.636082+07	f
1556	470009	48604	001	2019-07-18 18:52:58.496938	8	470009	2019-07-18 19:00:58.122806+07	f
1559	430018	48219	010	2019-07-18 21:23:16.285029	8	430018	2019-07-18 19:26:27.649909+07	f
1534	480014	48116	001	2019-07-05 17:04:57.12245	6	280019	2019-08-02 07:49:25.052442+07	f
1535	470019	48116	001	2019-07-08 11:15:04.900891	6	280019	2019-08-02 07:49:30.111879+07	f
1562	480020	48116	001	2019-07-19 15:38:25.026311	6	280019	2019-08-02 07:49:34.229022+07	f
1563	300021	48206	001	2019-07-21 19:31:13.876912	11	300021	2019-07-21 17:31:17.764582+07	f
1564	300021	48206	001	2019-07-21 19:31:53.061174	11	300021	2019-07-21 17:32:03.99534+07	f
1518	470049	48201	002	2019-07-01 16:20:11.89459	6	280019	2019-07-22 08:59:12.977002+07	f
1550	460055	48117	001	2019-07-12 09:38:40.900453	6	280019	2019-07-22 08:59:21.613827+07	f
1520	470001	48117	001	2019-07-01 17:01:33.843395	6	280019	2019-07-22 09:00:04.650726+07	f
1525	470069	48117	001	2019-07-03 11:13:35.770248	6	280019	2019-07-22 09:00:07.099069+07	f
1527	470008	48117	001	2019-07-03 14:32:18.742197	6	280019	2019-07-22 09:00:09.934108+07	f
1528	470035	48117	001	2019-07-03 17:04:19.704183	6	280019	2019-07-22 09:00:11.423062+07	f
1555	470034	48117	001	2019-07-16 09:41:54.688438	6	280019	2019-07-22 09:00:13.243003+07	f
1553	470025	48117	001	2019-07-16 09:40:54.252403	6	280019	2019-07-22 09:00:14.99273+07	f
1532	460036	48117	001	2019-07-05 16:08:01.032395	6	280019	2019-07-22 09:00:17.590262+07	f
1536	460024	48117	001	2019-07-08 16:04:15.861524	6	280019	2019-07-22 09:00:19.248184+07	f
1543	470028	48117	001	2019-07-10 14:56:03.380316	6	280019	2019-07-22 09:00:20.837866+07	f
1544	450050	48117	001	2019-07-10 15:15:51.74996	6	280019	2019-07-22 09:00:22.889987+07	f
1545	470057	48117	001	2019-07-10 16:49:01.542647	6	280019	2019-07-22 09:00:26.043607+07	f
1548	470029	48117	001	2019-07-11 14:08:54.76216	6	280019	2019-07-22 09:00:27.965417+07	f
1554	470043	48117	001	2019-07-16 09:41:20.339092	6	280019	2019-07-22 09:00:30.293575+07	f
1523	470022	48117	001	2019-07-02 10:16:34.685603	6	280019	2019-07-22 09:00:32.409959+07	f
1560	430018	48219	010	2019-07-18 21:26:35.260045	3	280019	2019-07-22 09:02:42.142821+07	f
1561	380034	48227	008	2019-07-18 21:29:14.002824	3	280019	2019-07-22 09:03:19.002283+07	f
1565	280019	48604	001	2019-07-22 11:05:28.159145	11	280019	2019-07-22 09:06:22.117037+07	f
1521	470001	48116	001	2019-07-01 17:01:46.512092	6	280019	2019-08-02 07:49:36.994153+07	f
1522	480001	48116	001	2019-07-01 17:51:28.167661	6	280019	2019-08-02 07:49:39.357973+07	f
1524	470022	48116	001	2019-07-02 10:17:13.330226	6	280019	2019-08-02 07:49:41.245246+07	f
1542	290001	48604	001	2019-07-10 13:11:28.369525	4	290001	2019-08-02 22:00:01.355682+07	f
1539	340010	48604	001	2019-07-08 20:11:01.02796	6	230002	2019-08-05 15:31:02.543965+07	f
1547	440037	48604	001	2019-07-11 08:02:09.627163	6	230002	2019-08-05 15:31:14.844883+07	f
1611	050006	48225	001	2019-09-11 09:44:37.429646	6	000000	2019-09-11 09:44:37.429646+07	f
1612	270009	48225	001	2019-09-11 09:44:37.429646	6	000000	2019-09-11 09:44:37.429646+07	f
1578	270009	48208	003	2019-09-09 16:59:16.659904	0	000000	2019-09-09 16:59:16.659904+07	f
1579	280031	48208	003	2019-09-09 16:59:16.659904	0	000000	2019-09-09 16:59:16.659904+07	f
1580	360012	48208	003	2019-09-09 17:03:18.159495	0	000000	2019-09-09 17:03:18.159495+07	f
1581	370042	48208	003	2019-09-09 17:03:18.159495	0	000000	2019-09-09 17:03:18.159495+07	f
1582	050006	48208	003	2019-09-09 17:12:02.884764	0	000000	2019-09-09 17:12:02.884764+07	f
1583	270009	48208	003	2019-09-09 17:12:02.884764	0	000000	2019-09-09 17:12:02.884764+07	f
1584	360012	48208	003	2019-09-09 17:24:06.455486	0	000000	2019-09-09 17:24:06.455486+07	f
1622	460016	48225	001	2019-09-11 09:44:37.429646	6	000000	2019-09-19 15:49:57.881617+07	t
1587	050006	48210	004	2019-09-10 08:50:00.302072	0	000000	2019-09-10 08:50:00.302072+07	f
1588	270009	48210	004	2019-09-10 08:50:00.302072	0	000000	2019-09-10 08:50:00.302072+07	f
1613	478003	48225	001	2019-09-11 09:44:37.429646	6	000000	2019-09-11 09:44:37.429646+07	f
1614	478007	48225	001	2019-09-11 09:44:37.429646	6	000000	2019-09-11 09:44:37.429646+07	f
1615	280031	48225	001	2019-09-11 09:44:37.429646	6	000000	2019-09-11 09:44:37.429646+07	f
1616	370062	48225	001	2019-09-11 09:44:37.429646	6	000000	2019-09-11 09:44:37.429646+07	f
1617	400034	48225	001	2019-09-11 09:44:37.429646	6	000000	2019-09-11 09:44:37.429646+07	f
1585	370042	48208	003	2019-09-09 17:24:06.455486	11	000000	2019-09-10 09:12:50.828459+07	f
1618	410038	48225	001	2019-09-11 09:44:37.429646	6	000000	2019-09-11 09:44:37.429646+07	f
1619	420041	48225	001	2019-09-11 09:44:37.429646	6	000000	2019-09-11 09:44:37.429646+07	f
1620	300014	48225	001	2019-09-11 09:44:37.429646	6	000000	2019-09-11 09:44:37.429646+07	f
1621	360012	48225	001	2019-09-11 09:44:37.429646	6	000000	2019-09-11 09:44:37.429646+07	f
1623	330045	48225	001	2019-09-11 09:44:37.429646	6	000000	2019-09-11 09:44:37.429646+07	f
1624	050006	48220	003	2019-09-11 10:22:46.958993	6	000000	2019-09-11 10:22:46.958993+07	f
1625	370062	48220	003	2019-09-11 10:23:43.170694	6	000000	2019-09-11 10:23:43.170694+07	f
1626	460055	48220	003	2019-09-11 10:25:05.226611	6	000000	2019-09-11 10:25:05.226611+07	f
1627	460068	48220	003	2019-09-11 10:25:05.226611	6	000000	2019-09-11 10:25:05.226611+07	f
1609	460016	48225	001	2019-09-11 09:44:19.077496	6	000000	2019-09-19 15:49:57.881617+07	t
1805	010005	48210	004	2019-09-24 09:05:31.463362	6	000000	2019-09-24 09:05:31.463362+07	f
1590	050006	48210	003	2019-09-10 09:26:09.824363	0	000000	2019-09-10 09:26:09.824363+07	f
1591	270009	48210	003	2019-09-10 09:26:09.824363	0	000000	2019-09-10 09:26:09.824363+07	f
1592	280031	48210	003	2019-09-10 09:27:59.047171	6	000000	2019-09-10 09:27:59.047171+07	f
1593	478007	48210	003	2019-09-10 09:27:59.047171	6	000000	2019-09-10 09:27:59.047171+07	f
1594	050006	48201	004	2019-09-11 09:08:24.048211	6	000000	2019-09-11 09:08:24.048211+07	f
1595	270009	48201	004	2019-09-11 09:08:24.048211	6	000000	2019-09-11 09:08:24.048211+07	f
1596	478003	48225	001	2019-09-11 09:17:09.372158	6	000000	2019-09-11 09:17:09.372158+07	f
1597	478007	48225	001	2019-09-11 09:17:09.372158	6	000000	2019-09-11 09:17:09.372158+07	f
1598	050006	48225	001	2019-09-11 09:17:48.285051	6	000000	2019-09-11 09:17:48.285051+07	f
1599	270009	48225	001	2019-09-11 09:17:48.285051	6	000000	2019-09-11 09:17:48.285051+07	f
1600	478003	48225	001	2019-09-11 09:17:48.285051	6	000000	2019-09-11 09:17:48.285051+07	f
1601	478007	48225	001	2019-09-11 09:17:48.285051	6	000000	2019-09-11 09:17:48.285051+07	f
1602	280031	48225	001	2019-09-11 09:21:52.622466	6	000000	2019-09-11 09:21:52.622466+07	f
1603	370062	48225	001	2019-09-11 09:21:52.622466	6	000000	2019-09-11 09:21:52.622466+07	f
1604	400034	48225	001	2019-09-11 09:24:18.065348	6	000000	2019-09-11 09:24:18.065348+07	f
1605	410038	48225	001	2019-09-11 09:24:18.065348	6	000000	2019-09-11 09:24:18.065348+07	f
1606	420041	48225	001	2019-09-11 09:35:00.095961	6	000000	2019-09-11 09:35:00.095961+07	f
1607	300014	48225	001	2019-09-11 09:43:28.108466	6	000000	2019-09-11 09:43:28.108466+07	f
1608	360012	48225	001	2019-09-11 09:43:28.108466	6	000000	2019-09-11 09:43:28.108466+07	f
1610	330045	48225	001	2019-09-11 09:44:19.077496	6	000000	2019-09-11 09:44:19.077496+07	f
1628	270009	48220	003	2019-09-11 10:26:31.56847	6	000000	2019-09-11 10:26:31.56847+07	f
1629	280031	48220	003	2019-09-11 10:26:31.56847	6	000000	2019-09-11 10:26:31.56847+07	f
1630	410038	48220	003	2019-09-11 10:27:56.621271	6	000000	2019-09-11 10:27:56.621271+07	f
1631	458009	48220	003	2019-09-11 10:27:56.621271	6	000000	2019-09-11 10:27:56.621271+07	f
1632	458009	48225	001	2019-09-11 11:23:33.446176	6	000000	2019-09-11 11:23:33.446176+07	f
1633	370042	48225	001	2019-09-11 11:24:07.167847	6	000000	2019-09-11 11:24:07.167847+07	f
1634	370043	48225	001	2019-09-11 11:24:07.167847	6	000000	2019-09-11 11:24:07.167847+07	f
1635	380044	48225	001	2019-09-11 11:25:26.143663	6	000000	2019-09-11 11:25:26.143663+07	f
1636	420006	48225	001	2019-09-11 11:26:36.537866	6	000000	2019-09-11 11:26:36.537866+07	f
1637	290006	48225	001	2019-09-11 13:16:14.504135	6	000000	2019-09-11 13:16:14.504135+07	f
1638	390006	48225	001	2019-09-11 13:16:14.504135	6	000000	2019-09-11 13:16:14.504135+07	f
1794	000000	48216	007	2019-09-19 10:43:58.434509	0	000000	2019-09-24 15:52:23.416348+07	t
1812	000000	48506	001	2019-09-24 10:36:28.763724	3	000000	2019-09-24 15:52:23.416348+07	t
1640	420053	48225	001	2019-09-11 13:41:09.375634	6	000000	2019-09-11 13:41:09.375634+07	f
1641	440002	48225	001	2019-09-11 14:08:11.445674	6	000000	2019-09-11 14:08:11.445674+07	f
1642	430029	48225	001	2019-09-11 14:15:36.744033	6	000000	2019-09-11 14:15:36.744033+07	f
1643	450039	48225	001	2019-09-11 14:17:09.442899	6	000000	2019-09-11 14:17:09.442899+07	f
1644	460013	48225	001	2019-09-11 14:17:09.442899	6	000000	2019-09-11 14:17:09.442899+07	f
1645	460025	48225	001	2019-09-11 14:22:16.368342	6	000000	2019-09-11 14:22:16.368342+07	f
1646	460027	48225	001	2019-09-11 14:22:16.368342	6	000000	2019-09-11 14:22:16.368342+07	f
1647	470001	48225	001	2019-09-11 14:24:52.509293	6	000000	2019-09-11 14:24:52.509293+07	f
1648	470004	48225	001	2019-09-11 14:41:35.090924	6	000000	2019-09-11 14:41:35.090924+07	f
1649	470049	48225	001	2019-09-11 14:41:35.090924	6	000000	2019-09-11 14:41:35.090924+07	f
1800	000000	48118	001	2019-09-19 14:27:10.127662	11	000000	2019-09-24 15:52:23.416348+07	t
1798	000000	48205	003	2019-09-19 14:25:29.55727	11	000000	2019-09-24 15:52:23.416348+07	t
1737	000000	48107	001	2019-09-17 09:23:10.976438	11	000000	2019-09-24 15:52:23.416348+07	t
1799	000000	48118	001	2019-09-19 14:26:41.447194	11	000000	2019-09-24 15:52:23.416348+07	t
1728	000000	48118	001	2019-09-12 16:49:17.198563	11	000000	2019-09-24 15:52:23.416348+07	t
1813	000000	48205	002	2019-09-24 10:52:14.38597	0	000000	2019-09-24 15:52:23.416348+07	t
1776	000000	48227	001	2019-09-18 14:44:10.641813	11	000000	2019-09-24 15:52:23.416348+07	t
1777	000000	48227	001	2019-09-18 14:51:04.359613	11	000000	2019-09-24 15:52:23.416348+07	t
1778	000000	48227	001	2019-09-18 14:54:10.530417	11	000000	2019-09-24 15:52:23.416348+07	t
1779	000000	48227	001	2019-09-18 14:55:08.45608	0	000000	2019-09-24 15:52:23.416348+07	t
1786	000000	48604	001	2019-09-18 15:14:58.903424	8	000000	2019-09-24 15:52:23.416348+07	t
1787	000000	48604	001	2019-09-18 15:15:33.905098	8	000000	2019-09-24 15:52:23.416348+07	t
1804	000000	48205	003	2019-09-20 08:35:16.496823	11	000000	2019-09-24 15:52:23.416348+07	t
1811	000000	48118	001	2019-09-24 10:35:59.353704	0	000000	2019-09-24 15:52:23.416348+07	t
1820	000605	48210	004	2019-09-25 10:08:50.426153	0	000000	2019-09-25 10:08:50.426153+07	f
1821	110009	48210	004	2019-09-25 10:08:50.426153	0	000000	2019-09-25 10:08:50.426153+07	f
1693	460016	48118	001	2019-09-12 10:51:54.981025	6	000000	2019-09-19 15:49:57.881617+07	t
1806	070005	48210	004	2019-09-24 09:06:37.402308	6	000000	2019-09-24 09:06:37.402308+07	f
1730	050006	48205	002	2019-09-13 08:32:12.629277	6	000000	2019-09-13 08:32:12.629277+07	f
1731	480009	48205	002	2019-09-13 13:42:13.721392	6	000000	2019-09-13 13:42:13.721392+07	f
1732	370062	48205	002	2019-09-13 13:51:00.895975	6	000000	2019-09-13 13:51:00.895975+07	f
1733	050006	48209	004	2019-09-13 15:10:56.198964	6	000000	2019-09-13 15:10:56.198964+07	f
1775	000000	48227	001	2019-09-18 14:40:48.221164	11	000000	2019-09-24 15:52:23.416348+07	t
1735	370062	48209	004	2019-09-13 15:21:16.534892	6	000000	2019-09-13 15:21:16.534892+07	f
1736	270009	48209	004	2019-09-13 15:23:09.432161	6	000000	2019-09-13 15:23:09.432161+07	f
1575	000000	48208	002	2019-08-15 10:55:48.982218	11	000000	2019-09-24 15:52:23.416348+07	t
1576	000000	48208	002	2019-08-15 10:56:57.998696	8	000000	2019-09-24 15:52:23.416348+07	t
1589	000000	47227	001	2019-09-10 09:00:11.662959	0	000000	2019-09-24 15:52:23.416348+07	t
1574	000000	48217	003	2019-08-15 09:43:11.615598	6	000000	2019-09-24 15:52:23.416348+07	t
1577	000000	48208	002	2019-08-15 11:00:25.231636	6	000000	2019-09-24 15:52:23.416348+07	t
1586	000000	48210	004	2019-09-10 08:39:21.876169	6	000000	2019-09-24 15:52:23.416348+07	t
1639	000000	48225	001	2019-09-11 13:26:10.841515	11	000000	2019-09-24 15:52:23.416348+07	t
1650	000000	48225	001	2019-09-11 17:32:37.675577	11	000000	2019-09-24 15:52:23.416348+07	t
1651	000000	48225	001	2019-09-11 17:36:22.528317	11	000000	2019-09-24 15:52:23.416348+07	t
1652	000000	48225	001	2019-09-11 17:37:15.124407	0	000000	2019-09-24 15:52:23.416348+07	t
1743	040005	48205	002	2019-09-18 09:20:13.93081	0	000000	2019-09-18 09:20:13.93081+07	f
1746	140020	48227	001	2019-09-18 13:52:36.051697	0	000000	2019-09-18 13:52:36.051697+07	f
1653	000000	48601	001	2019-09-12 08:44:55.315558	3	000000	2019-09-24 15:52:23.416348+07	t
1654	000000	48209	004	2019-09-12 08:53:13.673857	11	000000	2019-09-24 15:52:23.416348+07	t
1655	000000	48209	004	2019-09-12 08:54:46.843107	11	000000	2019-09-24 15:52:23.416348+07	t
1656	000000	48209	004	2019-09-12 08:55:19.06435	11	000000	2019-09-24 15:52:23.416348+07	t
1657	000000	48209	004	2019-09-12 08:58:19.941385	11	000000	2019-09-24 15:52:23.416348+07	t
1658	000000	48209	004	2019-09-12 08:59:17.448135	11	000000	2019-09-24 15:52:23.416348+07	t
1659	000000	48209	004	2019-09-12 09:01:00.711533	11	000000	2019-09-24 15:52:23.416348+07	t
1660	000000	48209	004	2019-09-12 09:02:13.912264	11	000000	2019-09-24 15:52:23.416348+07	t
1807	040005	48210	004	2019-09-24 09:07:07.199417	6	000000	2019-09-24 09:07:07.199417+07	f
1814	000605	48205	002	2019-09-24 10:57:08.321984	0	000000	2019-09-24 10:57:08.321984+07	f
1815	010005	48205	002	2019-09-24 10:57:08.321984	0	000000	2019-09-24 10:57:08.321984+07	f
1816	070005	48205	002	2019-09-24 10:57:08.321984	0	000000	2019-09-24 10:57:08.321984+07	f
1744	001120	48208	004	2019-09-18 13:21:18.891242	0	000000	2019-09-24 15:20:57.673852+07	t
1745	001120	48227	001	2019-09-18 13:30:06.052894	0	000000	2019-09-24 15:20:57.673852+07	t
1780	001120	48227	002	2019-09-18 14:57:34.631429	0	000000	2019-09-24 15:20:57.673852+07	t
1781	001120	48227	003	2019-09-18 14:58:08.412395	0	000000	2019-09-24 15:20:57.673852+07	t
1783	001120	48227	005	2019-09-18 15:04:58.12795	0	000000	2019-09-24 15:20:57.673852+07	t
1784	001120	48604	001	2019-09-18 15:09:17.193041	8	000000	2019-09-24 15:20:57.673852+07	t
1793	001120	48118	001	2019-09-18 15:55:17.824399	0	000000	2019-09-24 15:20:57.673852+07	t
1797	001120	48210	004	2019-09-19 10:55:21.179097	6	000000	2019-09-24 15:20:57.673852+07	t
1788	000605	48604	001	2019-09-18 15:26:54.70253	3	000000	2019-09-18 15:26:54.70253+07	f
1789	000605	48227	001	2019-09-18 15:28:41.620831	0	000000	2019-09-18 15:28:41.620831+07	f
1790	000605	48227	002	2019-09-18 15:30:03.546209	0	000000	2019-09-18 15:30:03.546209+07	f
1791	000605	48118	001	2019-09-18 15:31:42.521611	8	000000	2019-09-18 15:32:02.283074+07	f
1792	000605	48118	001	2019-09-18 15:32:07.541152	0	000000	2019-09-18 15:32:07.541152+07	f
1796	050006	48210	004	2019-09-19 10:54:56.122691	6	000000	2019-09-19 10:54:56.122691+07	f
1808	000605	48118	001	2019-09-24 09:20:09.43863	6	000000	2019-09-24 09:20:09.43863+07	f
1817	160035	48210	004	2019-09-24 13:01:16.590346	0	000000	2019-09-24 13:01:16.590346+07	f
1818	190007	48210	004	2019-09-24 13:01:16.590346	0	000000	2019-09-24 13:01:16.590346+07	f
1819	200009	48210	004	2019-09-24 13:01:16.590346	0	000000	2019-09-24 13:01:16.590346+07	f
1661	000000	48209	004	2019-09-12 09:03:54.807695	11	000000	2019-09-24 15:52:23.416348+07	t
1662	000000	48209	004	2019-09-12 09:04:25.17533	11	000000	2019-09-24 15:52:23.416348+07	t
1663	000000	48209	004	2019-09-12 09:05:14.026751	11	000000	2019-09-24 15:52:23.416348+07	t
1801	000000	48118	001	2019-09-19 15:30:02.011758	11	000000	2019-09-24 15:52:23.416348+07	t
1802	000000	48118	001	2019-09-19 15:34:26.072276	11	000000	2019-09-24 15:52:23.416348+07	t
1822	440040	48118	001	2019-09-25 10:24:51.32977	0	000000	2019-09-25 10:24:51.32977+07	f
1823	450040	48118	001	2019-09-25 10:24:51.32977	0	000000	2019-09-25 10:24:51.32977+07	f
1666	000000	48209	004	2019-09-12 09:13:53.590102	11	000000	2019-09-24 15:52:23.416348+07	t
1667	000000	48209	004	2019-09-12 09:14:11.124518	11	000000	2019-09-24 15:52:23.416348+07	t
1668	000000	48209	004	2019-09-12 09:16:42.568556	11	000000	2019-09-24 15:52:23.416348+07	t
1669	000000	48209	004	2019-09-12 09:22:19.272897	11	000000	2019-09-24 15:52:23.416348+07	t
1670	000000	48209	004	2019-09-12 09:31:01.319833	11	000000	2019-09-24 15:52:23.416348+07	t
1671	000000	48209	004	2019-09-12 09:31:49.189566	11	000000	2019-09-24 15:52:23.416348+07	t
1672	000000	48209	004	2019-09-12 09:32:12.388476	11	000000	2019-09-24 15:52:23.416348+07	t
1795	000000	48502	001	2019-09-19 10:47:15.312973	8	001120	2019-11-28 15:26:53.737205+07	t
1782	001120	48227	004	2019-09-18 15:04:07.991914	3	001120	2020-02-21 16:08:47.538874+07	t
1673	000000	48209	004	2019-09-12 09:34:11.551447	11	000000	2019-09-24 15:52:23.416348+07	t
1674	000000	48209	004	2019-09-12 09:35:21.608065	11	000000	2019-09-24 15:52:23.416348+07	t
1675	000000	48209	004	2019-09-12 09:35:50.852805	11	000000	2019-09-24 15:52:23.416348+07	t
1676	000000	48209	004	2019-09-12 09:36:52.279511	11	000000	2019-09-24 15:52:23.416348+07	t
1677	000000	48209	004	2019-09-12 09:37:21.937632	11	000000	2019-09-24 15:52:23.416348+07	t
1678	000000	48209	004	2019-09-12 09:42:18.421312	11	000000	2019-09-24 15:52:23.416348+07	t
1679	000000	48209	004	2019-09-12 09:49:57.804193	11	000000	2019-09-24 15:52:23.416348+07	t
1680	000000	48209	004	2019-09-12 09:50:49.020826	11	000000	2019-09-24 15:52:23.416348+07	t
1681	000000	48209	004	2019-09-12 09:51:40.123262	11	000000	2019-09-24 15:52:23.416348+07	t
1682	000000	48209	004	2019-09-12 09:52:07.157062	11	000000	2019-09-24 15:52:23.416348+07	t
864	460016	47117	001	2018-09-28 00:00:00	8	330045	2019-09-19 15:49:57.881617+07	t
1366	460016	48104	001	2019-06-12 15:54:20.97746	3	280019	2019-09-19 15:49:57.881617+07	t
1683	000000	48209	004	2019-09-12 09:52:23.776619	11	000000	2019-09-24 15:52:23.416348+07	t
1684	000000	48209	004	2019-09-12 09:53:12.654976	11	000000	2019-09-24 15:52:23.416348+07	t
1685	000000	48209	004	2019-09-12 09:54:29.221789	11	000000	2019-09-24 15:52:23.416348+07	t
1686	000000	48209	004	2019-09-12 09:55:16.429682	11	000000	2019-09-24 15:52:23.416348+07	t
1809	000000	48118	001	2019-09-24 09:24:23.475178	8	000000	2019-09-24 15:52:23.416348+07	t
1664	000000	48209	004	2019-09-12 09:05:50.416116	11	000000	2019-09-24 15:52:23.416348+07	t
1665	000000	48209	004	2019-09-12 09:13:08.541154	11	000000	2019-09-24 15:52:23.416348+07	t
1687	000000	48209	004	2019-09-12 09:59:09.997526	11	000000	2019-09-24 15:52:23.416348+07	t
1688	000000	48209	004	2019-09-12 10:07:00.850876	11	000000	2019-09-24 15:52:23.416348+07	t
1689	000000	48209	004	2019-09-12 10:08:36.391045	11	000000	2019-09-24 15:52:23.416348+07	t
1690	000000	48209	004	2019-09-12 10:08:54.851422	11	000000	2019-09-24 15:52:23.416348+07	t
1691	000000	48209	004	2019-09-12 10:12:25.761677	11	000000	2019-09-24 15:52:23.416348+07	t
1692	000000	48209	004	2019-09-12 10:16:56.589916	0	000000	2019-09-24 15:52:23.416348+07	t
1694	000000	48118	001	2019-09-12 14:03:42.659163	11	000000	2019-09-24 15:52:23.416348+07	t
1695	000000	48118	001	2019-09-12 14:10:24.119308	11	000000	2019-09-24 15:52:23.416348+07	t
1696	000000	48118	001	2019-09-12 14:30:00.799879	11	000000	2019-09-24 15:52:23.416348+07	t
1697	000000	48118	001	2019-09-12 14:34:25.381796	11	000000	2019-09-24 15:52:23.416348+07	t
1698	000000	48118	001	2019-09-12 14:35:58.794433	11	000000	2019-09-24 15:52:23.416348+07	t
1699	000000	48118	001	2019-09-12 14:36:30.56859	11	000000	2019-09-24 15:52:23.416348+07	t
1700	000000	48118	001	2019-09-12 14:37:45.634545	11	000000	2019-09-24 15:52:23.416348+07	t
1701	000000	48118	001	2019-09-12 14:38:21.433441	11	000000	2019-09-24 15:52:23.416348+07	t
1702	000000	48118	001	2019-09-12 14:43:28.285139	11	000000	2019-09-24 15:52:23.416348+07	t
1703	000000	48118	001	2019-09-12 14:44:55.996435	11	000000	2019-09-24 15:52:23.416348+07	t
1704	000000	48118	001	2019-09-12 14:48:34.557541	11	000000	2019-09-24 15:52:23.416348+07	t
1705	000000	48118	001	2019-09-12 14:52:09.990793	11	000000	2019-09-24 15:52:23.416348+07	t
1706	000000	48118	001	2019-09-12 14:53:30.180417	11	000000	2019-09-24 15:52:23.416348+07	t
1707	000000	48118	001	2019-09-12 14:53:57.387959	11	000000	2019-09-24 15:52:23.416348+07	t
1708	000000	48118	001	2019-09-12 14:54:44.04485	11	000000	2019-09-24 15:52:23.416348+07	t
1709	000000	48118	001	2019-09-12 14:55:24.916496	11	000000	2019-09-24 15:52:23.416348+07	t
1710	000000	48118	001	2019-09-12 15:16:13.406114	11	000000	2019-09-24 15:52:23.416348+07	t
1711	000000	48118	001	2019-09-12 15:16:57.610303	11	000000	2019-09-24 15:52:23.416348+07	t
1712	000000	48118	001	2019-09-12 15:28:15.762529	11	000000	2019-09-24 15:52:23.416348+07	t
1713	000000	48118	001	2019-09-12 15:57:28.918462	11	000000	2019-09-24 15:52:23.416348+07	t
1714	000000	48118	001	2019-09-12 16:08:01.954067	11	000000	2019-09-24 15:52:23.416348+07	t
1715	000000	48118	001	2019-09-12 16:09:29.900136	11	000000	2019-09-24 15:52:23.416348+07	t
1716	000000	48118	001	2019-09-12 16:10:05.479418	11	000000	2019-09-24 15:52:23.416348+07	t
1717	000000	48118	001	2019-09-12 16:10:44.19491	11	000000	2019-09-24 15:52:23.416348+07	t
1718	000000	48118	001	2019-09-12 16:12:25.255841	11	000000	2019-09-24 15:52:23.416348+07	t
1719	000000	48118	001	2019-09-12 16:25:54.043424	11	000000	2019-09-24 15:52:23.416348+07	t
1720	000000	48118	001	2019-09-12 16:26:49.551431	11	000000	2019-09-24 15:52:23.416348+07	t
1721	000000	48118	001	2019-09-12 16:27:53.834595	11	000000	2019-09-24 15:52:23.416348+07	t
1722	000000	48118	001	2019-09-12 16:29:19.751014	11	000000	2019-09-24 15:52:23.416348+07	t
1723	000000	48118	001	2019-09-12 16:30:37.197068	11	000000	2019-09-24 15:52:23.416348+07	t
1724	000000	48118	001	2019-09-12 16:32:17.039339	11	000000	2019-09-24 15:52:23.416348+07	t
1725	000000	48118	001	2019-09-12 16:33:26.9735	11	000000	2019-09-24 15:52:23.416348+07	t
1726	000000	48118	001	2019-09-12 16:34:23.562812	11	000000	2019-09-24 15:52:23.416348+07	t
1727	000000	48118	001	2019-09-12 16:47:54.999915	11	000000	2019-09-24 15:52:23.416348+07	t
1803	000000	48118	001	2019-09-19 15:53:13.001698	0	000000	2019-09-24 15:52:23.416348+07	t
1810	000000	48118	001	2019-09-24 10:34:05.89741	11	000000	2019-09-24 15:52:23.416348+07	t
1734	000000	48209	004	2019-09-13 15:14:02.419672	6	000000	2019-09-24 15:52:23.416348+07	t
1738	000000	48205	002	2019-09-17 17:38:36.255283	11	000000	2019-09-24 15:52:23.416348+07	t
1739	000000	48205	002	2019-09-18 09:01:06.038991	11	000000	2019-09-24 15:52:23.416348+07	t
1740	000000	48205	002	2019-09-18 09:03:12.754973	11	000000	2019-09-24 15:52:23.416348+07	t
1741	000000	48205	002	2019-09-18 09:04:34.981807	11	000000	2019-09-24 15:52:23.416348+07	t
1742	000000	48205	002	2019-09-18 09:12:49.189737	0	000000	2019-09-24 15:52:23.416348+07	t
1747	000000	48227	001	2019-09-18 13:58:00.03481	11	000000	2019-09-24 15:52:23.416348+07	t
1748	000000	48227	001	2019-09-18 14:01:31.178215	11	000000	2019-09-24 15:52:23.416348+07	t
1749	000000	48227	001	2019-09-18 14:03:32.086221	11	000000	2019-09-24 15:52:23.416348+07	t
1750	000000	48227	001	2019-09-18 14:07:06.703159	11	000000	2019-09-24 15:52:23.416348+07	t
1751	000000	48227	001	2019-09-18 14:08:37.214408	11	000000	2019-09-24 15:52:23.416348+07	t
1752	000000	48227	001	2019-09-18 14:10:55.556128	11	000000	2019-09-24 15:52:23.416348+07	t
1753	000000	48227	001	2019-09-18 14:11:53.103412	11	000000	2019-09-24 15:52:23.416348+07	t
1754	000000	48227	001	2019-09-18 14:13:26.606577	11	000000	2019-09-24 15:52:23.416348+07	t
1755	000000	48227	001	2019-09-18 14:13:56.322366	11	000000	2019-09-24 15:52:23.416348+07	t
1756	000000	48227	001	2019-09-18 14:14:39.981779	11	000000	2019-09-24 15:52:23.416348+07	t
1757	000000	48227	001	2019-09-18 14:16:02.387305	11	000000	2019-09-24 15:52:23.416348+07	t
1758	000000	48227	001	2019-09-18 14:18:58.777748	11	000000	2019-09-24 15:52:23.416348+07	t
1759	000000	48227	001	2019-09-18 14:20:11.960215	11	000000	2019-09-24 15:52:23.416348+07	t
1760	000000	48227	001	2019-09-18 14:20:39.941411	11	000000	2019-09-24 15:52:23.416348+07	t
1761	000000	48227	001	2019-09-18 14:21:11.351579	11	000000	2019-09-24 15:52:23.416348+07	t
1762	000000	48227	001	2019-09-18 14:21:43.07928	11	000000	2019-09-24 15:52:23.416348+07	t
1763	000000	48227	001	2019-09-18 14:22:31.571305	11	000000	2019-09-24 15:52:23.416348+07	t
1764	000000	48227	001	2019-09-18 14:23:41.740789	11	000000	2019-09-24 15:52:23.416348+07	t
1765	000000	48227	001	2019-09-18 14:24:23.812537	11	000000	2019-09-24 15:52:23.416348+07	t
1766	000000	48227	001	2019-09-18 14:25:33.304284	11	000000	2019-09-24 15:52:23.416348+07	t
1767	000000	48227	001	2019-09-18 14:26:28.456999	11	000000	2019-09-24 15:52:23.416348+07	t
1768	000000	48227	001	2019-09-18 14:26:58.231084	11	000000	2019-09-24 15:52:23.416348+07	t
1769	000000	48227	001	2019-09-18 14:28:07.24149	11	000000	2019-09-24 15:52:23.416348+07	t
1770	000000	48227	001	2019-09-18 14:28:41.65079	11	000000	2019-09-24 15:52:23.416348+07	t
1771	000000	48227	001	2019-09-18 14:29:25.469528	11	000000	2019-09-24 15:52:23.416348+07	t
1772	000000	48227	001	2019-09-18 14:30:27.254023	11	000000	2019-09-24 15:52:23.416348+07	t
1773	000000	48227	001	2019-09-18 14:34:06.05365	11	000000	2019-09-24 15:52:23.416348+07	t
1774	000000	48227	001	2019-09-18 14:36:21.324333	11	000000	2019-09-24 15:52:23.416348+07	t
1729	000000	48209	005	2019-09-12 16:50:26.048803	1	001008	2019-10-08 16:01:07.392743+07	t
1825	001008	48201	013	2019-10-08 16:03:06.414219	0	001008	2019-10-08 16:03:06.414219+07	f
1826	001008	48207	007	2019-10-08 16:03:40.381994	0	001008	2019-10-08 16:03:40.381994+07	f
1828	001008	48217	014	2019-10-08 16:05:20.199341	0	001008	2019-10-08 16:05:20.199341+07	f
1827	001008	48223	011	2019-10-08 16:04:26.003705	8	001008	2019-10-08 16:08:00.858803+07	f
1824	001008	48216	022	2019-10-08 16:02:36.39587	11	001008	2019-10-08 16:08:39.482737+07	f
1829	001008	48216	022	2019-10-08 16:08:52.447351	0	001008	2019-10-08 16:08:52.447351+07	f
1831	001120	48207	008	2019-10-10 16:29:31.59181	0	001120	2019-10-10 16:29:31.59181+07	f
1832	001120	48215	013	2019-10-10 16:32:59.651938	0	001120	2019-10-10 16:32:59.651938+07	f
1833	001120	48216	018	2019-10-10 16:42:03.445724	0	001120	2019-10-10 16:42:03.445724+07	f
1835	001008	48118	001	2019-09-25 00:00:00	0	001008	2019-09-25 00:00:00+07	f
1838	001008	48101	002	2019-06-12 00:00:00	6	001008	2019-10-22 00:00:00+07	f
1839	001008	48653	001	2019-10-23 14:39:57.448796	3	001008	2019-10-23 14:39:57.448796+07	f
1840	001008	48108	003	2019-10-25 08:55:09.805798	0	001008	2019-10-25 08:55:09.805798+07	f
1842	001120	48206	004	2019-10-28 11:34:30.843695	0	001120	2019-10-28 11:34:30.843695+07	f
1843	001008	48652	002	2019-10-28 11:35:12.072645	8	001008	2019-10-28 11:36:57.221194+07	f
1844	001120	48207	005	2019-10-28 14:56:47.277995	8	001120	2019-10-28 14:56:57.541819+07	f
1845	001120	48207	005	2019-10-28 14:57:31.459733	8	001120	2019-10-28 14:57:49.878919+07	f
1846	001120	48655	001	2019-10-28 17:34:55.813288	8	001120	2019-10-28 17:35:06.425087+07	f
1841	001120	48652	002	2019-10-28 11:33:09.501538	8	001120	2019-10-28 17:35:51.883805+07	f
1830	001008	48201	005	2019-10-08 16:12:00.096519	6	001008	2019-10-29 09:25:57.27537+07	f
1869	001201	48103	001	2019-11-07 14:40:05.493396	8	001008	2019-11-07 14:40:11.642537+07	f
1847	001108	48201	015	2019-10-29 10:28:35.063451	6	001008	2019-10-29 10:39:18.971455+07	f
1870	001201	48604	001	2019-11-07 14:41:27.785479	8	001008	2019-11-07 14:41:33.645237+07	f
1848	001201	48201	015	2019-10-29 10:39:41.870653	6	001008	2019-10-29 10:40:36.343434+07	f
1785	001120	48604	001	2019-09-18 15:10:34.067643	8	001120	2019-11-27 14:54:09.025658+07	t
1850	000605	48201	015	2019-10-29 10:43:38.076102	6	001008	2019-10-29 10:44:51.906142+07	f
1851	001202	48201	015	2019-10-29 10:45:43.973045	8	001202	2019-10-29 10:48:43.172092+07	f
1852	001202	48201	015	2019-10-29 10:49:01.759121	8	001202	2019-10-29 10:51:17.757464+07	f
1854	001202	48653	002	2019-10-29 10:52:15.900712	3	001202	2019-10-29 10:52:15.900712+07	f
1855	001120	48653	002	2019-10-29 10:53:31.220872	3	001120	2019-10-29 10:53:31.220872+07	f
1856	001008	48653	002	2019-10-29 10:54:02.658781	3	001008	2019-10-29 10:54:02.658781+07	f
1857	001202	48226	005	2019-10-29 10:55:24.268723	0	001202	2019-10-29 10:55:24.268723+07	f
1858	001202	48654	002	2019-10-29 10:57:39.939705	3	001202	2019-10-29 10:57:39.939705+07	f
1859	001108	48217	014	2019-10-29 10:59:39.689873	0	001108	2019-10-29 10:59:39.689873+07	f
1860	001202	48202	010	2019-10-29 11:01:21.114491	0	001202	2019-10-29 11:01:21.114491+07	f
1853	001202	48201	015	2019-10-29 10:51:31.554	8	001202	2019-10-29 11:04:51.101055+07	f
1861	001202	48201	015	2019-10-29 11:04:58.578481	6	001008	2019-10-29 11:08:13.700692+07	f
1862	001008	48223	003	2019-10-29 15:32:16.460089	0	001008	2019-10-29 15:32:16.460089+07	f
1849	001120	48201	015	2019-10-29 10:41:28.244565	8	001120	2019-10-31 09:29:18.78+07	f
1863	001120	48201	015	2019-10-31 09:29:26.942131	0	001120	2019-10-31 09:29:26.942131+07	f
1864	001120	48103	001	2019-11-07 14:18:19.202193	8	001120	2019-11-07 14:18:48.214729+07	f
1865	001120	48103	001	2019-11-07 14:28:31.240927	8	001120	2019-11-07 14:28:51.738853+07	f
1866	001120	48103	001	2019-11-07 14:34:36.611408	8	001120	2019-11-07 14:35:10.269351+07	f
1867	001008	48103	001	2019-11-07 14:35:50.133933	8	001008	2019-11-07 14:36:16.082711+07	f
1868	001008	48103	001	2019-11-07 14:38:05.247854	8	001008	2019-11-07 14:38:34.025136+07	f
1874	001008	48111	002	2019-11-27 17:10:09.101609	0	001008	2019-11-27 17:10:09.101609+07	f
1837	001008	48102	001	2019-10-22 14:08:05.123288	8	001008	2019-11-28 13:24:27.312629+07	f
1873	001008	48103	002	2019-11-27 16:07:01.005635	8	001008	2019-11-28 13:26:20.467464+07	f
1876	001008	48103	002	2019-11-28 13:26:29.73956	8	001008	2019-11-28 13:28:06.770359+07	f
1872	001008	48501	002	2019-11-27 16:06:48.098203	8	001008	2019-11-28 13:29:14.185602+07	f
1879	001008	48602	001	2019-11-28 13:50:10.970401	8	001008	2019-11-28 14:26:42.782054+07	f
1878	001008	48604	002	2019-11-28 13:46:20.662253	8	001008	2019-11-28 14:28:25.98778+07	f
1881	001008	48602	001	2019-11-28 14:26:45.416117	8	001008	2019-11-28 14:31:57.630798+07	f
1883	001008	48602	001	2019-11-28 14:32:07.707421	8	001008	2019-11-28 14:36:00.363083+07	f
1884	001008	48602	001	2019-11-28 14:36:03.581182	3	001008	2019-11-28 14:36:03.581182+07	f
1871	001120	48604	001	2019-11-27 14:54:19.33655	8	001120	2019-11-28 14:38:16.636566+07	f
1882	001008	48604	002	2019-11-28 14:28:30.190605	8	001008	2019-11-28 14:41:47.167588+07	f
1885	001008	48604	002	2019-11-28 14:42:36.628591	3	001008	2019-11-28 14:42:36.628591+07	f
1886	001008	48502	001	2019-11-28 14:56:59.315392	8	001120	2019-11-28 15:06:53.741241+07	f
1875	001008	48101	003	2019-11-28 10:56:03.965718	8	001008	2019-11-28 15:12:40.030067+07	f
1887	001008	48101	003	2019-11-28 15:12:43.0273	0	001008	2019-11-28 15:12:43.0273+07	f
1889	000000	48502	001	2019-11-28 15:27:58.327197	8	001120	2019-11-28 15:29:15.057039+07	f
1890	000000	48502	001	2019-11-28 15:29:33.839206	8	001120	2019-11-28 15:39:01.180927+07	f
1888	001008	48502	001	2019-11-28 15:26:25.801317	8	001008	2019-11-29 10:48:44.580109+07	f
1892	001008	48502	001	2019-11-29 10:48:52.725761	8	001008	2019-11-29 10:48:57.989312+07	f
1893	001008	48604	001	2019-11-29 10:51:44.929204	8	001008	2019-11-29 10:51:53.401709+07	f
1894	001008	48604	001	2019-11-29 11:05:49.264783	3	001008	2019-11-29 11:05:49.264783+07	f
1877	001008	48501	002	2019-11-28 13:29:19.473519	8	001008	2019-11-29 11:07:54.204935+07	f
1880	001008	48103	002	2019-11-28 14:01:14.103681	8	001008	2019-11-29 11:15:59.238706+07	f
1895	001008	48103	002	2019-11-29 11:16:06.459657	0	001008	2019-11-29 11:16:06.459657+07	f
1896	001008	48501	002	2019-11-29 13:43:43.589241	3	001008	2019-11-29 13:43:43.589241+07	f
1891	000000	48502	001	2019-11-28 15:43:38.508938	8	001008	2019-11-29 13:53:57.137784+07	f
1897	000000	48502	001	2019-11-29 13:53:59.383264	3	001008	2019-11-29 13:53:59.383264+07	f
1898	000000	48501	002	2019-11-29 13:54:15.050116	3	001008	2019-11-29 13:54:15.050116+07	f
1899	000000	48101	002	2019-11-29 13:54:51.018934	8	001008	2019-11-29 14:20:08.071374+07	f
1834	001120	48216	019	2019-10-10 00:00:00	3	001120	2020-02-27 11:33:47.936532+07	f
1836	001120	48504	001	2019-10-14 07:00:00	8	001120	2020-02-25 16:40:22.886189+07	f
1901	000000	49205	001	2019-12-04 09:15:02.144427	8	001120	2019-12-04 09:25:03.542119+07	f
1902	000000	49205	001	2019-12-04 09:25:16.767703	8	001120	2019-12-04 09:51:11.986707+07	f
1903	000000	49205	001	2019-12-04 09:51:27.697055	8	001120	2019-12-04 09:51:49.833561+07	f
1904	001120	48604	001	2019-12-12 09:09:49.119501	8	001120	2019-12-12 09:10:37.920861+07	f
1905	000000	48604	001	2019-12-12 09:11:16.520949	8	001120	2019-12-12 09:11:47.418334+07	f
1906	001120	48604	001	2019-12-12 10:20:12.837334	8	001120	2019-12-12 10:20:41.047958+07	f
1907	000000	49205	001	2019-12-12 10:21:40.063824	8	001120	2019-12-12 10:22:48.318159+07	f
1900	001120	49205	001	2019-12-04 09:03:53.424453	8	001120	2019-12-16 14:28:27.882538+07	f
1908	001120	48101	003	2019-12-16 14:29:10.041546	8	001120	2019-12-16 14:30:57.956888+07	f
1909	001120	48101	003	2019-12-16 14:31:23.109489	8	001120	2019-12-16 14:32:46.655262+07	f
1911	000000	48101	003	2019-12-16 14:36:54.617094	8	001120	2019-12-16 14:37:50.288666+07	f
1912	000000	48101	003	2019-12-16 14:38:54.512553	8	001120	2019-12-16 14:40:23.955124+07	f
1913	000000	48101	003	2019-12-16 14:40:58.568981	8	001120	2019-12-16 14:41:06.797025+07	f
1914	000000	48101	003	2019-12-16 14:42:16.474704	8	001120	2019-12-16 14:43:16.083064+07	f
1915	000000	48101	003	2019-12-16 14:45:36.797668	8	001120	2019-12-16 14:46:50.92307+07	f
1910	001120	48101	003	2019-12-16 14:35:53.197279	8	001120	2019-12-16 14:47:00.382928+07	f
1916	001120	48101	003	2019-12-16 14:47:12.336809	8	001120	2019-12-16 14:49:11.737073+07	f
1917	001120	48101	003	2019-12-16 14:49:43.520323	8	001120	2019-12-16 14:50:54.517147+07	f
1918	001120	48101	003	2019-12-16 14:51:28.688769	8	001120	2019-12-16 14:53:25.327432+07	f
1919	001120	48101	003	2019-12-16 14:53:43.378639	8	001120	2019-12-16 14:56:01.334757+07	f
1920	001120	48101	003	2019-12-16 15:00:22.051325	8	001120	2019-12-16 15:00:58.489974+07	f
1921	001120	48101	003	2019-12-16 15:01:59.631306	8	001120	2019-12-16 15:03:34.367132+07	f
1922	001120	48101	003	2019-12-16 15:05:56.363943	8	001120	2019-12-16 15:07:44.088679+07	f
1923	001120	48101	003	2019-12-16 15:07:56.491053	8	001120	2019-12-16 15:08:07.295809+07	f
1924	001120	48101	003	2019-12-16 15:08:20.366319	8	001120	2019-12-16 15:08:38.833572+07	f
1925	001120	48101	003	2019-12-16 15:09:07.675353	8	001120	2019-12-16 15:09:49.966591+07	f
1926	001120	48101	003	2019-12-16 15:11:28.67143	8	001120	2019-12-16 15:12:54.470408+07	f
1927	001120	48101	003	2019-12-16 15:15:12.855864	8	001120	2019-12-16 15:16:30.386028+07	f
1928	001120	48101	003	2019-12-16 15:20:09.777001	8	001120	2019-12-16 15:20:22.748431+07	f
1929	001120	48101	003	2019-12-16 15:26:57.448122	8	001120	2019-12-16 15:27:39.798582+07	f
1930	001120	48101	003	2019-12-16 15:27:56.07825	8	001120	2019-12-16 15:28:16.787473+07	f
1931	001120	48101	003	2019-12-16 16:39:32.48315	0	001120	2019-12-16 16:39:32.48315+07	f
1932	000605	49101	001	2020-02-17 11:26:36.907946	0	000605	2020-02-17 11:26:36.907946+07	f
1934	001120	48501	003	2020-02-19 14:37:22.912565	3	001120	2020-02-19 14:37:22.912565+07	f
1935	001120	48602	001	2020-02-19 14:37:39.867552	3	001120	2020-02-19 14:37:39.867552+07	f
1936	001120	48602	002	2020-02-19 16:56:09.82822	8	001120	2020-02-19 16:59:00.73437+07	f
1937	001120	48602	002	2020-02-19 16:59:38.374996	3	001120	2020-02-19 16:59:38.374996+07	f
1942	001202	48902	001	2020-02-25 15:51:51.492398	8	001120	2020-02-25 15:51:54.825639+07	f
1957	001202	48205	006	2020-02-27 10:19:14.028246	0	001120	2020-02-27 10:24:56.109866+07	f
1939	001202	48902	001	2020-02-25 15:40:59.509742	8	001120	2020-02-25 15:41:18.571794+07	f
1940	001202	48902	001	2020-02-25 15:44:49.498745	8	001120	2020-02-25 15:46:29.981544+07	f
1941	001202	48902	001	2020-02-25 15:49:07.173958	8	001120	2020-02-25 15:49:12.250613+07	f
1943	001202	48902	001	2020-02-25 15:54:22.033061	8	001120	2020-02-25 15:54:24.757005+07	f
1960	001120	48901	001	2020-02-27 13:26:23.212129	3	001120	2020-02-28 11:38:23.832+07	f
1973	001202	48205	009	2020-03-04 14:33:57.036336	3	001202	2020-03-05 17:00:27.526402+07	f
1954	001120	49205	001	2020-02-27 10:03:22.051324	0	001120	2020-02-27 10:03:22.051324+07	f
1955	001202	49205	001	2020-02-27 10:17:17.673489	0	001120	2020-02-27 10:17:17.673489+07	f
1944	001120	48504	001	2020-02-25 17:01:09.978349	3	001120	2020-02-25 17:01:09.978349+07	f
1933	000605	49151	001	2020-02-17 14:23:42.684562	8	000605	2020-02-26 09:39:28.984455+07	f
1945	001202	49101	001	2020-02-26 09:40:11.108727	8	000605	2020-02-26 09:40:36.834573+07	f
1947	001120	48217	010	2020-02-27 09:29:33.926596	8	001120	2020-02-27 09:31:34.423765+07	f
1949	001120	48217	010	2020-02-27 09:31:56.264676	8	001120	2020-02-27 09:31:58.983395+07	f
1950	001120	48217	010	2020-02-27 09:33:06.272029	8	001120	2020-02-27 09:33:09.379153+07	f
1951	001120	48217	010	2020-02-27 09:38:59.305587	8	001120	2020-02-27 09:39:02.409072+07	f
1948	001201	48217	010	2020-02-27 09:30:06.254694	8	001120	2020-02-27 09:39:12.43024+07	f
1952	001120	48901	001	2020-02-27 09:57:00.207998	8	001120	2020-02-27 10:39:38.813597+07	f
1958	001120	48901	001	2020-02-27 11:29:17.9771	8	001120	2020-02-27 11:29:37.145255+07	f
1953	001202	48901	001	2020-02-27 09:57:16.14283	7	001120	2020-02-27 13:42:28.912019+07	f
1970	001202	48610	002	2020-03-04 09:28:18.97791	3	001120	2020-03-04 09:28:18.97791+07	f
1959	001120	48901	001	2020-02-27 11:30:22.043828	8	001120	2020-02-27 13:22:45.955358+07	f
1974	001120	48205	009	2020-03-04 14:34:07.65747	10	001120	2020-03-06 10:25:03.197648+07	f
1961	001202	48208	008	2020-02-27 14:04:10.012904	8	001120	2020-02-27 14:07:15.221549+07	f
1938	001120	48208	009	2020-02-25 10:30:15.195523	8	001120	2020-02-27 15:28:09.779466+07	f
1962	001120	48208	009	2020-02-27 15:28:22.001145	8	001120	2020-02-27 15:29:28.908881+07	f
1963	001120	48208	009	2020-02-27 15:29:52.649744	8	001120	2020-02-27 15:31:26.803374+07	f
1956	001120	48205	006	2020-02-27 10:19:08.554897	8	001120	2020-02-27 10:24:23.851171+07	f
1964	001120	48208	009	2020-02-27 15:32:11.653197	0	001120	2020-02-27 15:32:11.653197+07	f
1965	001120	48903	001	2020-02-27 15:34:45.450454	8	001120	2020-02-27 15:35:11.18+07	f
1967	001120	48101	002	2020-03-02 11:26:40.622748	3	001120	2020-03-02 11:27:19.83055+07	f
1968	001202	48101	002	2020-03-02 13:48:56.400868	3	001120	2020-03-02 13:49:48.667913+07	f
1971	001202	48205	009	2020-03-04 09:34:01.669601	8	001120	2020-03-04 09:37:28.342811+07	f
1972	001202	48205	009	2020-03-04 09:37:35.526376	8	001120	2020-03-04 14:33:49.925751+07	f
1976	001008	48226	008	2020-03-05 09:58:36.774413	8	001202	2020-03-05 10:07:05.350152+07	f
1966	001202	48226	008	2020-03-02 10:38:51.806187	8	001202	2020-03-05 10:07:26.386571+07	f
1979	001008	48226	009	2020-03-05 10:09:31.186649	0	001202	2020-03-05 10:09:31.186649+07	f
1982	001201	48209	010	2020-03-05 10:13:01.259318	0	001202	2020-03-05 10:13:01.259318+07	f
1980	001202	48209	010	2020-03-05 10:12:48.773499	8	001202	2020-03-05 10:13:05.586887+07	f
1981	001202	48209	010	2020-03-05 10:12:51.552904	8	001202	2020-03-05 10:13:38.011006+07	f
1978	001202	48226	008	2020-03-05 10:08:03.09971	8	001202	2020-03-05 10:14:13.718041+07	f
1977	001008	48226	008	2020-03-05 10:07:15.44818	8	001202	2020-03-05 10:14:27.953567+07	f
1969	001120	48215	016	2020-03-04 09:22:23.392717	8	001202	2020-03-05 16:34:52.13227+07	f
1946	001120	48202	026	2020-02-27 09:06:18.053896	10	001120	2020-03-05 13:41:04.497119+07	f
1975	001202	48226	009	2020-03-05 09:55:01.543046	3	001202	2020-03-06 10:24:12.24229+07	f
1983	001202	48209	010	2020-03-05 10:18:37.045569	8	001202	2020-03-05 10:19:07.411795+07	f
2009	001202	48202	023	2020-03-05 16:50:58.326564	8	001202	2020-03-05 16:56:28.538096+07	f
1984	001202	48209	010	2020-03-05 10:19:14.684423	8	001202	2020-03-05 10:22:44.407445+07	f
1985	001202	48209	010	2020-03-05 10:22:47.112076	8	001202	2020-03-05 10:27:56.018738+07	f
1986	001202	48209	010	2020-03-05 10:27:58.798444	8	001202	2020-03-05 10:30:35.129212+07	f
1987	001202	48209	010	2020-03-05 10:30:51.169538	8	001202	2020-03-05 10:31:01.861926+07	f
1988	001120	48217	015	2020-03-05 10:32:31.062444	8	001120	2020-03-05 10:33:46.606105+07	f
1989	001120	48217	015	2020-03-05 10:38:25.098871	8	001120	2020-03-05 10:40:04.407922+07	f
1991	001120	48217	015	2020-03-05 10:41:27.807584	8	001120	2020-03-05 10:50:52.722139+07	f
1992	001202	48217	015	2020-03-05 10:53:37.751901	8	001120	2020-03-05 10:54:44.676305+07	f
1993	001120	48209	010	2020-03-05 11:01:19.569687	8	001120	2020-03-05 11:04:52.417087+07	f
1994	001202	48209	010	2020-03-05 11:06:49.789647	8	001120	2020-03-05 11:10:01.850337+07	f
1995	001120	48217	019	2020-03-05 11:18:07.500435	8	001120	2020-03-05 11:19:45.729901+07	f
1996	001202	48217	019	2020-03-05 11:20:50.934321	8	001120	2020-03-05 11:27:56.465421+07	f
2010	001120	48202	023	2020-03-05 16:51:11.91033	8	001120	2020-03-05 16:57:00.607104+07	f
2011	001120	48202	023	2020-03-05 16:57:08.706054	8	001120	2020-03-05 16:57:26.346973+07	f
2012	001120	48202	023	2020-03-05 16:58:28.498413	8	001120	2020-03-05 16:58:53.300522+07	f
2013	001120	48202	023	2020-03-05 16:58:56.796886	8	001120	2020-03-05 17:00:11.626822+07	f
1990	001120	48226	008	2020-03-05 10:39:20.955934	8	001120	2020-03-05 16:02:40.629228+07	f
2015	001202	48226	008	2020-03-05 17:01:30.767175	3	001202	2020-03-05 17:01:59.802717+07	f
2014	001120	48202	023	2020-03-05 17:00:14.273255	8	001120	2020-03-05 17:02:07.211413+07	f
1998	001202	48226	008	2020-03-05 16:27:56.475371	8	001202	2020-03-05 16:30:36.803573+07	f
2016	001120	48202	023	2020-03-05 17:02:10.036588	8	001120	2020-03-05 17:03:49.52083+07	f
2017	001120	48202	023	2020-03-05 17:03:52.36023	8	001120	2020-03-05 17:08:22.488354+07	f
2018	001120	48202	023	2020-03-05 17:08:26.367999	0	001120	2020-03-05 17:08:26.367999+07	f
1999	001120	48226	008	2020-03-05 16:31:55.183112	8	001202	2020-03-05 16:33:10.263557+07	f
2000	001202	48209	010	2020-03-05 16:36:29.933628	8	001120	2020-03-05 16:36:47.522361+07	f
2001	001202	48226	008	2020-03-05 16:39:34.088585	8	001202	2020-03-05 16:39:56.301646+07	f
2002	001120	48226	008	2020-03-05 16:40:40.359403	8	001202	2020-03-05 16:41:15.462417+07	f
2003	001202	48905	001	2020-03-05 16:43:07.188358	8	001202	2020-03-05 16:43:46.263936+07	f
2004	001120	48905	001	2020-03-05 16:44:47.528279	8	001202	2020-03-05 16:44:59.216478+07	f
2005	001202	48212	013	2020-03-05 16:45:30.864836	8	001202	2020-03-05 16:46:20.398146+07	f
2006	001120	48212	013	2020-03-05 16:47:09.549675	8	001202	2020-03-05 16:48:23.115055+07	f
2007	001120	48212	013	2020-03-05 16:49:21.318739	0	001202	2020-03-05 16:49:21.318739+07	f
2008	001202	48212	013	2020-03-05 16:49:28.071978	0	001202	2020-03-05 16:49:28.071978+07	f
1997	001120	48217	019	2020-03-05 11:32:24.290248	10	001120	2020-03-05 18:19:51.257412+07	f
2019	001202	48110	001	2020-03-05 17:09:45.191788	8	001202	2020-03-05 17:16:31.305498+07	f
2020	001120	48110	001	2020-03-05 17:09:54.149166	8	001202	2020-03-05 17:17:02.440508+07	f
2021	001120	48226	008	2020-03-05 17:17:58.404873	0	001202	2020-03-05 17:17:58.404873+07	f
2024	001202	49101	001	2020-05-11 10:57:51.907815	0	001202	2020-05-11 10:57:51.907815+07	f
2025	001202	48651	001	2020-05-11 11:21:36.328513	3	001202	2020-05-11 11:21:36.328513+07	f
2026	001202	48605	001	2020-05-11 11:21:49.952034	3	001202	2020-05-11 11:21:49.952034+07	f
2027	001202	48653	001	2020-05-11 11:22:06.706166	3	001202	2020-05-11 11:22:06.706166+07	f
2028	001202	49101	002	2020-05-11 11:25:41.570324	0	001202	2020-05-11 11:25:41.570324+07	f
2022	001202	48209	010	2020-03-05 17:19:17.634732	8	001202	2020-03-05 17:22:07.346208+07	f
2023	001120	48209	010	2020-03-05 17:19:26.355852	8	001202	2020-03-05 17:22:13.906123+07	f
\.


--
-- Data for Name: tbl_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_permission (permission_id, shain_cd, start_date, end_date, permission_cd) FROM stdin;
14	001002	2018-01-01	2020-01-01	99
21	290011	2019-02-21	2020-03-31	99
24	390032	2019-04-17	2020-03-31	99
25	360015	2019-04-17	2020-03-31	99
30	160035	2019-06-01	2020-03-31	99
31	290016	2019-06-14	2020-03-31	99
32	230002	2019-06-19	2020-03-31	99
35	270009	2019-06-20	2020-03-31	70
36	340051	2019-06-20	2020-03-31	70
37	410003	2019-06-20	2020-03-31	70
38	420043	2019-06-20	2020-03-31	70
39	380039	2019-06-20	2020-03-31	70
40	200032	2019-06-20	2020-03-31	70
42	450065	2019-06-20	2020-03-31	70
43	430052	2019-06-20	2020-03-31	70
44	210004	2019-06-20	2020-03-31	70
46	280019	2019-06-21	2020-03-31	99
48	000000	2019-08-09	2020-08-09	99
50	001008	2019-07-10	2020-07-10	99
52	001108	2019-10-29	2019-11-29	01
53	001201	2019-10-29	2019-11-29	99
49	000605	2019-08-12	2020-08-12	99
51	001202	2020-03-02	2020-11-29	99
47	001120	2019-08-09	9999-08-09	99
\.


--
-- Data for Name: tbl_qrcode; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_qrcode (qrcode_id, shain_cd, qrcode_data, created_at, nittei_id, kensyuu_id, kensyuu_sub_id) FROM stdin;
1	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 15:57:29.081854+07	\N	\N	\N
2	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:08:02.071671+07	\N	\N	\N
3	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:09:30.106877+07	\N	\N	\N
4	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:10:05.619992+07	\N	\N	\N
5	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:10:44.306458+07	\N	\N	\N
6	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:12:25.385636+07	\N	\N	\N
7	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:25:54.253406+07	\N	\N	\N
84	460016	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOQAAADkCAYAAACIV4iNAAAAAklEQVR4AewaftIAAAw6SURBVO3BQW4sy7LgQDKh/W+ZfYY+CiBRJd34r93M/mGtdYWHtdY1HtZa13hYa13jYa11jYe11jUe1lrXeFhrXeNhrXWNh7XWNR7WWtd4WGtd42GtdY2HtdY1HtZa13hYa13jhw+p/KWKN1T+UsUbKlPFicpvqphUTireUDmpeENlqphU/lLFJx7WWtd4WGtd42GtdY0fvqzim1S+qWJSeaPiDZWpYqqYVD5R8YbKpDJVTCqTylQxqbyh8psqvknlmx7WWtd4WGtd42GtdY0ffpnKGxVvqEwVn6j4L1W8oTKpTBVvVEwqU8WkMqlMFZPKVPGGyjepvFHxmx7WWtd4WGtd42GtdY0f/seonKhMFZPKVHGiclLxhsobFW+oTBVvqEwVJyonKlPFGxX/Sx7WWtd4WGtd42GtdY0f/sdUnKhMKt9UcaLyTSpvVJyofEJlqnhDZaqYKv6XPay1rvGw1rrGw1rrGj/8soq/pHJScaIyqbyhMlVMFZPKVDGpTBVvqEwqU8VU8YbKVDGpnFRMFZPKVPFNFTd5WGtd42GtdY2HtdY1fvgylf9SxaRyojJVTCpTxaQyVUwqU8U3qUwVJxWTylQxqUwVn6iYVKaKN1SmihOVmz2sta7xsNa6xsNa6xo/fKjiZhVvqHxTxaTyTRW/qeITFScVJxWTylRxUvF/ycNa6xoPa61rPKy1rmH/8AGVqWJS+aaKT6hMFZPKGxWTyv8lFZPKGxWTyknFpDJVnKicVEwq31Txmx7WWtd4WGtd42GtdY0fPlQxqZxUTCpTxYnKVPEJlW+qmFROKk5UpoqbVfymim+qmFSmir/0sNa6xsNa6xoPa61r2D98kcobFZPKScWk8omKSWWqmFROKiaV31RxonJSMam8UTGpnFScqHxTxaTymyo+8bDWusbDWusaD2uta9g/fEBlqphUpopvUpkqvkllqnhD5Y2Kv6Tymyomlanim1Q+UXGiMlV808Na6xoPa61rPKy1rmH/8AGVqeJEZao4UZkqTlSmiknlN1WcqEwVJypvVEwqU8UbKicVJypTxaQyVbyhMlX8JZWp4hMPa61rPKy1rvGw1rqG/cMHVH5TxaQyVfwmlW+qOFGZKiaVk4o3VKaKSeWk4i+pTBUnKicVk8pUMalMFd/0sNa6xsNa6xoPa61r2D98kcpJxRsq31RxonJS8YbKScUbKt9UMalMFZ9QmSpOVN6omFSmiknlExWTylTxiYe11jUe1lrXeFhrXeOHD6mcVEwqU8WkMlVMKicVk8qJyknFGypTxRsqU8VUcaIyVUwqb6i8UTFVTCpTxVQxqfymijdUftPDWusaD2utazysta7xw4cqTlSmipOKSeWkYlL5RMWkMlWcVEwqJxVTxRsqJypvVEwqU8U3qbxRMan8pYpJ5Zse1lrXeFhrXeNhrXUN+4cPqJxUvKEyVUwqJxWfUJkqTlQ+UTGpTBWTyknFGypTxaRyUvGGyhsVk8pUMamcVEwqb1T8poe11jUe1lrXeFhrXeOHX6byRsWkMlVMKm+ofFPFpPKJiknlEypTxVQxqUwVJypTxUnFGypTxUnFicpJxYnKScUnHtZa13hYa13jYa11jR/+YxWTylQxqUwVk8pU8U0qJxUnKm9UfKLiRGWq+ITKVPGGyhsqU8Wk8obKVPGXHtZa13hYa13jYa11jR/+WMWkMlVMKlPFGypTxYnKpDJVfKJiUvlNFZPKVDGpvFFxovJGxaTyTRVvqPylh7XWNR7WWtd4WGtd44c/pjJVnFR8omJSOan4JpWTikllqjhRmSreUJkqJpUTlZOKSeWNikllqnhDZaqYVN6o+KaHtdY1HtZa13hYa13D/uEDKlPFpDJVTCrfVDGpTBWTyknFpPJGxaRyUjGp/KaKN1ROKiaVb6qYVH5TxaRyUvGJh7XWNR7WWtd4WGtd44cvUzlROal4Q+WkYlKZKiaVSeWNipOKT1S8oTJVTConFVPFpPKJijdUTireUJkq/ksPa61rPKy1rvGw1rrGD7+s4kTlRGWqeENlqjipmFSmikllUpkqTlQ+oTJVnKhMFZPKicpUMamcVEwqU8U3qUwVJyr/pYe11jUe1lrXeFhrXeOHD1VMKt9U8YmKE5VPVEwqk8pJxYnKScUbFW+oTBUnFTepeKNiUjmp+KaHtdY1HtZa13hYa13jhw+pTBWfUPmEylRxUvF/ico3qUwVJypTxaRyUnGi8gmVv6QyVXziYa11jYe11jUe1lrXsH/4gMpvqphUTiomlZOKSWWqmFSmihOVqWJSOal4Q2WqOFE5qThR+UTFicpUcaIyVXyTylTxTQ9rrWs8rLWu8bDWuob9wwdUTiomlaliUjmpmFSmihOVqeINlTcqvknlExUnKm9UfEJlqjhRmSpOVH5TxTc9rLWu8bDWusbDWusaP3yo4kTlExWTyonKScWkMlVMKicVJyrfVDGpfFPFpHKiMlW8UfEJlanipOINlb/0sNa6xsNa6xoPa61r/PDLKiaVk4pJ5ZtU/lLFicpUMalMKm9UvKEyVUwqb6i8UTGp3KRiUpkqPvGw1rrGw1rrGg9rrWv88CGVk4qpYlKZKqaKSeUTFZPKpPKGylRxovKJikllqphUpopJZao4qZhUPlExqUwVb6hMFZPKVHFSMan8poe11jUe1lrXeFhrXeOHX6YyVUwVJypTxYnKGxUnKlPFpHKi8psqJpWpYlKZKk5UTio+ofKGyknFGyqfqPimh7XWNR7WWtd4WGtd44cPVUwqJyonFVPFJyreUHmjYlJ5o+KkYlI5qZhUpoq/VDGpTBWTyhsVJypTxYnKVDGp/KaHtdY1HtZa13hYa13D/uEDKicVk8pUcaIyVXxCZao4UflExaQyVUwqb1S8oTJVTCpTxaQyVUwqJxWTylQxqbxRMalMFScqn6j4xMNa6xoPa61rPKy1rvHDL1M5UZkqpopJ5Y2KqeJE5aTiN1V8QuWkYlL5TRUnFScVn6iYVKaKk4pJZar4poe11jUe1lrXeFhrXeOHD1X8JpWp4hMqU8U3qUwVU8WkMlWcqEwVJxWTylQxqfwmlTcqJpWp4kRlqphUTlSmikllqvjEw1rrGg9rrWs8rLWu8cOXqZxUvFHxhspU8UbFGypvqEwVk8pJxaQyVUwqn1D5TRWfUDmpmFSmikllqjip+KaHtdY1HtZa13hYa13jh19W8YbKGxUnKm+oTBWTylRxovJGxRsVk8pUMalMKicVk8pJxaQyVZyofJPKGxUnKicVn3hYa13jYa11jYe11jXsH75I5Y2KN1ROKt5QeaPiROWNik+oTBWTylQxqUwVJyrfVPFfUpkqTlSmim96WGtd42GtdY2HtdY17B8+oPJGxRsqJxWTylRxojJVTConFZPKVHGi8l+qmFTeqPiEyknFpPJfqvhND2utazysta7xsNa6xg8fqvhNFScqJypTxVQxqUwVk8qkMlVMKicVk8pJxRsq31Txmyo+UfGGyknFpDJVfNPDWusaD2utazysta7xw4dU/lLFVHGi8kbFJ1T+kspUcVJxUnGiMlWcqEwVJyonFZPKicpUcVIxqUwVk8pU8YmHtdY1HtZa13hYa13jhy+r+CaVE5WTik+onFRMKm+ofKLiDZVPVEwqU8VUMalMFZPKVPGJik9UnFR808Na6xoPa61rPKy1rvHDL1N5o+I3qbxRcaLyiYoTlUnlExVvqJxUvFExqUwVk8pUcaLyCZU3Kr7pYa11jYe11jUe1lrX+OF/nMpJxYnKN1WcqJxUnKicqEwVn1CZKt6omFSmijcqJpVvqphUpopPPKy1rvGw1rrGw1rrGj/8f05lqvhNKlPFGyonFZPKVHGiMlWcVJyovFExqZxUvFHxTRXf9LDWusbDWusaD2uta/zwyyp+U8WJyknFpDJVTConFZPKVHFScaIyVUwqb6hMFZPKVDGpTBVvVEwqJxXfpDJVvKEyVXziYa11jYe11jUe1lrXsH/4gMpfqphUpooTlTcq3lD5RMUbKlPFicpU8YbKVPGGyknFpHJSMalMFZPKb6r4xMNa6xoPa61rPKy1rmH/sNa6wsNa6xoPa61rPKy1rvGw1rrGw1rrGg9rrWs8rLWu8bDWusbDWusaD2utazysta7xsNa6xsNa6xoPa61rPKy1rvH/AFbF0bDg8zw1AAAAAElFTkSuQmCC	2019-10-08 16:05:20.224453+07	12625	48217	014
90	460016	data:image/png;base64,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oYrfVPFGxRsqJxUnKm+oTBWTyknFGypTxScqTir+pYo3VKaKE5Wp4pse1lrXeFhrXeNhrXWNHz6k8jdVTBUnKlPFVPGJikllUnmjYlI5UZkq3lA5qZhUpooTlaniROWkYlI5UZkqTlSmihOVqeITD2utazysta7xsNa6xg9fVvFNKicqU8WJyknFicpJxaQyVUwqn6j4poqTikllqpgqJpWp4kTlExW/qeKbHtZa13hYa13jYa11jR9+mcobFZ9QmSomlROVqWKqmFQmlTcqTlQmlW+qOFE5qXijYlL5JpVPVEwqf9PDWusaD2utazysta7xw/8zFZPKGypvVEwqn6i4icpU8U0Vk8pJxaTyiYoTlaniEw9rrWs8rLWu8bDWusYP/zEVJypTxYnKScWkclIxqUwVJypvVLyhMlVMKt9UcaJyUjGpnFScqEwVJxXf9LDWusbDWusaD2uta/zwyyp+U8Wk8obKGxWTylQxqXxTxaQyVbyhMlVMKlPFpPKGylRxUvFGxaRyovIJlaniEw9rrWs8rLWu8bDWusYPX6byN6mcVJyovKFyovI3VUwqU8WkMlW8oTJVfELlExWTylQxqZxUTCp/08Na6xoPa61rPKy1rmF/sNa6wsNa6xoPa61rPKy1rvGw1rrGw1rrGg9rrWs8rLWu8bDWusbDWusaD2utazysta7xsNa6xsNa6xoPa61rPKy1rvF/byXq/TI+Bm8AAAAASUVORK5CYII=	2019-10-22 14:08:05.206249+07	14463	48102	001
8	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:25:54.293543+07	\N	\N	\N
9	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:25:54.300506+07	\N	\N	\N
10	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:26:49.826095+07	\N	\N	\N
11	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:26:49.84294+07	\N	\N	\N
12	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:26:49.861286+07	\N	\N	\N
13	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:27:54.030031+07	\N	\N	\N
14	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:27:54.061438+07	\N	\N	\N
85	460016	data:image/png;base64,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	2019-10-08 16:08:52.458676+07	12610	48216	022
91	460016	data:image/png;base64,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	2019-10-23 14:39:57.482497+07	14708	48653	001
15	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:27:54.070823+07	\N	\N	\N
16	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:29:19.957986+07	\N	\N	\N
17	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:29:19.968815+07	\N	\N	\N
18	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:29:19.974225+07	\N	\N	\N
19	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:30:37.325+07	\N	\N	\N
20	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:30:37.34225+07	\N	\N	\N
21	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:30:37.351992+07	\N	\N	\N
86	460016	data:image/png;base64,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	2019-10-08 16:12:00.116193+07	12472	48201	005
92	460016	data:image/png;base64,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	2019-10-25 08:55:09.85634+07	14723	48108	003
22	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:32:17.257308+07	\N	\N	\N
23	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:32:17.261674+07	\N	\N	\N
24	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:32:17.278377+07	\N	\N	\N
25	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:33:27.171541+07	\N	\N	\N
26	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:33:27.189684+07	\N	\N	\N
27	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:33:27.213773+07	\N	\N	\N
28	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:34:23.74676+07	\N	\N	\N
87	460016	data:image/png;base64,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	2019-10-10 16:29:31.610319+07	12534	48207	008
93	460016	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOQAAADkCAYAAACIV4iNAAAAAklEQVR4AewaftIAAAxXSURBVO3BQW4sy7LgQDKh/W+ZraGPAkhU6bz4t93MfrHWusLDWusaD2utazysta7xsNa6xsNa6xoPa61rPKy1rvGw1rrGw1rrGg9rrWs8rLWu8bDWusbDWusaD2utazysta7xw4dU/qWKN1Q+UXGi8k0VJypTxV9SmSo+oXJS8YbKVDGp/EsVn3hYa13jYa11jYe11jV++LKKb1J5Q2WqOFE5UZkq3qg4UZlUTiomlZOKSWWqmFSmikllqvgmlb9U8U0q3/Sw1rrGw1rrGg9rrWv88MdU3qh4Q+VE5ZtUpopJZVKZKqaKSWWqmFTeUDlRmSreUDmpOKl4Q+WbVN6o+EsPa61rPKy1rvGw1rrGD/8xFZPKVPEJlUnlDZWpYqqYVKaKSeUTFZPKScUbKicqU8UbFf8lD2utazysta7xsNa6xg//MSpTxaQyVZyoTBWTyhsVJyonKt+kMlVMKm+oTBWTylQxqUwVU8V/2cNa6xoPa61rPKy1rvHDH6v4lyo+oTJVnFRMKlPFpDJVTBWTylTxhspJxUnFpDJVTBWTylQxqUwVk8pU8U0VN3lYa13jYa11jYe11jV++DKVm6hMFZPKVDGpTBWTylQxqUwVk8pU8YbKVHFSMalMFZPKVDGpTBX/kspUcaJys4e11jUe1lrXeFhrXeOHD1XcRGWq+ETFpDJVTCpTxUnFJyq+SWWqmFSmik9UnFRMKlPFScX/JQ9rrWs8rLWu8bDWusYPH1KZKiaVb6qYKt5QmSr+kso3qXxCZaqYVD6hcqJyUvGGylQxqXxTxV96WGtd42GtdY2HtdY1fvjHKiaVk4oTlZOKqeJEZar4SxWTylQxqbxRMam8ofJGxV+q+ETFGyr/0sNa6xoPa61rPKy1rmG/+IDKScUbKm9UnKj8pYoTlTcqJpWpYlKZKiaVqeKbVP6liknlpOITKm9UfOJhrXWNh7XWNR7WWtf44UMVk8qk8kbFicqJyknFiconVE4q3qiYVKaKSWWqmFTeqPhLFW+ovKHyRsVUcaLyTQ9rrWs8rLWu8bDWuob94gMqU8WkMlVMKm9UTCpTxaQyVZyonFRMKlPFN6n8pYpJ5Y2KT6hMFW+oTBWfUDmp+EsPa61rPKy1rvGw1rqG/eIDKicVb6hMFZPKVDGpnFS8ofKJiknlpGJSmSo+oTJVnKhMFZ9QmSreUJkqTlSmijdUTiq+6WGtdY2HtdY1HtZa17Bf/CGVqeJE5aRiUjmpmFROKiaVNyreUPlExaRyUnGiMlV8QmWqmFSmiknlExWfUJkqJpWp4hMPa61rPKy1rvGw1rrGD1+m8obKScVJxaQyqUwVk8obFZPKicobFZPKVPFGxaQyVUwVJyonFScqU8WkMlVMKlPFicpUMalMFVPFpPKXHtZa13hYa13jYa11DfvFH1I5qZhUvqliUjmpmFQ+UTGpvFExqZxUTCpTxaQyVUwqU8UbKp+oOFE5qZhUpopJ5aRiUpkqPvGw1rrGw1rrGg9rrWv88CGVk4pPVJyofKLipOJE5RMVk8qkMlWcqEwVk8onVKaKk4pJ5RMqU8WkMqmcqLyh8pce1lrXeFhrXeNhrXUN+8X/kMpUMamcVJyoTBWTylTxl1ROKiaVNyomlaliUjmpmFT+UsWkclLxhspJxYnKScUnHtZa13hYa13jYa11jR++TGWqmFSmipOKb1KZKr5J5RMqU8UbKn+pYlI5qZhUpopJ5ZtU3lCZKqaKv/Sw1rrGw1rrGg9rrWv88MdUTlS+qeIvqXyiYlI5UXmjYlKZVKaKSeVEZaqYVN5QmSomlaliUpkqTireUJkqJpWp4hMPa61rPKy1rvGw1rrGDx9SmSreUJkqTlSmikllqjhRmSpOKt5QmVSmiknlEyonFW+ofFPFGxWTylTxhspUMalMFZPKX3pYa13jYa11jYe11jV++DKVqWJSOVF5Q2Wq+ITKVHGiclIxqUwqN6s4UZkqJpWTiknlpGJS+YTKVPG/9LDWusbDWusaD2uta/zwZRWfqHhDZVKZKiaVN1SmiqniRGWqmFTeqHhD5URlqviEyknFScWJyknFGypvVPylh7XWNR7WWtd4WGtd44c/pvIJlaniL1WcqEwVk8qJyjepTBUnKlPFpPJGxSdUTio+oTJVnKicVEwqU8UnHtZa13hYa13jYa11jR++TGWqmFTeqPhLFScqJypTxTepnFS8UXGzim+q+ETFScU3Pay1rvGw1rrGw1rrGvaLD6hMFZPKVDGpfFPF/yUqU8Wk8pcq3lCZKk5UpopJ5SYVk8obFZ94WGtd42GtdY2HtdY17BcfUPlExRsqU8WkMlVMKlPFGyp/qeJE5aTiDZVvqjhRmSomlaniROWk4ptUpopvelhrXeNhrXWNh7XWNewXf0hlqnhD5Y2KSWWqmFTeqHhD5aRiUpkqTlSmim9SOan4hMpUMamcVJyofFPFpDJVfOJhrXWNh7XWNR7WWtf44UMqU8VUMalMFScVJyqTyicqJpVJ5Y2KT6icVEwqJxWTylTxL1VMKlPFicpUcVJxonKiMlV808Na6xoPa61rPKy1rmG/+IDKGxVvqEwVb6icVEwqJxWfUJkqTlSmihOVqWJSmSomlaniEypTxRsqb1RMKicVn1CZKj7xsNa6xsNa6xoPa61r2C++SOWbKj6h8omKE5WpYlKZKk5U3qg4UTmpmFQ+UTGpnFRMKicVJypTxaRyUvGGylTxiYe11jUe1lrXeFhrXcN+8T+k8kbFGypTxYnKVHGiclIxqUwVk8pU8U0qU8W/pHJSMam8UXGi8k0V3/Sw1rrGw1rrGg9rrWv88CGVqeJE5aTiDZVPqEwVk8pU8S+pfKLiRGWqmFROKr5JZaqYVKaKE5Wp4kRlqviXHtZa13hYa13jYa11jR++TOWNihOVqWKqmFSmipOKSWWqmFSmihOVT1RMKicVb1RMKlPFicobFScqk8qJylRxojJVnKi8UfGJh7XWNR7WWtd4WGtdw37xAZWTikllqphUpoo3VD5RMan8pYoTlW+qmFTeqJhUTipuovJGxaRyUvGJh7XWNR7WWtd4WGtdw37xAZWp4ptUpopJ5RMVk8pUMalMFZPKScWk8kbFGyonFScqJxWTyjdVTCrfVDGpfKLiEw9rrWs8rLWu8bDWusYPH6o4UflExaQyVUwqU8WJyhsVk8pUcaIyVUwqb6h8QuUTKicVk8pJxScqJpW/VPFND2utazysta7xsNa6hv3ii1SmijdUPlExqXyiYlJ5o2JSOamYVD5R8U0q/0sVk8pUMalMFZPKVHGiclLxiYe11jUe1lrXeFhrXeOHP6ZyUjFVnKhMFZPKVDGpTBXfVDGpTBUnKlPFpHJSMalMFZPKGxWTylRxojJVfKJiUpkqJpWbPay1rvGw1rrGw1rrGvaLD6i8UfGGylQxqUwVJypTxYnKGxVvqEwVk8pfqjhROamYVKaKE5WTiknlZhWfeFhrXeNhrXWNh7XWNX74UMVfqvhLKlPFScWJyhsVk8pJxRsqU8UnKk4q3qj4poo3VKaKE5Wp4pse1lrXeFhrXeNhrXWNHz6k8i9VTBVvVEwqf6liUjmpmFROVKaKN1ROKiaVqeJEZaqYVN6omFROVKaKE5Wp4kRlqvjEw1rrGg9rrWs8rLWu8cOXVXyTyonKJyomlaniROWNiknlExXfVHFSMalMFVPFpDJVnKh8ouIvVXzTw1rrGg9rrWs8rLWu8cMfU3mj4psqTlSmihOVN1SmiqniRGVS+aaKE5WTijcqJpVvUvlExaTyLz2sta7xsNa6xsNa6xo//MdUvFHxRsUbKpPKJypuojJVfFPFpHJSMal8ouJEZar4xMNa6xoPa61rPKy1rvHD/2dUpooTlaniRGWqOFGZKk5U3qh4Q2WqmFS+qeJE5aRiUjmpOFGZKk4qvulhrXWNh7XWNR7WWtf44Y9V/KWKSeWkYlJ5Q2WqmComlW+qmFSmijdUTlSmiknlDZWp4qRiUplUpopJ5UTlEypTxSce1lrXeFhrXeNhrXWNH75M5V9SOan4Syr/SxWTylQxqUwVk8qJylTxCZVPVEwqU8WkclIxqfxLD2utazysta7xsNa6hv1irXWFh7XWNR7WWtd4WGtd42GtdY2HtdY1HtZa13hYa13jYa11jYe11jUe1lrXeFhrXeNhrXWNh7XWNR7WWtd4WGtd4/8B/c7K/FkFv7sAAAAASUVORK5CYII=	2019-10-28 11:33:09.597401+07	14715	48652	002
29	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:34:23.757693+07	\N	\N	\N
30	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:34:23.764211+07	\N	\N	\N
31	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:47:55.000191+07	\N	\N	\N
32	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:49:17.202781+07	\N	\N	\N
33	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-12 16:50:26.165863+07	\N	\N	\N
34	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-17 09:23:11.216864+07	\N	\N	\N
35	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-17 17:38:36.257325+07	\N	\N	\N
88	460016	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOQAAADkCAYAAACIV4iNAAAAAklEQVR4AewaftIAAAwmSURBVO3BQY4cSXAAQffC/P/LLh5DlwQK3UOmVmFmf7DWusLDWusaD2utazysta7xsNa6xsNa6xoPa61rPKy1rvGw1rrGw1rrGg9rrWs8rLWu8bDWusbDWusaD2utazysta7xw4dU/qaKN1T+poo3VKaKE5XfVDGpnFS8oXJS8YbKVDGp/E0Vn3hYa13jYa11jYe11jV++LKKb1J5Q2WqOFGZKr5JZaqYKiaVT1S8oTKpTBWTyqQyVUwqb6j8popvUvmmh7XWNR7WWtd4WGtd44dfpvJGxRsqJypTxRsqU8WJyicq3lCZVKaKNyomlaliUplUpopJZap4Q+WbVN6o+E0Pa61rPKy1rvGw1rrGD/8xFZPKGyrfVPGGyhsVb6hMFW+oTBUnKicqU8UbFf8lD2utazysta7xsNa6xg//z6icVEwqb1RMKr9J5Y2KE5VPqEwVb6hMFVPFf9nDWusaD2utazysta7xwy+r+JtU3qj4JpWp4kRlqphUpoo3VCaVqWKqeENlqphUTiqmikllqvimips8rLWu8bDWusbDWusaP3yZyr9UMalMFZPKVPGGylQxqUwV36QyVZxUTCpTxaQyVXyiYlKZKt5QmSpOVG72sNa6xsNa6xoPa61r/PChiv9LVL6p4qRiUvmmit9U8YmKk4qTikllqjip+L/kYa11jYe11jUe1lrXsD/4gMpUMal8U8UbKp+o+CaVm1RMKm9UTConFZPKVHGiclIxqXxTxW96WGtd42GtdY2HtdY1fvhQxaRyUjGpnFS8ofJGxYnKVDGpTBWTyknFicpUcbOK31TxTRWTylTxNz2sta7xsNa6xsNa6xr2Bx9Q+UTFicpJxYnKVDGpvFExqUwVJyrfVHGiclIxqbxRMamcVEwqv6liUvlNFZ94WGtd42GtdY2HtdY1fvjLKt6oeEPlmypOKr6p4psqTlQ+oXJSMalMFd+kMqm8UXGiMlV808Na6xoPa61rPKy1rvHD5VQ+UTGpTBUnKicVk8obFScqb1RMKlPFVHGiclJxojJVTCpTxaQyVUwqU8VvqphUpopPPKy1rvGw1rrGw1rrGj/8YyonFZPKScUbKicVk8onKk5UpopJ5Y2KE5Wp4psqTipOKiaVqeJE5aRiUpkqJpWp4pse1lrXeFhrXeNhrXUN+4MPqEwVk8pJxYnKVDGpvFExqXxTxaRyUvGGyjdVTCpTxSdUpooTlZOKE5WpYlL5RMWkMlV84mGtdY2HtdY1HtZa1/jhQxVvVEwqJxWTylRxojKpTBWTylTxhspU8YbKVDFVnKhMFZPKGypvVEwVk8pUMVVMKpPKVPGJijdUftPDWusaD2utazysta7xwy+r+ITKVDGpvFExqUwVk8pUcVIxqZxUTBVvqHxTxaQyVXyTyhsVk8rfVDGpfNPDWusaD2utazysta5hf/ABlaliUvlExaRyUvEJlaniROUTFZPKVDGpnFR8k8pJxRsqb1RMKlPFpHJSMam8UfGbHtZa13hYa13jYa11DfuDX6QyVbyhMlWcqHyi4ptUTipOVN6omFSmihOVqeJEZar4JpWp4hMqJxUnKicVn3hYa13jYa11jYe11jXsDz6gMlWcqEwVb6hMFZPKv1RxojJV/EsqU8UbKicVb6icVEwqU8Wk8omKSeWk4hMPa61rPKy1rvGw1rrGDx+qmFQ+oXJScVJxojJVvKEyVbxRMan8popJZaqYVN6oOFF5o2JS+aaKN1T+poe11jUe1lrXeFhrXcP+4AMqn6j4TSo3q5hUpooTlaniROWkYlL5RMWkclJxojJVnKicVEwqb1R808Na6xoPa61rPKy1rmF/8AGVqeINlW+qmFTeqJhUTiomlU9UTCq/qeINlZOKSeWbKiaV31QxqZxUfOJhrXWNh7XWNR7WWtf44ctUPlHxhsqkMlV8U8VJxW+qeENlqphUTiqmiknlExVvqJxUvKEyVfxLD2utazysta7xsNa6xg+/rOJE5URlqjip+ITKGypvVEwqn1CZKk5UpopJ5URlqphUTiomlanim1SmihOVf+lhrXWNh7XWNR7WWtf44UMVk8o3VXxCZaqYVKaKSWVSOak4UZkqTlROKt6oeENlqjipeKPiN1W8UTGpnFR808Na6xoPa61rPKy1rvHDh1S+SeWbKk4qJpWpYlKZKk5Uvknlm1SmihOVqWJSOamYVL5J5W9SmSo+8bDWusbDWusaD2uta9gffJHKGxWTylQxqbxR8YbKN1WcqJxUvKEyVZyonFScqHyi4ptUpopvUpkqvulhrXWNh7XWNR7WWtewP7iYyhsVn1CZKk5UTiq+SeUTFScqb1R8QmWqOFE5qZhUflPFNz2sta7xsNa6xsNa6xr2Bx9QmSomlaliUpkqTlTeqDhReaNiUpkqTlQ+UTGpvFHxhsobFTdRmSreUDmp+KaHtdY1HtZa13hYa13jhw9VTCqfUDmpmFROVE4qTlROKt6omFSmikllUnmj4g2VqWJSeUPljYpJ5Y2K31QxqUwVn3hYa13jYa11jYe11jV++GUVJxVvqHyiYlL5m1Q+UTGpTBWTylQxqUwVJxWTyicqJpWp4g2VqWJSmSpOKiaV3/Sw1rrGw1rrGg9rrWv88CGVE5Wp4g2VqWJS+UTFicqJylQxqfymikllqphUpooTlZOKT6i8oXJS8YbKJyq+6WGtdY2HtdY1HtZa1/jhQxUnKpPKScVU8YmKN1TeqJhU3qg4qZhUPlHxN1VMKlPFpPJGxYnKVHGiMlVMKr/pYa11jYe11jUe1lrX+OHLVE4q3lCZKk4qTlSmijdUTiomlTdU3qh4Q2WqmFSmiknlROWkYlKZKiaVE5Wp4ptUTlSmik88rLWu8bDWusbDWusaP3xI5RMqU8VUMalMFZPKVDFVnFRMKlPFicpUMamcVHxC5aRiUvlNFScVJxWfqJhUpoqTikllqvimh7XWNR7WWtd4WGtd44dfVjGpTBWTyknFScWJyknFVPFGxaQyVUwqU8WJylRxUjGpTBWTym9SeaNiUpkqTlSmiknlRGWqmFSmik88rLWu8bDWusbDWusaP3yoYlJ5Q+Wk4g2Vk4pPqJxUnKhMFZPKScWkMlVMKp9Q+U0Vn1A5qZhUpopJZao4qfimh7XWNR7WWtd4WGtd44e/rOJEZVJ5o+JE5aTijYpJZaqYVE4qPqEyVUwqk8pJxaRyUjGpTBUnKt+k8kbFicpJxSce1lrXeFhrXeNhrXWNH36ZyknFVPEJlanipGJSmSpOVP6lihOVqWJSmSreUHlDZaqYKv4mlanijYpvelhrXeNhrXWNh7XWNX74kMobFW+onFR8QuUTFW9UTCp/k8pUMam8UfEJlZOKSeU3qZxU/KaHtdY1HtZa13hYa13jhw9V/KaKE5UTlZOKSWVSmSomlaniRGWqmFROKt5Q+aaKT6icVHyi4g2Vk4pJZar4poe11jUe1lrXeFhrXeOHD6n8TRVTxYnKVPFGxaTyhspvUpkqTipOKk5UpooTlaliUplUTiomlROVqeKkYlKZKiaVqeITD2utazysta7xsNa6xg9fVvFNKicqb6hMFZ+oOKmYVCaVT1S8ofKJikllqpgqJpWpYlKZKj5R8YmKk4pvelhrXeNhrXWNh7XWNX74ZSpvVHyi4kRlUjlROVE5qTipOFGZVD5R8YbKScUbFZPKVDGpTBUnKp9QeaPimx7WWtd4WGtd42GtdY0f/mNUTipOVD5RcVJxonJScaJyojJVfEJlqnijYlKZKt6omFS+qWJSmSo+8bDWusbDWusaD2uta/yw/peKSWWqmFQmlTcq3lA5qZhUpooTlanipOJE5Y2KSeWk4o2Kb6r4poe11jUe1lrXeFhrXeOHX1bxmypOVCaVqWJSmSomlZOKSWWqOKk4UZkqJpU3VKaKSWWqmFSmijcqJpWTim9SmSreUJkqPvGw1rrGw1rrGg9rrWvYH3xA5W+qmFSmihOVNyreUPlExRsqU8WJylTxhspU8YbKScWkclIxqUwVk8pvqvjEw1rrGg9rrWs8rLWuYX+w1rrCw1rrGg9rrWs8rLWu8bDWusbDWusaD2utazysta7xsNa6xsNa6xoPa61rPKy1rvGw1rrGw1rrGg9rrWs8rLWu8T80B8CsTgHxFQAAAABJRU5ErkJggg==	2019-10-10 16:32:59.685017+07	12585	48215	013
94	460016	data:image/png;base64,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	2019-10-28 11:34:30.903658+07	14533	48206	004
36	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-18 09:01:06.033677+07	\N	\N	\N
37	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-18 09:03:12.76058+07	\N	\N	\N
38	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-18 09:04:34.988916+07	\N	\N	\N
39	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-18 09:12:49.194888+07	\N	\N	\N
40	040005	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAALqSURBVO3BQY7cQAwEwSxC//9yeo88NSBIs/bQjIg/WGMUa5RijVKsUYo1SrFGKdYoxRqlWKMUa5RijVKsUYo1SrFGKdYoxRrl4qEk/CaVkyScqHRJ6FS6JPwmlSeKNUqxRinWKBcvU3lTEk6S0Kl0SeiS0KncofKmJLypWKMUa5RijXLxYUm4Q+UOlROVkyR0Knck4Q6VTyrWKMUapVijXAyXhBOVSYo1SrFGKdYoF18uCXeodEnoVL5ZsUYp1ijFGuXiw1Q+SeVvUvmXFGuUYo1SrFEuXpaE35SETqVLQqfyRBL+ZcUapVijFGuU+IP/SBJOVL5ZsUYp1ijFGuXioSR0Kl0SOpUuCZ1Kl4RO5SQJd6g8kYRO5SQJncqbijVKsUYp1ijxBy9KQqfyNyWhU7kjCZ3KSRI6lS4JncqbijVKsUYp1igXDyWhU7kjCZ1Kl4QTlSeS0Kl0KidJ6FS6JJwkoVN5olijFGuUYo0Sf/CiJDyhcpKEE5UuCZ3KHUnoVE6S0Kl0SehU3lSsUYo1SrFGufgwlS4JdyShUzlJwh1J6FTuSEKn0iWhU+mS0Kk8UaxRijVKsUaJP/hiSehUuiScqHRJ6FS6JHQqXRI6lS4JncqbijVKsUYp1igXDyXhN6l0KicqXRLuSMIdKl0SOpUuCZ3KE8UapVijFGuUi5epvCkJdyThjiScqHRJ6JJwovKbijVKsUYp1igXH5aEO1TuSMKJSpeETqVLQpeEE5WTJHQqn1SsUYo1SrFGufhyKl0STlROVLok3JGETqVLQqfypmKNUqxRijXKxZdLwkkSOpUuCZ1Kp3KShJMkdCpdEjqVJ4o1SrFGKdYoFx+m8kkqXRI6lROVkyScqNyRhE8q1ijFGqVYo1y8LAm/KQmdSpeETqVLQqdyotIloVPpktCpdEl4U7FGKdYoxRol/mCNUaxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlD+MSjL8jVjYvAAAAABJRU5ErkJggg==	2019-09-18 09:20:13.916314+07	\N	\N	\N
41	001120	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKbSURBVO3BQW7kQAwEwSxC//9yro88NSBIM/YSjIg/WGMUa5RijVKsUYo1SrFGKdYoxRqlWKMUa5RijVKsUYo1SrFGKdYoxRrl4qEkfJPKE0noVE6S8E0qTxRrlGKNUqxRLl6m8qYk3JGET1J5UxLeVKxRijVKsUa5+LAk3KFyRxI6lS4JncqbknCHyicVa5RijVKsUS6GScJJEjqVSYo1SrFGKdYoF8OodEnoVLokdCr/s2KNUqxRijXKxYepfFMSTpLQqTyh8pcUa5RijVKsUS5eloTfpNIloVPpktCpnCThLyvWKMUapVijXDyk8j9TOVH5nxRrlGKNUqxR4g8eSEKn0iXhTSpPJKFTOUnCm1Q+qVijFGuUYo1y8cepfFIS7lC5IwnfVKxRijVKsUa5+GUqJ0noVLoknKh0Kl0SOpUuCV0SOpW/pFijFGuUYo0Sf/BFSThROUlCp3KShDepnCThROWTijVKsUYp1igXDyWhU+mScKLSJeFE5SQJJypdEjqVkyR0Kn9JsUYp1ijFGuXiIZUTlTtU7kjCX6byTcUapVijFGuU+IMHkvBNKk8koVPpktCpnCShU+mS0Kl8UrFGKdYoxRrl4mUqb0rCSRI6lROVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtU3pSEE5UuCZ1Kp9IloUvCiconFWuUYo1SrFEuhlPpktAl4SQJJypdEn5TsUYp1ijFGuViuCR0Kl0SOpUuCXeo/KZijVKsUYo1ysWHqXySSpeEkyScJOGbktCpPFGsUYo1SrFGuXhZEr4pCXeodEnoVE6ScEcSOpVO5U3FGqVYoxRrlPiDNUaxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFH+AX+V9etijYfrAAAAAElFTkSuQmCC	2019-09-18 13:21:18.93424+07	\N	\N	\N
42	001120	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKbSURBVO3BQW7kQAwEwSxC//9yro88NSBIM/YSjIg/WGMUa5RijVKsUYo1SrFGKdYoxRqlWKMUa5RijVKsUYo1SrFGKdYoxRrl4qEkfJPKE0noVE6S8E0qTxRrlGKNUqxRLl6m8qYk3JGET1J5UxLeVKxRijVKsUa5+LAk3KFyRxI6lS4JncqbknCHyicVa5RijVKsUS6GScJJEjqVSYo1SrFGKdYoF8OodEnoVLokdCr/s2KNUqxRijXKxYepfFMSTpLQqTyh8pcUa5RijVKsUS5eloTfpNIloVPpktCpnCThLyvWKMUapVijXDyk8j9TOVH5nxRrlGKNUqxR4g8eSEKn0iXhTSpPJKFTOUnCm1Q+qVijFGuUYo1y8cepfFIS7lC5IwnfVKxRijVKsUa5+GUqJ0noVLoknKh0Kl0SOpUuCV0SOpW/pFijFGuUYo0Sf/BFSThROUlCp3KShDepnCThROWTijVKsUYp1igXDyWhU+mScKLSJeFE5SQJJypdEjqVkyR0Kn9JsUYp1ijFGuXiIZUTlTtU7kjCX6byTcUapVijFGuU+IMHkvBNKk8koVPpktCpnCShU+mS0Kl8UrFGKdYoxRrl4mUqb0rCSRI6lROVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtU3pSEE5UuCZ1Kp9IloUvCiconFWuUYo1SrFEuhlPpktAl4SQJJypdEn5TsUYp1ijFGuViuCR0Kl0SOpUuCXeo/KZijVKsUYo1ysWHqXySSpeEkyScJOGbktCpPFGsUYo1SrFGuXhZEr4pCXeodEnoVE6ScEcSOpVO5U3FGqVYoxRrlPiDNUaxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFH+AX+V9etijYfrAAAAAElFTkSuQmCC	2019-09-18 13:30:06.056876+07	\N	\N	\N
89	460016	data:image/png;base64,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	2019-10-10 16:42:03.509273+07	12606	48216	018
95	460016	data:image/png;base64,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	2019-10-28 11:35:12.08868+07	14715	48652	002
43	140020	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKpSURBVO3BQW7kQAwEwUxC//9yrY88NSBIM2sTjDA/WGMUa5RijVKsUYo1SrFGKdYoxRqlWKMUa5RijVKsUYo1SrFGKdYoxRrl4iGVb0pCp3KShE7lJAmdyjcl4YlijVKsUYo1ysXLkvAmld8kCW9SeVOxRinWKMUa5eLDVO5IwicloVN5QuWOJHxSsUYp1ijFGuXij0tCp9KpdEnokjBJsUYp1ijFGuXij1M5SUKncpKEv6xYoxRrlGKNcvFhSfikJNyRhDcl4Tcp1ijFGqVYo1y8TOWbVLokdCpdEjqVLgknKr9ZsUYp1ijFGsX8YI1RrFGKNUqxRrl4SKVLwonKNyWhU+mS0Kl0SThR6ZLQqdyRhCeKNUqxRinWKBcPJeFEpUtCp3KShE7lTSp3qJyodEnoVD6pWKMUa5RijXLxnyWhU+lUTpLQqTyRhDuS0KmcJKFTeVOxRinWKMUaxfzgAZVPSkKnckcSTlTelIQTlS4JbyrWKMUapVijXHxYEp5QOUnCHSqfpHKHSpeEJ4o1SrFGKdYoFw8l4ZOScKLSJaFT6ZLQqdyRhDtUvqlYoxRrlGKNcvGQyjcl4USlS0Kn0iXhTSonSehU3lSsUYo1SrFGuXhZEt6kckcSTpJwh0qXhJMkdConSXhTsUYp1ijFGuXiw1TuSMITKidJOFG5Q6VLwolKl4Q3FWuUYo1SrFEuhkvCicodKnck4ZuKNUqxRinWKBd/XBJOVJ5IQqdyotIloVM5ScITxRqlWKMUa5SLD0vCN6l0SehUTpJwRxI6lf+pWKMUa5RijXLxMpVvUumS0Kl0SehUOpUuCScqXRI6lZMkvKlYoxRrlGKNYn6wxijWKMUapVijFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNco/SAn3+6r0F7kAAAAASUVORK5CYII=	2019-09-18 13:52:36.069166+07	\N	\N	\N
44	aa	undefined	2019-09-18 14:11:53.097+07	\N	\N	\N
45	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHQAAAB0CAYAAABUmhYnAAAAAklEQVR4AewaftIAAAKiSURBVO3BQY7cQAwEwSxC//9y2keeGhCkGa+5jIh/scYo1ijFGqVYoxRrlGKNUqxRijVKsUYp1ijFGqVYoxRrlGKNUqxRijXKxUNJ+CaVO5LQqXRJ6FS6JHyTyhPFGqVYoxRrlIuXqbwpCXck4Q6VO1TelIQ3FWuUYo1SrFEuPiwJd6jckYQTlS4JJyp3JOEOlU8q1ijFGqVYo1wMo/KbFWuUYo1SrFEuhktCp9IlYZJijVKsUYo1ysWHqXxTEk6S0Kk8ofKTFGuUYo1SrFEuXpaEf0mlS0Kn0iWhUzlJwk9WrFGKNUqxRol/8R9LQqfymxVrlGKNUqxRLh5KQqfSJeFNKp1Kl4ROpUtCp3KShDepfFKxRinWKMUa5eIhlROVO5LQqXRJOFG5Iwl3qNyRhG8q1ijFGqVYo1w8lIRO5Y4kdCpdEu5IQqfSqXRJ6FS6JHRJ6FR+kmKNUqxRijXKxUMqJ0k4UemS0Kl0SehU7kjCSRJOVH6yYo1SrFGKNcrFQ0m4Q6VLwkkSOpUuCXeodEnoVE6S0Kn8JMUapVijFGuUi4dUnlB5k8pvVqxRijVKsUa5eCgJ36TSqdyRhE6lS0Kn0ql0SehU/qVijVKsUYo1ysXLVN6UhJMkdCpdEjqVE5WTJDyRhBOVJ4o1SrFGKdYoFx+WhDtUnkhCp9IloVPpktCpdCpdEu5Q+aRijVKsUYo1ysUvl4STJJyo/CTFGqVYoxRrlIvhktCpdEnoVLok/E+KNUqxRinWKBcfpvJJKl0SOpUuCSdJ+KYkdCpPFGuUYo1SrFEuXpaEb0pCp9IloVPpktCpnCThTSpvKtYoxRqlWKPEv1hjFGuUYo1SrFGKNUqxRinWKMUapVijFGuUYo1SrFGKNUqxRinWKMUa5Q+3Fvb5idxXmgAAAABJRU5ErkJggg==	2019-09-18 14:16:02.402653+07	\N	\N	\N
46	ddddd	undefined	2019-09-18 14:18:58.777974+07	\N	\N	\N
47	aaa,bbb	undefined	2019-09-18 14:20:11.952637+07	\N	\N	\N
48	aaa,bbb	undefined	2019-09-18 14:20:39.942832+07	\N	\N	\N
49	aaa,bbb	undefined	2019-09-18 14:21:11.351786+07	\N	\N	\N
50	aaa,bbb	undefined	2019-09-18 14:21:43.090847+07	\N	\N	\N
51	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAAOVSURBVO3BQY5bSwIDwWRB979yjhd/wVUBwpNst4cR8Rdm/nOYKYeZcpgph5lymCmHmXKYKYeZcpgph5lymCmHmXKYKYeZcpgpLx5Kwu+k0pJwo3KThBuVloSmcpOE30nlicNMOcyUw0x58WEqn5SEG5WbJDSVG5UblSdUPikJn3SYKYeZcpgpL74sCe9Q+SSVJ5LQVFoSmso7kvAOlW86zJTDTDnMlBc/XBKeUGlJaCotCU3lX3KYKYeZcpgpL/4xKi0JTeVGpSXh/8lhphxmymGmvPgylb9ZEm5Uvknlb3KYKYeZcpgpLz4sCT+ZSktCU2lJaCo3SfibHWbKYaYcZsqLh1R+kiQ0lW9S+UkOM+UwUw4z5cVDSWgq70hCU2lJeEcS/qQkfJLKTRKayhOHmXKYKYeZ8uLDktBUWhKayo1KS8KNyhNJaCotCU2lJaGptCTcqNwkoal80mGmHGbKYabEX3ggCe9QaUl4h0pLwjtUWhKayk0SblTekYQnVD7pMFMOM+UwU158mUpLQlN5RxJuVFoSWhKayicl4UalqbQk/EmHmXKYKYeZ8uIhlXeotCR8UhKayhNJeIdKS8InqbQkNJUnDjPlMFMOM+XFQ0loKjdJuFG5SUJTuUlCU2lJuFFpSWgqLQlNpSXhRuUmCU3lkw4z5TBTDjMl/sIXJaGptCR8kspNEm5UbpJwo3KThKbSkvAOlU86zJTDTDnMlBdfptKS0FRaEppKS0JTaUloKjcqT6jcJKGp/M0OM+UwUw4z5cVDSbhRuUlCU2lJaCpPqLQkNJWWhKbSkvCOJDyh0pLQVJ44zJTDTDnMlPgLP1gSmsoTSWgqLQk3Ku9IQlO5SUJT+aTDTDnMlMNMefFQEn4nlXckoancqNyotCTcJKGp3CThTzrMlMNMOcyUFx+m8klJuFFpSWgqN0loKi0JT6h8UxKayhOHmXKYKYeZ8uLLkvAOlXck4SYJNyotCTcqLQktCT/ZYaYcZsphprz44VRaEprKTRKaSktCS0JTuUlCU3kiCd90mCmHmXKYKS/+MSo3SbhJwo3KNyXhHSqfdJgph5lymCkvvkzld0rCO1RaEppKS0JTaUm4SUJT+ZscZsphphxmyosPS8LvlIR3qLQkvEPlCZUblZaEmyQ0lScOM+UwUw4zJf7CzH8OM+UwUw4z5TBTDjPlMFMOM+UwUw4z5TBTDjPlMFMOM+UwUw4z5X8J1ZsTrZa8BgAAAABJRU5ErkJggg==	2019-09-18 14:51:04.363994+07	12679	48227	1
52	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAAOVSURBVO3BQY5bSwIDwWRB979yjhd/wVUBwpNst4cR8Rdm/nOYKYeZcpgph5lymCmHmXKYKYeZcpgph5lymCmHmXKYKYeZcpgpLx5Kwu+k0pJwo3KThBuVloSmcpOE30nlicNMOcyUw0x58WEqn5SEG5WbJDSVG5UblSdUPikJn3SYKYeZcpgpL74sCe9Q+SSVJ5LQVFoSmso7kvAOlW86zJTDTDnMlBc/XBKeUGlJaCotCU3lX3KYKYeZcpgpL/4xKi0JTeVGpSXh/8lhphxmymGmvPgylb9ZEm5Uvknlb3KYKYeZcpgpLz4sCT+ZSktCU2lJaCo3SfibHWbKYaYcZsqLh1R+kiQ0lW9S+UkOM+UwUw4z5cVDSWgq70hCU2lJeEcS/qQkfJLKTRKayhOHmXKYKYeZ8uLDktBUWhKayo1KS8KNyhNJaCotCU2lJaGptCTcqNwkoal80mGmHGbKYabEX3ggCe9QaUl4h0pLwjtUWhKayk0SblTekYQnVD7pMFMOM+UwU158mUpLQlN5RxJuVFoSWhKayicl4UalqbQk/EmHmXKYKYeZ8uIhlXeotCR8UhKayhNJeIdKS8InqbQkNJUnDjPlMFMOM+XFQ0loKjdJuFG5SUJTuUlCU2lJuFFpSWgqLQlNpSXhRuUmCU3lkw4z5TBTDjMl/sIXJaGptCR8kspNEm5UbpJwo3KThKbSkvAOlU86zJTDTDnMlBdfptKS0FRaEppKS0JTaUloKjcqT6jcJKGp/M0OM+UwUw4z5cVDSbhRuUlCU2lJaCpPqLQkNJWWhKbSkvCOJDyh0pLQVJ44zJTDTDnMlPgLP1gSmsoTSWgqLQk3Ku9IQlO5SUJT+aTDTDnMlMNMefFQEn4nlXckoancqNyotCTcJKGp3CThTzrMlMNMOcyUFx+m8klJuFFpSWgqN0loKi0JT6h8UxKayhOHmXKYKYeZ8uLLkvAOlXck4SYJNyotCTcqLQktCT/ZYaYcZsphprz44VRaEprKTRKaSktCS0JTuUlCU3kiCd90mCmHmXKYKS/+MSo3SbhJwo3KNyXhHSqfdJgph5lymCkvvkzld0rCO1RaEppKS0JTaUm4SUJT+ZscZsphphxmyosPS8LvlIR3qLQkvEPlCZUblZaEmyQ0lScOM+UwUw4zJf7CzH8OM+UwUw4z5TBTDjPlMFMOM+UwUw4z5TBTDjPlMFMOM+UwUw4z5X8J1ZsTrZa8BgAAAABJRU5ErkJggg==	2019-09-18 14:54:10.958841+07	12679	48227	001
53	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAAOVSURBVO3BQY5bSwIDwWRB979yjhd/wVUBwpNst4cR8Rdm/nOYKYeZcpgph5lymCmHmXKYKYeZcpgph5lymCmHmXKYKYeZcpgpLx5Kwu+k0pJwo3KThBuVloSmcpOE30nlicNMOcyUw0x58WEqn5SEG5WbJDSVG5UblSdUPikJn3SYKYeZcpgpL74sCe9Q+SSVJ5LQVFoSmso7kvAOlW86zJTDTDnMlBc/XBKeUGlJaCotCU3lX3KYKYeZcpgpL/4xKi0JTeVGpSXh/8lhphxmymGmvPgylb9ZEm5Uvknlb3KYKYeZcpgpLz4sCT+ZSktCU2lJaCo3SfibHWbKYaYcZsqLh1R+kiQ0lW9S+UkOM+UwUw4z5cVDSWgq70hCU2lJeEcS/qQkfJLKTRKayhOHmXKYKYeZ8uLDktBUWhKayo1KS8KNyhNJaCotCU2lJaGptCTcqNwkoal80mGmHGbKYabEX3ggCe9QaUl4h0pLwjtUWhKayk0SblTekYQnVD7pMFMOM+UwU158mUpLQlN5RxJuVFoSWhKayicl4UalqbQk/EmHmXKYKYeZ8uIhlXeotCR8UhKayhNJeIdKS8InqbQkNJUnDjPlMFMOM+XFQ0loKjdJuFG5SUJTuUlCU2lJuFFpSWgqLQlNpSXhRuUmCU3lkw4z5TBTDjMl/sIXJaGptCR8kspNEm5UbpJwo3KThKbSkvAOlU86zJTDTDnMlBdfptKS0FRaEppKS0JTaUloKjcqT6jcJKGp/M0OM+UwUw4z5cVDSbhRuUlCU2lJaCpPqLQkNJWWhKbSkvCOJDyh0pLQVJ44zJTDTDnMlPgLP1gSmsoTSWgqLQk3Ku9IQlO5SUJT+aTDTDnMlMNMefFQEn4nlXckoancqNyotCTcJKGp3CThTzrMlMNMOcyUFx+m8klJuFFpSWgqN0loKi0JT6h8UxKayhOHmXKYKYeZ8uLLkvAOlXck4SYJNyotCTcqLQktCT/ZYaYcZsphprz44VRaEprKTRKaSktCS0JTuUlCU3kiCd90mCmHmXKYKS/+MSo3SbhJwo3KNyXhHSqfdJgph5lymCkvvkzld0rCO1RaEppKS0JTaUm4SUJT+ZscZsphphxmyosPS8LvlIR3qLQkvEPlCZUblZaEmyQ0lScOM+UwUw4zJf7CzH8OM+UwUw4z5TBTDjPlMFMOM+UwUw4z5TBTDjPlMFMOM+UwUw4z5X8J1ZsTrZa8BgAAAABJRU5ErkJggg==	2019-09-18 14:55:08.455886+07	12679	48227	001
59	001120	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAAOTSURBVO3BQY7cWgIDweSD7n/lHC/+grMRIKiq0TYYEf9g5j+HmXKYKYeZcpgph5lymCmHmXKYKYeZcpgph5lymCmHmXKYKYeZcvFSEn6Syp0kvKHSktBUnkjCT1J54zBTDjPlMFMuPkzlk5LwhkpLwhtJaCpPqHxSEj7pMFMOM+UwUy6+LAlPqDyRhKbSktBUWhLuqLQkfFISnlD5psNMOcyUw0y5mP+ThKZyJwlN5W92mCmHmXKYKRf/OJU7Ki0Jd1T+ZYeZcpgph5ly8WUqv0kS7qi0JNxReUPlNznMlMNMOcyUiw9Lwm+ShKbSkvCESktCU7mThN/sMFMOM+UwUy5eUvnNVFoSfpLK3+QwUw4z5TBTLl5KQlNpSfgklabSknBH5U4SmkpLwhNJ+CSVbzrMlMNMOcyUiy9TaUl4QqUl4QmVJ1RaEprKnSQ0lSeS0FRaEprKJx1mymGmHGZK/IMPSsITKi0Jb6h8UxKaSkvCHZWWhKbyRBKayhuHmXKYKYeZcvFhKp+k0pLQVFoS3lB5Q+UJlZaEpvKTDjPlMFMOM+XipSTcUWlJaCp3knAnCU2lJaGp3ElCU2kqLQlNpSXhCZWWhKbyTYeZcpgph5ly8cNUWhLuqDyRhKZyJwlNpSWhqTSVloSm8kQSmkpLQlP5pMNMOcyUw0yJf/BCEppKS8IdlTtJaCotCU2lJaGpvJGEpvJEEprKG0loKm8cZsphphxmysUvp3JH5Y7KnSQ0lSeS8ITKnSQ0lZ90mCmHmXKYKRc/TOWJJDSVO0loKk8koal8UhLuqLQkNJVvOsyUw0w5zJT4B3+xJDSVloSm8kQSmkpLQlN5Igl3VFoSmsonHWbKYaYcZsrFS0n4SSpN5Ykk3FFpKm8koak8kYSm0pLQVN44zJTDTDnMlIsPU/mkJNxJwh2VloSmcicJb6i8oXJH5ZMOM+UwUw4z5eLLkvCEyicl4Q2VloQ7SXhDpSXhCZU3DjPlMFMOM+XiH6PyRBLuqDSVJ5LwRBKaSkvCNx1mymGmHGbKxT8uCU2lqbQktCQ0lZaEOypPJOGOSkvCJx1mymGmHGbKxZepfJPKG0m4o9KS8EQS7qj8JoeZcpgph5ly8WFJ+ElJuKPyhEpLwh2VloSm0pLQknAnCT/pMFMOM+UwU+IfzPznMFMOM+UwUw4z5TBTDjPlMFMOM+UwUw4z5TBTDjPlMFMOM+UwU/4HE8+j/qC2TXEAAAAASUVORK5CYII=	2019-09-18 15:10:34.07843+07	12697	48604	001
54	001120	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAAOZSURBVO3BQY7kSAIDQWdA//+ybx/mwJMAQZk1XbM0i38w84/DTDnMlMNMOcyUw0w5zJTDTDnMlMNMOcyUw0w5zJTDTDnMlMNMuXgpCT9JpSXhCZU7SWgqLQlN5U4SfpLKG4eZcpgph5ly8WEqn5SEOyotCXeS0FSayh2VN1Q+KQmfdJgph5lymCkXX5aEJ1Q+SaUl4YkkNJWWhKbyRBKeUPmmw0w5zJTDTLn45ZLwhEpLwh2VloSm8l9ymCmHmXKYKRf/MSotCXdU7iTh/8lhphxmymGmXHyZyt9EpSXhjso3qfxNDjPlMFMOM+Xiw5Lwm6m0JDSVloSmcicJf7PDTDnMlMNMuXhJ5TdJQlP5JpXf5DBTDjPlMFMuXkpCU3kiCU2lJeGJJDSVloRvSsInqdxJQlN54zBTDjPlMFPiH7yQhCdU3kjCEypPJKGptCQ0lZaEptKScEflThKayicdZsphphxmysVLKt+UhKbSktBUWhLuqDSVJ5LQVO6otCTcScJPOsyUw0w5zJT4By8koam0JDSVN5LQVH5SEt5QuZOEJ1Q+6TBTDjPlMFMuXlJpSfikJDSVO0loKi0JTeVOEp5QaUn4JJWWhKbyxmGmHGbKYaZcvJSEptKS8EQSmsoTKi0JTaUl4Y5KS0JTaUloKi0Jd1TuJKGpfNJhphxmymGmxD/4oiQ8odKScEfliSTcUbmThE9SuZOEOyqfdJgph5lymCkXP0zlCZWWhE9SeUOlJaGpPJGEf9NhphxmymGmXLyUhDsqTyThjsoTSWgqLQlNpSWhqbQk3EnCJ6m0JDSVNw4z5TBTDjPl4iWVT1J5IglN5QmVloSm0pJwR+WJJDSVO0loKp90mCmHmXKYKRcvJeEnqfybVFoS7iShqdxJQlP5SYeZcpgph5ly8WEqn5SEOyotCU3lThKayp0kPKHyRhLuJKGpvHGYKYeZcpgpF1+WhCdUnkhCU7mThKbSknBHpSWhJeE3O8yUw0w5zJSLX06lJaGpNJWWhKbSktCS0FTuJKGpvJGEbzrMlMNMOcyUi/8zSbiThDsq35SEJ1Q+6TBTDjPlMFMuvkzlJ6m0JNxRaUloKi0JTaUloam0JDSVv8lhphxmymGmxD94IQk/SaUl4QmVloQ7Km8koak8kYQnVN44zJTDTDnMlPgHM/84zJTDTDnMlMNMOcyUw0w5zJTDTDnMlMNMOcyUw0w5zJTDTDnMlP8BDPmfDOcizgkAAAAASUVORK5CYII=	2019-09-18 14:57:34.640563+07	12680	48227	002
55	001120	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAAOpSURBVO3BQY5jBxYDweSD7n/lnF54wdUHBKkKdg8j4h/M/OOYKcdMOWbKMVOOmXLMlGOmHDPlmCnHTDlmyjFTjplyzJRjprz4UBJ+k8o7ktBUWhKaSktCU3lHEn6TyieOmXLMlGOmvPgylW9KwidUWhKaSkvCkyQ0lXeofFMSvumYKcdMOWbKix+WhHeovCMJTaUl4UkSmkpLQlP5piS8Q+UnHTPlmCnHTHnxl0nCE5WWhJaEptKS8ETlv+yYKcdMOWbKi7+cSkvCJ1T+ZsdMOWbKMVNe/DCV36TSktBUWhKaSkvCE5VPqPybHDPlmCnHTHnxZUn4m6m0JDSVJ0n4NztmyjFTjpkS/+A/LAlPVD6RhKbyNztmyjFTjpny4kNJaCotCd+k0lS+KQlNpSXhiUpLwjep/KRjphwz5ZgpL36YSktCU/lEEr5JpSWhqTxJQlN5RxKaSktCU/mmY6YcM+WYKS9+WBKayjuS0FSeqLQkNJV3qLQkNJUnSWgqLQlN5YlKS0JT+cQxU46ZcsyUF1+WhCdJeIdKS0JTaUl4koSm8k0q71BpSWgqv+mYKcdMOWbKiw+ptCQ0lSdJeJKEd6h8IglNpam0JDSVloR3qLQkNJWfdMyUY6YcM+XFh5LQVFoSnqi0JDSVdyThiUpLQlNpSWgqTaUloam8IwlNpSWhqXzTMVOOmXLMlPgHH0hCU2lJaCotCe9QeUcSmsonktBU3pGEpvKJJDSVTxwz5Zgpx0x58cNUnqi0JDSVT6g8SUJTeUcSmkpLQlN5koSm8puOmXLMlGOmvPhlSXii0pLQVN6RhKbyJAlN5R1JeJKEJyotCU3lJx0z5Zgpx0yJf/AfloQnKp9IQlNpSWgq70jCE5WWhKbyTcdMOWbKMVNefCgJv0mlqbQktCR8QuUTSWgq70hCU2lJaCqfOGbKMVOOmfLiy1S+KQlPkvAJlSdJ+ITKJ1SeqHzTMVOOmXLMlBc/LAnvUPkmlZaEd6i0JDxJwidUWhLeofKJY6YcM+WYKS/+MipPVFoSnqg0lXck4R1JaCotCT/pmCnHTDlmyov/cyotCS0JTaUl4YnKO5LwRKUl4ZuOmXLMlGOmvPhhKj9JpSWhqTxJwhOVloQnKi0JT1T+TY6ZcsyUY6a8+LIk/KYkNJWWhKbyRKUl4YlKS8I7kvAkCb/pmCnHTDlmSvyDmX8cM+WYKcdMOWbKMVOOmXLMlGOmHDPlmCnHTDlmyjFTjplyzJT/AWGRswr7/LEFAAAAAElFTkSuQmCC	2019-09-18 14:58:08.43659+07	12681	48227	003
56	001120	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAAOSSURBVO3BO45jixUEwawD7n/LqTFklJwLEGT3+6gi4h/M/NcxU46ZcsyUY6YcM+WYKcdMOWbKMVOOmXLMlGOmHDPlmCnHTHnxoST8JpV3JOGJypMkNJV3JOE3qXzimCnHTDlmyosvU/mmJHxCpSWhJeEdSWgq71D5piR80zFTjplyzJQXPywJ71B5RxLeofKOJDSVb0rCO1R+0jFTjplyzJQX8z+S0FRaEp6o/JMdM+WYKcdMefEvo9KS0JLQVN6h8m92zJRjphwz5cUPU/lNSXii8kSlJeGJyidU/k6OmXLMlGOmvPiyJPyVVFoSniShqTxRaUloKk+S8Hd2zJRjphwz5cWHVP7OVH6SyhOVf5Jjphwz5Zgp8Q8+kISm0pLwTSrvSMInVFoSnqi0JHyTyk86ZsoxU46Z8uLLkvBNKu9IwjtUniShqTxJQlN5RxKaSktCU/mmY6YcM+WYKS++TOVJEprKkyQ0lW9KQlNpKi0JTeVJEppKS0JTeaLSktBUPnHMlGOmHDPlxYdUWhLekYSm0lT+SVTeodKS0FR+0zFTjplyzJQXH0rCE5WWhKbSkvAOlScqLQlNpSWhqTSVloSm0pLwDpWWhKbyk46ZcsyUY6a8+DKVloSm8g6Vb1JpSWgqLQlNpam0JDSVdyShqbQkNJVvOmbKMVOOmRL/4ANJaCotCU9UniThm1Q+kYSm8o4kNJVPJKGpfOKYKcdMOWbKi79YEp6otCS8Q+VJEprKO5LQVFoSmsqTJDSV33TMlGOmHDPlxS9TeZKEloSm8iQJn0hCU3lHEp4k4YlKS0JT+UnHTDlmyjFT4h/8gyWhqXxTEppKS0JTeUcSnqi0JDSVbzpmyjFTjpny4kNJ+E0qTaUloam0JDxR+aYkNJV3JKGptCQ0lU8cM+WYKcdMefFlKt+UhCdJeJKEJypPVFoS3qHyCZUnKt90zJRjphwz5cUPS8I7VD6h0pLwm5LwCZWWhHeofOKYKcdMOWbKi385lSdJeKLSVN6RhHckoam0JPykY6YcM+WYKS/+z6m0JLQkNJWWhCcq70jCE5WWhG86ZsoxU46Z8uKHqfwklZaEpvIkCU9UWhKeqLQkPFH5OzlmyjFTjpny4suS8JuS0FQ+odKS8ETliUpLQkvCkyT8pmOmHDPlmCnxD2b+65gpx0w5ZsoxU46ZcsyUY6YcM+WYKcdMOWbKMVOOmXLMlGOm/AeYvKb1P27duQAAAABJRU5ErkJggg==	2019-09-18 15:04:07.981347+07	12682	48227	004
57	001120	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAAORSURBVO3BQY7cWgIDweRD3f/KOV78BVcCBKl67AYj4h/M/OcwUw4z5TBTDjPlMFMOM+UwUw4z5TBTDjPlMFMOM+UwUw4z5TBTPjyUhJ+kckcS7lBpSWgqdyThJ6k8cZgph5lymCkfXqbypiT8pCRcSUJTuUPlTUl402GmHGbKYaZ8+LIk3KFyRxKayh0qV5LQVN6UhDtUvukwUw4z5TBTPvwySbgjCVdUWhKuqPzLDjPlMFMOM+XDL6NyJQlPqPxmh5lymCmHmfLhy1T+n5LQVO5IwhWVJ1T+JoeZcpgph5ny4WVJ+JckoalcUWlJaCpXkvA3O8yUw0w5zJT4B/+wJFxReSIJTeU3O8yUw0w5zJQPDyWhqbQkvEmlqVxJQlNpSbii0pJwRaUl4U0q33SYKYeZcpgpH16WhDepXElCU2kqd6i0JDSVK0loKnckoam0JDSVNx1mymGmHGZK/IMHktBUWhLepHIlCU2lJaGp3JGEptKScEWlJaGp3JGEpvLEYaYcZsphpnz4YSotCU3lCZWWhJ+kcodKS0JT+UmHmXKYKYeZ8uHLVJ5IwhMqdyShqTSVloSm0pJwh0pLQlP5psNMOcyUw0z58LIkNJUrKi0JTaUl4U1JaCotCU2lqbQkNJU7ktBUWhKaypsOM+UwUw4zJf7BA0loKi0JTaUloam0JDSVloQ7VJ5IQlO5IwlN5YkkNJUnDjPlMFMOM+XDl6m0JDSVloSm8k1JaCp3JKGptCQ0lStJaCo/6TBTDjPlMFM+/DCVloSm0pJwh8oTSWgqdyThShKuqLQkNJVvOsyUw0w5zJT4B/+wJDSVloSmckcSmkpLQlO5IwlXVFoSmsqbDjPlMFMOM+XDQ0n4SSpN5Y4kXFF5UxKayh1JaCotCU3licNMOcyUw0z58DKVNyXhShKeULkjCXeoPKFyReVNh5lymCmHmfLhy5Jwh8oTKi0JT6i0JFxJwhMqLQl3qDxxmCmHmXKYKR9+OZUrSbii0lTuSMIdSWgqLQnfdJgph5lymCkffpkkXFFpKi0JLQlNpSXhisodSbii0pLwpsNMOcyUw0z58GUq36TyRBKuqLQkXFFpSbii8jc5zJTDTDnMlA8vS8JPSkJTeUKlJeGKSktCU2lJaEm4koSfdJgph5lymCnxD2b+c5gph5lymCmHmXKYKYeZcpgph5lymCmHmXKYKYeZcpgph5lymCn/A/0bogD/gCNwAAAAAElFTkSuQmCC	2019-09-18 15:04:58.127824+07	12683	48227	005
58	001120	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAAOTSURBVO3BQY7cWgIDweSD7n/lHC/+grMRIKiq0TYYEf9g5j+HmXKYKYeZcpgph5lymCmHmXKYKYeZcpgph5lymCmHmXKYKYeZcvFSEn6Syp0kvKHSktBUnkjCT1J54zBTDjPlMFMuPkzlk5LwhkpLwhtJaCpPqHxSEj7pMFMOM+UwUy6+LAlPqDyRhKbSktBUWhLuqLQkfFISnlD5psNMOcyUw0y5mP+ThKZyJwlN5W92mCmHmXKYKRf/OJU7Ki0Jd1T+ZYeZcpgph5ly8WUqv0kS7qi0JNxReUPlNznMlMNMOcyUiw9Lwm+ShKbSkvCESktCU7mThN/sMFMOM+UwUy5eUvnNVFoSfpLK3+QwUw4z5TBTLl5KQlNpSfgklabSknBH5U4SmkpLwhNJ+CSVbzrMlMNMOcyUiy9TaUl4QqUl4QmVJ1RaEprKnSQ0lSeS0FRaEprKJx1mymGmHGZK/IMPSsITKi0Jb6h8UxKaSkvCHZWWhKbyRBKayhuHmXKYKYeZcvFhKp+k0pLQVFoS3lB5Q+UJlZaEpvKTDjPlMFMOM+XipSTcUWlJaCp3knAnCU2lJaGp3ElCU2kqLQlNpSXhCZWWhKbyTYeZcpgph5ly8cNUWhLuqDyRhKZyJwlNpSWhqTSVloSm8kQSmkpLQlP5pMNMOcyUw0yJf/BCEppKS8IdlTtJaCotCU2lJaGpvJGEpvJEEprKG0loKm8cZsphphxmysUvp3JH5Y7KnSQ0lSeS8ITKnSQ0lZ90mCmHmXKYKRc/TOWJJDSVO0loKk8koal8UhLuqLQkNJVvOsyUw0w5zJT4B3+xJDSVloSm8kQSmkpLQlN5Igl3VFoSmsonHWbKYaYcZsrFS0n4SSpN5Ykk3FFpKm8koak8kYSm0pLQVN44zJTDTDnMlIsPU/mkJNxJwh2VloSmcicJb6i8oXJH5ZMOM+UwUw4z5eLLkvCEyicl4Q2VloQ7SXhDpSXhCZU3DjPlMFMOM+XiH6PyRBLuqDSVJ5LwRBKaSkvCNx1mymGmHGbKxT8uCU2lqbQktCQ0lZaEOypPJOGOSkvCJx1mymGmHGbKxZepfJPKG0m4o9KS8EQS7qj8JoeZcpgph5ly8WFJ+ElJuKPyhEpLwh2VloSm0pLQknAnCT/pMFMOM+UwU+IfzPznMFMOM+UwUw4z5TBTDjPlMFMOM+UwUw4z5TBTDjPlMFMOM+UwU/4HE8+j/qC2TXEAAAAASUVORK5CYII=	2019-09-18 15:09:17.196008+07	12697	48604	001
96	460016	data:image/png;base64,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	2019-10-28 14:56:47.333184+07	14803	48207	005
60	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAAOMSURBVO3BQY7kSAIDQWdA//+ybx/mwL0IEJRZU9OgWfyDmX8cZsphphxmymGmHGbKYaYcZsphphxmymGmHGbKYaYcZsphphxmysVLSfhJKneS8IZKS0JTeSIJP0nljcNMOcyUw0y5+DCVT0rCEyp3kvBGEprKEyqflIRPOsyUw0w5zJSLL0vCEypPJKGpfJJKS8InJeEJlW86zJTDTDnMlIv5P0loKneS0FT+yw4z5TBTDjPl4i+XhKbSkvCEyt/sMFMOM+UwUy6+TOXfpHJH5U4S7qi8ofKbHGbKYaYcZsrFhyXhN0lCU2lJaCp3VFoSmsqdJPxmh5lymCmHmXLxkspvkoQ7SfhJKv8lh5lymCmHmXLxUhKaSkvCJ6k0lTtJaCotCS0JTaUl4YkkfJLKNx1mymGmHGbKxYcl4Y5KS8IdlZaEb1JpSWgqd5LQVJ5IQlNpSWgqn3SYKYeZcpgpF1+m0pLQVO4koak8kYSWhCdUWhKayp0kNJWWhCdUWhKayhuHmXKYKYeZcvFhKndUWhKaSlNpSWgqT6h8k8oTKi0J/6bDTDnMlMNMufiyJNxRuZOEptKS0FSayhNJaCpNpSWhqbQkPKHSktBUvukwUw4z5TBTLj4sCZ+k0pLwRBKaSktCU2lJaCpNpSWhqTyRhKbSktBUPukwUw4z5TBT4h+8kISm0pLwhEpLQlNpSXhC5Y0kNJUnktBUWhKayp0kNJU3DjPlMFMOM+Xiy1RaEu4koal8UxKayhNJeELlNzvMlMNMOcyUi19GpSXhjkpLwhtJaCqflIQ7Ki0JTeWbDjPlMFMOMyX+wX9YEprKJyWhqbQkNJUnknBHpSWhqXzSYaYcZsphply8lISfpNJUWhLeUGkqbyShqbyh0pLQVN44zJTDTDnMlIsPU/mkJNxJwhsqd5Lwhso3qXzSYaYcZsphplx8WRKeUHlD5U4SnlBpSbiThDdUWhKeUHnjMFMOM+UwUy7+MkloKk2lJeGOSlN5IglPJKGptCR802GmHGbKYaZc/OWS0FSaSktCS0JTaUm4o/JEEu6otCR80mGmHGbKYaZcfJnKN6m8kYQ7Ki0JTyThjspvcpgph5lymCkXH5aEn5SEJ1TuqLQk3FFpSWgqLQktCXeS8JMOM+UwUw4zJf7BzD8OM+UwUw4z5TBTDjPlMFMOM+UwUw4z5TBTDjPlMFMOM+UwUw4z5X+jBpQUX4uSVAAAAABJRU5ErkJggg==	2019-09-18 15:14:58.911284+07	12697	48604	001
61	000000	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAAOMSURBVO3BQY7kSAIDQWdA//+ybx/mwL0IEJRZU9OgWfyDmX8cZsphphxmymGmHGbKYaYcZsphphxmymGmHGbKYaYcZsphphxmysVLSfhJKneS8IZKS0JTeSIJP0nljcNMOcyUw0y5+DCVT0rCEyp3kvBGEprKEyqflIRPOsyUw0w5zJSLL0vCEypPJKGpfJJKS8InJeEJlW86zJTDTDnMlIv5P0loKneS0FT+yw4z5TBTDjPl4i+XhKbSkvCEyt/sMFMOM+UwUy6+TOXfpHJH5U4S7qi8ofKbHGbKYaYcZsrFhyXhN0lCU2lJaCp3VFoSmsqdJPxmh5lymCmHmXLxkspvkoQ7SfhJKv8lh5lymCmHmXLxUhKaSkvCJ6k0lTtJaCotCS0JTaUl4YkkfJLKNx1mymGmHGbKxYcl4Y5KS8IdlZaEb1JpSWgqd5LQVJ5IQlNpSWgqn3SYKYeZcpgpF1+m0pLQVO4koak8kYSWhCdUWhKayp0kNJWWhCdUWhKayhuHmXKYKYeZcvFhKndUWhKaSlNpSWgqT6h8k8oTKi0J/6bDTDnMlMNMufiyJNxRuZOEptKS0FSayhNJaCpNpSWhqbQkPKHSktBUvukwUw4z5TBTLj4sCZ+k0pLwRBKaSktCU2lJaCpNpSWhqTyRhKbSktBUPukwUw4z5TBT4h+8kISm0pLwhEpLQlNpSXhC5Y0kNJUnktBUWhKayp0kNJU3DjPlMFMOM+Xiy1RaEu4koal8UxKayhNJeELlNzvMlMNMOcyUi19GpSXhjkpLwhtJaCqflIQ7Ki0JTeWbDjPlMFMOMyX+wX9YEprKJyWhqbQkNJUnknBHpSWhqXzSYaYcZsphply8lISfpNJUWhLeUGkqbyShqbyh0pLQVN44zJTDTDnMlIsPU/mkJNxJwhsqd5Lwhso3qXzSYaYcZsphplx8WRKeUHlD5U4SnlBpSbiThDdUWhKeUHnjMFMOM+UwUy7+MkloKk2lJeGOSlN5IglPJKGptCR802GmHGbKYaZc/OWS0FSaSktCS0JTaUm4o/JEEu6otCR80mGmHGbKYaZcfJnKN6m8kYQ7Ki0JTyThjspvcpgph5lymCkXH5aEn5SEJ1TuqLQk3FFpSWgqLQktCXeS8JMOM+UwUw4zJf7BzD8OM+UwUw4z5TBTDjPlMFMOM+UwUw4z5TBTDjPlMFMOM+UwUw4z5X+jBpQUX4uSVAAAAABJRU5ErkJggg==	2019-09-18 15:15:33.944082+07	12697	48604	001
62	000605	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAAOISURBVO3BO47kWBAEQY8E739l3xZGSGUfQJBV80GYxR9U/TJULUPVMlQtQ9UyVC1D1TJULUPVMlQtQ9UyVC1D1TJULUPVMlQtFw8l4ZtUtiTcoXKShE3lJAmbypaEb1J5YqhahqplqFouXqbypiQ8oXKShCdU7lB5UxLeNFQtQ9UyVC0XH5aEO1SeUNmS8KYknKjckYQ7VD5pqFqGqmWoWi7+cip3qJwkYUvCpvIvG6qWoWoZqpaLv1wSTlS2JNT/G6qWoWoZqpaLD1P5JJUnVE6ScJKETeUOlT/JULUMVctQtVy8LAnflIRNZUvCprIlYVP5pCT8yYaqZahahqol/uAfkoQ7VLYkbCpbEk5U/mZD1TJULUPVcvFQEjaVkyR8k8qWhC0Jm8odKlsSNpWTJGwqWxLuUHliqFqGqmWoWi4eUjlJwhMqJ0nYVL4pCb+TypuGqmWoWoaqJf7ggSRsKlsSTlS2JLxJZUvCpnKShBOVkyRsKidJ2FS2JJyoPDFULUPVMlQt8QdflIRN5Y4kbCpbEk5UtiRsKnck4UTliSTcofLEULUMVctQtcQffFASNpUtCZvKloQ7VLYkbCp3JGFTOUnCicoTSThReWKoWoaqZahaLh5KwqZyh8qJykkSTlROknCisiVhUzlR2ZJwh8qJypuGqmWoWoaq5eJlSdhUTpKwqWxJ2FTuSMKmsqlsSbgjCZvKicpJEk5UtiRsKk8MVctQtQxVy8XLVLYkPKHySUnYVLYkbConSThR2ZKwqWxJ2FQ+aahahqplqFouvkzljiRsKpvKloSTJJwk4SQJTyThiSR80lC1DFXLULVcPKRyovKEykkSnlA5ScIdKnck4Q6VTxqqlqFqGaqWi4eS8E0qJyp3JOEOlS0JJ0nYVE6ScJKEE5UnhqplqFqGquXiZSpvSsKbkrCpbEnYVJ5QuUPldxqqlqFqGaqWiw9Lwh0qf7IknCThk5JwovLEULUMVctQtVz8Y5KwqWwqWxJOknCHypaEE5UtCb/TULUMVctQtVz85VROknCisiVhUzlJwonKSRI2lZMkfNJQtQxVy1C1XHyYyjcl4Y4kPKFykoQTlZMkfNNQtQxVy1C1XLwsCd+UhG9KwonKpnJHEjaVkyS8aahahqplqFriD6p+GaqWoWoZqpahahmqlqFqGaqWoWoZqpahahmqlqFqGaqWoWoZqpb/AJx3hBvvIsLxAAAAAElFTkSuQmCC	2019-09-18 15:26:54.71214+07	12697	48604	001
63	000605	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAAOSSURBVO3BQa5bSQIDwcyC7n9ljheNBjdTwIOkb7vBCPMLM/84zJTDTDnMlMNMOcyUw0w5zJTDTDnMlMNMOcyUw0w5zJTDTDnMlBdvUvlJSWgqLQk3Ki0JTaUl4UalJaGp/KQkvOMwUw4z5TBTXnxYEj5J5R0qNyotCU8k4YkkfJLKJx1mymGmHGbKiy9TeSIJn5SEptKS0FRuktBUWhKeUHkiCd90mCmHmXKYKS/+ckloKj8pCf8lh5lymCmHmfLiL6fSknCjMv/fYaYcZsphprz4siR8UxKayhMqLQlN5UalJeGJJPxJDjPlMFMOM+XFh6n8JJWWhKbSktBUfpLKn+wwUw4z5TBTzC/Mv1RaEppKS8J/yWGmHGbKYaa8eJNKS8KNyk9KwhNJeIdKS8KNSktCU3kiCe84zJTDTDnMlBdvSkJTeSIJT6i0JNyo3CThHSq/UxI+6TBTDjPlMFPML/xBVJ5Iwo3KE0loKjdJuFFpSbhRaUloKjdJeMdhphxmymGmvHiTyk0S3pGEptJUbpLwjiTcqNwk4YkkNJWfdJgph5lymCnmF96g8kQSblSeSMKNSkvCEyotCTcqN0l4h8pNEt5xmCmHmXKYKS8+LAlNpancJOFGpancJOFG5SYJTaUl4SYJTeWJJNwk4ZMOM+UwUw4zxfzCG1RuktBUWhJuVD4pCTcqLQlN5R1JuFFpSbhRaUl4x2GmHGbKYaa8+LAkNJUblZskNJWWhBuVG5WWhKbSknCj0pJwo9KS0FRaEr7pMFMOM+UwU158WRKaSkvCjUpLQlNpSWhJaCo3KjcqT6h8kso3HWbKYaYcZsqLNyXhiSQ8kYR3qNwk4UbliSQ8ofJEEr7pMFMOM+UwU168SeUnJeFG5SYJTeWJJDSVG5WWhBuVG5WbJLzjMFMOM+UwU158WBI+SeWJJNyotCQ0lZaEdyThiST8ToeZcpgph5ny4stUnkjCJ6l8ksqNyjep3CThHYeZcpgph5ny4j8uCTcqNypPJKGp3CShqfxOh5lymCmHmfLiL5eEpvJEEppKS8KNyk0SblRaEm5UvukwUw4z5TBTXnxZEn5SEprKjco7ktBUWhKaSkvCjcpPOsyUw0w5zJQXH6byk1RaEr5J5SYJTaUl4UalJeFG5ZMOM+UwUw4zxfzCzD8OM+UwUw4z5TBTDjPlMFMOM+UwUw4z5TBTDjPlMFMOM+UwUw4z5X/JZYQtK7nnNAAAAABJRU5ErkJggg==	2019-09-18 15:28:41.62206+07	12679	48227	001
64	000605	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAAOgSURBVO3BQY5jCZYDQeeD7n9ln1z0gqsPCFJEVtXQLP7BzP8cM+WYKcdMOWbKMVOOmXLMlGOmHDPlmCnHTDlmyjFTjplyzJQXH0rCb1JpSXii8iQJT1RaEprKkyT8JpVPHDPlmCnHTHnxZSrflIQnKk+S0FSayjtUPqHyTUn4pmOmHDPlmCkvflgS3qHyiSR8UxKaSktCU3lHEt6h8pOOmXLMlGOmvPiXS0JTaUl4RxKaSktCU/kvOWbKMVOOmfLiPyYJT5LwRKUl4f+TY6YcM+WYKS9+mMrfpNKS0FRaEprKT1L5JzlmyjFTjpny4suS8DeptCQ0lZaEptKS0FRaEprKkyT8kx0z5Zgpx0x58SGVfzKVloTfpPJvcsyUY6YcM+XFh5LQVN6RhKbSkvCOJDSVptKS8E1J+CaVJ0loKp84ZsoxU46ZEv/gi5LwCZVPJOGbVFoSmkpLQlNpSXii8iQJTeWbjplyzJRjprz4UBLeofIkCU9UvknlE0loKk9UWhJaEv6mY6YcM+WYKS++TKUl4UkSmsqTJDSVd6j8pCQ8UWkqLQl/0zFTjplyzJQXX5aEJ0loKk+S8CQJPykJ71BpSfgmlZaEpvKJY6YcM+WYKS++TKUl4UkSmkpTaUloKk+S8CQJT1RaEppKS0JTaUl4h0pLQlP5pmOmHDPlmCkvPqTyROVJEp4koal8IglPVN6RhCdJeKLSkvA3HTPlmCnHTHnxy5LQVJ6otCQ0lZaEptKS0FQ+odKS0FQ+kYTfdMyUY6YcMyX+wQeS8A6VdyShqbQkNJV3JKGptCQ0lZaE36TSktBUPnHMlGOmHDPlxYdUfpLKT1JpSWgqLQlPVN6RhKbyJAlN5ZuOmXLMlGOmvPhQEn6TyjuS0FQ+odKS8CQJTeVJEv6mY6YcM+WYKS++TOWbkvBEpSWhqTxJQlN5koR3qPykJDSVTxwz5Zgpx0x58cOS8A6VdyThHUloKi0JT1RaEloS/s2OmXLMlGOmvPiXU2lJaEloKi0JTaUloSWhqTxJQlN5koSm0pLwk46ZcsyUY6a8+I9TaUl4koQnKj9JpSXhico3HTPlmCnHTHnxw1R+k8o7VFoSmkpLQlNpSWgqLQlNpSXhbzpmyjFTjpkS/+ADSfhNKi0J71BpSXii8okkNJV3JOEdKp84ZsoxU46ZEv9g5n+OmXLMlGOmHDPlmCnHTDlmyjFTjplyzJRjphwz5Zgpx0w5Zsr/AQ/8mCjKZKZVAAAAAElFTkSuQmCC	2019-09-18 15:30:03.554114+07	12680	48227	002
65	000605	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAAOPSURBVO3BQW7lVgADweaD7n/lziyy4EqAoG97nLAq/sHMvw4z5TBTDjPlMFMOM+UwUw4z5TBTDjPlMFMOM+UwUw4z5TBTDjPl4qUkfCeVloQnVFoSmsqdJDSVO0n4TipvHGbKYaYcZsrFh6l8UhLuqLQkvJGEOyotCU3ljsonJeGTDjPlMFMOM+XiiyXhCZWvlISm8kQSPikJT6h8pcNMOcyUw0y5+OWS8EYS7qjcUfkvOcyUw0w5zJSL/xmVJ5Lwf3KYKYeZcpgpF19M5TuptCQ8kYSmcicJTeUJlb/JYaYcZsphplx8WBJ+kyQ0lZaEpvJGEv5mh5lymCmHmXLxksrfTOWTkvCEym9ymCmHmXKYKRcvJaGpPJGEptKS8DdRaUloSfgklTtJaCpvHGbKYaYcZsrFSyotCXdUnlBpSfgklZaEptKS0FRaEppKS8IdlTtJaCqfdJgph5lymCkXLyWhqbQktCQ8kYQ7Kk8k4Y7KE0loKndUWhJaEn7SYaYcZsphplx8WBKayp0k3FF5IglN5Y7KJyWhqdxRaUn4SYeZcpgph5ly8c2S8EQSmkpLwp0kvJGEJ1RaEprKGyotCU3ljcNMOcyUw0y5+DCVOypPqLQkNJU3knBHpSWhqbQkNJWWhCdUWhKayicdZsphphxmysVLKneS8IRKS0JTaUloKneScEfliSQ0lSdUWhJ+0mGmHGbKYaZcfDOVloSWhKbyRhLuqLyhcicJTeWJJHynw0w5zJTDTLl4KQl3VFoSmsqdJNxReUKlJaGptCQ0lZaEJ5LwhkpLQlN54zBTDjPlMFPiH/xiSbij8kQSmkpLwh2VJ5LQVO4koal80mGmHGbKYaZcvJSE76RyR+UNlTsqLQl3ktBU7iThJx1mymGmHGbKxYepfFIS7qi8kYSm0pLwhspXSkJTeeMwUw4z5TBTLr5YEp5QeSIJTaUl4Y5KS8IdlZaEloTf7DBTDjPlMFMufjmVJ1RaEppKS0JLQlO5k4SmcicJTaUl4SsdZsphphxmysV/nEpLwp0k3FH5SiotCXdUPukwUw4z5TBTLr6Yyk9Kwh2VloSm0pLQVFoSmkpLQlNpSfhJh5lymCmHmXLxYUn4Tkm4o3InCU+oPJGEpnJHpSXhThKayhuHmXKYKYeZEv9g5l+HmXKYKYeZcpgph5lymCmHmXKYKYeZcpgph5lymCmHmXKYKYeZ8g/Pm4QzAPCVKQAAAABJRU5ErkJggg==	2019-09-18 15:31:42.521095+07	12471	48118	001
66	000605	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIQAAACECAYAAABRRIOnAAAAAklEQVR4AewaftIAAAOPSURBVO3BQW7lVgADweaD7n/lziyy4EqAoG97nLAq/sHMvw4z5TBTDjPlMFMOM+UwUw4z5TBTDjPlMFMOM+UwUw4z5TBTDjPl4qUkfCeVloQnVFoSmsqdJDSVO0n4TipvHGbKYaYcZsrFh6l8UhLuqLQkvJGEOyotCU3ljsonJeGTDjPlMFMOM+XiiyXhCZWvlISm8kQSPikJT6h8pcNMOcyUw0y5+OWS8EYS7qjcUfkvOcyUw0w5zJSL/xmVJ5Lwf3KYKYeZcpgpF19M5TuptCQ8kYSmcicJTeUJlb/JYaYcZsphplx8WBJ+kyQ0lZaEpvJGEv5mh5lymCmHmXLxksrfTOWTkvCEym9ymCmHmXKYKRcvJaGpPJGEptKS8DdRaUloSfgklTtJaCpvHGbKYaYcZsrFSyotCXdUnlBpSfgklZaEptKS0FRaEppKS8IdlTtJaCqfdJgph5lymCkXLyWhqbQktCQ8kYQ7Kk8k4Y7KE0loKndUWhJaEn7SYaYcZsphplx8WBKayp0k3FF5IglN5Y7KJyWhqdxRaUn4SYeZcpgph5ly8c2S8EQSmkpLwp0kvJGEJ1RaEprKGyotCU3ljcNMOcyUw0y5+DCVOypPqLQkNJU3knBHpSWhqbQkNJWWhCdUWhKayicdZsphphxmysVLKneS8IRKS0JTaUloKneScEfliSQ0lSdUWhJ+0mGmHGbKYaZcfDOVloSWhKbyRhLuqLyhcicJTeWJJHynw0w5zJTDTLl4KQl3VFoSmsqdJNxReUKlJaGptCQ0lZaEJ5LwhkpLQlN54zBTDjPlMFPiH/xiSbij8kQSmkpLwh2VJ5LQVO4koal80mGmHGbKYaZcvJSE76RyR+UNlTsqLQl3ktBU7iThJx1mymGmHGbKxYepfFIS7qi8kYSm0pLwhspXSkJTeeMwUw4z5TBTLr5YEp5QeSIJTaUl4Y5KS8IdlZaEloTf7DBTDjPlMFMufjmVJ1RaEppKS0JLQlO5k4SmcicJTaUl4SsdZsphphxmysV/nEpLwp0k3FH5SiotCXdUPukwUw4z5TBTLr6Yyk9Kwh2VloSm0pLQVFoSmkpLQlNpSfhJh5lymCmHmXLxYUn4Tkm4o3InCU+oPJGEpnJHpSXhThKayhuHmXKYKYeZEv9g5l+HmXKYKYeZcpgph5lymCmHmXKYKYeZcpgph5lymCmHmXKYKYeZ8g/Pm4QzAPCVKQAAAABJRU5ErkJggg==	2019-09-18 15:32:07.54582+07	12471	48118	001
67	001120	data:image/png;base64,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	2019-09-18 15:55:17.829661+07	12471	48118	001
68	000000	data:image/png;base64,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	2019-09-19 10:43:58.441902+07	12595	48216	007
69	000000	data:image/png;base64,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	2019-09-19 10:47:15.31889+07	12688	48502	001
70	000000	data:image/png;base64,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	2019-09-19 14:25:29.567278+07	12517	48205	003
71	000000	data:image/png;base64,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	2019-09-19 14:26:41.447324+07	12471	48118	001
72	000000	data:image/png;base64,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	2019-09-19 14:27:10.136432+07	12471	48118	001
73	000000	data:image/png;base64,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	2019-09-19 15:30:02.005019+07	12471	48118	001
74	460016	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAALQAAAC0CAYAAAA9zQYyAAAAAklEQVR4AewaftIAAAdTSURBVO3BQY4kR5IAQVVH/f/Lun0bu2wAgcxqkg4TsT9Y6xKHtS5yWOsih7UucljrIoe1LnJY6yKHtS5yWOsih7UucljrIoe1LnJY6yKHtS5yWOsih7Uu8sOHVP6mikllqphUpoonKlPFpPKkYlJ5UvGGylQxqUwVk8pU8UTlb6r4xGGtixzWushhrYv88GUV36TypGJSmSomlScVTyreqHiiMlU8qXhDZaqYVKaKJxXfpPJNh7UucljrIoe1LvLDL1N5o+KbVP4mlaliUnmi8qRiUpkqJpVJ5ZtU3qj4TYe1LnJY6yKHtS7yw3+cypOKN1TeqJgqPlExqbyhMlVMKlPFTQ5rXeSw1kUOa13kh/WoYlKZVKaKSWWqeKIyVUwq6/93WOsih7UucljrIj/8soq/qWJSmSomlaliUvkmlaliqnhSMalMFU8qvqni3+Sw1kUOa13ksNZFfvgylZtVTCpvVEwqU8WkMlW8oTJVTCpTxROVf7PDWhc5rHWRw1oXsT/4D1P5RMWk8qRiUvlExaQyVUwqU8X6n8NaFzmsdZHDWhexP/iAylTxhspUMal8omJS+UTFGyrfVPGGyj+p4onKVPGJw1oXOax1kcNaF/nhQxWTylQxqbxRMak8qXhS8YbKE5UnFZPKGxVvqLxR8QmVqeKJylTxTYe1LnJY6yKHtS7yw4dUpopPqDypmFQmlaniico3VUwqU8WkMlU8UXlS8URlUvmbKn7TYa2LHNa6yGGti/zwZSpTxRsVb1Q8UflExZOKSeWNikllqnhS8UTljYpvUnlS8U2HtS5yWOsih7Uu8sOHKiaVJxVPVN6oeFIxqUwVk8qk8qTiScWkMlU8UfmmijdUpopvUpkqPnFY6yKHtS5yWOsi9gcfUJkqJpWpYlKZKp6ovFHxTSqfqPiEyjdVTCpTxaTyRsWkMlV802GtixzWushhrYv88KGKSWWqeFIxqTypeEPljYo3Kp6oPFF5UvGbVKaKNyomlUllqvhNh7UucljrIoe1LvLDh1SmiicqU8WTim+q+JsqPqEyVXxC5YnKVDFVPKmYVJ6oTBWfOKx1kcNaFzmsdRH7gy9SeVIxqXyiYlJ5UjGpTBWTyhsVT1SmikllqniiMlU8UXlSMak8qZhU3qj4psNaFzmsdZHDWhf54V+m4jepTBWTylTxCZWpYlKZKiaVJxVPVJ5UTCpTxROVqWJS+ZsOa13ksNZFDmtdxP7gF6k8qXiiMlU8UXmjYlJ5o+ITKv9mFZPKJyp+02GtixzWushhrYvYH3xA5UnFGypTxROV31QxqfxNFZPKk4onKr+pYlJ5UvFNh7UucljrIoe1LvLDL1P5hMpU8aTim1SmiicqU8Wk8obKVPGGylQxqUwVk8pU8YmK33RY6yKHtS5yWOsi9gdfpPJNFU9UporfpDJVPFGZKp6ofKLiicpU8YbKk4onKlPFNx3WushhrYsc1rrIDx9SmSreUJkqJpVPqDyp+CaVqeITFZPKE5U3VKaKSeUNlX/SYa2LHNa6yGGti9gffJHKVDGpTBWTylTxCZUnFZPKk4pJ5Y2KSeVJxb+Jym+q+MRhrYsc1rrIYa2L/PAhlaniScWkMlVMKlPFpPJGxRsVk8pU8URlUpkqJpU3VKaKN1SmikllqphUPlHxTYe1LnJY6yKHtS7yw5epPKmYKp5UTCpTxRsqn6iYVJ5UPFGZKiaVJxWTyhsVk8pU8UbFP+mw1kUOa13ksNZFfvhQxROVSWWqeKIyVTxReVLxRGVSmSq+qWJS+ZtUpopJZap4Q2Wq+E2HtS5yWOsih7Uu8sO/XMVvUpkqJpUnFZPKGyqfUJkqJpWp4onKE5VvUpkqPnFY6yKHtS5yWOsiP3xI5RMqU8Wk8kbFGxWTylQxqUwVb6hMFZPKk4pvUvknVXzTYa2LHNa6yGGti9gf/IepPKl4ovKkYlL5RMUnVJ5UPFF5UvGGylQxqUwVv+mw1kUOa13ksNZFfviQyt9U8aRiUpkqpopJ5Y2KJypPVD5R8UbFpPJEZap4ojJV/E2HtS5yWOsih7Uu8sOXVXyTypOKSWWqeKLyRsWkMlVMFZPKGxWfUPlExSdUporfdFjrIoe1LnJY6yI//DKVNyreUJkqJpU3Kn5TxROVJypTxZOKJyqTyicqJpW/6bDWRQ5rXeSw1kV++I+reKPiicpU8aTiicpUMak8UXlDZaqYVKaKJypPKj6hMlV84rDWRQ5rXeSw1kV+uIzKVDGpTBVTxROVqWJSeaNiUvkmlScqU8WTim+q+KbDWhc5rHWRw1oX+eGXVfyTVH6TyhsqU8WTikllUpkqJpWp4o2KSeVJxROVqeKbDmtd5LDWRQ5rXeSHL1P5m1SeVEwqk8obFU9UpopJZVJ5o+JvUpkqvkllqvjEYa2LHNa6yGGti9gfrHWJw1oXOax1kcNaFzmsdZHDWhc5rHWRw1oXOax1kcNaFzmsdZHDWhc5rHWRw1oXOax1kcNaF/k/mInAeb0FWhIAAAAASUVORK5CYII=	2019-09-19 15:34:26.092741+07	12471	48118	001
75	460016	data:image/png;base64,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	2019-09-19 15:53:13.084868+07	12471	48118	001
76	460016	data:image/png;base64,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	2019-09-20 08:35:16.507454+07	12517	48205	003
77	460016	data:image/png;base64,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	2019-09-24 10:34:05.902079+07	12471	48118	001
78	460016	data:image/png;base64,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	2019-09-24 10:35:59.352022+07	12471	48118	001
79	460016	data:image/png;base64,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	2019-09-24 10:36:28.773757+07	12692	48506	001
80	460016	data:image/png;base64,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	2019-10-08 16:02:36.453248+07	12610	48216	022
81	460016	data:image/png;base64,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	2019-10-08 16:03:06.434247+07	12484	48201	013
82	460016	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOQAAADkCAYAAACIV4iNAAAAAklEQVR4AewaftIAAAwaSURBVO3BQW4sy7LgQDKh/W+ZfYY+CiBRJd34r93M/mGtdYWHtdY1HtZa13hYa13jYa11jYe11jUe1lrXeFhrXeNhrXWNh7XWNR7WWtd4WGtd42GtdY2HtdY1HtZa13hYa13jhw+p/KWKN1T+UsUbKlPFicpvqphUTireUDmpeENlqphU/lLFJx7WWtd4WGtd42GtdY0fvqzim1TeUDmpmFTeqHhDZaqYKiaVT1S8oTKpTBWTyqQyVUwqb6j8popvUvmmh7XWNR7WWtd4WGtd44dfpvJGxRsqU8Wk8omKN1Smijcq3lCZVKaKNyomlaliUplUpopJZap4Q+WbVN6o+E0Pa61rPKy1rvGw1rrGD/+fUZkqPqHyTSpvVLyhMlW8oTJVnKicqEwVb1T8L3lYa13jYa11jYe11jV++B+jMlVMKpPKVPGJiknlN6l8k8onVKaKN1Smiqnif9nDWusaD2utazysta7xwy+r+C+pTBVvqHyi4kRlqphUpoo3VN6oeENlqphUTiqmikllqvimips8rLWu8bDWusbDWusaP3yZyn+pYlI5UZkqTiomlROVqeKbVKaKk4pJZaqYVKaKT1RMKlPFGypTxYnKzR7WWtd4WGtd42GtdQ37h//DVE4q/pLKJyomlaniDZWpYlKZKt5QmSp+k8pU8b/kYa11jYe11jUe1lrXsH/4gMpUMal8U8WJyknFicpJxaQyVZyo3KRiUnmjYlI5qZhUpooTlZOKSeWbKn7Tw1rrGg9rrWs8rLWu8cOHKiaVk4pJ5aRiUnmjYlJ5o+KkYlKZKk4qTlSmiptV/KaKb6qYVKaKv/Sw1rrGw1rrGg9rrWvYP3xAZaqYVN6omFSmihOVqWJSeaNiUrlJxYnKScWk8kbFpHJScaLyTRWTym+q+MTDWusaD2utazysta5h//BFKicVn1CZKk5UpopJZao4UflNFX9J5TdVTCpTxTepfKLiRGWq+KaHtdY1HtZa13hYa13D/uEDKicVn1CZKk5UpopJZao4UflExaQyVZyovFExqUwVb6icVJyoTBWTylTxhspU8ZdUpopPPKy1rvGw1rrGw1rrGj/8MZU3KiaVqeKbVN6oeKPiRGWqmFTeqDhRmSq+qeKk4g2VqeJE5aRiUpkqJpWp4pse1lrXeFhrXeNhrXUN+4eLqXxTxYnKGxUnKicVb6h8U8WkMlV8QmWqOFF5o2JSmSomlU9UTCpTxSce1lrXeFhrXeNhrXWNH75MZaqYVN6omFROKiaVSWWqOKmYVE5Upoo3VKaKqeJEZaqYVN5QeaNiqphUpoqpYlL5TRVvqPymh7XWNR7WWtd4WGtdw/7hD6l8omJSeaNiUpkqJpWp4g2Vk4pPqHyi4kRlqviEyicqJpWTikllqviEylTxiYe11jUe1lrXeFhrXeOHD6mcVJxUTCpTxRsVb1RMKlPFico3qUwVb1S8oTJVnKhMFb+pYlKZKiaVSWWqmFTeqJgqvulhrXWNh7XWNR7WWtewf/iAylQxqUwVJypvVEwqU8Wk8omKT6hMFScqU8UbKlPFicpUcaIyVXyTylTxCZWTihOVk4pPPKy1rvGw1rrGw1rrGj98qGJSeUNlqjhR+U0VJypvVHyi4hMVJypTxSdUpoo3VN5QmSomlTdUpoq/9LDWusbDWusaD2uta/zwx1TeUJkqPlExqUwqn6g4qZhUflPFpDJVTCpvVJyovFExqXxTxRsqf+lhrXWNh7XWNR7WWtf44UMqU8WkclIxqUwV36QyVfwllaliUpkqTlSmijdUpopJ5UTlpGJSeaNiUpkq3lCZKiaVNyq+6WGtdY2HtdY1HtZa17B/+IDKVDGp/KWKSeUTFd+kclIxqfymijdUTiomlW+qmFR+U8WkclLxiYe11jUe1lrXeFhrXeOHL1M5qZhUpoo3VCaVqWJSmSr+UsUnKt5QmSomlZOKqWJS+UTFGyonFW+oTBX/pYe11jUe1lrXeFhrXeOHX1bxCZWp4g2VqWJSOal4Q2WqOFH5hMpUcaIyVUwqJypTxaRyUjGpTBXfpDJVnKj8lx7WWtd4WGtd42GtdY0fPlQxqXxTxRsVk8pJxSdUpopJ5aTiROWk4o2KN1SmipOKm1S8UTGpnFR808Na6xoPa61rPKy1rvHDZVS+qeJE5aTiJirfpDJVnKhMFZPKScWJyidU/pLKVPGJh7XWNR7WWtd4WGtdw/7hi1TeqJhUpopJ5RMVk8obFd+kclLxhspUcaJyUnGi8omKE5Wp4kRlqvgmlanimx7WWtd4WGtd42GtdQ37hw+oTBXfpPJGxaTyiYpJZar4SyqfqDhReaPiEypTxYnKScWk8psqvulhrXWNh7XWNR7WWtewf/hFKlPFpDJV/CaVqeJEZaqYVKaKE5VPVEwqb1S8ofJGxV9SmSomlaniDZWTim96WGtd42GtdY2HtdY1fvhlFZ9QmSpOVP5SxRsVk8pUMalMKm9UvKEyVUwqb6i8UTGp3KRiUpkqPvGw1rrGw1rrGg9rrWv88CGVqWJSmSqmipOK36TyhspU8YbKJyomlaliUpkqJpWp4qRiUvlExaQyVbyhMlVMKlPFScWk8pse1lrXeFhrXeNhrXWNHz5U8ZtUvqniDZWpYlKZKiaV31QxqUwVk8pUcaJyUvEJlTdUTireUPlExTc9rLWu8bDWusbDWusaP3xI5aTiRGWqmComlaliUpkq3lB5o2JSeaPipGJS+b+kYlKZKiaVNypOVKaKE5WpYlL5TQ9rrWs8rLWu8bDWusYPH6o4UZkqpooTlW9SmSqmihOVk4oTlROVNyq+SWWqmFROVE4qJpWpYlI5UZkqvknlRGWq+MTDWusaD2utazysta7xwy+rOFGZKqaKSeUNlaniRGWqmCpOVD5R8QmVk4pJ5TdVnFScVHyiYlKZKk4qJpWp4pse1lrXeFhrXeNhrXWNHz6kMlVMKicVJypvVJyoTBUnKicVU8UbKlPFicpUcVIxqUwVk8pvUnmjYlKZKk5UpopJ5URlqphUpopPPKy1rvGw1rrGw1rrGj/8sooTlZOKN1SmiqnijYpvUpkqJpWTikllqphUPqHymyo+oXJSMalMFZPKVHFS8U0Pa61rPKy1rvGw1rqG/cMXqUwVb6icVEwqJxWTyicqJpWTikllqnhDZaqYVKaKSeWNikllqjhRmSpOVP5SxRsqJxWfeFhrXeNhrXWNh7XWNX74ZSonFVPFico3VUwqU8VJxV+qmFSmikllqphUpoo3VN5QmSqmir+kMlW8UfFND2utazysta7xsNa6hv3DB1TeqHhD5aRiUpkqJpWp4kRlqphUTipOVP5LFZPKGxWfUDmpmFT+SxW/6WGtdY2HtdY1HtZa1/jhQxW/qeJE5UTlN1W8oTJVTConFW+ofFPFb6r4RMUbKicVk8pU8U0Pa61rPKy1rvGw1rrGDx9S+UsVU8UbKm9UTCpTxX9JZao4qTipOFGZKk5UpooTlZOKSeVEZao4qZhUpopJZar4xMNa6xoPa61rPKy1rvHDl1V8k8qJyhsVJypTxVQxqZxUnKh8ouINlU9UTCpTxVQxqUwVk8pU8YmKT1ScVHzTw1rrGg9rrWs8rLWu8cMvU3mj4hMVk8qkMlVMFScqU8Wk8kbFicqk8omKN1ROKt6omFSmikllqjhR+YTKGxXf9LDWusbDWusaD2uta/zwP67iROWkYqqYVE5UpooTlZOKE5UTlaniEypTxRsVk8pU8UbFpPJNFZPKVPGJh7XWNR7WWtd4WGtd44f/MSonFScVk8pUMVVMKicqU8UbKicVk8pUcaIyVZxUnKi8UTGpnFS8UfFNFd/0sNa6xsNa6xoPa61r/PDLKn5TxYnKpDJVTCpTxYnKVDGpTBUnFScqU8Wk8obKVDGpTBWTylTxRsWk8pdUpoo3VKaKTzysta7xsNa6xsNa6xr2Dx9Q+UsVk8pUcaLyRsUbKp+oeENlqjhRmSreUJkq3lA5qZhUTiomlaliUvlNFZ94WGtd42GtdY2HtdY17B/WWld4WGtd42GtdY2HtdY1HtZa13hYa13jYa11jYe11jUe1lrXeFhrXeNhrXWNh7XWNR7WWtd4WGtd42GtdY2HtdY1/h+kSMaUocN0SQAAAABJRU5ErkJggg==	2019-10-08 16:03:40.403971+07	12538	48207	007
83	460016	data:image/png;base64,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xVRxovJGxYnKVDGp/CWVqeKk4qTiRGWqOFGZKk5UTiomlROVqeKkYlKZKiaVqeITD2utazysta7xsNa6xg9fVvFNKicqv0llqphUPqHyiYo3VD5RMalMFVPFpDJVTCpTxScqPlFxUvFND2utazysta7xsNa6xg+/TOWNim+q+E0Vb6hMFScqk8onKt5QOal4o2JSmSomlaniROUTKm9UfNPDWusaD2utazysta7xw/+YiknlpOKk4hMqU8WJyknFicqJylTxCZWp4o2KSWWqeKNiUvmmikllqvjEw1rrGg9rrWs8rLWu8cP/GJU3VKaKSeWkYlI5UZkq3lA5qZhUpooTlanipOJE5Y2KSeWk4o2Kb6r4poe11jUe1lrXeFhrXeOHX1bxmypOVN5QmSomlUllqphUpoqTihOVqWJSeUNlqphUpopJZap4o2JSOan4JpWp4g2VqeITD2utazysta7xsNa6hv3DB1T+UsWkMlWcqLxR8YbKJyreUJkqTlSmijdUpoo3VE4qJpWTikllqphUflPFJx7WWtd4WGtd42GtdQ37h7XWFR7WWtd4WGtd42GtdY2HtdY1HtZa13hYa13jYa11jYe11jUe1lrXeFhrXeNhrXWNh7XWNR7WWtd4WGtd42GtdY3/A7Ji7ooKqE3+AAAAAElFTkSuQmCC	2019-10-08 16:04:26.017321+07	12660	48223	011
\.


--
-- Data for Name: tbl_recommend_template; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_recommend_template (id, column_id, column_name, is_check) FROM stdin;
1	kensyuu_category	研修カテゴリ	f
2	shukankikan	主管組織	f
3	taishosha	対象者／レベル	f
4	tema_category	テーマカテゴリ	f
5	skill_list	スキルカテゴリ	t
6	taishosha_level	対象者	f
\.


--
-- Data for Name: tbl_setting; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_setting (setting_id, header_color, header_menu_icon_color, header_title_font_color, header_info_font_color, footer_color, footer_font_color, saving_search_time, saving_day_send_mail) FROM stdin;
1	#f5f5f5	#000000	#000000	#000000	#f5f5f5	#000000	1	4
2	#f5f5f5	#000000	#000000	#000000	#f5f5f5	#000000	1	4
\.


--
-- Data for Name: tbl_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_tags (id_tag, tag_name, id_tag_father, created_at, created_by, updated_at, updated_by, del_fg, count_tag) FROM stdin;
1	Angular	\N	2020-03-10 15:35:24.521661+07	001120	\N	\N	f	0
9	Angular_044	1	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
40	ABC	1	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
4	Angular_03	1	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
2	AI	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	t	0
3	Machine	2	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
5	AI	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
8	Deep Learning	5	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
7	Machine Learning	5	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
6	C#	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
22	ASP.Net	6	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
44	Entity Framework	6	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
36	MongoDB	6	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
21	.net  Core	6	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
10	Microsoft	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
13	Word	10	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
12	Power Point	10	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
11	Excel	10	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
51	Access	10	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
14	Mobile App	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
16	Android	14	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
15	Ios	14	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
17	Microsoft	14	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
18	Linux	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
19	CentOS	18	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
20	Python	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
47	Python 1	20	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
24	Unix	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
49	Unix 2	24	2020-03-10 15:35:38.89714+07	\N	\N	\N	t	0
48	Unix 1	24	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
25	Java	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
26	PHP	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
27	NodeJS	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
28	IoT	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
29	React	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
30	React Native	29	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
31	HardWare	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
32	Mainboard	31	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
38	Chip	31	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
33	Google	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
34	Drive	33	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
35	OS	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
66	Windows	35	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
37	Javascript	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
39	Jquery	37	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
41	Chromium	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
43	Chrome	41	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
42	Edge	41	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
45	IDE	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
46	Visual Studio Code	45	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
52	Videos	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
55	Doc 1	52	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
54	Cube System Vietnam	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
56	Books	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
53	C++ Tutorial	56	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
57	Videos	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
61	HTML Tutorial	57	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
63	Java Tutorial	57	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
59	NodeJS Tutorial	57	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
60	ReactJS Tutorial	57	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
58	Angular Tutorial	57	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
62	C# Tutorial	57	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
64	Accessories	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
65	Applications	\N	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
67	Katalon	65	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
68	ChromeSetup	65	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	0
69	Test Space	\N	2020-03-10 15:39:58.784765+07	001120	\N	\N	f	0
70	Test Space Child	69	2020-03-10 15:39:58.785681+07	001120	\N	\N	f	0
23	MVC	6	2020-03-10 15:35:38.89714+07	\N	\N	\N	f	2
\.


--
-- Data for Name: tbl_temp; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_temp (count_shain, count_kensyuu, skill_name) FROM stdin;
694	779	HM
54	65	OA
482	1083	TC
534	639	MG
\.


--
-- Data for Name: tbl_tsuuchi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_tsuuchi (tsuuchi_id, shain_cd, moushikomi_id, tsuuchi_naiyou, tsuuchi_tourokubi) FROM stdin;
1	290011	1	中途社員研修 に申込をしました。	2018-08-20
2	290011	1	あなたは 岸菜　圭一郎さんの ステータスを 開始待ちに変更しました。	2018-08-20
3	290011	1	中途社員研修は 開始待ちのステータスが岸菜　圭一郎さんに変更されました。	2018-08-20
4	290011	1	中途社員研修は 承認済みのステータスが岸菜　圭一郎さんに変更されました。	2018-08-20
5	290011	1	あなたは 岸菜　圭一郎さんの ステータスを 承認済みに変更しました。	2018-08-20
6	290011	1	あなたは 岸菜　圭一郎さんの ステータスを 開始待ちに変更しました。	2018-08-20
7	290011	1	中途社員研修は 開始待ちのステータスが岸菜　圭一郎さんに変更されました。	2018-08-20
8	290011	2	Microsoft Azure入門 (UCV42L)  に申込をしました。	2018-08-20
9	290011	3	Microsoft Azure入門 (UCV42L)  に申込をしました。	2018-08-20
10	290011	4	Microsoft Azure入門 (UCV42L)  に申込をしました。	2018-08-20
11	290011	4	Microsoft Azure入門 (UCV42L) は アンケート回答待ちのステータスが岸菜　圭一郎さんに変更されました。	2018-08-20
12	290011	4	あなたは 岸菜　圭一郎さんの ステータスを アンケート回答待ちに変更しました。	2018-08-20
13	290011	1	中途社員研修は 完了のステータスが岸菜　圭一郎さんに変更されました。	2018-08-20
14	290011	1	あなたは 岸菜　圭一郎さんの ステータスを 完了に変更しました。	2018-08-20
15	290011	4	Microsoft Azure入門 (UCV42L) は アンケート回答待ちのステータスが岸菜　圭一郎さんに変更されました。	2018-08-20
16	290011	4	あなたは 岸菜　圭一郎さんの ステータスを アンケート回答待ちに変更しました。	2018-08-20
17	290011	5	マネージャ研修 に申込をしました。	2018-08-20
18	290011	5	あなたは 岸菜　圭一郎さんの ステータスを アンケート回答待ちに変更しました。	2018-08-20
19	290011	5	マネージャ研修は アンケート回答待ちのステータスが岸菜　圭一郎さんに変更されました。	2018-08-20
20	290011	6	新任管理職研修 に申込をしました。	2018-08-20
21	280019	7	事例から学ぶ　アジャイル開発のプロジェクトマネジメント(UBS79L) に申込をしました。	2018-08-21
22	280019	7	あなたは 長谷　真紀さんの ステータスを 承認済みに変更しました。	2018-08-21
23	280019	7	事例から学ぶ　アジャイル開発のプロジェクトマネジメント(UBS79L)は 承認済みのステータスが長谷　真紀さんに変更されました。	2018-08-21
24	280019	7	事例から学ぶ　アジャイル開発のプロジェクトマネジメント(UBS79L)は 研修先申込中のステータスが長谷　真紀さんに変更されました。	2018-08-21
25	280019	7	あなたは 長谷　真紀さんの ステータスを 研修先申込中に変更しました。	2018-08-21
26	290011	5	マネージャ研修 をキャンセルしました。	2018-08-22
27	290011	8	マネージャ研修 に申込をしました。	2018-08-22
28	160035	9	新任JP-B研修 に申込をしました。	2018-08-22
29	430050	10	Excel VBA　による部門業務システムの構築（UUL79L） に申込をしました。	2018-08-22
30	280019	11	新人フォローアップ研修 に申込をしました。	2018-08-22
31	280019	12	新任JP-B研修 に申込をしました。	2018-08-22
32	430050	10	あなたは 秋山　美也子さんの ステータスを 研修参加申請中に変更しました。	2018-08-22
33	430050	10	Excel VBA　による部門業務システムの構築（UUL79L）は 研修参加申請中のステータスが秋山　美也子さんに変更されました。	2018-08-22
34	430050	10	Excel VBA　による部門業務システムの構築（UUL79L）は 経費精算待ちのステータスが秋山　美也子さんに変更されました。	2018-08-22
35	430050	10	あなたは 秋山　美也子さんの ステータスを 経費精算待ちに変更しました。	2018-08-22
36	160035	13	ビジョナリー・ウーマン研修 に申込をしました。	2018-08-22
37	280019	13	あなたは 丹野　透さんの ステータスを キャンセルに変更しました。	2018-08-22
38	160035	13	ビジョナリー・ウーマン研修は キャンセルのステータスが長谷　真紀さんに変更されました。	2018-08-22
39	430050	11	あなたは 長谷　真紀さんの ステータスを 研修先申込中に変更しました。	2018-08-22
40	280019	11	新人フォローアップ研修は 研修先申込中のステータスが秋山　美也子さんに変更されました。	2018-08-22
41	290011	14	<One set with 2 classes>\nシェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L） に申込をしました。	2018-08-23
42	290011	8	あなたは 岸菜　圭一郎さんの ステータスを 研修参加申請中に変更しました。	2018-08-23
43	290011	8	マネージャ研修は 研修参加申請中のステータスが岸菜　圭一郎さんに変更されました。	2018-08-23
44	290011	8	マネージャ研修は 研修参加申請中のステータスが岸菜　圭一郎さんに変更されました。	2018-08-23
45	290011	8	あなたは 岸菜　圭一郎さんの ステータスを 研修参加申請中に変更しました。	2018-08-23
46	290011	4	あなたは$Microsoft Azure入門 (UCV42L) の調査を完成しました。	2018-08-23
47	290011	4	あなたは 岸菜　圭一郎さんの ステータスを アンケート回答待ちに変更しました。	2018-08-23
48	290011	4	Microsoft Azure入門 (UCV42L) は アンケート回答待ちのステータスが岸菜　圭一郎さんに変更されました。	2018-08-23
49	290011	4	????Microsoft Azure入門 (UCV42L) ???????????	2018-08-24
50	290011	4	あなたは 岸菜　圭一郎さんの ステータスを アンケート回答待ちに変更しました。	2018-08-24
51	290011	4	Microsoft Azure入門 (UCV42L) は アンケート回答待ちのステータスが岸菜　圭一郎さんに変更されました。	2018-08-24
52	290011	4	????Microsoft Azure入門 (UCV42L) ???????????	2018-08-24
53	290011	4	あなたは 岸菜　圭一郎さんの ステータスを アンケート回答待ちに変更しました。	2018-08-24
54	290011	4	Microsoft Azure入門 (UCV42L) は アンケート回答待ちのステータスが岸菜　圭一郎さんに変更されました。	2018-08-24
55	290011	4	あなたはMicrosoft Azure入門 (UCV42L) の調査を完成しました。	2018-08-24
56	290011	15	テスト品質管理　【実践】 に申込をしました。	2018-08-27
58	290011	4	あなたは 岸菜　圭一郎さんの ステータスを アンケート回答待ちに変更しました。	2018-08-28
57	290011	4	Microsoft Azure入門 (UCV42L) は アンケート回答待ちのステータスが岸菜　圭一郎さんに変更されました。	2018-08-28
59	290011	4	あなたはMicrosoft Azure入門 (UCV42L) のアンケートを完成しました。	2018-08-28
60	430050	16	プロジェクトマネジメントの技法 (UAQ41L)  に申込をしました。	2018-08-29
61	430050	16	プロジェクトマネジメントの技法 (UAQ41L)  をキャンセルしました。	2018-08-29
62	430050	17	プロジェクトマネジメントの技法 (UAQ41L)  に申込をしました。	2018-08-29
63	430050	18	基礎から学ぶ！Excelマクロ機能による業務の自動化 (UUF09L) に申込をしました。	2018-08-29
64	140020	19	あなたは秋山　美也子さんに新任管理職研修が代替登録されました。	2018-08-29
65	430050	19	あなたは岡本　崇司さんの代わりに、新任管理職研修 を登録しました。	2018-08-29
66	280019	12	あなたは 長谷　真紀さんの ステータスを 開始待ちに変更しました。	2018-08-29
67	280019	12	新任JP-B研修は 開始待ちのステータスが長谷　真紀さんに変更されました。	2018-08-29
68	430050	14	あなたは 岸菜　圭一郎さんの ステータスを キャンセルに変更しました。	2018-08-29
69	290011	14	<One set with 2 classes>\nシェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）は キャンセルのステータスが秋山　美也子さんに変更されました。	2018-08-29
70	430050	18	あなたは 秋山　美也子さんの ステータスを 開始待ちに変更しました。	2018-08-29
71	430050	18	基礎から学ぶ！Excelマクロ機能による業務の自動化 (UUF09L)は 開始待ちのステータスが秋山　美也子さんに変更されました。	2018-08-29
72	430050	10	あなたは 秋山　美也子さんの ステータスを 完了に変更しました。	2018-08-29
73	430050	10	Excel VBA　による部門業務システムの構築（UUL79L）は 完了のステータスが秋山　美也子さんに変更されました。	2018-08-29
74	430050	20	PJリーダのための戦略的交渉術 ～交渉戦略の立案と実践スキル～(UZE88L)  に申込をしました。	2018-08-29
75	430050	21	組織を強くする問題解決の技術(BS-007) に申込をしました。	2018-08-29
76	430050	21	組織を強くする問題解決の技術(BS-007)は 研修先申込中のステータスが秋山　美也子さんに変更されました。	2018-08-29
77	430050	21	あなたは 秋山　美也子さんの ステータスを 研修先申込中に変更しました。	2018-08-29
78	430050	17	あなたは 秋山　美也子さんの ステータスを 経費精算待ちに変更しました。	2018-08-29
79	430050	17	プロジェクトマネジメントの技法 (UAQ41L) は 経費精算待ちのステータスが秋山　美也子さんに変更されました。	2018-08-29
80	430050	22	作業プランニング／タイムマネジメント（BS-001） に申込をしました。	2018-08-29
81	430050	22	作業プランニング／タイムマネジメント（BS-001）は アンケート回答待ちのステータスが秋山　美也子さんに変更されました。	2018-08-29
82	430050	22	あなたは 秋山　美也子さんの ステータスを アンケート回答待ちに変更しました。	2018-08-29
83	430050	23	あなたは井手　健二さんの代わりに、ビジネスコミュニケーション 【advance】（BS-004） を登録しました。	2018-08-29
84	290001	23	あなたは秋山　美也子さんにビジネスコミュニケーション 【advance】（BS-004）が代替登録されました。	2018-08-29
85	290001	23	あなたは秋山　美也子さんにビジネスコミュニケーション 【advance】（BS-004）がキャンセルされました。	2018-08-29
86	430050	23	あなたは井手　健二さんの代わりに、ビジネスコミュニケーション 【advance】（BS-004） をキャンセルしました。	2018-08-29
87	430050	24	ビジネスコミュニケーション 【advance】（BS-004） に申込をしました。	2018-08-29
88	430050	24	ビジネスコミュニケーション 【advance】（BS-004） をキャンセルしました。	2018-08-29
89	430050	18	基礎から学ぶ！Excelマクロ機能による業務の自動化 (UUF09L) をキャンセルしました。	2018-08-29
90	430050	25	基礎から学ぶ！Excelマクロ機能による業務の自動化 (UUF09L) に申込をしました。	2018-08-29
91	430050	25	基礎から学ぶ！Excelマクロ機能による業務の自動化 (UUF09L) をキャンセルしました。	2018-08-29
92	430050	26	基礎から学ぶ！Excelマクロ機能による業務の自動化 (UUF09L) に申込をしました。	2018-08-29
93	430050	27	基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L) に申込をしました。	2018-08-29
94	430050	27	基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L) をキャンセルしました。	2018-08-29
95	430050	27	基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L) をキャンセルしました。	2018-08-29
96	430050	28	基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L) に申込をしました。	2018-08-29
97	430050	29	Androidアプリ開発－WebAPI、非同期処理、サービス－ (UFN51L) に申込をしました。	2018-08-29
98	280019	29	あなたは秋山　美也子さんの代わりに、Androidアプリ開発－WebAPI、非同期処理、サービス－ (UFN51L) をキャンセルしました。	2018-08-29
99	430050	29	あなたは長谷　真紀さんにAndroidアプリ開発－WebAPI、非同期処理、サービス－ (UFN51L)がキャンセルされました。	2018-08-29
100	280019	30	テスト品質管理　【実践】 に申込をしました。	2018-08-30
101	280019	30	テスト品質管理　【実践】は 開始待ちのステータスが長谷　真紀さんに変更されました。	2018-08-30
102	280019	30	あなたは 長谷　真紀さんの ステータスを 開始待ちに変更しました。	2018-08-30
104	280019	30	テスト品質管理　【実践】は アンケート回答待ちのステータスが長谷　真紀さんに変更されました。	2018-08-30
103	280019	30	あなたは 長谷　真紀さんの ステータスを アンケート回答待ちに変更しました。	2018-08-30
105	280019	31	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2018-08-30
106	280019	32	プロジェクトマネジメントの技法 (UAQ41L)  に申込をしました。	2018-08-30
107	280019	32	あなたは 長谷　真紀さんの ステータスを 経費精算待ちに変更しました。	2018-08-30
108	280019	32	プロジェクトマネジメントの技法 (UAQ41L) は 経費精算待ちのステータスが長谷　真紀さんに変更されました。	2018-08-30
109	280019	32	プロジェクトマネジメントの技法 (UAQ41L) は キャンセル依頼中のステータスが長谷　真紀さんに変更されました。	2018-08-30
110	280019	32	あなたは 長谷　真紀さんの ステータスを キャンセル依頼中に変更しました。	2018-08-30
111	280019	33	PJリーダのための戦略的交渉術 ～交渉戦略の立案と実践スキル～(UZE88L)  に申込をしました。	2018-08-30
112	280019	33	PJリーダのための戦略的交渉術 ～交渉戦略の立案と実践スキル～(UZE88L) は アンケート回答待ちのステータスが長谷　真紀さんに変更されました。	2018-08-30
113	280019	33	あなたは 長谷　真紀さんの ステータスを アンケート回答待ちに変更しました。	2018-08-30
114	280019	33	あなたはPJリーダのための戦略的交渉術 ～交渉戦略の立案と実践スキル～(UZE88L) のアンケートを完成しました。	2018-08-30
115	280019	33	PJリーダのための戦略的交渉術 ～交渉戦略の立案と実践スキル～(UZE88L)  をキャンセルしました。	2018-08-30
116	290011	15	テスト品質管理　【実践】は のステータスが岸菜　圭一郎さんに変更されました。	2018-09-06
117	290011	15	あなたは 岸菜　圭一郎さんの ステータスを に変更しました。	2018-09-06
118	430050	21	組織を強くする問題解決の技術(BS-007) をキャンセルしました。	2018-09-14
119	430050	8	あなたは岸菜　圭一郎さんの代わりに、マネージャ研修 をキャンセルしました。	2018-09-14
120	290011	8	あなたは秋山　美也子さんにマネージャ研修がキャンセルされました。	2018-09-14
121	430050	34	新人フォローアップ研修 に申込をしました。	2018-09-18
122	430050	34	新人フォローアップ研修 をキャンセルしました。	2018-09-18
123	200009	35	あなたは秋山　美也子さんに新人フォローアップ研修が代替登録されましました。	2018-09-18
124	430050	35	あなたは荻野　孝行さんの代わりに、新人フォローアップ研修 を登録しました。	2018-09-18
125	460009	36	あなたは秋山　美也子さんに新人フォローアップ研修が代替登録されましました。	2018-09-18
126	430050	36	あなたは尾身　憧也さんの代わりに、新人フォローアップ研修 を登録しました。	2018-09-18
127	430050	36	あなたは尾身　憧也さんの代わりに、新人フォローアップ研修 をキャンセルしました。	2018-09-18
128	460009	36	あなたは秋山　美也子さんに新人フォローアップ研修がキャンセルされました。	2018-09-18
129	460009	37	あなたは秋山　美也子さんに新人フォローアップ研修が代替登録されましました。	2018-09-18
130	430050	37	あなたは尾身　憧也さんの代わりに、新人フォローアップ研修 を登録しました。	2018-09-18
131	430050	38	あなたは根本　侑歌さんの代わりに、新人フォローアップ研修 を登録しました。	2018-09-18
132	460037	38	あなたは秋山　美也子さんに新人フォローアップ研修が代替登録されましました。	2018-09-18
134	280019	32	プロジェクトマネジメントの技法 (UAQ41L) は アンケート回答待ちのステータスが秋山　美也子さんに変更されました。	2018-09-19
133	430050	32	あなたは 長谷　真紀さんの ステータスを アンケート回答待ちに変更しました。	2018-09-19
135	430052	39	あなたは秋山　美也子さんに中途社員研修が代替登録されましました。	2018-09-19
136	430050	39	あなたは丸山　順さんの代わりに、中途社員研修 を登録しました。	2018-09-19
137	430050	40	あなたは丸山　順さんの代わりに、業務の生産性を高める！改善のポイント（UUF05L） を登録しました。	2018-09-19
138	430052	40	あなたは秋山　美也子さんに業務の生産性を高める！改善のポイント（UUF05L）が代替登録されましました。	2018-09-19
140	160035	9	あなたは秋山　美也子さんに新任JP-B研修がキャンセルされました。	2018-09-20
139	430050	9	あなたは丹野　透さんの代わりに、新任JP-B研修 をキャンセルしました。	2018-09-20
141	430050	41	あなたは丹野　透さんの代わりに、新任JP-B研修 を登録しました。	2018-09-20
142	160035	41	あなたは秋山　美也子さんに新任JP-B研修が代替登録されましました。	2018-09-20
143	430050	17	あなたは 秋山　美也子さんの ステータスを 開始待ちに変更しました。	2018-09-20
144	430050	17	プロジェクトマネジメントの技法 (UAQ41L) は 開始待ちのステータスが秋山　美也子さんに変更されました。	2018-09-20
145	430050	42	イマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G) に申込をしました。	2018-09-20
146	430050	42	イマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G) をキャンセルしました。	2018-09-20
147	430050	43	イマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G) に申込をしました。	2018-09-20
148	200027	44	あなたは秋山　美也子さんにイマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G)が代替登録されましました。	2018-09-20
149	430050	44	あなたは新居田　麻紀子さんの代わりに、イマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G) を登録しました。	2018-09-20
150	430050	45	イマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G) に申込をしました。	2018-09-20
151	430050	45	イマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G) をキャンセルしました。	2018-09-20
152	200027	46	あなたは秋山　美也子さんにイマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G)が代替登録されましました。	2018-09-20
153	430050	46	あなたは新居田　麻紀子さんの代わりに、イマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G) を登録しました。	2018-09-20
154	200027	46	あなたは秋山　美也子さんにイマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G)がキャンセルされました。	2018-09-20
155	430050	46	あなたは新居田　麻紀子さんの代わりに、イマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G) をキャンセルしました。	2018-09-20
156	200027	47	あなたは秋山　美也子さんにイマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G)が代替登録されましました。	2018-09-20
157	430050	47	あなたは新居田　麻紀子さんの代わりに、イマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G) を登録しました。	2018-09-20
158	200027	47	あなたは秋山　美也子さんにイマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G)がキャンセルされました。	2018-09-20
159	430050	47	あなたは新居田　麻紀子さんの代わりに、イマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G) をキャンセルしました。	2018-09-20
160	430050	48	あなたは新居田　麻紀子さんの代わりに、イマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G) を登録しました。	2018-09-20
161	200027	48	あなたは秋山　美也子さんにイマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G)が代替登録されましました。	2018-09-20
162	430050	49	イマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G) に申込をしました。	2018-09-20
163	430050	49	イマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G) をキャンセルしました。	2018-09-20
164	430050	50	イマドキなWebページ作成に役立つJavaScriptライブラリー９選 (WSC0079G) に申込をしました。	2018-09-20
165	430050	22	あなたは作業プランニング／タイムマネジメント（BS-001）のアンケートを完成しました。	2018-09-20
166	430050	51	ビジネスコミュニケーション 【advance】（BS-004） に申込をしました。	2018-09-20
167	430050	26	基礎から学ぶ！Excelマクロ機能による業務の自動化 (UUF09L)は 開始待ちのステータスが秋山　美也子さんに変更されました。	2018-09-20
168	430050	26	あなたは 秋山　美也子さんの ステータスを 開始待ちに変更しました。	2018-09-20
169	430050	34	あなたは 秋山　美也子さんの ステータスを アンケート回答待ちに変更しました。	2018-09-20
170	430050	34	新人フォローアップ研修は アンケート回答待ちのステータスが秋山　美也子さんに変更されました。	2018-09-20
171	110008	52	あなたは岸菜　圭一郎さんに\r\n<One set with 2 classes>\r\nシェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）が代替登録されましました。	2018-09-20
172	290011	52	あなたは土田　伸治さんの代わりに、\r\n<One set with 2 classes>\r\nシェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L） を登録しました。	2018-09-20
173	430050	28	基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L)は アンケート回答待ちのステータスが秋山　美也子さんに変更されました。	2018-09-20
174	430050	28	あなたは 秋山　美也子さんの ステータスを アンケート回答待ちに変更しました。	2018-09-20
175	430050	28	あなたは基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L)のアンケートを完成しました。	2018-09-20
176	430050	28	あなたは 秋山　美也子さんの ステータスを アンケート回答待ちに変更しました。	2018-09-20
177	430050	28	基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L)は アンケート回答待ちのステータスが秋山　美也子さんに変更されました。	2018-09-20
178	430050	28	あなたは基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L)のアンケートを完成しました。	2018-09-20
179	280019	32	あなたはプロジェクトマネジメントの技法 (UAQ41L) のアンケートを完成しました。	2018-09-26
180	230020	53	２９９の施策から紐解く業務カイゼン ５つのポイント に申込をしました。	2018-09-27
181	230020	53	２９９の施策から紐解く業務カイゼン ５つのポイント をキャンセルしました。	2018-09-27
182	280019	54	中途社員研修 に申込をしました。	2018-09-27
183	280019	54	中途社員研修 をキャンセルしました。	2018-09-27
184	430050	55	入社3年目研修 に申込をしました。	2018-09-27
185	430050	55	入社3年目研修 をキャンセルしました。	2018-09-27
186	280019	54	中途社員研修 をキャンセルしました。	2018-09-27
187	280019	54	あなたは 長谷　真紀さんの ステータスを 申込不可に変更しました。	2018-09-27
188	280019	54	中途社員研修のステータスは、長谷　真紀さんによって申込不可に変更されました	2018-09-27
189	430050	56	オペレーショナルマネジャーから戦略的マネジャーへ（AMC0024V） に申込をしました。	2018-09-27
190	430050	57	あなたは長谷　真紀さんの代わりに、オペレーショナルマネジャーから戦略的マネジャーへ（AMC0024V） を登録しました。	2018-09-27
191	280019	57	あなたは秋山　美也子さんにオペレーショナルマネジャーから戦略的マネジャーへ（AMC0024V）が代替登録されましました。	2018-09-27
193	430050	55	入社3年目研修のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-09-28
192	430050	55	あなたは 秋山　美也子さんの ステータスを アンケート回答待ちに変更しました。	2018-09-28
194	430050	55	入社3年目研修のステータスは、秋山　美也子さんによってキャンセルに変更されました	2018-09-28
195	430050	55	あなたは 秋山　美也子さんの ステータスを キャンセルに変更しました。	2018-09-28
196	430050	56	オペレーショナルマネジャーから戦略的マネジャーへ（AMC0024V）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-09-28
197	430050	56	あなたは 秋山　美也子さんの ステータスを アンケート回答待ちに変更しました。	2018-09-28
198	280019	57	あなたは 長谷　真紀さんの ステータスを キャンセルに変更しました。	2018-09-28
199	280019	57	オペレーショナルマネジャーから戦略的マネジャーへ（AMC0024V）のステータスは、長谷　真紀さんによってキャンセルに変更されました	2018-09-28
200	280019	596	Javaによるデータ構造とアルゴリズム（JAC0080G） に申込をしました。	2018-09-28
201	430050	596	あなたは 長谷　真紀さんの ステータスを 開始待ちに変更しました。	2018-09-28
202	280019	596	Javaによるデータ構造とアルゴリズム（JAC0080G）のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-09-28
203	280019	596	Javaによるデータ構造とアルゴリズム（JAC0080G）のステータスは、長谷　真紀さんによってアンケート回答待ちに変更されました	2018-09-28
204	280019	596	あなたは 長谷　真紀さんの ステータスを アンケート回答待ちに変更しました。	2018-09-28
205	280019	597	プロジェクトマネジメントの技法 (UAQ41L)  に申込をしました。	2018-09-28
206	280019	597	あなたは 長谷　真紀さんの ステータスを アンケート回答待ちに変更しました。	2018-09-28
207	280019	597	プロジェクトマネジメントの技法 (UAQ41L) のステータスは、長谷　真紀さんによってアンケート回答待ちに変更されました	2018-09-28
208	430050	654	ビジネスコミュニケーション 【basic】（BS-002） に申込をしました。	2018-09-28
209	280019	597	プロジェクトマネジメントの技法 (UAQ41L)  をキャンセルしました。	2018-09-28
210	430050	654	ビジネスコミュニケーション 【basic】（BS-002）のステータスは、秋山　美也子さんによってキャンセルに変更されました	2018-09-28
211	430050	654	あなたは 秋山　美也子さんの ステータスを キャンセルに変更しました。	2018-09-28
212	430050	56	あなたは 秋山　美也子さんの ステータスを キャンセルに変更しました。	2018-09-28
213	430050	56	オペレーショナルマネジャーから戦略的マネジャーへ（AMC0024V）のステータスは、秋山　美也子さんによってキャンセルに変更されました	2018-09-28
214	430050	655	新人フォローアップ研修 に申込をしました。	2018-09-28
215	430050	655	新人フォローアップ研修のステータスは、秋山　美也子さんによってキャンセルに変更されました	2018-09-28
216	430050	655	あなたは 秋山　美也子さんの ステータスを キャンセルに変更しました。	2018-09-28
217	420004	783	ＳＥに求められるヒアリングスキル(UZE66L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-03
218	430050	783	あなたは 上田　康誉さんの ステータスを アンケート回答待ちに変更しました。	2018-10-03
219	390036	781	ＳＥに求められるヒアリングスキル(UZE66L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-03
220	430050	781	あなたは 清野　卓也さんの ステータスを アンケート回答待ちに変更しました。	2018-10-03
221	340031	780	ＳＥに求められるヒアリングスキル(UZE66L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-03
222	430050	780	あなたは 長岡　大義さんの ステータスを アンケート回答待ちに変更しました。	2018-10-03
223	430050	784	あなたは 安武　浩二さんの ステータスを アンケート回答待ちに変更しました。	2018-10-03
224	410049	784	ＳＥに求められるヒアリングスキル(UZE66L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-03
225	320013	782	ＳＥに求められるヒアリングスキル(UZE66L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-03
226	430050	782	あなたは 大野　悟さんの ステータスを アンケート回答待ちに変更しました。	2018-10-03
227	440007	785	UNIX／Linux入門（UMI11L）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-03
228	430050	785	あなたは 海老原　直人さんの ステータスを アンケート回答待ちに変更しました。	2018-10-03
229	460013	786	UNIX／Linux入門（UMI11L）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-03
230	430050	786	あなたは 久保　颯大朗さんの ステータスを アンケート回答待ちに変更しました。	2018-10-03
232	430050	803	あなたは 瀬戸　一誠さんの ステータスを キャンセルに変更しました。	2018-10-04
231	370023	803	プロジェクト実行管理（PM-004）のステータスは、秋山　美也子さんによってキャンセルに変更されました	2018-10-04
234	430050	1068	あなたは 大平　龍之介さんの ステータスを 完了に変更しました。	2018-10-09
233	470010	1068	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
235	470009	1067	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
236	430050	1067	あなたは 内山　正輝さんの ステータスを 完了に変更しました。	2018-10-09
237	470008	1066	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
238	430050	1066	あなたは 魚谷　優治さんの ステータスを 完了に変更しました。	2018-10-09
239	470007	1065	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
240	430050	1065	あなたは 井出　栞さんの ステータスを 完了に変更しました。	2018-10-09
241	470006	1064	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
242	430050	1064	あなたは 生亀　龍之介さんの ステータスを 完了に変更しました。	2018-10-09
243	470005	1063	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
244	430050	1063	あなたは 五十嵐　基剛さんの ステータスを 完了に変更しました。	2018-10-09
245	430050	1062	あなたは 新木　滉二さんの ステータスを 完了に変更しました。	2018-10-09
246	470004	1062	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
247	430050	1061	あなたは 荒井　里江さんの ステータスを 完了に変更しました。	2018-10-09
248	470003	1061	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
249	470002	1060	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
250	430050	1060	あなたは 新井　悠介さんの ステータスを 完了に変更しました。	2018-10-09
251	430050	1059	あなたは 新井　美智子さんの ステータスを 完了に変更しました。	2018-10-09
252	470001	1059	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
253	470026	1083	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
254	430050	1083	あなたは 阪元　美穂さんの ステータスを 完了に変更しました。	2018-10-09
255	470016	1074	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
256	430050	1074	あなたは 加賀　文将さんの ステータスを 完了に変更しました。	2018-10-09
257	470017	1075	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
258	430050	1075	あなたは 加藤　桃太郎さんの ステータスを 完了に変更しました。	2018-10-09
259	430050	1076	あなたは 苅田　力斗さんの ステータスを 完了に変更しました。	2018-10-09
260	470018	1076	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
261	470018	1076	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
262	430050	1076	あなたは 苅田　力斗さんの ステータスを 完了に変更しました。	2018-10-09
263	470019	1077	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
264	430050	1077	あなたは 河内　晴太さんの ステータスを 完了に変更しました。	2018-10-09
265	470021	1078	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
266	430050	1078	あなたは 木田　実希さんの ステータスを 完了に変更しました。	2018-10-09
267	430050	1073	あなたは 落合　彬さんの ステータスを 完了に変更しました。	2018-10-09
268	470015	1073	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
269	430050	1072	あなたは 荻野　慎之介さんの ステータスを 完了に変更しました。	2018-10-09
270	470014	1072	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
271	470014	1072	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
272	430050	1072	あなたは 荻野　慎之介さんの ステータスを 完了に変更しました。	2018-10-09
273	430050	1080	あなたは GAO　XUANさんの ステータスを 完了に変更しました。	2018-10-09
274	470023	1080	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
275	470024	1081	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
276	430050	1081	あなたは 越塚　菜々子さんの ステータスを 完了に変更しました。	2018-10-09
277	430050	1082	あなたは 古場　翔さんの ステータスを 完了に変更しました。	2018-10-09
278	470025	1082	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
279	430050	1084	あなたは 笹野　健太さんの ステータスを 完了に変更しました。	2018-10-09
280	470027	1084	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
281	430050	1085	あなたは 佐藤　涼さんの ステータスを 完了に変更しました。	2018-10-09
282	470028	1085	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
283	470029	1086	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
284	430050	1086	あなたは 城　大地さんの ステータスを 完了に変更しました。	2018-10-09
285	430050	1087	あなたは 杉浦　彗太さんの ステータスを 完了に変更しました。	2018-10-09
286	470030	1087	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
287	470031	1088	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
288	430050	1088	あなたは 関谷　太郎さんの ステータスを 完了に変更しました。	2018-10-09
289	430050	1089	あなたは 高橋　拓臣さんの ステータスを 完了に変更しました。	2018-10-09
290	470032	1089	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
291	470033	1090	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
292	430050	1090	あなたは 高山　春菜さんの ステータスを 完了に変更しました。	2018-10-09
293	430050	1090	あなたは 高山　春菜さんの ステータスを 完了に変更しました。	2018-10-09
294	470033	1090	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
295	470034	1091	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
296	430050	1091	あなたは 谷口　賢吾さんの ステータスを 完了に変更しました。	2018-10-09
297	470035	1092	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
298	430050	1092	あなたは 張　悦さんの ステータスを 完了に変更しました。	2018-10-09
299	430050	1093	あなたは 中野　幹也さんの ステータスを 完了に変更しました。	2018-10-09
300	470036	1093	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
301	430050	1094	あなたは 長原　英里香さんの ステータスを 完了に変更しました。	2018-10-09
302	470037	1094	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
303	430050	1095	あなたは 中村　涼綜さんの ステータスを 完了に変更しました。	2018-10-09
304	470038	1095	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
305	430050	1096	あなたは 桧山　貴憲さんの ステータスを 完了に変更しました。	2018-10-09
306	470039	1096	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
307	430050	1097	あなたは 福原　大哉さんの ステータスを 完了に変更しました。	2018-10-09
308	470040	1097	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
309	470041	1098	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
310	430050	1098	あなたは 冬木　駿也さんの ステータスを 完了に変更しました。	2018-10-09
311	470042	1099	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
312	430050	1099	あなたは 堀口　琢充さんの ステータスを 完了に変更しました。	2018-10-09
313	430050	1100	あなたは 前田　裕佳さんの ステータスを 完了に変更しました。	2018-10-09
314	470043	1100	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
315	470044	1101	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
316	430050	1101	あなたは 松浦　優さんの ステータスを 完了に変更しました。	2018-10-09
317	430050	1102	あなたは 森戸　義宗さんの ステータスを 完了に変更しました。	2018-10-09
318	470045	1102	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
319	430050	1103	あなたは 矢戸　佑樹さんの ステータスを 完了に変更しました。	2018-10-09
320	470046	1103	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
321	470047	1104	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
322	430050	1104	あなたは 山下　巽さんの ステータスを 完了に変更しました。	2018-10-09
323	430050	1105	あなたは 山谷　優太さんの ステータスを 完了に変更しました。	2018-10-09
324	470048	1105	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
325	430050	1106	あなたは 吉田　陽一郎さんの ステータスを 完了に変更しました。	2018-10-09
326	470049	1106	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
327	470050	1107	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
328	430050	1107	あなたは 和田　健太さんの ステータスを 完了に変更しました。	2018-10-09
329	470013	1071	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
330	430050	1071	あなたは 岡本　桂輔さんの ステータスを 完了に変更しました。	2018-10-09
331	430050	1070	あなたは 岡崎　航己さんの ステータスを 完了に変更しました。	2018-10-09
332	470012	1070	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
333	430050	1069	あなたは 大吉　裕真さんの ステータスを 完了に変更しました。	2018-10-09
334	470011	1069	新人フォローアップ研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-09
335	430050	899	あなたは 福谷　重崇さんの ステータスを 完了に変更しました。	2018-10-15
336	390025	899	要件定義のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-15
337	430050	907	あなたは 田中　友樹さんの ステータスを 完了に変更しました。	2018-10-15
338	400022	907	要件定義のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-15
339	450068	906	要件定義のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-15
340	430050	906	あなたは 中馬　望さんの ステータスを 完了に変更しました。	2018-10-15
341	400037	905	要件定義のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-15
342	430050	905	あなたは 渡辺　倫基さんの ステータスを 完了に変更しました。	2018-10-15
343	430050	904	あなたは 玉井　美早さんの ステータスを 完了に変更しました。	2018-10-15
344	430022	904	要件定義のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-15
345	430050	903	あなたは 藤田　潤さんの ステータスを 完了に変更しました。	2018-10-15
346	470055	903	要件定義のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-15
347	390012	902	要件定義のステータスは、秋山　美也子さんによってキャンセルに変更されました	2018-10-15
348	430050	902	あなたは 新海　美月さんの ステータスを キャンセルに変更しました。	2018-10-15
349	390012	902	要件定義のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-15
350	430050	902	あなたは 新海　美月さんの ステータスを 完了に変更しました。	2018-10-15
351	430050	901	あなたは 小野澤　晃さんの ステータスを 完了に変更しました。	2018-10-15
352	360011	901	要件定義のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-15
353	420019	900	要件定義のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-15
354	430050	900	あなたは 杉本　恭彦さんの ステータスを 完了に変更しました。	2018-10-15
355	430027	898	要件定義のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-15
356	430050	898	あなたは 中村　和樹さんの ステータスを 完了に変更しました。	2018-10-15
358	430050	787	あなたは 佐々木　弥生さんの ステータスを アンケート回答待ちに変更しました。	2018-10-16
357	430017	787	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-16
359	450041	779	体験！Androidプログラミング (UFN15L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-16
360	430050	779	あなたは 三木　愛美さんの ステータスを アンケート回答待ちに変更しました。	2018-10-16
362	280019	945	あなたは 丸井　綾子さんの ステータスを キャンセルに変更しました。	2018-10-17
361	370039	945	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2018-10-17
363	440022	940	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2018-10-17
364	280019	940	あなたは 斉藤　朋華さんの ステータスを キャンセルに変更しました。	2018-10-17
365	360012	937	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2018-10-17
366	280019	937	あなたは 郭　エイさんの ステータスを キャンセルに変更しました。	2018-10-17
368	280019	951	あなたは 永尾　江里子さんの ステータスを キャンセルに変更しました。	2018-10-18
367	360049	951	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2018-10-18
369	458003	1201	Node.js + Express + MongoDB ～JavaScript によるｻｰﾊﾞｰｻｲﾄﾞWebｱﾌﾟﾘｹｰｼｮﾝ開発 (WSC0065R) に申込をしました。	2018-10-19
370	458003	1201	Node.js + Express + MongoDB ～JavaScript によるｻｰﾊﾞｰｻｲﾄﾞWebｱﾌﾟﾘｹｰｼｮﾝ開発 (WSC0065R)のステータスは、長谷　真紀さんによって申込不可に変更されました	2018-10-19
371	280019	1201	あなたは 草野　美保さんの ステータスを 申込不可に変更しました。	2018-10-19
372	440042	938	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2018-10-19
373	280019	938	あなたは 平山　温子さんの ステータスを キャンセルに変更しました。	2018-10-19
374	430050	1202	あなたはZHU　GUANGYAOさんの代わりに、中途社員研修 を登録しました。	2018-10-19
375	460068	1202	あなたは秋山　美也子さんに中途社員研修が代替登録されましました。	2018-10-19
376	430050	1203	あなたは篠原　秀彦さんの代わりに、中途社員研修 を登録しました。	2018-10-19
377	460067	1203	あなたは秋山　美也子さんに中途社員研修が代替登録されましました。	2018-10-19
378	430050	1204	あなたは立花　沙紀さんの代わりに、中途社員研修 を登録しました。	2018-10-19
379	460069	1204	あなたは秋山　美也子さんに中途社員研修が代替登録されましました。	2018-10-19
380	460070	1205	あなたは秋山　美也子さんに中途社員研修が代替登録されましました。	2018-10-19
381	430050	1205	あなたは中村　義一さんの代わりに、中途社員研修 を登録しました。	2018-10-19
382	460071	1206	あなたは秋山　美也子さんに中途社員研修が代替登録されましました。	2018-10-19
383	430050	1206	あなたは前嶋　梨奈さんの代わりに、中途社員研修 を登録しました。	2018-10-19
384	460072	1207	あなたは秋山　美也子さんに中途社員研修が代替登録されましました。	2018-10-19
385	430050	1207	あなたは矢口　裕希さんの代わりに、中途社員研修 を登録しました。	2018-10-19
386	430050	1208	あなたは鴻池　伸欣さんの代わりに、中途社員研修 を登録しました。	2018-10-19
387	470052	1208	あなたは秋山　美也子さんに中途社員研修が代替登録されましました。	2018-10-19
388	470053	1209	あなたは秋山　美也子さんに中途社員研修が代替登録されましました。	2018-10-19
389	430050	1209	あなたはZHOU　SIYUANさんの代わりに、中途社員研修 を登録しました。	2018-10-19
390	470054	1210	あなたは秋山　美也子さんに中途社員研修が代替登録されましました。	2018-10-19
391	430050	1210	あなたは瀧川　太爾さんの代わりに、中途社員研修 を登録しました。	2018-10-19
392	470055	1211	あなたは秋山　美也子さんに中途社員研修が代替登録されましました。	2018-10-19
393	430050	1211	あなたは藤田　潤さんの代わりに、中途社員研修 を登録しました。	2018-10-19
394	430050	1212	あなたは新井　厚子さんの代わりに、中途社員研修 を登録しました。	2018-10-19
395	470056	1212	あなたは秋山　美也子さんに中途社員研修が代替登録されましました。	2018-10-19
2409	000000	1695	テスト品質管理 【実践】 に申込をしました。	2019-09-12
396	470057	1213	あなたは秋山　美也子さんに中途社員研修が代替登録されましました。	2018-10-19
397	430050	1213	あなたは大川　祥太さんの代わりに、中途社員研修 を登録しました。	2018-10-19
398	430050	1214	中途社員研修 に申込をしました。	2018-10-19
399	470059	1215	あなたは秋山　美也子さんに中途社員研修が代替登録されましました。	2018-10-19
400	430050	1215	あなたは石田　奈美さんの代わりに、中途社員研修 を登録しました。	2018-10-19
401	470060	1216	あなたは秋山　美也子さんに中途社員研修が代替登録されましました。	2018-10-19
402	430050	1216	あなたは井ノ山　裕貴さんの代わりに、中途社員研修 を登録しました。	2018-10-19
403	430050	1217	あなたは廣木　瑠実菜さんの代わりに、中途社員研修 を登録しました。	2018-10-19
404	470061	1217	あなたは秋山　美也子さんに中途社員研修が代替登録されましました。	2018-10-19
405	430050	1218	あなたは堀川　大輔さんの代わりに、中途社員研修 を登録しました。	2018-10-19
406	470062	1218	あなたは秋山　美也子さんに中途社員研修が代替登録されましました。	2018-10-19
407	430050	1219	あなたは東　由依子さんの代わりに、中途社員研修 を登録しました。	2018-10-19
408	470063	1219	あなたは秋山　美也子さんに中途社員研修が代替登録されましました。	2018-10-19
409	430050	1220	あなたは田中　潤さんの代わりに、中途社員研修 を登録しました。	2018-10-19
410	470064	1220	あなたは秋山　美也子さんに中途社員研修が代替登録されましました。	2018-10-19
411	430050	1214	あなたは 秋山　美也子さんの ステータスを キャンセルに変更しました。	2018-10-19
412	430050	1214	中途社員研修のステータスは、秋山　美也子さんによってキャンセルに変更されました	2018-10-19
413	430050	1220	あなたは 田中　潤さんの ステータスを 開始待ちに変更しました。	2018-10-19
414	470064	1220	中途社員研修のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-10-19
415	430050	1219	あなたは 東　由依子さんの ステータスを 開始待ちに変更しました。	2018-10-19
416	470063	1219	中途社員研修のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-10-19
417	430050	1218	あなたは 堀川　大輔さんの ステータスを 開始待ちに変更しました。	2018-10-19
418	470062	1218	中途社員研修のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-10-19
419	430050	1217	あなたは 廣木　瑠実菜さんの ステータスを 開始待ちに変更しました。	2018-10-19
420	470061	1217	中途社員研修のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-10-19
421	470060	1216	中途社員研修のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-10-19
422	430050	1216	あなたは 井ノ山　裕貴さんの ステータスを 開始待ちに変更しました。	2018-10-19
423	430050	1215	あなたは 石田　奈美さんの ステータスを 開始待ちに変更しました。	2018-10-19
424	470059	1215	中途社員研修のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-10-19
425	430050	1214	中途社員研修のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-10-19
426	430050	1214	あなたは 秋山　美也子さんの ステータスを 開始待ちに変更しました。	2018-10-19
427	430050	1214	あなたは 秋山　美也子さんの ステータスを キャンセルに変更しました。	2018-10-19
428	430050	1214	中途社員研修のステータスは、秋山　美也子さんによってキャンセルに変更されました	2018-10-19
429	430050	1213	あなたは 大川　祥太さんの ステータスを 開始待ちに変更しました。	2018-10-19
430	470057	1213	中途社員研修のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-10-19
431	470056	1212	中途社員研修のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-10-19
432	430050	1212	あなたは 新井　厚子さんの ステータスを 開始待ちに変更しました。	2018-10-19
433	470055	1211	中途社員研修のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-10-19
434	430050	1211	あなたは 藤田　潤さんの ステータスを 開始待ちに変更しました。	2018-10-19
435	430050	1210	あなたは 瀧川　太爾さんの ステータスを 開始待ちに変更しました。	2018-10-19
436	470054	1210	中途社員研修のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-10-19
437	470053	1209	中途社員研修のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-10-19
438	430050	1209	あなたは ZHOU　SIYUANさんの ステータスを 開始待ちに変更しました。	2018-10-19
439	430050	1208	あなたは 鴻池　伸欣さんの ステータスを 開始待ちに変更しました。	2018-10-19
440	470052	1208	中途社員研修のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-10-19
441	430050	1207	あなたは 矢口　裕希さんの ステータスを 開始待ちに変更しました。	2018-10-19
442	460072	1207	中途社員研修のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-10-19
443	460071	1206	中途社員研修のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-10-19
444	430050	1206	あなたは 前嶋　梨奈さんの ステータスを 開始待ちに変更しました。	2018-10-19
445	430050	1205	あなたは 中村　義一さんの ステータスを 開始待ちに変更しました。	2018-10-19
446	460070	1205	中途社員研修のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-10-19
447	430050	1204	あなたは 立花　沙紀さんの ステータスを 開始待ちに変更しました。	2018-10-19
448	460069	1204	中途社員研修のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-10-19
449	430050	1203	あなたは 篠原　秀彦さんの ステータスを 開始待ちに変更しました。	2018-10-19
450	460067	1203	中途社員研修のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-10-19
451	460068	1202	中途社員研修のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-10-19
452	430050	1202	あなたは ZHU　GUANGYAOさんの ステータスを 開始待ちに変更しました。	2018-10-19
454	450038	1116	入社3年目研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2018-10-24
453	280019	1116	あなたは 前田　有葉さんの ステータスを キャンセルに変更しました。	2018-10-24
455	450071	1221	プロジェクト実行管理（PM-004） に申込をしました。	2018-10-24
456	430050	1221	あなたは 小南　勝彦さんの ステータスを 研修先申込中に変更しました。	2018-10-24
457	450071	1221	プロジェクト実行管理（PM-004）のステータスは、秋山　美也子さんによって研修先申込中に変更されました	2018-10-24
459	430050	1221	あなたは 小南　勝彦さんの ステータスを 開始待ちに変更しました。	2018-10-29
458	450071	1221	プロジェクト実行管理（PM-004）のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-10-29
460	430050	1123	あなたは 天野　智裕さんの ステータスを 完了に変更しました。	2018-10-29
461	450001	1123	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
462	450033	1122	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
463	430050	1122	あなたは 深澤　朋也さんの ステータスを 完了に変更しました。	2018-10-29
464	450012	1121	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
465	430050	1121	あなたは 神谷　駿さんの ステータスを 完了に変更しました。	2018-10-29
466	430050	1120	あなたは 井出　好希さんの ステータスを 完了に変更しました。	2018-10-29
467	450003	1120	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
468	450040	1119	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
469	430050	1119	あなたは 松本　隆太さんの ステータスを 完了に変更しました。	2018-10-29
470	430050	1118	あなたは 楊　飛さんの ステータスを 完了に変更しました。	2018-10-29
471	450051	1118	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
472	430050	1117	あなたは 岩城　敦士さんの ステータスを 完了に変更しました。	2018-10-29
473	450004	1117	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
474	430050	1115	あなたは 長田　直樹さんの ステータスを 完了に変更しました。	2018-10-29
475	450029	1115	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
476	430050	1138	あなたは 菊池　友貴さんの ステータスを 完了に変更しました。	2018-10-29
477	450014	1138	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
478	430050	1114	あなたは 宮下　桃華さんの ステータスを 完了に変更しました。	2018-10-29
479	450044	1114	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
480	450021	1113	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
481	430050	1113	あなたは 清水　尚哉さんの ステータスを 完了に変更しました。	2018-10-29
482	430050	1139	あなたは 田中　誠也さんの ステータスを 完了に変更しました。	2018-10-29
483	450025	1139	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
484	430050	1112	あなたは 石川　晃さんの ステータスを 完了に変更しました。	2018-10-29
485	450002	1112	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
486	430050	1111	あなたは 船山　善宣さんの ステータスを 完了に変更しました。	2018-10-29
487	450035	1111	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
488	430050	1110	あなたは 小川　将司さんの ステータスを 完了に変更しました。	2018-10-29
489	450009	1110	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
490	430050	1109	あなたは 松田　達朗さんの ステータスを 完了に変更しました。	2018-10-29
491	450039	1109	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
492	430050	1108	あなたは 澤谷　航介さんの ステータスを 完了に変更しました。	2018-10-29
493	450019	1108	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
494	430050	1140	あなたは 森山　大輝さんの ステータスを 完了に変更しました。	2018-10-29
495	450047	1140	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
496	430050	1132	あなたは 前川　智恒さんの ステータスを 完了に変更しました。	2018-10-29
497	450037	1132	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
498	430050	1131	あなたは 藤井　一毅さんの ステータスを 完了に変更しました。	2018-10-29
499	450034	1131	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
500	450026	1141	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
501	430050	1141	あなたは 譚　克震さんの ステータスを 完了に変更しました。	2018-10-29
502	430050	1133	あなたは 齊藤　政樹さんの ステータスを 完了に変更しました。	2018-10-29
503	450017	1133	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
504	430050	1142	あなたは 鈴木　梨夏さんの ステータスを 完了に変更しました。	2018-10-29
505	450023	1142	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
506	430050	1143	あなたは 三原　健さんの ステータスを 完了に変更しました。	2018-10-29
507	450043	1143	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
508	430050	1144	あなたは 三木　愛美さんの ステータスを 完了に変更しました。	2018-10-29
509	450041	1144	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
510	430050	1134	あなたは 久保　健太さんの ステータスを 完了に変更しました。	2018-10-29
511	450015	1134	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
512	430050	1135	あなたは 中山　翔太さんの ステータスを 完了に変更しました。	2018-10-29
513	450030	1135	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
514	430050	1136	あなたは 山口　拳さんの ステータスを 完了に変更しました。	2018-10-29
515	450049	1136	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
516	430050	1137	あなたは 南山　章宏さんの ステータスを 完了に変更しました。	2018-10-29
517	450042	1137	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
519	450045	1145	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
518	430050	1145	あなたは ミヤシロ　プレストン　アランさんの ステータスを 完了に変更しました。	2018-10-29
520	450054	1146	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
521	430050	1146	あなたは 渡邊　隼丞さんの ステータスを 完了に変更しました。	2018-10-29
522	430050	1147	あなたは 山口　熙さんの ステータスを 完了に変更しました。	2018-10-29
523	450050	1147	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
524	430050	1148	あなたは 樫村　尚樹さんの ステータスを 完了に変更しました。	2018-10-29
525	450010	1148	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
526	430050	1149	あなたは 清水　啓樹さんの ステータスを 完了に変更しました。	2018-10-29
527	450022	1149	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
528	430050	1125	あなたは 近江　将人さんの ステータスを 完了に変更しました。	2018-10-29
529	450006	1125	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
530	430050	1126	あなたは 臼井　時大さんの ステータスを 完了に変更しました。	2018-10-29
531	450005	1126	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
532	430050	1124	あなたは 富田　敦也さんの ステータスを 完了に変更しました。	2018-10-29
533	450028	1124	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
534	430050	1130	あなたは 安永　誠治さんの ステータスを 完了に変更しました。	2018-10-29
535	450048	1130	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
536	430050	1129	あなたは 平尾　悠輔さんの ステータスを 完了に変更しました。	2018-10-29
537	450032	1129	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
538	430050	1128	あなたは 李　文強さんの ステータスを キャンセル依頼中に変更しました。	2018-10-29
539	450052	1128	入社3年目研修のステータスは、秋山　美也子さんによってキャンセル依頼中に変更されました	2018-10-29
540	430050	1128	あなたは 李　文強さんの ステータスを 完了に変更しました。	2018-10-29
541	450052	1128	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
542	430050	1127	あなたは 嘉手苅　宥也さんの ステータスを 完了に変更しました。	2018-10-29
543	450011	1127	入社3年目研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-10-29
544	440047	723	JavaScriptプログラミング基礎 (UJS36L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
545	430050	723	あなたは 宮下　翼さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
546	430050	725	あなたは 澤谷　航介さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
547	450019	725	基礎から学ぶ！Excelマクロ機能による業務の自動化 (UUF09L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
548	430050	724	あなたは 細川　雅行さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
549	440044	724	プロジェクトマネジメントの技法 (UAQ41L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
550	420041	721	基礎から学ぶ！Excelマクロ機能による業務の自動化 (UUF09L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
551	430050	721	あなたは 雷　蕾さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
552	430050	722	あなたは 井出　好希さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
553	450003	722	JavaScriptプログラミング基礎 (UJS36L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
554	430050	729	あなたは 来間　さやかさんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
555	430013	729	Microsoft Azure入門 (UCV42L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
557	430050	730	あなたは 澤谷　航介さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
556	450019	730	基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
558	430050	727	あなたは 長田　直樹さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
559	450029	727	基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
560	430050	726	あなたは 雷　蕾さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
561	420041	726	基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
562	360053	728	Microsoft Azure入門 (UCV42L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
563	430050	728	あなたは 田原　和俊さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
564	430050	734	あなたは 佐藤　玲美さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
565	370019	734	Excel VBA　による部門業務システムの構築（UUL79L）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
566	430050	732	あなたは 山崎　晶子さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
567	460047	732	Excel VBA　による部門業務システムの構築（UUL79L）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
568	370020	731	速習　Swiftプログラミング言語 (UFN45L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
569	430050	731	あなたは 史　礼さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
570	430050	733	あなたは 中野　充啓さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
571	380053	733	速習　Swiftプログラミング言語 (UFN45L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
572	430050	737	あなたは 澤岻　夏海さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
573	460025	737	体験！Androidプログラミング (UFN15L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
574	430050	740	あなたは 大友　あゆ美さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
575	330004	740	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
576	450067	738	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
577	430050	738	あなたは 松本　和巳さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
578	430050	746	あなたは 土橋　優さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
579	420028	746	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
580	460036	745	UNIX／Linux入門（UMI11L）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
581	430050	745	あなたは 西村　明莉さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
582	430050	748	あなたは 園部　啓太さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
583	460024	748	UNIX／Linux入門（UMI11L）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
584	460010	744	UNIX／Linux入門（UMI11L）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
585	430050	744	あなたは 加藤　拳太さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
586	430050	750	あなたは 鈴木　照幸さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
587	270015	750	Microsoft Azure入門 (UCV42L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
588	430050	741	あなたは 松葉　慧さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
589	380038	741	Microsoft Azure入門 (UCV42L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
590	430050	751	あなたは 北谷　浩貴さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
591	350013	751	Androidアプリ開発－WebAPI、非同期処理、サービス－ (UFN51L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
592	430050	754	あなたは 川瀬　優さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
593	420011	754	プロジェクトマネジメントの技法 (UAQ41L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
594	430050	755	あなたは 中村　義一さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
595	460070	755	プロジェクトマネジメントの技法 (UAQ41L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
596	430050	752	あなたは 湯川　翔太さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
597	430040	752	プロジェクトマネジメントの技法 (UAQ41L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
599	430050	761	あなたは 佐藤　眞央さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
598	460018	761	作業プランニング／タイムマネジメント（BS-001）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
600	430050	763	あなたは 松本　隆太さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
601	450040	763	作業プランニング／タイムマネジメント（BS-001）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
602	430050	757	あなたは 大山　翔平さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
603	460008	757	作業プランニング／タイムマネジメント（BS-001）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
604	430050	758	あなたは 朴　志桓さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
605	370033	758	作業プランニング／タイムマネジメント（BS-001）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
606	460001	759	作業プランニング／タイムマネジメント（BS-001）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
607	430050	759	あなたは 安孫子　和之さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
608	470015	760	作業プランニング／タイムマネジメント（BS-001）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
609	430050	760	あなたは 落合　彬さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
610	430050	762	あなたは 松浦　優さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
611	470044	762	作業プランニング／タイムマネジメント（BS-001）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
612	430050	767	あなたは 三宅　隆一郎さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
613	410034	767	事例から学ぶ　アジャイル開発のプロジェクトマネジメント(UBS79L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
614	430050	764	あなたは 醍醐　政弘さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
615	420020	764	事例から学ぶ　アジャイル開発のプロジェクトマネジメント(UBS79L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
616	430050	765	あなたは 山田　太一さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
617	320038	765	事例から学ぶ　アジャイル開発のプロジェクトマネジメント(UBS79L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
618	440005	768	業務の生産性を高める！改善のポイント（UUF05L）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
619	430050	768	あなたは 岩澤　豊子さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
620	430050	769	あなたは 武藤　未華さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
621	420051	769	データベース入門 (DB0037CG)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
622	410032	772	プロジェクトマネジメントの技法 (UAQ41L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
623	430050	772	あなたは 張貝　祐真さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
624	430050	770	あなたは 松田　達朗さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
625	450039	770	プロジェクトマネジメントの技法 (UAQ41L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
626	430050	775	あなたは 松浦　優さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
627	470044	775	基礎から学ぶ！Excelマクロ機能による業務の自動化 (UUF09L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
628	430050	777	あなたは 和田　さやかさんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
629	370046	777	体験！Androidプログラミング (UFN15L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
630	470008	776	基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
631	430050	776	あなたは 魚谷　優治さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
632	450043	778	体験！Androidプログラミング (UFN15L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-29
633	430050	778	あなたは 三原　健さんの ステータスを アンケート回答待ちに変更しました。	2018-10-29
634	430017	787	あなたはシェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のアンケートを完成しました。	2018-10-31
681	470001	793	ビジネスコミュニケーション 【basic】（BS-002）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-07
635	360039	788	PJリーダのための戦略的交渉術 ～交渉戦略の立案と実践スキル～(UZE88L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-31
636	430050	788	あなたは 森田　淳一朗さんの ステータスを アンケート回答待ちに変更しました。	2018-10-31
637	440052	789	PJリーダのための戦略的交渉術 ～交渉戦略の立案と実践スキル～(UZE88L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-10-31
638	430050	789	あなたは 吉岡　慧さんの ステータスを アンケート回答待ちに変更しました。	2018-10-31
687	270009	1222	基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L) に申込をしました。	2018-11-08
639	440052	789	あなたはPJリーダのための戦略的交渉術 ～交渉戦略の立案と実践スキル～(UZE88L) のアンケートを完成しました。	2018-10-31
640	280019	949	あなたは 田中　ゆりさんの ステータスを キャンセルに変更しました。	2018-10-31
641	440028	949	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2018-10-31
642	470001	742	あなたはMicrosoft Azure入門 (UCV42L) のアンケートを完成しました。	2018-11-01
644	330004	943	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2018-11-02
643	280019	943	あなたは 大友　あゆ美さんの ステータスを キャンセルに変更しました。	2018-11-02
645	280019	950	あなたは 布居　直美さんの ステータスを 完了に変更しました。	2018-11-02
646	440070	950	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによって完了に変更されました	2018-11-02
647	440073	948	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによって完了に変更されました	2018-11-02
648	280019	948	あなたは 石川　美佳さんの ステータスを 完了に変更しました。	2018-11-02
649	280019	947	あなたは 飯島　汐莉さんの ステータスを 完了に変更しました。	2018-11-02
650	440003	947	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによって完了に変更されました	2018-11-02
651	430012	946	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによって完了に変更されました	2018-11-02
652	280019	946	あなたは 熊川　琴絵さんの ステータスを 完了に変更しました。	2018-11-02
653	280019	944	あなたは 奥田　茉莉さんの ステータスを 完了に変更しました。	2018-11-02
654	440014	944	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによって完了に変更されました	2018-11-02
655	280019	942	あなたは 原澤　あゆみさんの ステータスを 完了に変更しました。	2018-11-02
656	440040	942	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによって完了に変更されました	2018-11-02
657	280019	954	あなたは 三浦　友美さんの ステータスを 完了に変更しました。	2018-11-02
658	440071	954	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによって完了に変更されました	2018-11-02
659	280019	955	あなたは 辻内　夏奈子さんの ステータスを 完了に変更しました。	2018-11-02
660	450056	955	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによって完了に変更されました	2018-11-02
661	440036	956	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによって完了に変更されました	2018-11-02
662	280019	956	あなたは 成田　友衣子さんの ステータスを 完了に変更しました。	2018-11-02
663	280019	957	あなたは 永井　久栄さんの ステータスを 完了に変更しました。	2018-11-02
664	410044	957	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによって完了に変更されました	2018-11-02
665	450061	958	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによって完了に変更されました	2018-11-02
666	280019	958	あなたは 北野　聡美さんの ステータスを 完了に変更しました。	2018-11-02
667	280019	959	あなたは 矢原　小莉さんの ステータスを 完了に変更しました。	2018-11-02
668	440050	959	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによって完了に変更されました	2018-11-02
669	440039	952	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによって完了に変更されました	2018-11-02
670	280019	952	あなたは 橋本　翔子さんの ステータスを 完了に変更しました。	2018-11-02
671	280019	939	あなたは 佐藤　玲美さんの ステータスを 完了に変更しました。	2018-11-02
672	370019	939	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによって完了に変更されました	2018-11-02
673	440005	953	ビジョナリー・ウーマン研修のステータスは、長谷　真紀さんによって完了に変更されました	2018-11-02
674	280019	953	あなたは 岩澤　豊子さんの ステータスを 完了に変更しました。	2018-11-02
676	430050	790	あなたは 武藤　未華さんの ステータスを アンケート回答待ちに変更しました。	2018-11-05
675	420051	790	体験！Androidプログラミング (UFN15L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-05
678	430050	791	あなたは 田島　みずほさんの ステータスを アンケート回答待ちに変更しました。	2018-11-07
677	460027	791	ビジネスコミュニケーション 【basic】（BS-002）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-07
679	430050	792	あなたは 吉田　陽一郎さんの ステータスを アンケート回答待ちに変更しました。	2018-11-07
680	470049	792	ビジネスコミュニケーション 【basic】（BS-002）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-07
682	430050	793	あなたは 新井　美智子さんの ステータスを アンケート回答待ちに変更しました。	2018-11-07
683	430050	794	あなたは 藤井　一毅さんの ステータスを アンケート回答待ちに変更しました。	2018-11-07
684	450034	794	ビジネスコミュニケーション 【basic】（BS-002）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-07
685	470001	793	あなたはビジネスコミュニケーション 【basic】（BS-002）のアンケートを完成しました。	2018-11-07
686	460027	791	あなたはビジネスコミュニケーション 【basic】（BS-002）のアンケートを完成しました。	2018-11-07
688	430050	1222	あなたは 小俣　和也さんの ステータスを 研修先申込中に変更しました。	2018-11-08
689	270009	1222	基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L)のステータスは、秋山　美也子さんによって研修先申込中に変更されました	2018-11-08
690	270009	1222	基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L)のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-11-08
691	430050	1222	あなたは 小俣　和也さんの ステータスを 開始待ちに変更しました。	2018-11-08
692	430050	1222	あなたは 小俣　和也さんの ステータスを 申込不可に変更しました。	2018-11-08
693	270009	1222	基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L)のステータスは、秋山　美也子さんによって申込不可に変更されました	2018-11-08
695	430050	795	あなたは 中村　裕恵さんの ステータスを アンケート回答待ちに変更しました。	2018-11-09
694	430029	795	ビジネスコミュニケーション 【advance】（BS-004）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-09
696	450033	796	ビジネスコミュニケーション 【advance】（BS-004）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-09
697	430050	796	あなたは 深澤　朋也さんの ステータスを アンケート回答待ちに変更しました。	2018-11-09
698	470002	1223	Javaデータベースプログラミング (JAC0083G) に申込をしました。	2018-11-09
699	470049	792	あなたはビジネスコミュニケーション 【basic】（BS-002）のアンケートを完成しました。	2018-11-09
700	470002	1223	Javaデータベースプログラミング (JAC0083G)のステータスは、秋山　美也子さんによって研修先申込中に変更されました	2018-11-09
701	430050	1223	あなたは 新井　悠介さんの ステータスを 研修先申込中に変更しました。	2018-11-09
702	420051	790	あなたは体験！Androidプログラミング (UFN15L) のアンケートを完成しました。	2018-11-09
703	450033	796	あなたはビジネスコミュニケーション 【advance】（BS-004）のアンケートを完成しました。	2018-11-10
704	450034	794	あなたはビジネスコミュニケーション 【basic】（BS-002）のアンケートを完成しました。	2018-11-12
705	430010	808	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、長谷　真紀さんによってキャンセル（有償）に変更されました	2018-11-13
706	280019	808	あなたは 奥本　悠さんの ステータスを キャンセル（有償）に変更しました。	2018-11-13
708	430050	798	あなたは 佐藤　健太さんの ステータスを 完了に変更しました。	2018-11-15
707	360026	798	プロジェクト実行管理（PM-004）のステータスは、秋山　美也子さんによって完了に変更されました	2018-11-15
709	360026	798	プロジェクト実行管理（PM-004）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-15
710	430050	798	あなたは 佐藤　健太さんの ステータスを アンケート回答待ちに変更しました。	2018-11-15
711	450039	770	あなたはプロジェクトマネジメントの技法 (UAQ41L) のアンケートを完成しました。	2018-11-15
713	430050	1221	あなたは 小南　勝彦さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
712	450071	1221	プロジェクト実行管理（PM-004）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
714	430041	807	プロジェクト実行管理（PM-004）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
715	430050	807	あなたは 楊　涛さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
716	380017	804	プロジェクト実行管理（PM-004）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
717	430050	804	あなたは 金野　栄治さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
718	410009	802	プロジェクト実行管理（PM-004）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
719	430050	802	あなたは 落合　範俊さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
720	410011	801	プロジェクト実行管理（PM-004）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
721	430050	801	あなたは 川崎　高広さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
722	430002	805	プロジェクト実行管理（PM-004）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
723	430050	805	あなたは 安宅　勇人さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
724	430022	806	プロジェクト実行管理（PM-004）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
725	430050	806	あなたは 玉井　美早さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
726	430050	799	あなたは 斉藤　朋華さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
727	440022	799	プロジェクト実行管理（PM-004）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
728	370045	797	プロジェクト実行管理（PM-004）のステータスは、秋山　美也子さんによってキャンセル（有償）に変更されました	2018-11-19
729	430050	797	あなたは 渡部　健児さんの ステータスを キャンセル（有償）に変更しました。	2018-11-19
730	430033	809	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
731	430050	809	あなたは 福西　弘晋さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
732	460070	1205	中途社員研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-11-19
733	430050	1205	あなたは 中村　義一さんの ステータスを 完了に変更しました。	2018-11-19
734	430050	1206	あなたは 前嶋　梨奈さんの ステータスを 完了に変更しました。	2018-11-19
735	460071	1206	中途社員研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-11-19
736	460072	1207	中途社員研修のステータスは、秋山　美也子さんによってキャンセルに変更されました	2018-11-19
737	430050	1207	あなたは 矢口　裕希さんの ステータスを キャンセルに変更しました。	2018-11-19
738	430050	1208	あなたは 鴻池　伸欣さんの ステータスを キャンセルに変更しました。	2018-11-19
739	470052	1208	中途社員研修のステータスは、秋山　美也子さんによってキャンセルに変更されました	2018-11-19
740	470053	1209	中途社員研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-11-19
741	430050	1209	あなたは ZHOU　SIYUANさんの ステータスを 完了に変更しました。	2018-11-19
742	470054	1210	中途社員研修のステータスは、秋山　美也子さんによってキャンセルに変更されました	2018-11-19
743	430050	1210	あなたは 瀧川　太爾さんの ステータスを キャンセルに変更しました。	2018-11-19
744	470055	1211	中途社員研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-11-19
745	430050	1211	あなたは 藤田　潤さんの ステータスを 完了に変更しました。	2018-11-19
746	430050	1220	あなたは 田中　潤さんの ステータスを 完了に変更しました。	2018-11-19
747	470064	1220	中途社員研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-11-19
748	470063	1219	中途社員研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-11-19
749	430050	1219	あなたは 東　由依子さんの ステータスを 完了に変更しました。	2018-11-19
750	470062	1218	中途社員研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-11-19
751	430050	1218	あなたは 堀川　大輔さんの ステータスを 完了に変更しました。	2018-11-19
752	470061	1217	中途社員研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-11-19
753	430050	1217	あなたは 廣木　瑠実菜さんの ステータスを 完了に変更しました。	2018-11-19
754	430050	826	あなたは 村上　嘉正さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
755	370040	826	組織力を高めるマネジメントの技術(BS-008)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
756	430050	825	あなたは 瀧川　太爾さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
757	470054	825	組織力を高めるマネジメントの技術(BS-008)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
758	330018	824	組織力を高めるマネジメントの技術(BS-008)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
759	430050	824	あなたは 眞田　靖さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
760	240020	823	組織力を高めるマネジメントの技術(BS-008)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
761	430050	823	あなたは 茂木　孝之さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
762	360056	822	組織力を高めるマネジメントの技術(BS-008)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
763	430050	822	あなたは 小山内　克朋さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
764	290009	821	組織力を高めるマネジメントの技術(BS-008)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
765	430050	821	あなたは 狩俣　真一さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
766	340037	820	組織力を高めるマネジメントの技術(BS-008)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
767	430050	820	あなたは 星野　貴一さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
768	350001	819	組織力を高めるマネジメントの技術(BS-008)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
769	430050	819	あなたは 東　篤さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
770	430050	818	あなたは 富永　直也さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
771	370057	818	組織力を高めるマネジメントの技術(BS-008)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
772	400015	817	組織力を高めるマネジメントの技術(BS-008)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
773	430050	817	あなたは 小泉　啓樹さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
774	430050	816	あなたは 後藤　勝代さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
775	350017	816	組織力を高めるマネジメントの技術(BS-008)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
776	340057	815	組織力を高めるマネジメントの技術(BS-008)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
777	430050	815	あなたは 中野　真一さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
778	370081	814	組織力を高めるマネジメントの技術(BS-008)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
779	430050	814	あなたは 藤間　渉さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
780	440068	813	組織力を高めるマネジメントの技術(BS-008)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
781	430050	813	あなたは 安達　康弘さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
782	360014	812	組織力を高めるマネジメントの技術(BS-008)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
783	430050	812	あなたは 神田　将寛さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
784	450039	811	組織力を高めるマネジメントの技術(BS-008)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
785	430050	811	あなたは 松田　達朗さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
786	430050	810	あなたは 森本　修平さんの ステータスを アンケート回答待ちに変更しました。	2018-11-19
787	370042	810	組織力を高めるマネジメントの技術(BS-008)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-19
788	430050	1202	あなたは ZHU　GUANGYAOさんの ステータスを 完了に変更しました。	2018-11-19
789	460068	1202	中途社員研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-11-19
790	460067	1203	中途社員研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-11-19
791	430050	1203	あなたは 篠原　秀彦さんの ステータスを 完了に変更しました。	2018-11-19
792	460069	1204	中途社員研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-11-19
793	430050	1204	あなたは 立花　沙紀さんの ステータスを 完了に変更しました。	2018-11-19
794	470060	1216	中途社員研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-11-19
795	430050	1216	あなたは 井ノ山　裕貴さんの ステータスを 完了に変更しました。	2018-11-19
796	430050	1215	あなたは 石田　奈美さんの ステータスを 完了に変更しました。	2018-11-19
797	470059	1215	中途社員研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-11-19
798	470057	1213	中途社員研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-11-19
799	430050	1213	あなたは 大川　祥太さんの ステータスを 完了に変更しました。	2018-11-19
800	470056	1212	中途社員研修のステータスは、秋山　美也子さんによって完了に変更されました	2018-11-19
801	430050	1212	あなたは 新井　厚子さんの ステータスを 完了に変更しました。	2018-11-19
802	240020	823	組織力を高めるマネジメントの技術(BS-008)のステータスは、長谷　真紀さんによってキャンセル（有償）に変更されました	2018-11-19
803	280019	823	あなたは 茂木　孝之さんの ステータスを キャンセル（有償）に変更しました。	2018-11-19
804	330018	824	組織力を高めるマネジメントの技術(BS-008)のステータスは、長谷　真紀さんによってキャンセル（有償）に変更されました	2018-11-19
805	280019	824	あなたは 眞田　靖さんの ステータスを キャンセル（有償）に変更しました。	2018-11-19
806	470054	825	あなたは組織力を高めるマネジメントの技術(BS-008)のアンケートを完成しました。	2018-11-19
807	340037	820	あなたは組織力を高めるマネジメントの技術(BS-008)のアンケートを完成しました。	2018-11-19
808	360014	812	あなたは組織力を高めるマネジメントの技術(BS-008)のアンケートを完成しました。	2018-11-19
809	450071	1221	あなたはプロジェクト実行管理（PM-004）のアンケートを完成しました。	2018-11-19
811	430050	800	あなたは 山本　悟さんの ステータスを アンケート回答待ちに変更しました。	2018-11-20
810	400035	800	プロジェクト実行管理（PM-004）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-20
812	470002	1223	Javaデータベースプログラミング (JAC0083G)のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-11-20
813	430050	1223	あなたは 新井　悠介さんの ステータスを 開始待ちに変更しました。	2018-11-20
814	430050	827	あなたは 鴨下　幸史さんの ステータスを アンケート回答待ちに変更しました。	2018-11-20
815	400009	827	Node.js + Express + MongoDB ～JavaScript によるｻｰﾊﾞｰｻｲﾄﾞWebｱﾌﾟﾘｹｰｼｮﾝ開発 (WSC0065R)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-20
816	430050	828	あなたは 小笠　泰輔さんの ステータスを アンケート回答待ちに変更しました。	2018-11-20
817	430009	828	PJリーダのための戦略的交渉術 ～交渉戦略の立案と実践スキル～(UZE88L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-20
818	370040	826	あなたは組織力を高めるマネジメントの技術(BS-008)のアンケートを完成しました。	2018-11-20
819	430002	805	あなたはプロジェクト実行管理（PM-004）のアンケートを完成しました。	2018-11-20
820	370057	818	あなたは組織力を高めるマネジメントの技術(BS-008)のアンケートを完成しました。	2018-11-20
821	430041	807	あなたはプロジェクト実行管理（PM-004）のアンケートを完成しました。	2018-11-20
822	360026	798	あなたはプロジェクト実行管理（PM-004）のアンケートを完成しました。	2018-11-20
823	430022	806	あなたはプロジェクト実行管理（PM-004）のアンケートを完成しました。	2018-11-20
825	430050	830	あなたは 李　文強さんの ステータスを アンケート回答待ちに変更しました。	2018-11-21
824	450052	830	UNIX／Linux入門（UMI11L）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-21
826	410011	801	あなたはプロジェクト実行管理（PM-004）のアンケートを完成しました。	2018-11-21
827	370081	814	あなたは組織力を高めるマネジメントの技術(BS-008)のアンケートを完成しました。	2018-11-21
828	350001	819	あなたは組織力を高めるマネジメントの技術(BS-008)のアンケートを完成しました。	2018-11-21
829	360056	822	あなたは組織力を高めるマネジメントの技術(BS-008)のアンケートを完成しました。	2018-11-21
830	350017	816	あなたは組織力を高めるマネジメントの技術(BS-008)のアンケートを完成しました。	2018-11-22
831	400015	817	あなたは組織力を高めるマネジメントの技術(BS-008)のアンケートを完成しました。	2018-11-22
832	410009	802	あなたはプロジェクト実行管理（PM-004）のアンケートを完成しました。	2018-11-26
833	430050	829	あなたは 徳永　恭介さんの ステータスを アンケート回答待ちに変更しました。	2018-11-26
834	460031	829	UNIX／Linux入門（UMI11L）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-26
835	400009	827	あなたはNode.js + Express + MongoDB ～JavaScript によるｻｰﾊﾞｰｻｲﾄﾞWebｱﾌﾟﾘｹｰｼｮﾝ開発 (WSC0065R)のアンケートを完成しました。	2018-11-26
836	290009	821	あなたは組織力を高めるマネジメントの技術(BS-008)のアンケートを完成しました。	2018-11-28
837	430050	1224	組織を強くする問題解決の技術(BS-007) に申込をしました。	2018-11-28
838	430050	1224	あなたは 秋山　美也子さんの ステータスを アンケート回答待ちに変更しました。	2018-11-28
839	430050	1224	組織を強くする問題解決の技術(BS-007)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-28
840	430050	1224	組織を強くする問題解決の技術(BS-007) をキャンセルしました。	2018-11-28
841	430050	1224	あなたは 秋山　美也子さんの ステータスを 申込不可に変更しました。	2018-11-28
842	430050	1224	組織を強くする問題解決の技術(BS-007)のステータスは、秋山　美也子さんによって申込不可に変更されました	2018-11-28
843	430050	1009	あなたは 秋山　美也子さんの ステータスを アンケート回答待ちに変更しました。	2018-11-28
844	430050	1009	プロジェクトマネジメントの技法 (UAQ41L) のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-11-28
845	430050	1009	プロジェクトマネジメントの技法 (UAQ41L) のステータスは、秋山　美也子さんによってキャンセル（有償）に変更されました	2018-11-28
846	430050	1009	あなたは 秋山　美也子さんの ステータスを キャンセル（有償）に変更しました。	2018-11-28
847	430009	828	あなたはPJリーダのための戦略的交渉術 ～交渉戦略の立案と実践スキル～(UZE88L) のアンケートを完成しました。	2018-11-29
848	440068	813	あなたは組織力を高めるマネジメントの技術(BS-008)のアンケートを完成しました。	2018-11-29
849	430050	841	あなたは 竹内　博徳さんの ステータスを キャンセルに変更しました。	2018-12-03
850	430019	841	組織を強くする問題解決の技術(BS-007)のステータスは、秋山　美也子さんによってキャンセルに変更されました	2018-12-03
851	430029	795	あなたはビジネスコミュニケーション 【advance】（BS-004）のアンケートを完成しました。	2018-12-04
852	460042	831	Excel VBA　による部門業務システムの構築（UUL79L）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-12-04
853	430050	831	あなたは 村上　峻介さんの ステータスを アンケート回答待ちに変更しました。	2018-12-04
854	460042	831	あなたはExcel VBA　による部門業務システムの構築（UUL79L）のアンケートを完成しました。	2018-12-05
856	430050	832	あなたは 奥田　茉莉さんの ステータスを アンケート回答待ちに変更しました。	2018-12-10
855	440014	832	作業プランニング／タイムマネジメント（BS-001）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-12-10
857	450045	833	作業プランニング／タイムマネジメント（BS-001）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-12-10
858	430050	833	あなたは ミヤシロ　プレストン　アランさんの ステータスを アンケート回答待ちに変更しました。	2018-12-10
859	460046	834	作業プランニング／タイムマネジメント（BS-001）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-12-10
860	430050	834	あなたは 柳瀬　研志さんの ステータスを アンケート回答待ちに変更しました。	2018-12-10
861	460029	835	作業プランニング／タイムマネジメント（BS-001）のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-12-10
862	430050	835	あなたは ZHANG　XINさんの ステータスを アンケート回答待ちに変更しました。	2018-12-10
863	460046	834	あなたは作業プランニング／タイムマネジメント（BS-001）のアンケートを完成しました。	2018-12-11
864	450039	811	あなたは組織力を高めるマネジメントの技術(BS-008)のアンケートを完成しました。	2018-12-12
865	420014	838	事例から学ぶ　アジャイル開発のプロジェクトマネジメント(UBS79L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-12-17
866	430050	838	あなたは 齋藤　聡さんの ステータスを アンケート回答待ちに変更しました。	2018-12-17
867	320020	837	事例から学ぶ　アジャイル開発のプロジェクトマネジメント(UBS79L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-12-17
868	430050	837	あなたは 黒河　佳代さんの ステータスを アンケート回答待ちに変更しました。	2018-12-17
869	420025	839	組織を強くする問題解決の技術(BS-007)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-12-17
870	430050	839	あなたは 陳　凌君さんの ステータスを アンケート回答待ちに変更しました。	2018-12-17
871	430050	845	あなたは 清水　裕人さんの ステータスを アンケート回答待ちに変更しました。	2018-12-17
872	410018	845	組織を強くする問題解決の技術(BS-007)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-12-17
873	430050	844	あなたは 原　和子さんの ステータスを アンケート回答待ちに変更しました。	2018-12-17
874	260018	844	組織を強くする問題解決の技術(BS-007)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-12-17
875	430050	843	あなたは 楯岡　啓さんの ステータスを アンケート回答待ちに変更しました。	2018-12-17
876	310017	843	組織を強くする問題解決の技術(BS-007)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-12-17
877	430050	842	あなたは 河上　拓未さんの ステータスを アンケート回答待ちに変更しました。	2018-12-17
878	440017	842	組織を強くする問題解決の技術(BS-007)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-12-17
879	430050	840	あなたは 佐藤　志暢さんの ステータスを アンケート回答待ちに変更しました。	2018-12-17
880	420015	840	組織を強くする問題解決の技術(BS-007)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-12-17
881	450045	833	あなたは作業プランニング／タイムマネジメント（BS-001）のアンケートを完成しました。	2018-12-17
882	380066	836	事例から学ぶ　アジャイル開発のプロジェクトマネジメント(UBS79L)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-12-18
883	430050	836	あなたは 今井　正さんの ステータスを アンケート回答待ちに変更しました。	2018-12-18
884	460070	755	プロジェクトマネジメントの技法 (UAQ41L) のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
885	430050	755	あなたは 中村　義一さんの ステータスを 完了に変更しました。	2018-12-18
886	450003	722	JavaScriptプログラミング基礎 (UJS36L)のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
887	430050	722	あなたは 井出　好希さんの ステータスを 完了に変更しました。	2018-12-18
888	420011	754	プロジェクトマネジメントの技法 (UAQ41L) のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
889	430050	754	あなたは 川瀬　優さんの ステータスを 完了に変更しました。	2018-12-18
890	410034	767	事例から学ぶ　アジャイル開発のプロジェクトマネジメント(UBS79L)のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
891	430050	767	あなたは 三宅　隆一郎さんの ステータスを 完了に変更しました。	2018-12-18
892	430050	760	あなたは 落合　彬さんの ステータスを 完了に変更しました。	2018-12-18
893	470015	760	作業プランニング／タイムマネジメント（BS-001）のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
894	430050	744	あなたは 加藤　拳太さんの ステータスを 完了に変更しました。	2018-12-18
895	460010	744	UNIX／Linux入門（UMI11L）のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
896	270015	750	Microsoft Azure入門 (UCV42L) のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
897	430050	750	あなたは 鈴木　照幸さんの ステータスを 完了に変更しました。	2018-12-18
899	350013	751	Androidアプリ開発－WebAPI、非同期処理、サービス－ (UFN51L)のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
898	430050	751	あなたは 北谷　浩貴さんの ステータスを 完了に変更しました。	2018-12-18
900	430050	747	あなたは 田中　晃さんの ステータスを 完了に変更しました。	2018-12-18
901	460028	747	UNIX／Linux入門（UMI11L）のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
902	460024	748	UNIX／Linux入門（UMI11L）のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
903	430050	748	あなたは 園部　啓太さんの ステータスを 完了に変更しました。	2018-12-18
904	380038	741	Microsoft Azure入門 (UCV42L) のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
905	430050	741	あなたは 松葉　慧さんの ステータスを 完了に変更しました。	2018-12-18
906	460036	745	UNIX／Linux入門（UMI11L）のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
907	430050	745	あなたは 西村　明莉さんの ステータスを 完了に変更しました。	2018-12-18
908	430040	752	プロジェクトマネジメントの技法 (UAQ41L) のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
909	430050	752	あなたは 湯川　翔太さんの ステータスを 完了に変更しました。	2018-12-18
910	280014	753	プロジェクトマネジメントの技法 (UAQ41L) のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
911	430050	753	あなたは 高橋　浩司さんの ステータスを 完了に変更しました。	2018-12-18
913	460008	757	作業プランニング／タイムマネジメント（BS-001）のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
912	430050	757	あなたは 大山　翔平さんの ステータスを 完了に変更しました。	2018-12-18
914	370033	758	作業プランニング／タイムマネジメント（BS-001）のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
915	430050	758	あなたは 朴　志桓さんの ステータスを 完了に変更しました。	2018-12-18
916	430050	762	あなたは 松浦　優さんの ステータスを 完了に変更しました。	2018-12-18
917	470044	762	作業プランニング／タイムマネジメント（BS-001）のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
918	430050	775	あなたは 松浦　優さんの ステータスを 完了に変更しました。	2018-12-18
919	470044	775	基礎から学ぶ！Excelマクロ機能による業務の自動化 (UUF09L)のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
920	430050	765	あなたは 山田　太一さんの ステータスを 完了に変更しました。	2018-12-18
921	320038	765	事例から学ぶ　アジャイル開発のプロジェクトマネジメント(UBS79L)のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
922	430050	783	あなたは 上田　康誉さんの ステータスを 完了に変更しました。	2018-12-18
923	420004	783	ＳＥに求められるヒアリングスキル(UZE66L)のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
924	320004	689	プロジェクト実行管理（PM-004）のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
925	430050	689	あなたは 池島　祥子さんの ステータスを 完了に変更しました。	2018-12-18
926	430050	782	あなたは 大野　悟さんの ステータスを 完了に変更しました。	2018-12-18
927	320013	782	ＳＥに求められるヒアリングスキル(UZE66L)のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
928	410049	784	ＳＥに求められるヒアリングスキル(UZE66L)のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
929	430050	784	あなたは 安武　浩二さんの ステータスを 完了に変更しました。	2018-12-18
930	400035	800	プロジェクト実行管理（PM-004）のステータスは、秋山　美也子さんによって完了に変更されました	2018-12-18
931	430050	800	あなたは 山本　悟さんの ステータスを 完了に変更しました。	2018-12-18
933	430050	1224	あなたは 秋山　美也子さんの ステータスを アンケート回答待ちに変更しました。	2018-12-19
932	430050	1224	組織を強くする問題解決の技術(BS-007)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2018-12-19
934	440014	832	あなたは作業プランニング／タイムマネジメント（BS-001）のアンケートを完成しました。	2018-12-19
935	420015	840	あなたは組織を強くする問題解決の技術(BS-007)のアンケートを完成しました。	2018-12-19
936	420014	838	あなたは事例から学ぶ　アジャイル開発のプロジェクトマネジメント(UBS79L)のアンケートを完成しました。	2018-12-20
937	260018	844	あなたは組織を強くする問題解決の技術(BS-007)のアンケートを完成しました。	2018-12-21
938	310017	843	あなたは組織を強くする問題解決の技術(BS-007)のアンケートを完成しました。	2018-12-25
940	430050	728	あなたは 田原　和俊さんの ステータスを キャンセルに変更しました。	2018-12-26
939	360053	728	Microsoft Azure入門 (UCV42L) のステータスは、秋山　美也子さんによってキャンセルに変更されました	2018-12-26
941	430050	1225	あなたは田原　和俊さんの代わりに、Microsoft Azure入門 (UCV42L)  を登録しました。	2018-12-26
942	360053	1225	あなたは秋山　美也子さんにMicrosoft Azure入門 (UCV42L) が代替登録されましました。	2018-12-26
943	430013	729	Microsoft Azure入門 (UCV42L) のステータスは、秋山　美也子さんによってキャンセルに変更されました	2018-12-26
944	430050	729	あなたは 来間　さやかさんの ステータスを キャンセルに変更しました。	2018-12-26
945	430013	1226	あなたは秋山　美也子さんにMicrosoft Azure入門 (UCV42L) が代替登録されましました。	2018-12-26
946	430050	1226	あなたは来間　さやかさんの代わりに、Microsoft Azure入門 (UCV42L)  を登録しました。	2018-12-26
947	430013	1226	Microsoft Azure入門 (UCV42L) のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-12-26
948	430050	1226	あなたは 来間　さやかさんの ステータスを 開始待ちに変更しました。	2018-12-26
949	360053	1225	Microsoft Azure入門 (UCV42L) のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-12-26
950	430050	1225	あなたは 田原　和俊さんの ステータスを 開始待ちに変更しました。	2018-12-26
951	430050	724	あなたは 細川　雅行さんの ステータスを キャンセルに変更しました。	2018-12-26
952	440044	724	プロジェクトマネジメントの技法 (UAQ41L) のステータスは、秋山　美也子さんによってキャンセルに変更されました	2018-12-26
953	430050	1227	あなたは細川　雅行さんの代わりに、プロジェクトマネジメントの技法 (UAQ41L)  を登録しました。	2018-12-26
954	440044	1227	あなたは秋山　美也子さんにプロジェクトマネジメントの技法 (UAQ41L) が代替登録されましました。	2018-12-26
955	430050	1227	あなたは 細川　雅行さんの ステータスを 開始待ちに変更しました。	2018-12-26
956	440044	1227	プロジェクトマネジメントの技法 (UAQ41L) のステータスは、秋山　美也子さんによって開始待ちに変更されました	2018-12-26
957	450061	1228	あなたは秋山　美也子さんに基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L)が代替登録されましました。	2019-01-15
958	430050	1228	あなたは北野　聡美さんの代わりに、基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L) を登録しました。	2019-01-15
959	450061	1228	あなたは秋山　美也子さんに基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L)がキャンセルされました。	2019-01-15
960	430050	1228	あなたは北野　聡美さんの代わりに、基礎から学ぶ！Excel VBA による業務の自動化 (UUL80L) をキャンセルしました。	2019-01-15
962	450061	1229	あなたは秋山　美也子さんの代わりに、新任JP-B研修 を登録しました。	2019-01-18
961	430050	1229	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-18
963	430050	1229	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-18
964	450061	1229	あなたは 秋山　美也子さんの ステータスを 完了に変更しました。	2019-01-18
965	450061	1229	あなたは 秋山　美也子さんの ステータスを 申込不可に変更しました。	2019-01-18
966	430050	1229	新任JP-B研修のステータスは、北野　聡美さんによって申込不可に変更されました	2019-01-18
968	270009	1230	あなたは秋山　美也子さんにキャリア研修（40代向け）が代替登録されましました。	2019-01-21
967	430050	1230	あなたは小俣　和也さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-01-21
969	340051	1231	あなたは北野　聡美さんにキャリア研修（40代向け）が代替登録されましました。	2019-01-21
970	450061	1231	あなたは石黒　志野さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-01-21
971	450061	1232	あなたは齋藤　一成さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-01-21
972	270011	1232	あなたは北野　聡美さんにキャリア研修（40代向け）が代替登録されましました。	2019-01-21
973	450061	1233	あなたは遠藤　広之さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-01-21
974	270004	1233	あなたは北野　聡美さんにキャリア研修（40代向け）が代替登録されましました。	2019-01-21
975	270015	1234	あなたは北野　聡美さんにキャリア研修（40代向け）が代替登録されましました。	2019-01-21
976	450061	1234	あなたは鈴木　照幸さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-01-21
977	350054	1235	あなたは北野　聡美さんにキャリア研修（40代向け）が代替登録されましました。	2019-01-21
978	450061	1235	あなたは西田　智さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-01-21
979	450061	1236	あなたは高木　和幸さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-01-21
980	370051	1236	あなたは北野　聡美さんにキャリア研修（40代向け）が代替登録されましました。	2019-01-21
981	450061	1237	あなたは村木　正史さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-01-21
982	390038	1237	あなたは北野　聡美さんにキャリア研修（40代向け）が代替登録されましました。	2019-01-21
983	450061	1238	あなたは作間　啓介さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-01-21
984	410045	1238	あなたは北野　聡美さんにキャリア研修（40代向け）が代替登録されましました。	2019-01-21
985	470052	1239	あなたは北野　聡美さんにキャリア研修（40代向け）が代替登録されましました。	2019-01-21
986	450061	1239	あなたは鴻池　伸欣さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-01-21
987	360056	1240	あなたは北野　聡美さんにキャリア研修（40代向け）が代替登録されましました。	2019-01-21
988	450061	1240	あなたは小山内　克朋さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-01-21
989	450061	1241	あなたは松田　譲さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-01-21
990	270023	1241	あなたは北野　聡美さんにキャリア研修（40代向け）が代替登録されましました。	2019-01-21
991	380053	1242	あなたは北野　聡美さんにキャリア研修（40代向け）が代替登録されましました。	2019-01-21
992	450061	1242	あなたは中野　充啓さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-01-21
993	450061	1243	あなたは吉川　晃司さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-01-21
994	340054	1243	あなたは北野　聡美さんにキャリア研修（40代向け）が代替登録されましました。	2019-01-21
995	450061	1244	あなたは大槻　浩二さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-01-21
996	270005	1244	あなたは北野　聡美さんにキャリア研修（40代向け）が代替登録されましました。	2019-01-21
997	380061	1245	あなたは北野　聡美さんにキャリア研修（40代向け）が代替登録されましました。	2019-01-21
998	450061	1245	あなたは新田　純一さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-01-21
999	450061	1246	あなたは永田　夏子さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-01-21
1000	270014	1246	あなたは北野　聡美さんにキャリア研修（40代向け）が代替登録されましました。	2019-01-21
1001	270013	1247	あなたは北野　聡美さんにキャリア研修（40代向け）が代替登録されましました。	2019-01-21
1002	450061	1247	あなたは白石　智代さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-01-21
1003	470054	1248	あなたは北野　聡美さんにキャリア研修（40代向け）が代替登録されましました。	2019-01-21
1004	450061	1248	あなたは瀧川　太爾さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-01-21
1005	470054	1248	キャリア研修（40代向け）のステータスは、北野　聡美さんによってキャンセルに変更されました	2019-01-21
1006	450061	1248	あなたは 瀧川　太爾さんの ステータスを キャンセルに変更しました。	2019-01-21
1007	270013	1247	キャリア研修（40代向け）のステータスは、北野　聡美さんによってキャンセルに変更されました	2019-01-21
1008	450061	1247	あなたは 白石　智代さんの ステータスを キャンセルに変更しました。	2019-01-21
1009	270014	1246	キャリア研修（40代向け）のステータスは、北野　聡美さんによってキャンセルに変更されました	2019-01-21
1010	450061	1246	あなたは 永田　夏子さんの ステータスを キャンセルに変更しました。	2019-01-21
1011	380061	1245	キャリア研修（40代向け）のステータスは、北野　聡美さんによってキャンセルに変更されました	2019-01-21
1012	450061	1245	あなたは 新田　純一さんの ステータスを キャンセルに変更しました。	2019-01-21
2280	280019	1541	あなたは GAO　XUANさんの ステータスを 完了に変更しました。	2019-08-02
1013	270005	1244	キャリア研修（40代向け）のステータスは、北野　聡美さんによってキャンセルに変更されました	2019-01-21
1014	450061	1244	あなたは 大槻　浩二さんの ステータスを キャンセルに変更しました。	2019-01-21
1015	340054	1243	キャリア研修（40代向け）のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1016	450061	1243	あなたは 吉川　晃司さんの ステータスを 完了に変更しました。	2019-01-21
1017	380053	1242	キャリア研修（40代向け）のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1018	450061	1242	あなたは 中野　充啓さんの ステータスを 完了に変更しました。	2019-01-21
1019	450061	1241	あなたは 松田　譲さんの ステータスを 完了に変更しました。	2019-01-21
1020	270023	1241	キャリア研修（40代向け）のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1021	360056	1240	キャリア研修（40代向け）のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1022	450061	1240	あなたは 小山内　克朋さんの ステータスを 完了に変更しました。	2019-01-21
1023	470052	1239	キャリア研修（40代向け）のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1024	450061	1239	あなたは 鴻池　伸欣さんの ステータスを 完了に変更しました。	2019-01-21
1025	450061	1238	あなたは 作間　啓介さんの ステータスを 完了に変更しました。	2019-01-21
1026	410045	1238	キャリア研修（40代向け）のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1027	450061	1237	あなたは 村木　正史さんの ステータスを 完了に変更しました。	2019-01-21
1028	390038	1237	キャリア研修（40代向け）のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1029	450061	1236	あなたは 高木　和幸さんの ステータスを 完了に変更しました。	2019-01-21
1030	370051	1236	キャリア研修（40代向け）のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1031	350054	1235	キャリア研修（40代向け）のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1032	450061	1235	あなたは 西田　智さんの ステータスを 完了に変更しました。	2019-01-21
1033	270015	1234	キャリア研修（40代向け）のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1034	450061	1234	あなたは 鈴木　照幸さんの ステータスを 完了に変更しました。	2019-01-21
1035	270004	1233	キャリア研修（40代向け）のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1036	450061	1233	あなたは 遠藤　広之さんの ステータスを 完了に変更しました。	2019-01-21
1037	270011	1232	キャリア研修（40代向け）のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1038	450061	1232	あなたは 齋藤　一成さんの ステータスを 完了に変更しました。	2019-01-21
1039	450061	1231	あなたは 石黒　志野さんの ステータスを 完了に変更しました。	2019-01-21
1040	340051	1231	キャリア研修（40代向け）のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1041	450061	1230	あなたは 小俣　和也さんの ステータスを 完了に変更しました。	2019-01-21
1042	270009	1230	キャリア研修（40代向け）のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1043	450061	1249	あなたは穂積　正純さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1044	440045	1249	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1045	450061	1250	あなたは澄川　彬さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1046	370022	1250	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1047	450061	1251	あなたは伊藤　翔さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1048	420002	1251	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1049	450061	1252	あなたは高田　旭さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1050	460054	1252	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1051	440021	1253	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1052	450061	1253	あなたは侯　毅さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1053	430029	1254	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1054	450061	1254	あなたは中村　裕恵さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1055	460070	1255	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1056	450061	1255	あなたは中村　義一さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1057	370022	1250	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1058	450061	1250	あなたは 澄川　彬さんの ステータスを 完了に変更しました。	2019-01-21
1059	460070	1255	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1060	450061	1255	あなたは 中村　義一さんの ステータスを 完了に変更しました。	2019-01-21
1061	440045	1249	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1062	450061	1249	あなたは 穂積　正純さんの ステータスを 完了に変更しました。	2019-01-21
1063	450061	1251	あなたは 伊藤　翔さんの ステータスを 完了に変更しました。	2019-01-21
1064	420002	1251	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1065	440021	1253	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1066	450061	1253	あなたは 侯　毅さんの ステータスを 完了に変更しました。	2019-01-21
1067	430029	1254	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1068	450061	1254	あなたは 中村　裕恵さんの ステータスを 完了に変更しました。	2019-01-21
1069	460054	1252	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1070	450061	1252	あなたは 高田　旭さんの ステータスを 完了に変更しました。	2019-01-21
1071	450061	1256	あなたは澤谷　航介さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1072	450019	1256	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1073	450061	1257	あなたは松田　達朗さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1074	450039	1257	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1075	450061	1258	あなたは守屋　亮太さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1076	440049	1258	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1077	450061	1259	あなたは佐々木　弥生さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1078	430017	1259	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1079	450061	1260	あなたは木村　湧志さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1080	440019	1260	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1081	450061	1261	あなたは石川　晃さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1082	450002	1261	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1083	450061	1262	あなたは永島　彰吾さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1084	460034	1262	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1085	450061	1263	あなたは金澤　清二朗さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1086	460064	1263	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1087	440040	1264	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1088	450061	1264	あなたは原澤　あゆみさんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1089	450061	1265	あなたは山本　泰さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1090	440051	1265	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1091	450004	1266	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1092	450061	1266	あなたは岩城　敦士さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1093	450061	1267	あなたは深澤　朋也さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1094	450033	1267	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1095	390036	1268	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1096	450061	1268	あなたは清野　卓也さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1097	450061	1269	あなたは高田　裕能さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1098	440026	1269	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1099	450061	1270	あなたは臼井　時大さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1100	450005	1270	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1101	410028	1271	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1102	450061	1271	あなたは戸谷　敬さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1103	460061	1272	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1104	450061	1272	あなたは潮田　学さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1105	440017	1273	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1106	450061	1273	あなたは河上　拓未さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1107	450061	1274	あなたは中屋　成貴さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1108	440035	1274	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1109	450061	1275	あなたは中村　湧さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1110	430030	1275	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1111	380060	1276	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1112	450061	1276	あなたは藤本　伸吾さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1113	450061	1277	あなたは奥井　達哉さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1114	440013	1277	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1115	450061	1278	あなたは奥田　真由さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1116	370083	1278	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1117	460067	1279	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1118	450061	1279	あなたは篠原　秀彦さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1119	430033	1280	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1120	450061	1280	あなたは福西　弘晋さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1121	450061	1281	あなたは遠藤　啓太さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1122	440008	1281	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1123	440070	1282	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1124	450061	1282	あなたは布居　直美さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1125	430018	1283	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1126	450061	1283	あなたは篠倉　克真さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1127	450061	1284	あなたは中村　和樹さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1128	430027	1284	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1129	450061	1285	あなたは来間　さやかさんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1130	430013	1285	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1131	450061	1286	あなたは小南　勝彦さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1132	450071	1286	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1133	450061	1287	あなたは丹羽　紘也さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1134	440037	1287	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1135	450061	1288	あなたは原田　智志さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1136	440041	1288	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1137	450061	1289	あなたは高垣　晴揮さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1138	460053	1289	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1139	450061	1290	あなたは細川　雅行さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1140	440044	1290	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1141	450061	1291	あなたは今井　正さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1142	380066	1291	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1143	450061	1292	あなたは辻内　夏奈子さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1144	450056	1292	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1145	410044	1293	あなたは北野　聡美さんに新任JP-B研修が代替登録されましました。	2019-01-21
1146	450061	1293	あなたは永井　久栄さんの代わりに、新任JP-B研修 を登録しました。	2019-01-21
1147	450019	1256	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1148	450061	1256	あなたは 澤谷　航介さんの ステータスを 完了に変更しました。	2019-01-21
1149	450061	1285	あなたは 来間　さやかさんの ステータスを 完了に変更しました。	2019-01-21
1150	430013	1285	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1151	450061	1284	あなたは 中村　和樹さんの ステータスを 完了に変更しました。	2019-01-21
1152	430027	1284	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1153	430018	1283	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1154	450061	1283	あなたは 篠倉　克真さんの ステータスを 完了に変更しました。	2019-01-21
1155	440070	1282	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1156	450061	1282	あなたは 布居　直美さんの ステータスを 完了に変更しました。	2019-01-21
1157	440008	1281	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1158	450061	1281	あなたは 遠藤　啓太さんの ステータスを 完了に変更しました。	2019-01-21
1159	430033	1280	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1160	450061	1280	あなたは 福西　弘晋さんの ステータスを 完了に変更しました。	2019-01-21
1161	460067	1279	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1162	450061	1279	あなたは 篠原　秀彦さんの ステータスを 完了に変更しました。	2019-01-21
1163	370083	1278	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1164	450061	1278	あなたは 奥田　真由さんの ステータスを 完了に変更しました。	2019-01-21
1165	440013	1277	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1166	450061	1277	あなたは 奥井　達哉さんの ステータスを 完了に変更しました。	2019-01-21
1167	450061	1276	あなたは 藤本　伸吾さんの ステータスを 完了に変更しました。	2019-01-21
1168	380060	1276	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1169	430030	1275	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1170	450061	1275	あなたは 中村　湧さんの ステータスを 完了に変更しました。	2019-01-21
1171	440035	1274	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1172	450061	1274	あなたは 中屋　成貴さんの ステータスを 完了に変更しました。	2019-01-21
1173	450061	1273	あなたは 河上　拓未さんの ステータスを 完了に変更しました。	2019-01-21
1174	440017	1273	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1175	460061	1272	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1176	450061	1272	あなたは 潮田　学さんの ステータスを 完了に変更しました。	2019-01-21
1177	410028	1271	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1178	450061	1271	あなたは 戸谷　敬さんの ステータスを 完了に変更しました。	2019-01-21
1179	450061	1270	あなたは 臼井　時大さんの ステータスを 完了に変更しました。	2019-01-21
1180	450005	1270	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1181	440026	1269	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1182	450061	1269	あなたは 高田　裕能さんの ステータスを 完了に変更しました。	2019-01-21
1183	450061	1268	あなたは 清野　卓也さんの ステータスを 完了に変更しました。	2019-01-21
1184	390036	1268	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1185	450033	1267	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1186	450061	1267	あなたは 深澤　朋也さんの ステータスを 完了に変更しました。	2019-01-21
1187	450004	1266	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1188	450061	1266	あなたは 岩城　敦士さんの ステータスを 完了に変更しました。	2019-01-21
1189	440051	1265	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1190	450061	1265	あなたは 山本　泰さんの ステータスを 完了に変更しました。	2019-01-21
1191	450061	1264	あなたは 原澤　あゆみさんの ステータスを 完了に変更しました。	2019-01-21
1192	440040	1264	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1193	450061	1263	あなたは 金澤　清二朗さんの ステータスを 完了に変更しました。	2019-01-21
1194	460064	1263	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1195	460034	1262	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1196	450061	1262	あなたは 永島　彰吾さんの ステータスを 完了に変更しました。	2019-01-21
1197	450002	1261	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1198	450061	1261	あなたは 石川　晃さんの ステータスを 完了に変更しました。	2019-01-21
1199	440019	1260	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1200	450061	1260	あなたは 木村　湧志さんの ステータスを 完了に変更しました。	2019-01-21
1201	450061	1259	あなたは 佐々木　弥生さんの ステータスを 完了に変更しました。	2019-01-21
1202	430017	1259	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1203	440049	1258	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1204	450061	1258	あなたは 守屋　亮太さんの ステータスを 完了に変更しました。	2019-01-21
1205	450039	1257	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1206	450061	1257	あなたは 松田　達朗さんの ステータスを 完了に変更しました。	2019-01-21
1207	410044	1293	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1208	450061	1293	あなたは 永井　久栄さんの ステータスを 完了に変更しました。	2019-01-21
1209	450056	1292	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1210	450061	1292	あなたは 辻内　夏奈子さんの ステータスを 完了に変更しました。	2019-01-21
1211	380066	1291	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1212	450061	1291	あなたは 今井　正さんの ステータスを 完了に変更しました。	2019-01-21
1213	450061	1290	あなたは 細川　雅行さんの ステータスを 完了に変更しました。	2019-01-21
1214	440044	1290	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1215	460053	1289	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1216	450061	1289	あなたは 高垣　晴揮さんの ステータスを 完了に変更しました。	2019-01-21
1217	440041	1288	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1218	450061	1288	あなたは 原田　智志さんの ステータスを 完了に変更しました。	2019-01-21
1219	440037	1287	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1220	450061	1287	あなたは 丹羽　紘也さんの ステータスを 完了に変更しました。	2019-01-21
1221	450071	1286	新任JP-B研修のステータスは、北野　聡美さんによって完了に変更されました	2019-01-21
1222	450061	1286	あなたは 小南　勝彦さんの ステータスを 完了に変更しました。	2019-01-21
1223	360053	1225	Microsoft Azure入門 (UCV42L) のステータスは、北野　聡美さんによってキャンセルに変更されました	2019-02-01
1224	450061	1225	あなたは 田原　和俊さんの ステータスを キャンセルに変更しました。	2019-02-01
1226	430013	1226	Microsoft Azure入門 (UCV42L) のステータスは、北野　聡美さんによってアンケート回答待ちに変更されました	2019-02-14
1225	450061	1226	あなたは 来間　さやかさんの ステータスを アンケート回答待ちに変更しました。	2019-02-14
1227	430013	1226	あなたはMicrosoft Azure入門 (UCV42L) のアンケートを完成しました。	2019-02-19
1228	440044	1227	プロジェクトマネジメントの技法 (UAQ41L) のステータスは、北野　聡美さんによってアンケート回答待ちに変更されました	2019-02-27
1229	450061	1227	あなたは 細川　雅行さんの ステータスを アンケート回答待ちに変更しました。	2019-02-27
1230	440044	1227	あなたはプロジェクトマネジメントの技法 (UAQ41L) のアンケートを完成しました。	2019-02-27
1232	470002	1223	Javaデータベースプログラミング (JAC0083G)のステータスは、秋山　美也子さんによってアンケート回答待ちに変更されました	2019-03-13
1231	430050	1223	あなたは 新井　悠介さんの ステータスを アンケート回答待ちに変更しました。	2019-03-13
1233	470002	1223	あなたはJavaデータベースプログラミング (JAC0083G)のアンケートを完成しました。	2019-03-15
1234	290011	1294	幹部研修 に申込をしました。	2019-04-17
1235	290011	1295	test に申込をしました。	2019-04-17
1236	290011	1295	test をキャンセルしました。	2019-04-17
1237	290011	1296	てすと に申込をしました。	2019-04-17
1238	390032	1297	SI型PJ計画書の作り方と リスク判定シートの活用方法 に申込をしました。	2019-04-17
1239	390032	1297	SI型PJ計画書の作り方と リスク判定シートの活用方法 をキャンセルしました。	2019-04-17
1240	390032	1298	品質記録の書き方 に申込をしました。	2019-04-17
1241	390032	1298	品質記録の書き方 をキャンセルしました。	2019-04-17
1242	340051	1299	SI型PJ計画書の作り方と リスク判定シートの活用方法 に申込をしました。	2019-04-17
1243	290011	1300	ＰＭ７つ道具使用手順 に申込をしました。	2019-04-17
1244	290011	1301	SQLトレーニング 【e-learning】 に申込をしました。	2019-04-17
1245	360015	1302	品質分析手法【設計製造編、テスト編】 に申込をしました。	2019-04-17
1246	450010	1303	SI型PJ計画書の作り方と リスク判定シートの活用方法 に申込をしました。	2019-04-17
1247	360015	1302	品質分析手法【設計製造編、テスト編】 をキャンセルしました。	2019-04-17
1248	290016	1304	SI型PJ計画書の作り方と リスク判定シートの活用方法 に申込をしました。	2019-04-17
1249	290016	1304	SI型PJ計画書の作り方と リスク判定シートの活用方法 をキャンセルしました。	2019-04-17
1250	450010	1303	SI型PJ計画書の作り方と リスク判定シートの活用方法 をキャンセルしました。	2019-04-17
1251	340051	1299	あなたは吉鷹 里奈さんにSI型PJ計画書の作り方と リスク判定シートの活用方法がキャンセルされました。	2019-04-17
1252	390032	1299	あなたは石黒 志野さんの代わりに、SI型PJ計画書の作り方と リスク判定シートの活用方法 をキャンセルしました。	2019-04-17
1253	290016	1305	SI型PJ計画書の作り方と リスク判定シートの活用方法 に申込をしました。	2019-04-17
1254	450010	1306	SI型PJ計画書の作り方と リスク判定シートの活用方法 に申込をしました。	2019-04-17
1255	290016	1305	SI型PJ計画書の作り方と リスク判定シートの活用方法 をキャンセルしました。	2019-04-17
1256	450010	1306	SI型PJ計画書の作り方と リスク判定シートの活用方法 をキャンセルしました。	2019-04-17
1257	290037	682	あなたはオペレーショナルマネジャーから戦略的マネジャーへ（AMC0024V）のアンケートを完成しました。	2019-04-17
1258	460069	1307	ＰＭ７つ道具使用手順 に申込をしました。	2019-04-18
1259	460055	1308	ＰＭ７つ道具使用手順 に申込をしました。	2019-04-18
1260	460055	1309	品質分析手法【設計製造編、テスト編】 に申込をしました。	2019-04-18
1261	380060	1310	２９９の施策から紐解く業務カイゼン５つのポイント に申込をしました。	2019-04-24
1262	320056	1311	ＥＮ型ＰＪ計画書の作り方と\vリスク判定シートの活用方法 に申込をしました。	2019-05-27
1263	320056	1311	ＥＮ型ＰＪ計画書の作り方と\vリスク判定シートの活用方法 をキャンセルしました。	2019-05-27
1265	480001	1312	あなたは長谷 真紀さんに新人研修／基本コンテンツが代替登録されました。	2019-06-12
1264	280019	1312	あなたは赤荻 あずみさんの代わりに、新人研修／基本コンテンツ を登録しました。	2019-06-12
1266	280019	1312	あなたは 赤荻　あずみさんの ステータスを 完了に変更しました。	2019-06-12
1267	480001	1312	新人研修／基本コンテンツのステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1268	450025	1313	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1269	280019	1313	あなたは田中 誠也さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1270	450047	1314	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1271	280019	1314	あなたは森山 大輝さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1272	470010	1315	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1273	280019	1315	あなたは大平 龍之介さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1274	280019	1316	あなたは堀川 大輔さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1275	470062	1316	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1276	450023	1317	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1277	280019	1317	あなたは鈴木 梨夏さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1278	280019	1318	あなたはミヤシロ プレストン　アランさんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1279	450045	1318	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1280	470027	1319	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1281	280019	1319	あなたは笹野 健太さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1282	450054	1320	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1283	280019	1320	あなたは渡邊 隼丞さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1284	280019	1321	あなたは杉浦 慶太さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1285	460021	1321	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1286	280019	1313	あなたは 田中　誠也さんの ステータスを 完了に変更しました。	2019-06-12
1287	450025	1313	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1288	280019	1314	あなたは 森山　大輝さんの ステータスを 完了に変更しました。	2019-06-12
1289	450047	1314	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1290	470010	1315	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1291	280019	1315	あなたは 大平　龍之介さんの ステータスを 完了に変更しました。	2019-06-12
1292	280019	1316	あなたは 堀川　大輔さんの ステータスを 完了に変更しました。	2019-06-12
1293	470062	1316	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1294	280019	1317	あなたは 鈴木　梨夏さんの ステータスを 完了に変更しました。	2019-06-12
1295	450023	1317	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1296	280019	1318	あなたは ミヤシロ　プレストン　アランさんの ステータスを 完了に変更しました。	2019-06-12
1297	450045	1318	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1298	280019	1319	あなたは 笹野　健太さんの ステータスを 完了に変更しました。	2019-06-12
1299	470027	1319	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1300	450054	1320	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1301	280019	1320	あなたは 渡邊　隼丞さんの ステータスを 完了に変更しました。	2019-06-12
1302	280019	1321	あなたは 杉浦　慶太さんの ステータスを キャンセルに変更しました。	2019-06-12
1303	460021	1321	OJTトレーナー研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2019-06-12
1304	280019	1322	あなたは吉田 陽一郎さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1305	470049	1322	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1306	280019	1323	あなたは廣木 瑠実菜さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1307	470061	1323	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1308	280019	1324	あなたは中森 健さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1309	460055	1324	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1310	440049	1325	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1311	280019	1325	あなたは守屋 亮太さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1312	280019	1326	あなたは飯野 巧さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1313	460002	1326	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1314	460066	1327	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1315	280019	1327	あなたは長坂 健司さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1316	460052	1328	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1317	280019	1328	あなたは吉原 弾さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1318	280019	1329	あなたは田中 潤さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1319	470064	1329	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1320	280019	1330	あなたは長田 直樹さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1321	450029	1330	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1322	460072	1331	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1323	280019	1331	あなたは矢口 裕希さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1324	280019	1332	あなたは中村 義一さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1325	460070	1332	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1326	360034	1333	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1327	280019	1333	あなたは西條 恵美さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1328	280019	1334	あなたは西村 明莉さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1329	460036	1334	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1330	280019	1335	あなたは上野 栞里さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1331	460005	1335	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1332	280019	1336	あなたは富田 敦也さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1333	450028	1336	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1334	280019	1337	あなたは園部 啓太さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1335	460024	1337	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1336	460048	1338	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1337	280019	1338	あなたは山崎 歩美さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1338	280019	1339	あなたは齊藤 政樹さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1339	450017	1339	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1340	280019	1340	あなたは武田 了大さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1341	460026	1340	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1342	470014	1341	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1343	280019	1341	あなたは荻野 慎之介さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1344	450030	1342	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1345	280019	1342	あなたは中山 翔太さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1346	460019	1343	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1347	280019	1343	あなたは嶋本 龍二さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1348	470012	1344	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1349	280019	1344	あなたは岡崎 航己さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1350	280019	1345	あなたは橋本 香菜さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1351	460038	1345	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1352	280019	1346	あなたは苅田 力斗さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1353	470018	1346	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1354	280019	1347	あなたは矢戸 佑樹さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1355	470046	1347	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1356	280019	1348	あなたは菊池 友貴さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1357	450014	1348	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1358	280019	1349	あなたは高橋 拓臣さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1359	470032	1349	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1360	280019	1350	あなたは加賀 文将さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1361	470016	1350	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1362	450010	1351	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1363	280019	1351	あなたは樫村 尚樹さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1364	460037	1352	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1365	280019	1352	あなたは根本 侑歌さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1366	330026	1353	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1367	280019	1353	あなたは並木 佑介さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1368	450002	1354	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1369	280019	1354	あなたは石川 晃さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1370	430019	1355	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1371	280019	1355	あなたは竹内 博徳さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1372	380005	1356	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1373	280019	1356	あなたは石井 啓太郎さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1374	430009	1357	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1375	280019	1357	あなたは小笠 泰輔さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1376	280019	1358	あなたは蛭田 智子さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1377	460059	1358	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1378	210010	1359	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1379	280019	1359	あなたは片岡 久典さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1380	460044	1360	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1381	280019	1360	あなたは八島 啓太さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1382	460041	1361	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1383	280019	1361	あなたは町田 大希さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1384	460017	1362	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1385	280019	1362	あなたは佐々木 拓也さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1386	280019	1363	あなたは及川 翔さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1387	460007	1363	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1388	280019	1364	あなたは永島 彰吾さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1389	460034	1364	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1390	280019	1365	あなたは杉本 恭彦さんの代わりに、OJTトレーナー研修 を登録しました。	2019-06-12
1391	420019	1365	あなたは長谷 真紀さんにOJTトレーナー研修が代替登録されました。	2019-06-12
1392	280019	1365	あなたは 杉本　恭彦さんの ステータスを キャンセルに変更しました。	2019-06-12
1393	420019	1365	OJTトレーナー研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2019-06-12
1394	280019	1356	あなたは 石井　啓太郎さんの ステータスを キャンセルに変更しました。	2019-06-12
1395	380005	1356	OJTトレーナー研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2019-06-12
1396	280019	1357	あなたは 小笠　泰輔さんの ステータスを キャンセルに変更しました。	2019-06-12
1397	430009	1357	OJTトレーナー研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2019-06-12
1398	280019	1358	あなたは 蛭田　智子さんの ステータスを キャンセルに変更しました。	2019-06-12
1399	460059	1358	OJTトレーナー研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2019-06-12
1400	210010	1359	OJTトレーナー研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2019-06-12
1401	280019	1359	あなたは 片岡　久典さんの ステータスを キャンセルに変更しました。	2019-06-12
1402	280019	1360	あなたは 八島　啓太さんの ステータスを キャンセルに変更しました。	2019-06-12
1403	460044	1360	OJTトレーナー研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2019-06-12
1404	280019	1361	あなたは 町田　大希さんの ステータスを キャンセルに変更しました。	2019-06-12
1405	460041	1361	OJTトレーナー研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2019-06-12
1406	280019	1362	あなたは 佐々木　拓也さんの ステータスを キャンセルに変更しました。	2019-06-12
1407	460017	1362	OJTトレーナー研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2019-06-12
1408	460007	1363	OJTトレーナー研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2019-06-12
1409	280019	1363	あなたは 及川　翔さんの ステータスを キャンセルに変更しました。	2019-06-12
1410	280019	1364	あなたは 永島　彰吾さんの ステータスを キャンセルに変更しました。	2019-06-12
1411	460034	1364	OJTトレーナー研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2019-06-12
1412	470049	1322	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1413	280019	1322	あなたは 吉田　陽一郎さんの ステータスを 完了に変更しました。	2019-06-12
1414	280019	1323	あなたは 廣木　瑠実菜さんの ステータスを 完了に変更しました。	2019-06-12
1415	470061	1323	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1416	280019	1324	あなたは 中森　健さんの ステータスを 完了に変更しました。	2019-06-12
1417	460055	1324	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1418	280019	1325	あなたは 守屋　亮太さんの ステータスを 完了に変更しました。	2019-06-12
1419	440049	1325	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1420	460002	1326	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1421	280019	1326	あなたは 飯野　巧さんの ステータスを 完了に変更しました。	2019-06-12
1422	460066	1327	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1423	280019	1327	あなたは 長坂　健司さんの ステータスを 完了に変更しました。	2019-06-12
1424	280019	1328	あなたは 吉原　弾さんの ステータスを 完了に変更しました。	2019-06-12
1425	460052	1328	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1426	280019	1329	あなたは 田中　潤さんの ステータスを 完了に変更しました。	2019-06-12
1427	470064	1329	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1428	280019	1330	あなたは 長田　直樹さんの ステータスを 完了に変更しました。	2019-06-12
1429	450029	1330	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1430	280019	1331	あなたは 矢口　裕希さんの ステータスを 完了に変更しました。	2019-06-12
1431	460072	1331	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1432	280019	1332	あなたは 中村　義一さんの ステータスを 完了に変更しました。	2019-06-12
1433	460070	1332	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1434	280019	1333	あなたは 西條　恵美さんの ステータスを 完了に変更しました。	2019-06-12
1435	360034	1333	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1436	280019	1334	あなたは 西村　明莉さんの ステータスを 完了に変更しました。	2019-06-12
1437	460036	1334	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1438	280019	1335	あなたは 上野　栞里さんの ステータスを 完了に変更しました。	2019-06-12
1439	460005	1335	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1440	450028	1336	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1441	280019	1336	あなたは 富田　敦也さんの ステータスを 完了に変更しました。	2019-06-12
1442	280019	1337	あなたは 園部　啓太さんの ステータスを 完了に変更しました。	2019-06-12
1443	460024	1337	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1444	280019	1338	あなたは 山崎　歩美さんの ステータスを 完了に変更しました。	2019-06-12
1445	460048	1338	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1446	280019	1339	あなたは 齊藤　政樹さんの ステータスを 完了に変更しました。	2019-06-12
1447	450017	1339	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1448	280019	1340	あなたは 武田　了大さんの ステータスを 完了に変更しました。	2019-06-12
1449	460026	1340	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1450	280019	1341	あなたは 荻野　慎之介さんの ステータスを 完了に変更しました。	2019-06-12
1451	470014	1341	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1452	450030	1342	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1453	280019	1342	あなたは 中山　翔太さんの ステータスを 完了に変更しました。	2019-06-12
1454	280019	1343	あなたは 嶋本　龍二さんの ステータスを 完了に変更しました。	2019-06-12
1455	460019	1343	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1456	470012	1344	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1457	280019	1344	あなたは 岡崎　航己さんの ステータスを 完了に変更しました。	2019-06-12
1458	280019	1345	あなたは 橋本　香菜さんの ステータスを 完了に変更しました。	2019-06-12
1459	460038	1345	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1460	280019	1346	あなたは 苅田　力斗さんの ステータスを 完了に変更しました。	2019-06-12
1461	470018	1346	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1462	280019	1347	あなたは 矢戸　佑樹さんの ステータスを 完了に変更しました。	2019-06-12
1463	470046	1347	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1464	450014	1348	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1465	280019	1348	あなたは 菊池　友貴さんの ステータスを 完了に変更しました。	2019-06-12
1466	470032	1349	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1467	280019	1349	あなたは 高橋　拓臣さんの ステータスを 完了に変更しました。	2019-06-12
1468	280019	1350	あなたは 加賀　文将さんの ステータスを 完了に変更しました。	2019-06-12
1469	470016	1350	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1470	280019	1351	あなたは 樫村　尚樹さんの ステータスを 完了に変更しました。	2019-06-12
1471	450010	1351	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1472	280019	1352	あなたは 根本　侑歌さんの ステータスを 完了に変更しました。	2019-06-12
1473	460037	1352	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1474	280019	1353	あなたは 並木　佑介さんの ステータスを 完了に変更しました。	2019-06-12
1475	330026	1353	OJTトレーナー研修のステータスは、長谷　真紀さんによって完了に変更されました	2019-06-12
1476	280019	1354	あなたは 石川　晃さんの ステータスを キャンセルに変更しました。	2019-06-12
1477	450002	1354	OJTトレーナー研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2019-06-12
1478	280019	1355	あなたは 竹内　博徳さんの ステータスを キャンセルに変更しました。	2019-06-12
1479	430019	1355	OJTトレーナー研修のステータスは、長谷　真紀さんによってキャンセルに変更されました	2019-06-12
1480	460016	1366	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1481	280019	1366	あなたは小林 浩之さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1482	460013	1367	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1483	280019	1367	あなたは久保 颯大朗さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1484	460025	1368	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1485	280019	1368	あなたは澤岻 夏海さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1486	460027	1369	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1487	280019	1369	あなたは田島 みずほさんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1488	280019	1370	あなたは杉山 大貴さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1489	460022	1370	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1490	460044	1371	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1491	280019	1371	あなたは八島 啓太さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1492	460023	1372	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1493	280019	1372	あなたは鈴木 迅馬さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1494	460004	1373	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1495	280019	1373	あなたは井上 薫さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1496	460002	1374	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1497	280019	1374	あなたは飯野 巧さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1499	280019	1375	あなたは及川 翔さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1498	460007	1375	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1500	280019	1376	あなたは大山 翔平さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1501	460008	1376	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1502	280019	1377	あなたは吉原 弾さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1503	460052	1377	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1504	460034	1378	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1505	280019	1378	あなたは永島 彰吾さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1506	460001	1379	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1507	280019	1379	あなたは安孫子 和之さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1508	280019	1380	あなたは佐藤 眞央さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1509	460018	1380	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1510	280019	1381	あなたは熊坂 拓人さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1511	460014	1381	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1512	280019	1382	あなたはZHANG XINさんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1513	460029	1382	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1514	460006	1383	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1515	280019	1383	あなたは上山 真澄さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1516	460046	1384	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1517	280019	1384	あなたは柳瀬 研志さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1518	460031	1385	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1519	280019	1385	あなたは徳永 恭介さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1520	460010	1386	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1521	280019	1386	あなたは加藤 拳太さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1522	460024	1387	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1523	280019	1387	あなたは園部 啓太さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1524	460040	1388	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1525	280019	1388	あなたは前田 淳さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1526	280019	1389	あなたは町田 大希さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1527	460041	1389	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1528	280019	1390	あなたは佐々木 拓也さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1529	460017	1390	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1530	280019	1391	あなたは山崎 歩美さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1531	460048	1391	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1532	280019	1392	あなたは西村 明莉さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1533	460036	1392	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1534	460047	1393	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1535	280019	1393	あなたは山崎 晶子さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1536	280019	1394	あなたは上野 栞里さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1537	460005	1394	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1538	280019	1395	あなたは菅谷 将太郎さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1539	460020	1395	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1540	280019	1396	あなたは武田 了大さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1541	460026	1396	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1542	460050	1397	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1543	280019	1397	あなたは山田 洸太さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1544	280019	1398	あなたは小平 歩さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1545	460015	1398	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1546	280019	1399	あなたは嶋本 龍二さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1547	460019	1399	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1548	460038	1400	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1549	280019	1400	あなたは橋本 香菜さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1550	280019	1401	あなたは中川 大暉さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1551	460032	1401	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1552	280019	1402	あなたは西川 大貴さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1553	460035	1402	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
2116	470035	1528	テスト品質管理 【基礎】 に申込をしました。	2019-07-03
1554	280019	1403	あなたは角田 和統さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1555	460011	1403	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1556	280019	1404	あなたは山地 健大さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1557	460049	1404	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1558	280019	1405	あなたは杉浦 慶太さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1559	460021	1405	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1560	460033	1406	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1561	280019	1406	あなたは中島 弘貴さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1562	280019	1407	あなたは川西 一生さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1563	460012	1407	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1564	460039	1408	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1565	280019	1408	あなたは林 綾乃さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1566	460009	1409	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1567	280019	1409	あなたは尾身 憧也さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1568	280019	1410	あなたは根本 侑歌さんの代わりに、入社3年目研修 を登録しました。	2019-06-12
1569	460037	1410	あなたは長谷 真紀さんに入社3年目研修が代替登録されました。	2019-06-12
1570	450047	1411	ＥＮ型ＰＪ計画書の作り方とリスク判定シートの活用方法 に申込をしました。	2019-06-14
1571	480048	1412	ソフトウェア技術者のための論理思考の文書技術 に申込をしました。	2019-06-18
1573	480001	1413	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1572	280019	1413	あなたは赤荻 あずみさんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1574	280019	1414	あなたは荒牧 楓さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1575	480002	1414	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1576	280019	1415	あなたは石田 亮祐さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1577	480003	1415	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1578	280019	1416	あなたは稲岡 美咲さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1579	480004	1416	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1580	280019	1417	あなたは井上 由美夏さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1581	480005	1417	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1582	480006	1418	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1583	280019	1418	あなたは植木 淳平さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1584	280019	1419	あなたは大塚 裕斗さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1585	480007	1419	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1586	280019	1420	あなたは大橋 彩香さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1587	480008	1420	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1588	480009	1421	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1589	280019	1421	あなたは大林 義明さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1590	280019	1422	あなたは大森 裕介さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1591	480010	1422	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1592	280019	1423	あなたは小川 暁さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1593	480011	1423	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1594	280019	1424	あなたは片岡 義貴さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1595	480012	1424	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1596	480013	1425	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1597	280019	1425	あなたは片貝 勇太さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1598	480014	1426	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1599	280019	1426	あなたは金谷 日和さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1600	280019	1427	あなたは金子 怜叡さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1601	480015	1427	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1602	280019	1428	あなたは金丸 将大さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1603	480016	1428	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1604	480017	1429	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1605	280019	1429	あなたは清塚 大雅さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1606	280019	1430	あなたは窪田 さやかさんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1607	480018	1430	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1608	480019	1431	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1609	280019	1431	あなたは小池 真奈美さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1610	280019	1432	あなたは佐々木 真優さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1611	480020	1432	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1612	480021	1433	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1613	280019	1433	あなたは佐々木 美結さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1614	480022	1434	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1615	280019	1434	あなたは佐藤 眞央さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1616	280019	1435	あなたは塩入 静香さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1617	480023	1435	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1618	480024	1436	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1619	280019	1436	あなたは篠田 涼介さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1620	280019	1437	あなたは下澤 翼さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1621	480025	1437	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1622	480026	1438	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1623	280019	1438	あなたは下田 優馬さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1624	280019	1439	あなたは末釜 瑠璃乃さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1625	480027	1439	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1626	280019	1440	あなたは末松 美樹さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1627	480028	1440	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1628	280019	1441	あなたは鈴木 沙穂さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1629	480029	1441	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1630	280019	1442	あなたは隅田 光さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1631	480030	1442	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1632	280019	1443	あなたは高取 司さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1633	480031	1443	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1634	480032	1444	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1635	280019	1444	あなたは高橋 牧さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1636	480033	1445	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1637	280019	1445	あなたは竹内 香菜さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1638	480034	1446	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1639	280019	1446	あなたは辻村 剛さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1640	480035	1447	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1641	280019	1447	あなたは豊泉 一希さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1642	280019	1448	あなたは中村 博人さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1643	480036	1448	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1644	480037	1449	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1645	280019	1449	あなたは中山 瑞葉さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1646	280019	1450	あなたは永山 幸太さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1647	480038	1450	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1648	280019	1451	あなたは西窪 大樹さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1649	480039	1451	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1650	480040	1452	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1651	280019	1452	あなたは西山 達弥さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1652	280019	1453	あなたは長谷川 悠太さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1653	480041	1453	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1654	280019	1454	あなたは畠山 尭大さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1655	480042	1454	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1656	280019	1455	あなたは早坂 大輔さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1657	480043	1455	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1658	480044	1456	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1659	280019	1456	あなたは半田 開栄さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1660	280019	1457	あなたは升岡 穂乃実さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1661	480045	1457	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1662	480046	1458	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1663	280019	1458	あなたは真鳥 祐さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1664	480047	1459	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1665	280019	1459	あなたは三木 友裕さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1666	480048	1460	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1667	280019	1460	あなたは三橋 翼さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1668	280019	1461	あなたは森 福美さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1669	480049	1461	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1670	280019	1462	あなたは山本 雄河さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1671	480050	1462	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1672	480051	1463	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1673	280019	1463	あなたは吉田 美紀さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1674	280019	1464	あなたは吉田 裕貴さんの代わりに、新人フォローアップ研修 を登録しました。	2019-06-19
1675	480052	1464	あなたは長谷 真紀さんに新人フォローアップ研修が代替登録されました。	2019-06-19
1676	280019	1465	あなたは矢口 裕希さんの代わりに、中途社員研修 を登録しました。	2019-06-19
1677	460072	1465	あなたは長谷 真紀さんに中途社員研修が代替登録されました。	2019-06-19
1678	280019	1466	あなたは鴻池 伸欣さんの代わりに、中途社員研修 を登録しました。	2019-06-19
1679	470052	1466	あなたは長谷 真紀さんに中途社員研修が代替登録されました。	2019-06-19
1680	470054	1467	あなたは長谷 真紀さんに中途社員研修が代替登録されました。	2019-06-19
1681	280019	1467	あなたは瀧川 太爾さんの代わりに、中途社員研修 を登録しました。	2019-06-19
1682	280019	1468	あなたはNGUYEN THI NGOC MAIさんの代わりに、中途社員研修 を登録しました。	2019-06-19
1683	460060	1468	あなたは長谷 真紀さんに中途社員研修が代替登録されました。	2019-06-19
1684	280019	1469	あなたは澤村 沙織理さんの代わりに、中途社員研修 を登録しました。	2019-06-19
1685	470067	1469	あなたは長谷 真紀さんに中途社員研修が代替登録されました。	2019-06-19
1686	470068	1470	あなたは長谷 真紀さんに中途社員研修が代替登録されました。	2019-06-19
1687	280019	1470	あなたは山田 祐也さんの代わりに、中途社員研修 を登録しました。	2019-06-19
1688	280019	1471	あなたは小野田　 裕允さんの代わりに、中途社員研修 を登録しました。	2019-06-19
1689	470069	1471	あなたは長谷 真紀さんに中途社員研修が代替登録されました。	2019-06-19
1690	470070	1472	あなたは長谷 真紀さんに中途社員研修が代替登録されました。	2019-06-19
1691	280019	1472	あなたは中村 瑠美さんの代わりに、中途社員研修 を登録しました。	2019-06-19
1692	480053	1473	あなたは長谷 真紀さんに中途社員研修が代替登録されました。	2019-06-19
1693	280019	1473	あなたは金子 遥さんの代わりに、中途社員研修 を登録しました。	2019-06-19
1694	280019	1474	あなたは富塚 聡さんの代わりに、中途社員研修 を登録しました。	2019-06-19
1695	480054	1474	あなたは長谷 真紀さんに中途社員研修が代替登録されました。	2019-06-19
1696	280019	1475	あなたは後藤 直宏さんの代わりに、中途社員研修 を登録しました。	2019-06-19
1697	480055	1475	あなたは長谷 真紀さんに中途社員研修が代替登録されました。	2019-06-19
1698	280019	1476	あなたは吉田 勝洋さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1699	380044	1476	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1700	280019	1477	あなたは森田 麻美さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1701	380042	1477	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1702	380029	1478	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1703	280019	1478	あなたは陳 小琳さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1704	380038	1479	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1705	280019	1479	あなたは松葉 慧さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1706	380006	1480	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1707	280019	1480	あなたは李 株理さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1708	280019	1481	あなたは陶山 恭平さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1709	380022	1481	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1710	380031	1482	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1711	280019	1482	あなたは中塚 健人さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
2410	000000	1696	テスト品質管理 【実践】 に申込をしました。	2019-09-12
1712	280019	1483	あなたは石井 啓太郎さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1713	380005	1483	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1714	280019	1484	あなたは荒川 薫博さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1715	380002	1484	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1716	280019	1485	あなたは植野 与通さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1717	380008	1485	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1718	280019	1486	あなたは馬渡 聖子さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1719	380039	1486	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1720	380046	1487	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1721	280019	1487	あなたは渡辺 裕之さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1722	380017	1488	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1723	280019	1488	あなたは金野 栄治さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1724	380007	1489	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1725	280019	1489	あなたは今中 章博さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1726	280019	1490	あなたは藤本 祐己さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1727	380034	1490	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1728	370002	1491	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1729	280019	1491	あなたは飯島 大介さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1730	280019	1492	あなたは渡部 健児さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1731	370045	1492	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1732	370027	1493	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1733	280019	1493	あなたは中島 良介さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1734	280019	1494	あなたは持田 壮広さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1735	370041	1494	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1736	280019	1495	あなたは史 礼さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1737	370020	1495	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1738	370056	1496	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1739	280019	1496	あなたは西村 真理代さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1740	280019	1497	あなたは小林 建介さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1741	370016	1497	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1742	370083	1498	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1743	280019	1498	あなたは奥田 真由さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1744	430047	1499	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1745	280019	1499	あなたは柄澤 伸一さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1746	370010	1500	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1747	280019	1500	あなたは金綱 基晴さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1748	280019	1501	あなたは東 由依子さんの代わりに、キャリア研修（30代向け） を登録しました。	2019-06-19
1749	470063	1501	あなたは長谷 真紀さんにキャリア研修（30代向け）が代替登録されました。	2019-06-19
1750	280019	1502	あなたは若松 大起さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-06-19
1751	280031	1502	あなたは長谷 真紀さんにキャリア研修（40代向け）が代替登録されました。	2019-06-19
1752	280019	1503	あなたは伊東 順一さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-06-19
1753	280003	1503	あなたは長谷 真紀さんにキャリア研修（40代向け）が代替登録されました。	2019-06-19
1754	280019	1504	あなたは野田 誠人さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-06-19
1755	280020	1504	あなたは長谷 真紀さんにキャリア研修（40代向け）が代替登録されました。	2019-06-19
1756	280005	1505	あなたは長谷 真紀さんにキャリア研修（40代向け）が代替登録されました。	2019-06-19
1757	280019	1505	あなたは河野 健一さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-06-19
1758	280019	1506	あなたは丸山 龍一郎さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-06-19
1759	280025	1506	あなたは長谷 真紀さんにキャリア研修（40代向け）が代替登録されました。	2019-06-19
1760	280002	1507	あなたは長谷 真紀さんにキャリア研修（40代向け）が代替登録されました。	2019-06-19
1761	280019	1507	あなたは石井 正幸さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-06-19
1762	280010	1508	あなたは長谷 真紀さんにキャリア研修（40代向け）が代替登録されました。	2019-06-19
1763	280019	1508	あなたは清水 亮子さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-06-19
1764	280028	1509	あなたは長谷 真紀さんにキャリア研修（40代向け）が代替登録されました。	2019-06-19
1765	280019	1509	あなたは宮﨑 信人さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-06-19
1766	280019	1510	あなたは三浦 和人さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-06-19
1767	280026	1510	あなたは長谷 真紀さんにキャリア研修（40代向け）が代替登録されました。	2019-06-19
1768	280019	1511	あなたは高橋 浩司さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-06-19
1769	280014	1511	あなたは長谷 真紀さんにキャリア研修（40代向け）が代替登録されました。	2019-06-19
1770	280019	1512	あなたは野村 宗史さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-06-19
1771	280021	1512	あなたは長谷 真紀さんにキャリア研修（40代向け）が代替登録されました。	2019-06-19
1772	280019	1513	キャリア研修（40代向け） に申込をしました。	2019-06-19
1773	380061	1514	あなたは長谷 真紀さんにキャリア研修（40代向け）が代替登録されました。	2019-06-19
1774	280019	1514	あなたは新田 純一さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-06-19
1775	280019	1515	あなたは前田 智美さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-06-19
1776	420049	1515	あなたは長谷 真紀さんにキャリア研修（40代向け）が代替登録されました。	2019-06-19
1777	280019	1516	あなたは瀧川 太爾さんの代わりに、キャリア研修（40代向け） を登録しました。	2019-06-19
1778	470054	1516	あなたは長谷 真紀さんにキャリア研修（40代向け）が代替登録されました。	2019-06-19
1779	470063	1501	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1780	280019	1501	あなたは 東　由依子さんの ステータスを 開始待ちに変更しました。	2019-06-19
1781	280019	1500	あなたは 金綱　基晴さんの ステータスを 開始待ちに変更しました。	2019-06-19
1782	370010	1500	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1783	430047	1499	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1784	280019	1499	あなたは 柄澤　伸一さんの ステータスを 開始待ちに変更しました。	2019-06-19
1785	280019	1498	あなたは 奥田　真由さんの ステータスを 開始待ちに変更しました。	2019-06-19
1786	370083	1498	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1787	370016	1497	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1788	280019	1497	あなたは 小林　建介さんの ステータスを 開始待ちに変更しました。	2019-06-19
1789	280019	1496	あなたは 西村　真理代さんの ステータスを 開始待ちに変更しました。	2019-06-19
1790	370056	1496	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1791	370020	1495	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1792	280019	1495	あなたは 史　礼さんの ステータスを 開始待ちに変更しました。	2019-06-19
1793	280019	1494	あなたは 持田　壮広さんの ステータスを 開始待ちに変更しました。	2019-06-19
1794	370041	1494	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1795	370027	1493	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1796	280019	1493	あなたは 中島　良介さんの ステータスを 開始待ちに変更しました。	2019-06-19
1797	280019	1492	あなたは 渡部　健児さんの ステータスを 開始待ちに変更しました。	2019-06-19
1798	370045	1492	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1799	280019	1491	あなたは 飯島　大介さんの ステータスを 開始待ちに変更しました。	2019-06-19
1800	370002	1491	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1801	280019	1490	あなたは 藤本　祐己さんの ステータスを 開始待ちに変更しました。	2019-06-19
1802	380034	1490	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1803	280019	1489	あなたは 今中　章博さんの ステータスを 開始待ちに変更しました。	2019-06-19
1804	380007	1489	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1805	280019	1488	あなたは 金野　栄治さんの ステータスを 開始待ちに変更しました。	2019-06-19
1806	380017	1488	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1807	280019	1487	あなたは 渡辺　裕之さんの ステータスを 開始待ちに変更しました。	2019-06-19
1808	380046	1487	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1809	380039	1486	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1810	280019	1486	あなたは 馬渡　聖子さんの ステータスを 開始待ちに変更しました。	2019-06-19
1811	280019	1485	あなたは 植野　与通さんの ステータスを 開始待ちに変更しました。	2019-06-19
1812	380008	1485	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1813	380002	1484	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1814	280019	1484	あなたは 荒川　薫博さんの ステータスを 開始待ちに変更しました。	2019-06-19
1815	280019	1483	あなたは 石井　啓太郎さんの ステータスを 開始待ちに変更しました。	2019-06-19
1816	380005	1483	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1817	380031	1482	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1818	280019	1482	あなたは 中塚　健人さんの ステータスを 開始待ちに変更しました。	2019-06-19
1819	380022	1481	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1820	280019	1481	あなたは 陶山　恭平さんの ステータスを 開始待ちに変更しました。	2019-06-19
1821	280019	1480	あなたは 李　株理さんの ステータスを 開始待ちに変更しました。	2019-06-19
1822	380006	1480	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1823	380038	1479	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1824	280019	1479	あなたは 松葉　慧さんの ステータスを 開始待ちに変更しました。	2019-06-19
1825	280019	1478	あなたは 陳　小琳さんの ステータスを 開始待ちに変更しました。	2019-06-19
1826	380029	1478	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1827	380042	1477	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1828	280019	1477	あなたは 森田　麻美さんの ステータスを 開始待ちに変更しました。	2019-06-19
1829	380044	1476	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1830	280019	1476	あなたは 吉田　勝洋さんの ステータスを 開始待ちに変更しました。	2019-06-19
1831	280019	1464	あなたは 吉田　裕貴さんの ステータスを 開始待ちに変更しました。	2019-06-19
1832	480052	1464	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1833	280019	1463	あなたは 吉田　美紀さんの ステータスを 開始待ちに変更しました。	2019-06-19
1834	480051	1463	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1835	280019	1462	あなたは 山本　雄河さんの ステータスを 開始待ちに変更しました。	2019-06-19
1836	480050	1462	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1837	480049	1461	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1838	280019	1461	あなたは 森　福美さんの ステータスを 開始待ちに変更しました。	2019-06-19
1839	280019	1460	あなたは 三橋　翼さんの ステータスを 開始待ちに変更しました。	2019-06-19
1840	480048	1460	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1842	480047	1459	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1841	280019	1459	あなたは 三木　友裕さんの ステータスを 開始待ちに変更しました。	2019-06-19
1843	480046	1458	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1844	280019	1458	あなたは 真鳥　祐さんの ステータスを 開始待ちに変更しました。	2019-06-19
1845	280019	1457	あなたは 升岡　穂乃実さんの ステータスを 開始待ちに変更しました。	2019-06-19
1846	480045	1457	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1847	480044	1456	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1848	280019	1456	あなたは 半田　開栄さんの ステータスを 開始待ちに変更しました。	2019-06-19
1849	480043	1455	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1850	280019	1455	あなたは 早坂　大輔さんの ステータスを 開始待ちに変更しました。	2019-06-19
1851	480042	1454	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1852	280019	1454	あなたは 畠山　尭大さんの ステータスを 開始待ちに変更しました。	2019-06-19
1853	480042	1454	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1854	280019	1454	あなたは 畠山　尭大さんの ステータスを 開始待ちに変更しました。	2019-06-19
1855	480041	1453	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1856	280019	1453	あなたは 長谷川　悠太さんの ステータスを 開始待ちに変更しました。	2019-06-19
1857	480040	1452	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1858	280019	1452	あなたは 西山　達弥さんの ステータスを 開始待ちに変更しました。	2019-06-19
1859	280019	1451	あなたは 西窪　大樹さんの ステータスを 開始待ちに変更しました。	2019-06-19
1860	480039	1451	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1861	480038	1450	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1862	280019	1450	あなたは 永山　幸太さんの ステータスを 開始待ちに変更しました。	2019-06-19
1863	280019	1449	あなたは 中山　瑞葉さんの ステータスを 開始待ちに変更しました。	2019-06-19
1864	480037	1449	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1865	480036	1448	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1866	280019	1448	あなたは 中村　博人さんの ステータスを 開始待ちに変更しました。	2019-06-19
1867	280019	1447	あなたは 豊泉　一希さんの ステータスを 開始待ちに変更しました。	2019-06-19
1868	480035	1447	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1869	480034	1446	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1870	280019	1446	あなたは 辻村　剛さんの ステータスを 開始待ちに変更しました。	2019-06-19
1871	480033	1445	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1872	280019	1445	あなたは 竹内　香菜さんの ステータスを 開始待ちに変更しました。	2019-06-19
1873	480032	1444	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1874	280019	1444	あなたは 高橋　牧さんの ステータスを 開始待ちに変更しました。	2019-06-19
1876	280019	1443	あなたは 高取　司さんの ステータスを 開始待ちに変更しました。	2019-06-19
1875	480031	1443	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1877	280019	1442	あなたは 隅田　光さんの ステータスを 開始待ちに変更しました。	2019-06-19
1878	480030	1442	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1879	280019	1441	あなたは 鈴木　沙穂さんの ステータスを 開始待ちに変更しました。	2019-06-19
1880	480029	1441	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1881	480028	1440	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1882	280019	1440	あなたは 末松　美樹さんの ステータスを 開始待ちに変更しました。	2019-06-19
1883	280019	1439	あなたは 末釜　瑠璃乃さんの ステータスを 開始待ちに変更しました。	2019-06-19
1884	480027	1439	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1885	480026	1438	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1886	280019	1438	あなたは 下田　優馬さんの ステータスを 開始待ちに変更しました。	2019-06-19
1887	280019	1437	あなたは 下澤　翼さんの ステータスを 開始待ちに変更しました。	2019-06-19
1888	480025	1437	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1889	280019	1436	あなたは 篠田　涼介さんの ステータスを 開始待ちに変更しました。	2019-06-19
1890	480024	1436	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1891	280019	1435	あなたは 塩入　静香さんの ステータスを 開始待ちに変更しました。	2019-06-19
1892	480023	1435	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1893	280019	1434	あなたは 佐藤　眞央さんの ステータスを 開始待ちに変更しました。	2019-06-19
1894	480022	1434	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1895	280019	1433	あなたは 佐々木　美結さんの ステータスを 開始待ちに変更しました。	2019-06-19
1896	480021	1433	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1897	280019	1432	あなたは 佐々木　真優さんの ステータスを 開始待ちに変更しました。	2019-06-19
1898	480020	1432	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1899	480019	1431	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1900	280019	1431	あなたは 小池　真奈美さんの ステータスを 開始待ちに変更しました。	2019-06-19
1901	280019	1430	あなたは 窪田　さやかさんの ステータスを 開始待ちに変更しました。	2019-06-19
1902	480018	1430	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1903	280019	1429	あなたは 清塚　大雅さんの ステータスを 開始待ちに変更しました。	2019-06-19
1904	480017	1429	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1905	280019	1428	あなたは 金丸　将大さんの ステータスを 開始待ちに変更しました。	2019-06-19
1906	480016	1428	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1907	480015	1427	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1908	280019	1427	あなたは 金子　怜叡さんの ステータスを 開始待ちに変更しました。	2019-06-19
1909	280019	1426	あなたは 金谷　日和さんの ステータスを 開始待ちに変更しました。	2019-06-19
1910	480014	1426	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1911	280019	1425	あなたは 片貝　勇太さんの ステータスを 開始待ちに変更しました。	2019-06-19
1912	480013	1425	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1913	280019	1424	あなたは 片岡　義貴さんの ステータスを 開始待ちに変更しました。	2019-06-19
1914	480012	1424	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1915	280019	1423	あなたは 小川　暁さんの ステータスを 開始待ちに変更しました。	2019-06-19
1916	480011	1423	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1917	480010	1422	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1918	280019	1422	あなたは 大森　裕介さんの ステータスを 開始待ちに変更しました。	2019-06-19
1919	280019	1421	あなたは 大林　義明さんの ステータスを 開始待ちに変更しました。	2019-06-19
1920	480009	1421	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1921	480008	1420	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1922	280019	1420	あなたは 大橋　彩香さんの ステータスを 開始待ちに変更しました。	2019-06-19
1923	480007	1419	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1924	280019	1419	あなたは 大塚　裕斗さんの ステータスを 開始待ちに変更しました。	2019-06-19
1925	280019	1418	あなたは 植木　淳平さんの ステータスを 開始待ちに変更しました。	2019-06-19
1926	480006	1418	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1927	480005	1417	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1928	280019	1417	あなたは 井上　由美夏さんの ステータスを 開始待ちに変更しました。	2019-06-19
1929	280019	1416	あなたは 稲岡　美咲さんの ステータスを 開始待ちに変更しました。	2019-06-19
1930	480004	1416	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1931	480003	1415	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1932	280019	1415	あなたは 石田　亮祐さんの ステータスを 開始待ちに変更しました。	2019-06-19
1933	280019	1414	あなたは 荒牧　楓さんの ステータスを 開始待ちに変更しました。	2019-06-19
1934	480002	1414	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1935	480001	1413	新人フォローアップ研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1936	280019	1413	あなたは 赤荻　あずみさんの ステータスを 開始待ちに変更しました。	2019-06-19
1937	460037	1410	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1938	280019	1410	あなたは 根本　侑歌さんの ステータスを 開始待ちに変更しました。	2019-06-19
1939	280019	1409	あなたは 尾身　憧也さんの ステータスを 開始待ちに変更しました。	2019-06-19
1940	460009	1409	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1941	280019	1408	あなたは 林　綾乃さんの ステータスを 開始待ちに変更しました。	2019-06-19
1942	460039	1408	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1943	460012	1407	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1944	280019	1407	あなたは 川西　一生さんの ステータスを 開始待ちに変更しました。	2019-06-19
1945	460033	1406	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1946	280019	1406	あなたは 中島　弘貴さんの ステータスを 開始待ちに変更しました。	2019-06-19
1947	280019	1405	あなたは 杉浦　慶太さんの ステータスを 開始待ちに変更しました。	2019-06-19
1948	460021	1405	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1949	460049	1404	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1950	280019	1404	あなたは 山地　健大さんの ステータスを 開始待ちに変更しました。	2019-06-19
1951	460011	1403	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1952	280019	1403	あなたは 角田　和統さんの ステータスを 開始待ちに変更しました。	2019-06-19
1953	280019	1402	あなたは 西川　大貴さんの ステータスを 開始待ちに変更しました。	2019-06-19
1954	460035	1402	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1955	460032	1401	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1956	280019	1401	あなたは 中川　大暉さんの ステータスを 開始待ちに変更しました。	2019-06-19
1957	460038	1400	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1958	280019	1400	あなたは 橋本　香菜さんの ステータスを 開始待ちに変更しました。	2019-06-19
1959	460019	1399	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1960	280019	1399	あなたは 嶋本　龍二さんの ステータスを 開始待ちに変更しました。	2019-06-19
1961	460015	1398	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1962	280019	1398	あなたは 小平　歩さんの ステータスを 開始待ちに変更しました。	2019-06-19
1963	460050	1397	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1964	280019	1397	あなたは 山田　洸太さんの ステータスを 開始待ちに変更しました。	2019-06-19
1965	280019	1396	あなたは 武田　了大さんの ステータスを 開始待ちに変更しました。	2019-06-19
1966	460026	1396	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1967	460020	1395	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1968	280019	1395	あなたは 菅谷　将太郎さんの ステータスを 開始待ちに変更しました。	2019-06-19
1969	460005	1394	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1970	280019	1394	あなたは 上野　栞里さんの ステータスを 開始待ちに変更しました。	2019-06-19
1971	460047	1393	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1972	280019	1393	あなたは 山崎　晶子さんの ステータスを 開始待ちに変更しました。	2019-06-19
1973	280019	1392	あなたは 西村　明莉さんの ステータスを 開始待ちに変更しました。	2019-06-19
1974	460036	1392	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1975	460048	1391	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1976	280019	1391	あなたは 山崎　歩美さんの ステータスを 開始待ちに変更しました。	2019-06-19
1977	280019	1390	あなたは 佐々木　拓也さんの ステータスを 開始待ちに変更しました。	2019-06-19
1978	460017	1390	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1979	460041	1389	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1980	280019	1389	あなたは 町田　大希さんの ステータスを 開始待ちに変更しました。	2019-06-19
1981	460040	1388	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1982	280019	1388	あなたは 前田　淳さんの ステータスを 開始待ちに変更しました。	2019-06-19
1983	280019	1387	あなたは 園部　啓太さんの ステータスを 開始待ちに変更しました。	2019-06-19
1984	460024	1387	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1985	460010	1386	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1986	280019	1386	あなたは 加藤　拳太さんの ステータスを 開始待ちに変更しました。	2019-06-19
1987	280019	1385	あなたは 徳永　恭介さんの ステータスを 開始待ちに変更しました。	2019-06-19
1988	460031	1385	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1989	460046	1384	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1990	280019	1384	あなたは 柳瀬　研志さんの ステータスを 開始待ちに変更しました。	2019-06-19
1991	280019	1383	あなたは 上山　真澄さんの ステータスを 開始待ちに変更しました。	2019-06-19
1992	460006	1383	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1993	460029	1382	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1994	280019	1382	あなたは ZHANG　XINさんの ステータスを 開始待ちに変更しました。	2019-06-19
1995	460014	1381	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1996	280019	1381	あなたは 熊坂　拓人さんの ステータスを 開始待ちに変更しました。	2019-06-19
1997	280019	1380	あなたは 佐藤　眞央さんの ステータスを 開始待ちに変更しました。	2019-06-19
1998	460018	1380	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
1999	460001	1379	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2000	280019	1379	あなたは 安孫子　和之さんの ステータスを 開始待ちに変更しました。	2019-06-19
2001	280019	1378	あなたは 永島　彰吾さんの ステータスを 開始待ちに変更しました。	2019-06-19
2002	460034	1378	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2003	460052	1377	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2004	280019	1377	あなたは 吉原　弾さんの ステータスを 開始待ちに変更しました。	2019-06-19
2005	460008	1376	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2006	280019	1376	あなたは 大山　翔平さんの ステータスを 開始待ちに変更しました。	2019-06-19
2007	460007	1375	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2008	280019	1375	あなたは 及川　翔さんの ステータスを 開始待ちに変更しました。	2019-06-19
2009	460004	1373	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2010	280019	1373	あなたは 井上　薫さんの ステータスを 開始待ちに変更しました。	2019-06-19
2011	460002	1374	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2012	280019	1374	あなたは 飯野　巧さんの ステータスを 開始待ちに変更しました。	2019-06-19
2013	280019	1372	あなたは 鈴木　迅馬さんの ステータスを 開始待ちに変更しました。	2019-06-19
2014	460023	1372	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2015	280019	1371	あなたは 八島　啓太さんの ステータスを 開始待ちに変更しました。	2019-06-19
2016	460044	1371	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2017	460022	1370	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2018	280019	1370	あなたは 杉山　大貴さんの ステータスを 開始待ちに変更しました。	2019-06-19
2019	460027	1369	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2020	280019	1369	あなたは 田島　みずほさんの ステータスを 開始待ちに変更しました。	2019-06-19
2021	280019	1368	あなたは 澤岻　夏海さんの ステータスを 開始待ちに変更しました。	2019-06-19
2022	460025	1368	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2023	460013	1367	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2024	280019	1367	あなたは 久保　颯大朗さんの ステータスを 開始待ちに変更しました。	2019-06-19
2025	460016	1366	入社3年目研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2026	280019	1366	あなたは 小林　浩之さんの ステータスを 開始待ちに変更しました。	2019-06-19
2027	480055	1475	中途社員研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2028	280019	1475	あなたは 後藤　直宏さんの ステータスを 開始待ちに変更しました。	2019-06-19
2029	480054	1474	中途社員研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2030	280019	1474	あなたは 富塚　聡さんの ステータスを 開始待ちに変更しました。	2019-06-19
2031	480053	1473	中途社員研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2032	280019	1473	あなたは 金子　遥さんの ステータスを 開始待ちに変更しました。	2019-06-19
2033	470070	1472	中途社員研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2034	280019	1472	あなたは 中村　瑠美さんの ステータスを 開始待ちに変更しました。	2019-06-19
2035	470069	1471	中途社員研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2036	280019	1471	あなたは 小野田　　裕允さんの ステータスを 開始待ちに変更しました。	2019-06-19
2037	470068	1470	中途社員研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2038	280019	1470	あなたは 山田　祐也さんの ステータスを 開始待ちに変更しました。	2019-06-19
2039	470067	1469	中途社員研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2040	280019	1469	あなたは 澤村　沙織理さんの ステータスを 開始待ちに変更しました。	2019-06-19
2041	280019	1468	あなたは NGUYEN THI NGOC　MAIさんの ステータスを 開始待ちに変更しました。	2019-06-19
2042	460060	1468	中途社員研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2043	280019	1467	あなたは 瀧川　太爾さんの ステータスを 開始待ちに変更しました。	2019-06-19
2044	470054	1467	中途社員研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2045	280019	1466	あなたは 鴻池　伸欣さんの ステータスを 開始待ちに変更しました。	2019-06-19
2046	470052	1466	中途社員研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2047	460072	1465	中途社員研修のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2048	280019	1465	あなたは 矢口　裕希さんの ステータスを 開始待ちに変更しました。	2019-06-19
2049	280019	1516	あなたは 瀧川　太爾さんの ステータスを 開始待ちに変更しました。	2019-06-19
2050	470054	1516	キャリア研修（40代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2051	420049	1515	キャリア研修（40代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2052	280019	1515	あなたは 前田　智美さんの ステータスを 開始待ちに変更しました。	2019-06-19
2053	380061	1514	キャリア研修（40代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2054	280019	1514	あなたは 新田　純一さんの ステータスを 開始待ちに変更しました。	2019-06-19
2055	280019	1513	キャリア研修（40代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2056	280019	1513	あなたは 長谷　真紀さんの ステータスを 開始待ちに変更しました。	2019-06-19
2057	280019	1512	あなたは 野村　宗史さんの ステータスを 開始待ちに変更しました。	2019-06-19
2058	280021	1512	キャリア研修（40代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2059	280019	1511	あなたは 高橋　浩司さんの ステータスを 開始待ちに変更しました。	2019-06-19
2060	280014	1511	キャリア研修（40代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2061	280019	1510	あなたは 三浦　和人さんの ステータスを 開始待ちに変更しました。	2019-06-19
2062	280026	1510	キャリア研修（40代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2063	280019	1509	あなたは 宮﨑　信人さんの ステータスを 開始待ちに変更しました。	2019-06-19
2064	280028	1509	キャリア研修（40代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2065	280010	1508	キャリア研修（40代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2066	280019	1508	あなたは 清水　亮子さんの ステータスを 開始待ちに変更しました。	2019-06-19
2067	280002	1507	キャリア研修（40代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2068	280019	1507	あなたは 石井　正幸さんの ステータスを 開始待ちに変更しました。	2019-06-19
2069	280019	1506	あなたは 丸山　龍一郎さんの ステータスを 開始待ちに変更しました。	2019-06-19
2070	280025	1506	キャリア研修（40代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2071	280005	1505	キャリア研修（40代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2072	280019	1505	あなたは 河野　健一さんの ステータスを 開始待ちに変更しました。	2019-06-19
2073	280020	1504	キャリア研修（40代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2074	280019	1504	あなたは 野田　誠人さんの ステータスを 開始待ちに変更しました。	2019-06-19
2075	280003	1503	キャリア研修（40代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2076	280019	1503	あなたは 伊東　順一さんの ステータスを 開始待ちに変更しました。	2019-06-19
2077	280031	1502	キャリア研修（40代向け）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-19
2078	280019	1502	あなたは 若松　大起さんの ステータスを 開始待ちに変更しました。	2019-06-19
2080	480048	1412	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-06-20
2079	280019	1412	あなたは 三橋　翼さんの ステータスを 開始待ちに変更しました。	2019-06-20
2081	280019	1517	テスト品質管理 【基礎】 に申込をしました。	2019-06-28
2082	470049	1518	Excel VBA　による部門業務システムの構築（UUL79L） に申込をしました。	2019-07-01
2083	470049	1519	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L） に申込をしました。	2019-07-01
2084	470049	1518	Excel VBA　による部門業務システムの構築（UUL79L）のステータスは、長谷　真紀さんによって研修先申込中に変更されました	2019-07-01
2085	280019	1518	あなたは 吉田　陽一郎さんの ステータスを 研修先申込中に変更しました。	2019-07-01
2086	470049	1519	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、長谷　真紀さんによって研修先申込中に変更されました	2019-07-01
2087	280019	1519	あなたは 吉田　陽一郎さんの ステータスを 研修先申込中に変更しました。	2019-07-01
2088	470001	1520	テスト品質管理 【基礎】 に申込をしました。	2019-07-01
2089	470001	1521	ソフトウェア技術者のための論理思考の文書技術 に申込をしました。	2019-07-01
2090	470001	1520	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-01
2091	280019	1520	あなたは 新井　美智子さんの ステータスを 開始待ちに変更しました。	2019-07-01
2092	470001	1521	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-01
2093	280019	1521	あなたは 新井　美智子さんの ステータスを 開始待ちに変更しました。	2019-07-01
2094	480001	1522	ソフトウェア技術者のための論理思考の文書技術 に申込をしました。	2019-07-01
2095	480001	1522	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-01
2096	280019	1522	あなたは 赤荻　あずみさんの ステータスを 開始待ちに変更しました。	2019-07-01
2097	470022	1523	テスト品質管理 【基礎】 に申込をしました。	2019-07-02
2098	470022	1524	ソフトウェア技術者のための論理思考の文書技術 に申込をしました。	2019-07-02
2099	470022	1523	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-02
2100	280019	1523	あなたは 木村　幸奈さんの ステータスを 開始待ちに変更しました。	2019-07-02
2101	470022	1524	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-02
2102	280019	1524	あなたは 木村　幸奈さんの ステータスを 開始待ちに変更しました。	2019-07-02
2103	470069	1525	テスト品質管理 【基礎】 に申込をしました。	2019-07-03
2104	470069	1526	ソフトウェア技術者のための論理思考の文書技術 に申込をしました。	2019-07-03
2105	470069	1525	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-03
2106	280019	1525	あなたは 小野田　　裕允さんの ステータスを 開始待ちに変更しました。	2019-07-03
2107	470069	1526	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-03
2108	280019	1526	あなたは 小野田　　裕允さんの ステータスを 開始待ちに変更しました。	2019-07-03
2109	470049	1518	Excel VBA　による部門業務システムの構築（UUL79L）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-03
2110	280019	1518	あなたは 吉田　陽一郎さんの ステータスを 開始待ちに変更しました。	2019-07-03
2111	470049	1519	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-03
2112	280019	1519	あなたは 吉田　陽一郎さんの ステータスを 開始待ちに変更しました。	2019-07-03
2113	470008	1527	テスト品質管理 【基礎】 に申込をしました。	2019-07-03
2114	470008	1527	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-03
2115	280019	1527	あなたは 魚谷　優治さんの ステータスを 開始待ちに変更しました。	2019-07-03
2117	470035	1528	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-03
2118	280019	1528	あなたは 張　悦さんの ステータスを 開始待ちに変更しました。	2019-07-03
2119	230002	1529	Docker　コンテナと　Dev/Ops に申込をしました。	2019-07-04
2120	230002	1529	Docker　コンテナと　Dev/Ops をキャンセルしました。	2019-07-04
2121	280019	1530	Docker　コンテナと　Dev/Ops に申込をしました。	2019-07-04
2122	280019	1530	Docker　コンテナと　Dev/Ops をキャンセルしました。	2019-07-04
2123	230002	1529	Docker　コンテナと　Dev/Opsのステータスは、長谷　真紀さんによって削除に変更されました	2019-07-04
2124	280019	1529	あなたは 浦出　伸昭さんの ステータスを 削除に変更しました。	2019-07-04
2125	280019	1530	Docker　コンテナと　Dev/Opsのステータスは、長谷　真紀さんによって削除に変更されました	2019-07-04
2126	280019	1530	あなたは 長谷　真紀さんの ステータスを 削除に変更しました。	2019-07-04
2127	480055	1531	Docker　コンテナと　Dev/Ops に申込をしました。	2019-07-05
2128	460036	1532	テスト品質管理 【基礎】 に申込をしました。	2019-07-05
2129	460036	1532	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-05
2130	280019	1532	あなたは 西村　明莉さんの ステータスを 開始待ちに変更しました。	2019-07-05
2131	480044	1533	ソフトウェア技術者のための論理思考の文書技術 に申込をしました。	2019-07-05
2132	480014	1534	ソフトウェア技術者のための論理思考の文書技術 に申込をしました。	2019-07-05
2133	280019	1534	あなたは 金谷　日和さんの ステータスを 開始待ちに変更しました。	2019-07-05
2134	480014	1534	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-05
2135	480044	1533	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-05
2136	280019	1533	あなたは 半田　開栄さんの ステータスを 開始待ちに変更しました。	2019-07-05
2137	470019	1535	ソフトウェア技術者のための論理思考の文書技術 に申込をしました。	2019-07-08
2138	280019	1535	あなたは 河内　晴太さんの ステータスを 開始待ちに変更しました。	2019-07-08
2139	470019	1535	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-08
2140	460024	1536	テスト品質管理 【基礎】 に申込をしました。	2019-07-08
2141	460024	1536	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-08
2142	280019	1536	あなたは 園部　啓太さんの ステータスを 開始待ちに変更しました。	2019-07-08
2143	470044	1537	ソフトウェア技術者のための論理思考の文書技術 に申込をしました。	2019-07-08
2144	470044	1537	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-08
2145	280019	1537	あなたは 松浦　優さんの ステータスを 開始待ちに変更しました。	2019-07-08
2146	470013	1538	ソフトウェア技術者のための論理思考の文書技術 に申込をしました。	2019-07-08
2147	470013	1538	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-08
2148	280019	1538	あなたは 岡本　桂輔さんの ステータスを 開始待ちに変更しました。	2019-07-08
2149	340010	1539	Docker　コンテナと　Dev/Ops に申込をしました。	2019-07-08
2150	460058	1540	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L） に申込をしました。	2019-07-09
2151	470023	1541	ソフトウェア技術者のための論理思考の文書技術 に申込をしました。	2019-07-09
2153	280019	1541	あなたは GAO　XUANさんの ステータスを 開始待ちに変更しました。	2019-07-10
2152	470023	1541	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-10
2154	290001	1542	Docker　コンテナと　Dev/Ops に申込をしました。	2019-07-10
2155	370010	1500	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって削除に変更されました	2019-07-10
2156	280019	1500	あなたは 金綱　基晴さんの ステータスを 削除に変更しました。	2019-07-10
2157	380046	1487	キャリア研修（30代向け）のステータスは、長谷　真紀さんによって削除に変更されました	2019-07-10
2158	280019	1487	あなたは 渡辺　裕之さんの ステータスを 削除に変更しました。	2019-07-10
2159	470028	1543	テスト品質管理 【基礎】 に申込をしました。	2019-07-10
2160	450050	1544	テスト品質管理 【基礎】 に申込をしました。	2019-07-10
2161	280019	1543	あなたは 佐藤　涼さんの ステータスを 開始待ちに変更しました。	2019-07-10
2162	470028	1543	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-10
2163	450050	1544	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-10
2164	280019	1544	あなたは 山口　熙さんの ステータスを 開始待ちに変更しました。	2019-07-10
2165	470057	1545	テスト品質管理 【基礎】 に申込をしました。	2019-07-10
2166	460018	1546	ソフトウェア技術者のための論理思考の文書技術 に申込をしました。	2019-07-10
2167	470057	1545	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-10
2168	280019	1545	あなたは 大川　祥太さんの ステータスを 開始待ちに変更しました。	2019-07-10
2220	280019	1518	あなたは 吉田　陽一郎さんの ステータスを 完了に変更しました。	2019-07-22
2169	460018	1546	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-10
2170	280019	1546	あなたは 佐藤　眞央さんの ステータスを 開始待ちに変更しました。	2019-07-10
2171	440037	1547	Docker　コンテナと　Dev/Ops に申込をしました。	2019-07-11
2172	460058	1540	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、浦出　伸昭さんによって開始待ちに変更されました	2019-07-11
2173	230002	1540	あなたは 海老沼　慶宏さんの ステータスを 開始待ちに変更しました。	2019-07-11
2174	470029	1548	テスト品質管理 【基礎】 に申込をしました。	2019-07-11
2175	470029	1549	ソフトウェア技術者のための論理思考の文書技術 に申込をしました。	2019-07-11
2176	470029	1548	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-11
2177	280019	1548	あなたは 城　大地さんの ステータスを 開始待ちに変更しました。	2019-07-11
2178	470029	1549	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-11
2179	280019	1549	あなたは 城　大地さんの ステータスを 開始待ちに変更しました。	2019-07-11
2180	460055	1550	テスト品質管理 【基礎】 に申込をしました。	2019-07-12
2181	280019	1550	あなたは 中森　健さんの ステータスを 開始待ちに変更しました。	2019-07-12
2182	460055	1550	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-12
2183	250028	1551	テスト品質管理 【実践】 に申込をしました。	2019-07-12
2185	250028	1551	テスト品質管理 【実践】のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-16
2184	280019	1551	あなたは 清水　桂子さんの ステータスを 開始待ちに変更しました。	2019-07-16
2186	460053	1552	Docker　コンテナと　Dev/Ops に申込をしました。	2019-07-16
2187	280019	1553	あなたは古場 翔さんの代わりに、テスト品質管理 【基礎】 を登録しました。	2019-07-16
2188	470025	1553	あなたは長谷 真紀さんにテスト品質管理 【基礎】が代替登録されました。	2019-07-16
2189	280019	1554	あなたは前田 裕佳さんの代わりに、テスト品質管理 【基礎】 を登録しました。	2019-07-16
2190	470043	1554	あなたは長谷 真紀さんにテスト品質管理 【基礎】が代替登録されました。	2019-07-16
2191	280019	1555	あなたは谷口 賢吾さんの代わりに、テスト品質管理 【基礎】 を登録しました。	2019-07-16
2192	470034	1555	あなたは長谷 真紀さんにテスト品質管理 【基礎】が代替登録されました。	2019-07-16
2193	320020	837	あなたは事例から学ぶ　アジャイル開発のプロジェクトマネジメント(UBS79L)のアンケートを完成しました。	2019-07-17
2194	470009	1556	Docker　コンテナと　Dev/Ops に申込をしました。	2019-07-18
2195	370027	1557	Docker　コンテナと　Dev/Ops に申込をしました。	2019-07-18
2196	470009	1556	Docker　コンテナと　Dev/Ops をキャンセルしました。	2019-07-18
2197	470009	1558	Javaデータベースプログラミング (JAC0083G) に申込をしました。	2019-07-18
2198	430018	1559	業務の生産性を高める！改善のポイント（UUF05L） に申込をしました。	2019-07-18
2199	430018	1559	業務の生産性を高める！改善のポイント（UUF05L） をキャンセルしました。	2019-07-18
2200	430018	1560	業務の生産性を高める！改善のポイント（UUF05L） に申込をしました。	2019-07-18
2201	380034	1561	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-07-18
2203	470034	1555	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-19
2202	280019	1555	あなたは 谷口　賢吾さんの ステータスを 開始待ちに変更しました。	2019-07-19
2204	470025	1553	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-19
2205	280019	1553	あなたは 古場　翔さんの ステータスを 開始待ちに変更しました。	2019-07-19
2206	470043	1554	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-19
2207	280019	1554	あなたは 前田　裕佳さんの ステータスを 開始待ちに変更しました。	2019-07-19
2208	280019	1560	あなたは 篠倉　克真さんの ステータスを 研修先申込中に変更しました。	2019-07-19
2209	430018	1560	業務の生産性を高める！改善のポイント（UUF05L）のステータスは、長谷　真紀さんによって研修先申込中に変更されました	2019-07-19
2210	280019	1561	あなたは 藤本　祐己さんの ステータスを 研修先申込中に変更しました。	2019-07-19
2211	380034	1561	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L）のステータスは、長谷　真紀さんによって研修先申込中に変更されました	2019-07-19
2212	470009	1558	Javaデータベースプログラミング (JAC0083G)のステータスは、長谷　真紀さんによって研修先申込中に変更されました	2019-07-19
2213	280019	1558	あなたは 内山　正輝さんの ステータスを 研修先申込中に変更しました。	2019-07-19
2214	480020	1562	ソフトウェア技術者のための論理思考の文書技術 に申込をしました。	2019-07-19
2215	480020	1562	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-19
2216	280019	1562	あなたは 佐々木　真優さんの ステータスを 開始待ちに変更しました。	2019-07-19
2217	300021	1563	 SEに求められるヒアリングスキル～効果的な顧客要件の聞き取り～(UZE66L) に申込をしました。	2019-07-21
2218	300021	1564	 SEに求められるヒアリングスキル～効果的な顧客要件の聞き取り～(UZE66L) に申込をしました。	2019-07-21
2219	470049	1518	Excel VBA　による部門業務システムの構築（UUL79L）のステータスは、長谷　真紀さんによって完了に変更されました	2019-07-22
2221	460055	1550	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって完了に変更されました	2019-07-22
2222	280019	1550	あなたは 中森　健さんの ステータスを 完了に変更しました。	2019-07-22
2223	280019	1520	あなたは 新井　美智子さんの ステータスを 完了に変更しました。	2019-07-22
2224	470001	1520	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって完了に変更されました	2019-07-22
2225	470069	1525	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって完了に変更されました	2019-07-22
2226	280019	1525	あなたは 小野田　　裕允さんの ステータスを 完了に変更しました。	2019-07-22
2227	470008	1527	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって完了に変更されました	2019-07-22
2228	280019	1527	あなたは 魚谷　優治さんの ステータスを 完了に変更しました。	2019-07-22
2229	470035	1528	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって完了に変更されました	2019-07-22
2230	280019	1528	あなたは 張　悦さんの ステータスを 完了に変更しました。	2019-07-22
2231	470034	1555	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって完了に変更されました	2019-07-22
2232	280019	1555	あなたは 谷口　賢吾さんの ステータスを 完了に変更しました。	2019-07-22
2233	470025	1553	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって完了に変更されました	2019-07-22
2234	280019	1553	あなたは 古場　翔さんの ステータスを 完了に変更しました。	2019-07-22
2235	460036	1532	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって完了に変更されました	2019-07-22
2236	280019	1532	あなたは 西村　明莉さんの ステータスを 完了に変更しました。	2019-07-22
2237	280019	1536	あなたは 園部　啓太さんの ステータスを 完了に変更しました。	2019-07-22
2238	460024	1536	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって完了に変更されました	2019-07-22
2239	470028	1543	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって完了に変更されました	2019-07-22
2240	280019	1543	あなたは 佐藤　涼さんの ステータスを 完了に変更しました。	2019-07-22
2241	450050	1544	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって完了に変更されました	2019-07-22
2242	280019	1544	あなたは 山口　熙さんの ステータスを 完了に変更しました。	2019-07-22
2243	280019	1545	あなたは 大川　祥太さんの ステータスを 完了に変更しました。	2019-07-22
2244	470057	1545	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって完了に変更されました	2019-07-22
2245	280019	1548	あなたは 城　大地さんの ステータスを 完了に変更しました。	2019-07-22
2246	470029	1548	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって完了に変更されました	2019-07-22
2247	470043	1554	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって完了に変更されました	2019-07-22
2248	280019	1554	あなたは 前田　裕佳さんの ステータスを 完了に変更しました。	2019-07-22
2249	470022	1523	テスト品質管理 【基礎】のステータスは、長谷　真紀さんによって完了に変更されました	2019-07-22
2250	280019	1523	あなたは 木村　幸奈さんの ステータスを 完了に変更しました。	2019-07-22
2251	430018	1560	業務の生産性を高める！改善のポイント（UUF05L）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-22
2252	280019	1560	あなたは 篠倉　克真さんの ステータスを 開始待ちに変更しました。	2019-07-22
2253	380034	1561	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L）のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-22
2254	280019	1561	あなたは 藤本　祐己さんの ステータスを 開始待ちに変更しました。	2019-07-22
2255	280019	1565	Docker　コンテナと　Dev/Ops に申込をしました。	2019-07-22
2256	280019	1565	Docker　コンテナと　Dev/Opsのステータスは、長谷　真紀さんによって削除に変更されました	2019-07-22
2257	280019	1565	あなたは 長谷　真紀さんの ステータスを 削除に変更しました。	2019-07-22
2258	470009	1558	Javaデータベースプログラミング (JAC0083G)のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-07-24
2259	280019	1558	あなたは 内山　正輝さんの ステータスを 開始待ちに変更しました。	2019-07-24
2260	440041	1566	業務の生産性を高める！改善のポイント（UUF05L） に申込をしました。	2019-07-25
2261	440041	1566	業務の生産性を高める！改善のポイント（UUF05L） をキャンセルしました。	2019-07-25
2262	440041	1567	業務の生産性を高める！改善のポイント（UUF05L） に申込をしました。	2019-07-25
2263	440041	1567	業務の生産性を高める！改善のポイント（UUF05L） をキャンセルしました。	2019-07-25
2264	420014	1568	 SEに求められるヒアリングスキル～効果的な顧客要件の聞き取り～(UZE66L) に申込をしました。	2019-07-26
2265	420014	1568	 SEに求められるヒアリングスキル～効果的な顧客要件の聞き取り～(UZE66L)のステータスは、浦出　伸昭さんによって研修先申込中に変更されました	2019-07-26
2266	230002	1568	あなたは 齋藤　聡さんの ステータスを 研修先申込中に変更しました。	2019-07-26
2267	420014	1568	 SEに求められるヒアリングスキル～効果的な顧客要件の聞き取り～(UZE66L)のステータスは、浦出　伸昭さんによって開始待ちに変更されました	2019-07-26
2268	230002	1568	あなたは 齋藤　聡さんの ステータスを 開始待ちに変更しました。	2019-07-26
2270	280019	1533	あなたは 半田　開栄さんの ステータスを キャンセルに変更しました。	2019-07-31
2269	480044	1533	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによってキャンセルに変更されました	2019-07-31
2272	470044	1537	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって完了に変更されました	2019-08-02
2271	280019	1537	あなたは 松浦　優さんの ステータスを 完了に変更しました。	2019-08-02
2273	470029	1549	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって完了に変更されました	2019-08-02
2274	280019	1549	あなたは 城　大地さんの ステータスを 完了に変更しました。	2019-08-02
2275	480048	1412	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって完了に変更されました	2019-08-02
2276	280019	1412	あなたは 三橋　翼さんの ステータスを 完了に変更しました。	2019-08-02
2277	460018	1546	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって完了に変更されました	2019-08-02
2278	280019	1546	あなたは 佐藤　眞央さんの ステータスを 完了に変更しました。	2019-08-02
2279	470023	1541	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって完了に変更されました	2019-08-02
2281	280019	1526	あなたは 小野田　　裕允さんの ステータスを 完了に変更しました。	2019-08-02
2282	470069	1526	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって完了に変更されました	2019-08-02
2283	280019	1538	あなたは 岡本　桂輔さんの ステータスを 完了に変更しました。	2019-08-02
2284	470013	1538	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって完了に変更されました	2019-08-02
2285	280019	1534	あなたは 金谷　日和さんの ステータスを 完了に変更しました。	2019-08-02
2286	480014	1534	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって完了に変更されました	2019-08-02
2287	280019	1535	あなたは 河内　晴太さんの ステータスを 完了に変更しました。	2019-08-02
2288	470019	1535	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって完了に変更されました	2019-08-02
2289	280019	1562	あなたは 佐々木　真優さんの ステータスを 完了に変更しました。	2019-08-02
2290	480020	1562	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって完了に変更されました	2019-08-02
2291	470001	1521	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって完了に変更されました	2019-08-02
2292	280019	1521	あなたは 新井　美智子さんの ステータスを 完了に変更しました。	2019-08-02
2293	480001	1522	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって完了に変更されました	2019-08-02
2294	280019	1522	あなたは 赤荻　あずみさんの ステータスを 完了に変更しました。	2019-08-02
2295	470022	1524	ソフトウェア技術者のための論理思考の文書技術のステータスは、長谷　真紀さんによって完了に変更されました	2019-08-02
2296	280019	1524	あなたは 木村　幸奈さんの ステータスを 完了に変更しました。	2019-08-02
2297	370016	1497	キャリア研修（30代向け）のステータスは、長谷　真紀さんによってキャンセルに変更されました	2019-08-05
2298	280019	1497	あなたは 小林　建介さんの ステータスを キャンセルに変更しました。	2019-08-05
2299	280019	1496	あなたは 西村　真理代さんの ステータスを キャンセルに変更しました。	2019-08-05
2300	370056	1496	キャリア研修（30代向け）のステータスは、長谷　真紀さんによってキャンセルに変更されました	2019-08-05
2301	340010	1539	Docker　コンテナと　Dev/Opsのステータスは、浦出　伸昭さんによって完了に変更されました	2019-08-05
2302	230002	1539	あなたは 大川　満久さんの ステータスを 完了に変更しました。	2019-08-05
2303	230002	1547	あなたは 丹羽　紘也さんの ステータスを 完了に変更しました。	2019-08-05
2304	440037	1547	Docker　コンテナと　Dev/Opsのステータスは、浦出　伸昭さんによって完了に変更されました	2019-08-05
2305	280019	1569	あなたは横尾 亮さんの代わりに、中途社員研修 を登録しました。	2019-08-05
2306	480056	1569	あなたは長谷 真紀さんに中途社員研修が代替登録されました。	2019-08-05
2307	230002	1552	あなたは 高垣　晴揮さんの ステータスを 完了に変更しました。	2019-08-05
2308	460053	1552	Docker　コンテナと　Dev/Opsのステータスは、浦出　伸昭さんによって完了に変更されました	2019-08-05
2309	230002	1557	あなたは 中島　良介さんの ステータスを 完了に変更しました。	2019-08-05
2310	370027	1557	Docker　コンテナと　Dev/Opsのステータスは、浦出　伸昭さんによって完了に変更されました	2019-08-05
2311	230002	1531	あなたは 後藤　直宏さんの ステータスを 完了に変更しました。	2019-08-05
2312	480055	1531	Docker　コンテナと　Dev/Opsのステータスは、浦出　伸昭さんによって完了に変更されました	2019-08-05
2313	470002	1570	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L） に申込をしました。	2019-08-06
2314	460008	1571	Pythonプログラミング1 基本文法編（PRC0103G） に申込をしました。	2019-08-06
2316	280019	1570	あなたは 新井　悠介さんの ステータスを 研修先申込中に変更しました。	2019-08-07
2315	470002	1570	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、長谷　真紀さんによって研修先申込中に変更されました	2019-08-07
2317	460008	1572	Pythonプログラミング1 基本文法編（PRC0103G） に申込をしました。	2019-08-07
2318	460008	1571	Pythonプログラミング1 基本文法編（PRC0103G）のステータスは、長谷　真紀さんによって研修先申込中に変更されました	2019-08-07
2319	280019	1571	あなたは 大山　翔平さんの ステータスを 研修先申込中に変更しました。	2019-08-07
2320	280019	1572	あなたは 大山　翔平さんの ステータスを 申込不可に変更しました。	2019-08-07
2321	460008	1572	Pythonプログラミング1 基本文法編（PRC0103G）のステータスは、長谷　真紀さんによって申込不可に変更されました	2019-08-07
2322	460060	1573	テスト品質管理 【実践】 に申込をしました。	2019-08-07
2323	460060	1573	テスト品質管理 【実践】のステータスは、長谷　真紀さんによって開始待ちに変更されました	2019-08-07
2324	280019	1573	あなたは NGUYEN THI NGOC　MAIさんの ステータスを 開始待ちに変更しました。	2019-08-07
2325	000000	1574	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L） に申込をしました。	2019-08-15
2326	000000	1574	あなたは 冨田 隆司さんの ステータスを 開始待ちに変更しました。	2019-08-15
2327	000000	1574	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、冨田 隆司さんによって開始待ちに変更されました	2019-08-15
2328	000000	1576	Javaデータベースプログラミング (JAC0083G) に申込をしました。	2019-08-15
2329	000000	1576	Javaデータベースプログラミング (JAC0083G) をキャンセルしました。	2019-08-15
2330	000000	1577	Javaデータベースプログラミング (JAC0083G) に申込をしました。	2019-08-15
2331	000000	1577	Javaデータベースプログラミング (JAC0083G) をキャンセルしました。	2019-08-15
2332	000000	1586	 サーブレット＆JSPプログラミング(JAC0084G) に申込をしました。	2019-09-10
2333	000000	1589	組織力を高めるマネジメントの技術(BS-008) に申込をしました。	2019-09-10
2334	000000	1586	 サーブレット＆JSPプログラミング(JAC0084G)のステータスは、冨田 隆司さんによって経費精算待ちに変更されました	2019-09-10
2335	000000	1586	あなたは 冨田 隆司さんの ステータスを 経費精算待ちに変更しました。	2019-09-10
2337	000000	1574	あなたは 冨田 隆司さんの ステータスを 経費精算待ちに変更しました。	2019-09-10
2336	000000	1574	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、冨田 隆司さんによって経費精算待ちに変更されました	2019-09-10
2338	000000	1577	あなたは 冨田 隆司さんの ステータスを 経費精算待ちに変更しました。	2019-09-10
2339	000000	1577	Javaデータベースプログラミング (JAC0083G)のステータスは、冨田 隆司さんによって経費精算待ちに変更されました	2019-09-10
2340	000000	1585	あなたは 森本 修平さんの ステータスを 削除に変更しました。	2019-09-10
2341	370042	1585	Javaデータベースプログラミング (JAC0083G)のステータスは、冨田 隆司さんによって削除に変更されました	2019-09-10
2342	000000	1585	あなたは 森本 修平さんの ステータスを キャンセル（有償）に変更しました。	2019-09-10
2343	370042	1585	Javaデータベースプログラミング (JAC0083G)のステータスは、冨田 隆司さんによってキャンセル（有償）に変更されました	2019-09-10
2345	000000	1585	あなたは 森本 修平さんの ステータスを 削除に変更しました。	2019-09-10
2344	370042	1585	Javaデータベースプログラミング (JAC0083G)のステータスは、冨田 隆司さんによって削除に変更されました	2019-09-10
2346	000000	1577	あなたは 冨田 隆司さんの ステータスを 削除に変更しました。	2019-09-10
2347	000000	1577	Javaデータベースプログラミング (JAC0083G)のステータスは、冨田 隆司さんによって削除に変更されました	2019-09-10
2349	000000	1577	Javaデータベースプログラミング (JAC0083G)のステータスは、冨田 隆司さんによって経費精算待ちに変更されました	2019-09-10
2348	000000	1577	あなたは 冨田 隆司さんの ステータスを 経費精算待ちに変更しました。	2019-09-10
2350	000000	1577	Javaデータベースプログラミング (JAC0083G)のステータスは、冨田 隆司さんによって完了に変更されました	2019-09-10
2351	000000	1577	あなたは 冨田 隆司さんの ステータスを 完了に変更しました。	2019-09-10
2352	000000	1574	あなたは 冨田 隆司さんの ステータスを 完了に変更しました。	2019-09-10
2353	000000	1574	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、冨田 隆司さんによって完了に変更されました	2019-09-10
2354	000000	1586	あなたは 冨田 隆司さんの ステータスを 完了に変更しました。	2019-09-10
2355	000000	1586	 サーブレット＆JSPプログラミング(JAC0084G)のステータスは、冨田 隆司さんによって完了に変更されました	2019-09-10
2356	000000	1577	あなたは 冨田 隆司さんの ステータスを 経費精算待ちに変更しました。	2019-09-10
2357	000000	1577	Javaデータベースプログラミング (JAC0083G)のステータスは、冨田 隆司さんによって経費精算待ちに変更されました	2019-09-10
2358	000000	1577	あなたは 冨田 隆司さんの ステータスを 完了に変更しました。	2019-09-10
2359	000000	1577	Javaデータベースプログラミング (JAC0083G)のステータスは、冨田 隆司さんによって完了に変更されました	2019-09-10
2360	000000	1574	あなたは 冨田 隆司さんの ステータスを キャンセル（有償）に変更しました。	2019-09-10
2361	000000	1574	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、冨田 隆司さんによってキャンセル（有償）に変更されました	2019-09-10
2362	000000	1577	あなたは 冨田 隆司さんの ステータスを 削除に変更しました。	2019-09-10
2363	000000	1577	Javaデータベースプログラミング (JAC0083G)のステータスは、冨田 隆司さんによって削除に変更されました	2019-09-10
2364	000000	1586	 サーブレット＆JSPプログラミング(JAC0084G)のステータスは、冨田 隆司さんによって削除に変更されました	2019-09-10
2365	000000	1586	あなたは 冨田 隆司さんの ステータスを 削除に変更しました。	2019-09-10
2367	000000	1574	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、冨田 隆司さんによって完了に変更されました	2019-09-10
2366	000000	1574	あなたは 冨田 隆司さんの ステータスを 完了に変更しました。	2019-09-10
2368	000000	1577	あなたは 冨田 隆司さんの ステータスを 完了に変更しました。	2019-09-10
2369	000000	1577	Javaデータベースプログラミング (JAC0083G)のステータスは、冨田 隆司さんによって完了に変更されました	2019-09-10
2370	000000	1586	あなたは 冨田 隆司さんの ステータスを 完了に変更しました。	2019-09-10
2371	000000	1586	 サーブレット＆JSPプログラミング(JAC0084G)のステータスは、冨田 隆司さんによって完了に変更されました	2019-09-10
2372	000000	1639	リーダーコミュニケーション研修（BS-003） に申込をしました。	2019-09-11
2373	000000	1650	リーダーコミュニケーション研修（BS-003） に申込をしました。	2019-09-11
2374	000000	1651	リーダーコミュニケーション研修（BS-003） に申込をしました。	2019-09-11
2375	000000	1652	リーダーコミュニケーション研修（BS-003） に申込をしました。	2019-09-11
2376	000000	1653	システム設計・実装　　【基礎編】 （前編） に申込をしました。	2019-09-12
2377	000000	1657	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2378	000000	1658	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2379	000000	1659	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2380	000000	1660	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2381	000000	1661	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2382	000000	1662	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2383	000000	1663	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2384	000000	1664	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2385	000000	1665	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2386	000000	1666	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2387	000000	1667	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2388	000000	1671	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2389	000000	1672	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2390	000000	1673	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2391	000000	1676	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2392	000000	1677	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2393	000000	1678	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2394	000000	1679	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2395	000000	1680	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2396	000000	1681	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2397	000000	1682	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2398	000000	1683	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2399	000000	1684	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2400	000000	1685	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2401	000000	1686	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2402	000000	1687	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2403	000000	1688	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2404	000000	1689	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2405	000000	1690	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2406	000000	1691	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2407	000000	1692	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2408	000000	1694	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2411	000000	1697	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2412	000000	1698	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2413	000000	1699	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2414	000000	1700	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2415	000000	1701	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2416	000000	1702	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2417	000000	1703	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2418	000000	1704	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2419	000000	1705	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2420	000000	1706	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2421	000000	1707	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2422	000000	1708	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2423	000000	1709	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2424	000000	1710	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2425	000000	1711	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2426	000000	1712	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2427	000000	1719	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2428	000000	1720	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2429	000000	1721	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2430	000000	1722	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2431	000000	1724	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2432	000000	1725	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2433	000000	1727	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2434	000000	1728	テスト品質管理 【実践】 に申込をしました。	2019-09-12
2435	000000	1729	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2019-09-12
2436	000000	1737	キャリア研修（40代向け） に申込をしました。	2019-09-17
2437	000000	1738	アジャイル開発手法によるシステム開発(UBS99L) に申込をしました。	2019-09-17
2438	000000	1739	アジャイル開発手法によるシステム開発(UBS99L) に申込をしました。	2019-09-18
2439	000000	1740	アジャイル開発手法によるシステム開発(UBS99L) に申込をしました。	2019-09-18
2440	000000	1741	アジャイル開発手法によるシステム開発(UBS99L) に申込をしました。	2019-09-18
2441	000000	1742	アジャイル開発手法によるシステム開発(UBS99L) に申込をしました。	2019-09-18
2442	040005	1743	あなたは冨田 隆司さんにアジャイル開発手法によるシステム開発(UBS99L)が代替登録されました。	2019-09-18
2443	000000	1743	あなたは内田 敏雄さんの代わりに、アジャイル開発手法によるシステム開発(UBS99L) を登録しました。	2019-09-18
2445	001120	1744	あなたは冨田 隆司さんにJavaデータベースプログラミング (JAC0083G)が代替登録されました。	2019-09-18
2444	000000	1744	あなたは冨田 隆司さんの代わりに、Javaデータベースプログラミング (JAC0083G) を登録しました。	2019-09-18
2446	001120	1745	あなたは冨田 隆司さんにリーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L）が代替登録されました。	2019-09-18
2447	000000	1745	あなたは冨田 隆司さんの代わりに、リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） を登録しました。	2019-09-18
2448	000000	1747	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2449	000000	1748	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2450	000000	1749	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2451	000000	1750	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2452	000000	1751	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2453	000000	1752	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2454	000000	1753	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2455	000000	1754	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2456	000000	1755	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2457	000000	1756	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2458	000000	1757	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2459	000000	1758	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2460	000000	1759	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2461	000000	1760	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2462	000000	1761	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2463	000000	1762	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2464	000000	1763	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2465	000000	1764	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2466	000000	1765	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2467	000000	1766	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2468	000000	1767	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2469	000000	1768	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2470	000000	1769	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2471	000000	1770	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2472	000000	1771	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2473	000000	1772	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2474	000000	1773	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2475	000000	1774	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2476	000000	1775	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2477	000000	1776	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2478	000000	1779	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） に申込をしました。	2019-09-18
2479	001120	1780	あなたは冨田 隆司さんにリーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L）が代替登録されました。	2019-09-18
2480	000000	1780	あなたは冨田 隆司さんの代わりに、リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） を登録しました。	2019-09-18
2481	000000	1783	あなたは冨田 隆司さんの代わりに、リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L） を登録しました。	2019-09-18
2482	001120	1783	あなたは冨田 隆司さんにリーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L）が代替登録されました。	2019-09-18
2483	000000	1784	あなたはさんの代わりに、Docker　コンテナと　Dev/Ops をキャンセルしました。	2019-09-18
2484	001120	1784	あなたはさんにDocker　コンテナと　Dev/Opsがキャンセルされました。	2019-09-18
2485	001120	1785	あなたは冨田 隆司さんにDocker　コンテナと　Dev/Opsが代替登録されました。	2019-09-18
2486	000000	1785	あなたは冨田 隆司さんの代わりに、Docker　コンテナと　Dev/Ops を登録しました。	2019-09-18
2487	000000	1786	Docker　コンテナと　Dev/Ops をキャンセルしました。	2019-09-18
2488	000000	1787	Docker　コンテナと　Dev/Ops に申込をしました。	2019-09-18
2489	000000	1787	Docker　コンテナと　Dev/Ops をキャンセルしました。	2019-09-18
2491	000605	1788	あなたは冨田 隆司さんにDocker　コンテナと　Dev/Opsが代替登録されました。	2019-09-18
2490	000000	1788	あなたは冨田 隆司さんの代わりに、Docker　コンテナと　Dev/Ops を登録しました。	2019-09-18
2493	000605	1791	あなたはさんにテスト品質管理 【実践】がキャンセルされました。	2019-09-18
2492	000000	1791	あなたはさんの代わりに、テスト品質管理 【実践】 をキャンセルしました。	2019-09-18
2494	000605	1792	あなたは冨田 隆司さんにテスト品質管理 【実践】が代替登録されました。	2019-09-18
2495	000000	1792	あなたは冨田 隆司さんの代わりに、テスト品質管理 【実践】 を登録しました。	2019-09-18
2496	001120	1793	あなたは冨田 隆司さんにテスト品質管理 【実践】が代替登録されました。	2019-09-18
2497	000000	1793	あなたは冨田 隆司さんの代わりに、テスト品質管理 【実践】 を登録しました。	2019-09-18
2498	000000	1794	UNIX／Linux入門（UMI11L） に申込をしました。	2019-09-19
2499	000000	1795	ＥＮ型ＰＪ計画書の作り方とリスク判定シートの活用方法 に申込をしました。	2019-09-19
2500	000000	1798	アジャイル開発手法によるシステム開発(UBS99L) に申込をしました。	2019-09-19
2501	000000	1800	テスト品質管理 【実践】 に申込をしました。	2019-09-19
2502	000000	1801	テスト品質管理 【実践】 に申込をしました。	2019-09-19
2503	000000	1802	テスト品質管理 【実践】 に申込をしました。	2019-09-19
2504	000000	1803	テスト品質管理 【実践】 に申込をしました。	2019-09-19
2505	000000	1804	アジャイル開発手法によるシステム開発(UBS99L) に申込をしました。	2019-09-20
2506	000000	1809	テスト品質管理 【実践】 をキャンセルしました。	2019-09-24
2507	000000	1810	テスト品質管理 【実践】 に申込をしました。	2019-09-24
2508	000000	1811	テスト品質管理 【実践】 に申込をしました。	2019-09-24
2509	000000	1812	２９９の施策から紐解く業務カイゼン５つのポイント に申込をしました。	2019-09-24
2510	001008	1729	あなたは 冨田 隆司さんの ステータスを 承認済みに変更しました。	2019-10-08
2511	000000	1729	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G)のステータスは、Kim Myさんによって承認済みに変更されました	2019-10-08
2512	001120	1831	Pythonプログラミング1 基本文法編（PRC0103G） に申込をしました。	2019-10-10
2513	001120	1832	 Microsoft AzureによるITインフラの拡張 ～基本から学ぶサーバー構築～(MSC0517V) に申込をしました。	2019-10-10
2514	001120	1833	UNIX／Linux入門（UMI11L） に申込をしました。	2019-10-10
2515	001008	1837	新人研修／技術トレーニング に申込をしました。	2019-10-22
2516	001008	1839	AI構築コース（MLAP） に申込をしました。	2019-10-23
2517	001008	1840	新任JP-B研修（1回目） に申込をしました。	2019-10-25
2518	001120	1841	機械学習プログラミングコース（PMLI） に申込をしました。	2019-10-28
2519	001120	1842	 SEに求められるヒアリングスキル～効果的な顧客要件の聞き取り～(UZE66L) に申込をしました。	2019-10-28
2520	001008	1843	機械学習プログラミングコース（PMLI） に申込をしました。	2019-10-28
2521	001008	1843	機械学習プログラミングコース（PMLI） をキャンセルしました。	2019-10-28
2522	001120	1844	Pythonプログラミング1 基本文法編（PRC0103G） に申込をしました。	2019-10-28
2523	001120	1844	Pythonプログラミング1 基本文法編（PRC0103G） をキャンセルしました。	2019-10-28
2524	001120	1845	Pythonプログラミング1 基本文法編（PRC0103G） に申込をしました。	2019-10-28
2525	001120	1845	Pythonプログラミング1 基本文法編（PRC0103G） をキャンセルしました。	2019-10-28
2526	001120	1846	AI x Python and some stuff をキャンセルしました。	2019-10-28
2527	001120	1841	機械学習プログラミングコース（PMLI） をキャンセルしました。	2019-10-28
2528	001008	1830	あなたはExcel VBA　による部門業務システムの構築（UUL79L）のアンケートを完成しました。	2019-10-29
2529	001108	1847	Excel VBA　による部門業務システムの構築（UUL79L） に申込をしました。	2019-10-29
2530	001008	1847	あなたは Khanh Nguyenさんの ステータスを 完了に変更しました。	2019-10-29
2531	001108	1847	Excel VBA　による部門業務システムの構築（UUL79L）のステータスは、My Kimさんによって完了に変更されました	2019-10-29
2532	001008	1847	あなたは Khanh Nguyenさんの ステータスを 承認済みに変更しました。	2019-10-29
2533	001108	1847	Excel VBA　による部門業務システムの構築（UUL79L）のステータスは、My Kimさんによって承認済みに変更されました	2019-10-29
2534	001008	1847	あなたは Khanh Nguyenさんの ステータスを アンケート回答待ちに変更しました。	2019-10-29
2535	001108	1847	Excel VBA　による部門業務システムの構築（UUL79L）のステータスは、My Kimさんによってアンケート回答待ちに変更されました	2019-10-29
2536	001108	1847	あなたはExcel VBA　による部門業務システムの構築（UUL79L）のアンケートを完成しました。	2019-10-29
2537	001201	1848	Excel VBA　による部門業務システムの構築（UUL79L） に申込をしました。	2019-10-29
2538	001201	1848	Excel VBA　による部門業務システムの構築（UUL79L）のステータスは、My Kimさんによってアンケート回答待ちに変更されました	2019-10-29
2539	001008	1848	あなたは Thien Lapさんの ステータスを アンケート回答待ちに変更しました。	2019-10-29
2540	001201	1848	あなたはExcel VBA　による部門業務システムの構築（UUL79L）のアンケートを完成しました。	2019-10-29
2541	001120	1849	Excel VBA　による部門業務システムの構築（UUL79L） に申込をしました。	2019-10-29
2542	001008	1849	あなたは Khang Nguyenさんの ステータスを アンケート回答待ちに変更しました。	2019-10-29
2543	001120	1849	Excel VBA　による部門業務システムの構築（UUL79L）のステータスは、My Kimさんによってアンケート回答待ちに変更されました	2019-10-29
2544	001120	1849	あなたはExcel VBA　による部門業務システムの構築（UUL79L）のアンケートを完成しました。	2019-10-29
2545	000605	1850	Excel VBA　による部門業務システムの構築（UUL79L） に申込をしました。	2019-10-29
2546	001008	1850	あなたは Nuong Phamさんの ステータスを アンケート回答待ちに変更しました。	2019-10-29
2547	000605	1850	Excel VBA　による部門業務システムの構築（UUL79L）のステータスは、My Kimさんによってアンケート回答待ちに変更されました	2019-10-29
2548	000605	1850	あなたはExcel VBA　による部門業務システムの構築（UUL79L）のアンケートを完成しました。	2019-10-29
2549	001120	1855	AI構築コース（MLAP） に申込をしました。	2019-10-29
2550	001008	1856	AI構築コース（MLAP） に申込をしました。	2019-10-29
2551	001108	1859	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L） に申込をしました。	2019-10-29
2552	001202	1853	Excel VBA　による部門業務システムの構築（UUL79L） をキャンセルしました。	2019-10-29
2553	001202	1861	Excel VBA　による部門業務システムの構築（UUL79L） に申込をしました。	2019-10-29
2554	001202	1861	Excel VBA　による部門業務システムの構築（UUL79L）のステータスは、My Kimさんによってアンケート回答待ちに変更されました	2019-10-29
2555	001008	1861	あなたは Anh Ngocさんの ステータスを アンケート回答待ちに変更しました。	2019-10-29
2556	001202	1861	あなたはExcel VBA　による部門業務システムの構築（UUL79L）のアンケートを完成しました。	2019-10-29
2557	001120	1849	Excel VBA　による部門業務システムの構築（UUL79L） をキャンセルしました。	2019-10-31
2558	001120	1863	Excel VBA　による部門業務システムの構築（UUL79L） に申込をしました。	2019-10-31
2559	001120	1864	Huấn luyện kỹ năng OJT に申込をしました。	2019-11-07
2560	001120	1865	Huấn luyện kỹ năng OJT に申込をしました。	2019-11-07
2561	001120	1866	Huấn luyện kỹ năng OJT に申込をしました。	2019-11-07
2562	001120	1866	Huấn luyện kỹ năng OJT をキャンセルしました。	2019-11-07
2563	001008	1867	Huấn luyện kỹ năng OJT に申込をしました。	2019-11-07
2564	001008	1867	Huấn luyện kỹ năng OJT をキャンセルしました。	2019-11-07
2565	001008	1868	Huấn luyện kỹ năng OJT に申込をしました。	2019-11-07
2566	001008	1868	Huấn luyện kỹ năng OJT をキャンセルしました。	2019-11-07
2567	001008	1869	あなたはThien Lapさんの代わりに、Huấn luyện kỹ năng OJT を登録しました。	2019-11-07
2568	001201	1869	あなたはMy KimさんにHuấn luyện kỹ năng OJTが代替登録されました。	2019-11-07
2569	001008	1869	あなたはさんの代わりに、Huấn luyện kỹ năng OJT をキャンセルしました。	2019-11-07
2570	001201	1869	あなたはさんにHuấn luyện kỹ năng OJTがキャンセルされました。	2019-11-07
2571	001201	1870	あなたはMy KimさんにDocker và Dev/Opsが代替登録されました。	2019-11-07
2572	001008	1870	あなたはThien Lapさんの代わりに、Docker và Dev/Ops を登録しました。	2019-11-07
2573	001008	1870	あなたはさんの代わりに、Docker và Dev/Ops をキャンセルしました。	2019-11-07
2574	001201	1870	あなたはさんにDocker và Dev/Opsがキャンセルされました。	2019-11-07
2575	001120	1785	Docker và Dev/Ops をキャンセルしました。	2019-11-27
2576	001120	1871	Docker và Dev/Ops に申込をしました。	2019-11-27
2577	001008	1872	Cách tạo thiết kế của các project に申込をしました。	2019-11-27
2578	001008	1873	Huấn luyện kỹ năng OJT に申込をしました。	2019-11-27
2579	001008	1874	Giới thiệu công ty に申込をしました。	2019-11-27
2580	001008	1875	あなたはKhang NguyenさんにKiến thức cơ bảnが代替登録されました。	2019-11-28
2581	001120	1875	あなたはMy Kimさんの代わりに、Kiến thức cơ bản を登録しました。	2019-11-28
2582	001008	1837	Hướng dẫn công việc をキャンセルしました。	2019-11-28
2583	001008	1873	Huấn luyện kỹ năng OJT をキャンセルしました。	2019-11-28
2584	001008	1876	Huấn luyện kỹ năng OJT に申込をしました。	2019-11-28
2585	001008	1876	Huấn luyện kỹ năng OJT をキャンセルしました。	2019-11-28
2586	001008	1872	Cách tạo thiết kế của các project をキャンセルしました。	2019-11-28
2587	001008	1877	Cách tạo thiết kế của các project に申込をしました。	2019-11-28
2588	001008	1878	Docker và Dev/Ops に申込をしました。	2019-11-28
2589	001008	1879	ＡＷＳ-Ⅰ　システム自動拡張とメール連携編 に申込をしました。	2019-11-28
2590	001008	1880	Huấn luyện kỹ năng OJT に申込をしました。	2019-11-28
2591	001008	1879	ＡＷＳ-Ⅰ　システム自動拡張とメール連携編 をキャンセルしました。	2019-11-28
2592	001008	1881	ＡＷＳ-Ⅰ　システム自動拡張とメール連携編 に申込をしました。	2019-11-28
2593	001008	1878	Docker và Dev/Ops をキャンセルしました。	2019-11-28
2594	001008	1882	Docker và Dev/Ops に申込をしました。	2019-11-28
2595	001008	1881	ＡＷＳ-Ⅰ　システム自動拡張とメール連携編 をキャンセルしました。	2019-11-28
2596	001008	1883	ＡＷＳ-Ⅰ　システム自動拡張とメール連携編 に申込をしました。	2019-11-28
2597	001008	1883	ＡＷＳ-Ⅰ　システム自動拡張とメール連携編 をキャンセルしました。	2019-11-28
2598	001008	1884	ＡＷＳ-Ⅰ　システム自動拡張とメール連携編 に申込をしました。	2019-11-28
2599	001120	1871	Docker và Dev/Ops をキャンセルしました。	2019-11-28
2600	001008	1882	Docker và Dev/Ops をキャンセルしました。	2019-11-28
2601	001008	1885	Docker và Dev/Ops に申込をしました。	2019-11-28
2602	001008	1886	あなたはKhang Nguyenさんにリーダーコミュニケーション研修（BS-003）が代替登録されました。	2019-11-28
2603	001120	1886	あなたはMy Kimさんの代わりに、リーダーコミュニケーション研修（BS-003） を登録しました。	2019-11-28
2604	001120	1886	あなたはさんの代わりに、リーダーコミュニケーション研修（BS-003） をキャンセルしました。	2019-11-28
2605	001008	1886	あなたはさんにリーダーコミュニケーション研修（BS-003）がキャンセルされました。	2019-11-28
2606	001008	1875	Kiến thức cơ bản をキャンセルしました。	2019-11-28
2607	001008	1887	Kiến thức cơ bản に申込をしました。	2019-11-28
2608	001008	1888	あなたはKhang Nguyenさんにリーダーコミュニケーション研修（BS-003）が代替登録されました。	2019-11-28
2609	001120	1888	あなたはMy Kimさんの代わりに、リーダーコミュニケーション研修（BS-003） を登録しました。	2019-11-28
2610	001120	1795	あなたはさんの代わりに、リーダーコミュニケーション研修（BS-003） をキャンセルしました。	2019-11-28
2611	000000	1795	あなたはさんにリーダーコミュニケーション研修（BS-003）がキャンセルされました。	2019-11-28
2612	000000	1889	あなたはKhang Nguyenさんにリーダーコミュニケーション研修（BS-003）が代替登録されました。	2019-11-28
2613	001120	1889	あなたはKaigi Testさんの代わりに、リーダーコミュニケーション研修（BS-003） を登録しました。	2019-11-28
2614	001120	1889	あなたはさんの代わりに、リーダーコミュニケーション研修（BS-003） をキャンセルしました。	2019-11-28
2615	000000	1889	あなたはさんにリーダーコミュニケーション研修（BS-003）がキャンセルされました。	2019-11-28
2616	000000	1890	あなたはKhang Nguyenさんにリーダーコミュニケーション研修（BS-003）が代替登録されました。	2019-11-28
2617	001120	1890	あなたはKaigi Testさんの代わりに、リーダーコミュニケーション研修（BS-003） を登録しました。	2019-11-28
2618	001120	1890	あなたはさんの代わりに、リーダーコミュニケーション研修（BS-003） をキャンセルしました。	2019-11-28
2619	000000	1890	あなたはさんにリーダーコミュニケーション研修（BS-003）がキャンセルされました。	2019-11-28
2620	000000	1891	あなたはKhang Nguyenさんにリーダーコミュニケーション研修（BS-003）が代替登録されました。	2019-11-28
2621	001120	1891	あなたはKaigi Testさんの代わりに、リーダーコミュニケーション研修（BS-003） を登録しました。	2019-11-28
2622	001008	1888	リーダーコミュニケーション研修（BS-003） をキャンセルしました。	2019-11-29
2623	001008	1892	リーダーコミュニケーション研修（BS-003） に申込をしました。	2019-11-29
2624	001008	1892	リーダーコミュニケーション研修（BS-003） をキャンセルしました。	2019-11-29
2625	001008	1893	Docker và Dev/Ops に申込をしました。	2019-11-29
2626	001008	1893	Docker và Dev/Ops をキャンセルしました。	2019-11-29
2627	001008	1894	Docker và Dev/Ops に申込をしました。	2019-11-29
2628	001008	1877	Cách tạo thiết kế của các project をキャンセルしました。	2019-11-29
2629	001008	1880	Huấn luyện kỹ năng OJT をキャンセルしました。	2019-11-29
2630	001008	1895	Huấn luyện kỹ năng OJT に申込をしました。	2019-11-29
2631	001008	1896	Cách tạo thiết kế của các project に申込をしました。	2019-11-29
2632	000000	1891	あなたはさんにリーダーコミュニケーション研修（BS-003）がキャンセルされました。	2019-11-29
2633	001008	1891	あなたはさんの代わりに、リーダーコミュニケーション研修（BS-003） をキャンセルしました。	2019-11-29
2634	001008	1897	あなたはKaigi Testさんの代わりに、リーダーコミュニケーション研修（BS-003） を登録しました。	2019-11-29
2635	000000	1897	あなたはMy Kimさんにリーダーコミュニケーション研修（BS-003）が代替登録されました。	2019-11-29
2636	000000	1898	あなたはMy KimさんにCách tạo thiết kế của các projectが代替登録されました。	2019-11-29
2637	001008	1898	あなたはKaigi Testさんの代わりに、Cách tạo thiết kế của các project を登録しました。	2019-11-29
2638	000000	1899	あなたはMy KimさんにKiến thức cơ bảnが代替登録されました。	2019-11-29
2639	001008	1899	あなたはKaigi Testさんの代わりに、Kiến thức cơ bản を登録しました。	2019-11-29
2640	001008	1899	あなたはさんの代わりに、Kiến thức cơ bản をキャンセルしました。	2019-11-29
2641	000000	1899	あなたはさんにKiến thức cơ bảnがキャンセルされました。	2019-11-29
2642	001120	1900	Chia sẻ kinh nghiệm làm việc に申込をしました。	2019-12-04
2643	000000	1901	あなたはKhang NguyenさんにChia sẻ kinh nghiệm làm việcが代替登録されました。	2019-12-04
2644	001120	1901	あなたはKaigi Testさんの代わりに、Chia sẻ kinh nghiệm làm việc を登録しました。	2019-12-04
2645	001120	1901	あなたはさんの代わりに、Chia sẻ kinh nghiệm làm việc をキャンセルしました。	2019-12-04
2646	000000	1901	あなたはさんにChia sẻ kinh nghiệm làm việcがキャンセルされました。	2019-12-04
2647	000000	1902	あなたはKhang NguyenさんにChia sẻ kinh nghiệm làm việcが代替登録されました。	2019-12-04
2648	001120	1902	あなたはKaigi Testさんの代わりに、Chia sẻ kinh nghiệm làm việc を登録しました。	2019-12-04
2649	001120	1902	あなたはさんの代わりに、Chia sẻ kinh nghiệm làm việc をキャンセルしました。	2019-12-04
2650	000000	1902	あなたはさんにChia sẻ kinh nghiệm làm việcがキャンセルされました。	2019-12-04
2651	000000	1903	あなたはKhang NguyenさんにChia sẻ kinh nghiệm làm việcが代替登録されました。	2019-12-04
2652	001120	1903	あなたはKaigi Testさんの代わりに、Chia sẻ kinh nghiệm làm việc を登録しました。	2019-12-04
2653	001120	1903	あなたはさんの代わりに、Chia sẻ kinh nghiệm làm việc をキャンセルしました。	2019-12-04
2654	000000	1903	あなたはさんにChia sẻ kinh nghiệm làm việcがキャンセルされました。	2019-12-04
2655	001120	1904	Docker và Dev/Ops に申込をしました。	2019-12-12
2656	001120	1904	Docker và Dev/Ops をキャンセルしました。	2019-12-12
2657	000000	1905	あなたはKhang NguyenさんにDocker và Dev/Opsが代替登録されました。	2019-12-12
2658	001120	1905	あなたはKaigi Testさんの代わりに、Docker và Dev/Ops を登録しました。	2019-12-12
2659	001120	1905	あなたはさんの代わりに、Docker và Dev/Ops をキャンセルしました。	2019-12-12
2660	000000	1905	あなたはさんにDocker và Dev/Opsがキャンセルされました。	2019-12-12
2661	001120	1906	Docker và Dev/Ops に申込をしました。	2019-12-12
2662	001120	1906	Docker và Dev/Ops をキャンセルしました。	2019-12-12
2663	000000	1907	あなたはKhang NguyenさんにChia sẻ kinh nghiệm làm việcが代替登録されました。	2019-12-12
2664	001120	1907	あなたはKaigi Testさんの代わりに、Chia sẻ kinh nghiệm làm việc を登録しました。	2019-12-12
2665	001120	1907	あなたはさんの代わりに、Chia sẻ kinh nghiệm làm việc をキャンセルしました。	2019-12-12
2666	000000	1907	あなたはさんにChia sẻ kinh nghiệm làm việcがキャンセルされました。	2019-12-12
2667	001120	1900	Chia sẻ kinh nghiệm làm việc をキャンセルしました。	2019-12-16
2668	001120	1908	Kiến thức cơ bản に申込をしました。	2019-12-16
2669	001120	1908	Kiến thức cơ bản をキャンセルしました。	2019-12-16
2670	001120	1909	Kiến thức cơ bản に申込をしました。	2019-12-16
2671	001120	1909	Kiến thức cơ bản をキャンセルしました。	2019-12-16
2672	001120	1910	Kiến thức cơ bản に申込をしました。	2019-12-16
2673	000000	1911	あなたはKhang NguyenさんにKiến thức cơ bảnが代替登録されました。	2019-12-16
2674	001120	1911	あなたはKaigi Testさんの代わりに、Kiến thức cơ bản を登録しました。	2019-12-16
2675	001120	1911	あなたはさんの代わりに、Kiến thức cơ bản をキャンセルしました。	2019-12-16
2676	000000	1911	あなたはさんにKiến thức cơ bảnがキャンセルされました。	2019-12-16
2677	000000	1912	あなたはKhang NguyenさんにKiến thức cơ bảnが代替登録されました。	2019-12-16
2678	001120	1912	あなたはKaigi Testさんの代わりに、Kiến thức cơ bản を登録しました。	2019-12-16
2679	001120	1912	あなたはさんの代わりに、Kiến thức cơ bản をキャンセルしました。	2019-12-16
2680	000000	1912	あなたはさんにKiến thức cơ bảnがキャンセルされました。	2019-12-16
2681	000000	1913	あなたはKhang NguyenさんにKiến thức cơ bảnが代替登録されました。	2019-12-16
2682	001120	1913	あなたはKaigi Testさんの代わりに、Kiến thức cơ bản を登録しました。	2019-12-16
2683	001120	1913	あなたはさんの代わりに、Kiến thức cơ bản をキャンセルしました。	2019-12-16
2684	000000	1913	あなたはさんにKiến thức cơ bảnがキャンセルされました。	2019-12-16
2685	000000	1914	あなたはKhang NguyenさんにKiến thức cơ bảnが代替登録されました。	2019-12-16
2686	001120	1914	あなたはKaigi Testさんの代わりに、Kiến thức cơ bản を登録しました。	2019-12-16
2687	001120	1914	あなたはさんの代わりに、Kiến thức cơ bản をキャンセルしました。	2019-12-16
2688	000000	1914	あなたはさんにKiến thức cơ bảnがキャンセルされました。	2019-12-16
2689	000000	1915	あなたはKhang NguyenさんにKiến thức cơ bảnが代替登録されました。	2019-12-16
2690	001120	1915	あなたはKaigi Testさんの代わりに、Kiến thức cơ bản を登録しました。	2019-12-16
2691	001120	1915	あなたはさんの代わりに、Kiến thức cơ bản をキャンセルしました。	2019-12-16
2692	000000	1915	あなたはさんにKiến thức cơ bảnがキャンセルされました。	2019-12-16
2693	001120	1910	Kiến thức cơ bản をキャンセルしました。	2019-12-16
2694	001120	1916	Kiến thức cơ bản に申込をしました。	2019-12-16
2695	001120	1916	Kiến thức cơ bản をキャンセルしました。	2019-12-16
2696	001120	1917	Kiến thức cơ bản に申込をしました。	2019-12-16
2697	001120	1917	Kiến thức cơ bản をキャンセルしました。	2019-12-16
2698	001120	1918	Kiến thức cơ bản に申込をしました。	2019-12-16
2699	001120	1918	Kiến thức cơ bản をキャンセルしました。	2019-12-16
2700	001120	1919	Kiến thức cơ bản に申込をしました。	2019-12-16
2701	001120	1919	Kiến thức cơ bản をキャンセルしました。	2019-12-16
2702	001120	1920	Kiến thức cơ bản に申込をしました。	2019-12-16
2703	001120	1920	Kiến thức cơ bản をキャンセルしました。	2019-12-16
2704	001120	1921	Kiến thức cơ bản に申込をしました。	2019-12-16
2705	001120	1921	Kiến thức cơ bản をキャンセルしました。	2019-12-16
2706	001120	1922	Kiến thức cơ bản に申込をしました。	2019-12-16
2707	001120	1922	Kiến thức cơ bản をキャンセルしました。	2019-12-16
2708	001120	1923	Kiến thức cơ bản に申込をしました。	2019-12-16
2709	001120	1923	Kiến thức cơ bản をキャンセルしました。	2019-12-16
2710	001120	1924	Kiến thức cơ bản に申込をしました。	2019-12-16
2711	001120	1924	Kiến thức cơ bản をキャンセルしました。	2019-12-16
2712	001120	1925	Kiến thức cơ bản に申込をしました。	2019-12-16
2713	001120	1925	Kiến thức cơ bản をキャンセルしました。	2019-12-16
2714	001120	1926	Kiến thức cơ bản に申込をしました。	2019-12-16
2715	001120	1926	Kiến thức cơ bản をキャンセルしました。	2019-12-16
2716	001120	1927	Kiến thức cơ bản に申込をしました。	2019-12-16
2717	001120	1927	Kiến thức cơ bản をキャンセルしました。	2019-12-16
2718	001120	1928	Kiến thức cơ bản に申込をしました。	2019-12-16
2719	001120	1928	Kiến thức cơ bản をキャンセルしました。	2019-12-16
2720	001120	1929	Kiến thức cơ bản に申込をしました。	2019-12-16
2721	001120	1929	Kiến thức cơ bản をキャンセルしました。	2019-12-16
2722	001120	1930	Kiến thức cơ bản に申込をしました。	2019-12-16
2723	001120	1930	Kiến thức cơ bản をキャンセルしました。	2019-12-16
2724	001120	1931	Kiến thức cơ bản に申込をしました。	2019-12-16
2725	000605	1932	Kiến thức cơ bản に申込をしました。	2020-02-17
2726	000605	1933	Huong dan tao testcase/Test に申込をしました。	2020-02-17
2727	001120	1934	Cách tạo thiết kế của các project に申込をしました。	2020-02-19
2728	001120	1935	ＡＷＳ-Ⅰ　システム自動拡張とメール連携編 に申込をしました。	2020-02-19
2729	001120	1936	ＡＷＳ-Ⅰ　システム自動拡張とメール連携編 に申込をしました。	2020-02-19
2730	001120	1936	ＡＷＳ-Ⅰ　システム自動拡張とメール連携編 をキャンセルしました。	2020-02-19
2731	001120	1937	ＡＷＳ-Ⅰ　システム自動拡張とメール連携編 に申込をしました。	2020-02-19
2732	001120	1834	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-21
2733	001120	1834	UNIX／Linux入門（UMI11L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-21
2734	001120	1834	あなたは Khang Nguyenさんの ステータスを 承認済みに変更しました。	2020-02-21
2735	001120	1834	UNIX／Linux入門（UMI11L）のステータスは、Khang Nguyenさんによって承認済みに変更されました	2020-02-21
2736	001120	1834	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-21
2737	001120	1834	UNIX／Linux入門（UMI11L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-21
2738	001120	1834	あなたは Khang Nguyenさんの ステータスを 承認済みに変更しました。	2020-02-21
2739	001120	1834	UNIX／Linux入門（UMI11L）のステータスは、Khang Nguyenさんによって承認済みに変更されました	2020-02-21
2740	001120	1834	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-21
2741	001120	1834	UNIX／Linux入門（UMI11L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-21
2742	001120	1834	UNIX／Linux入門（UMI11L）のステータスは、Khang Nguyenさんによって承認済みに変更されました	2020-02-21
2743	001120	1834	あなたは Khang Nguyenさんの ステータスを 承認済みに変更しました。	2020-02-21
2744	001120	1834	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-21
2745	001120	1834	UNIX／Linux入門（UMI11L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-21
2746	001120	1782	あなたは Khang Nguyenさんの ステータスを 承認済みに変更しました。	2020-02-21
2797	001120	1938	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-02-25
2747	001120	1782	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L）のステータスは、Khang Nguyenさんによって承認済みに変更されました	2020-02-21
2748	001120	1834	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-02-21
2749	001120	1834	UNIX／Linux入門（UMI11L）のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-02-21
2750	001120	1782	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-21
2751	001120	1782	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-21
2752	001120	1834	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-21
2753	001120	1834	UNIX／Linux入門（UMI11L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-21
2754	001120	1782	あなたは Khang Nguyenさんの ステータスを 承認済みに変更しました。	2020-02-21
2755	001120	1782	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L）のステータスは、Khang Nguyenさんによって承認済みに変更されました	2020-02-21
2756	001120	1782	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-21
2757	001120	1782	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-21
2758	001120	1834	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-02-21
2759	001120	1834	UNIX／Linux入門（UMI11L）のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-02-21
2760	001120	1782	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L）のステータスは、Khang Nguyenさんによって承認済みに変更されました	2020-02-21
2761	001120	1782	あなたは Khang Nguyenさんの ステータスを 承認済みに変更しました。	2020-02-21
2762	001120	1834	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-21
2763	001120	1834	UNIX／Linux入門（UMI11L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-21
2764	001120	1782	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-21
2765	001120	1782	リーダーのためのストレスマネジメント研修～元気な職場と社員を目指して（UZE91L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-21
2766	001120	1938	Javaデータベースプログラミング (JAC0083G) に申込をしました。	2020-02-25
2767	001120	1938	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-25
2768	001120	1938	Javaデータベースプログラミング (JAC0083G)のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-25
2769	001120	1834	あなたは Khang Nguyenさんの ステータスを 研修先申込中に変更しました。	2020-02-25
2770	001120	1834	UNIX／Linux入門（UMI11L）のステータスは、Khang Nguyenさんによって研修先申込中に変更されました	2020-02-25
2771	001120	1834	あなたは Khang Nguyenさんの ステータスを 承認済みに変更しました。	2020-02-25
2772	001120	1834	UNIX／Linux入門（UMI11L）のステータスは、Khang Nguyenさんによって承認済みに変更されました	2020-02-25
2773	001120	1938	あなたは Khang Nguyenさんの ステータスを 研修先申込中に変更しました。	2020-02-25
2774	001120	1938	Javaデータベースプログラミング (JAC0083G)のステータスは、Khang Nguyenさんによって研修先申込中に変更されました	2020-02-25
2775	001120	1938	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-25
2776	001120	1938	Javaデータベースプログラミング (JAC0083G)のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-25
2777	001202	1939	あなたはKhang Nguyenさんにテスト研修TD02が代替登録されました。	2020-02-25
2778	001120	1939	あなたはAnh Ngocさんの代わりに、テスト研修TD02 を登録しました。	2020-02-25
2779	001120	1939	あなたはさんの代わりに、テスト研修TD02 をキャンセルしました。	2020-02-25
2780	001202	1939	あなたはさんにテスト研修TD02がキャンセルされました。	2020-02-25
2781	001202	1940	あなたはKhang Nguyenさんにテスト研修TD02が代替登録されました。	2020-02-25
2782	001120	1940	あなたはAnh Ngocさんの代わりに、テスト研修TD02 を登録しました。	2020-02-25
2783	001120	1940	あなたはさんの代わりに、テスト研修TD02 をキャンセルしました。	2020-02-25
2784	001202	1940	あなたはさんにテスト研修TD02がキャンセルされました。	2020-02-25
2785	001202	1941	あなたはKhang Nguyenさんにテスト研修TD02が代替登録されました。	2020-02-25
2786	001120	1941	あなたはAnh Ngocさんの代わりに、テスト研修TD02 を登録しました。	2020-02-25
2787	001120	1941	あなたはさんの代わりに、テスト研修TD02 をキャンセルしました。	2020-02-25
2788	001202	1941	あなたはさんにテスト研修TD02がキャンセルされました。	2020-02-25
2789	001202	1942	あなたはKhang Nguyenさんにテスト研修TD02が代替登録されました。	2020-02-25
2790	001120	1942	あなたはAnh Ngocさんの代わりに、テスト研修TD02 を登録しました。	2020-02-25
2791	001120	1942	あなたはさんの代わりに、テスト研修TD02 をキャンセルしました。	2020-02-25
2792	001202	1942	あなたはさんにテスト研修TD02がキャンセルされました。	2020-02-25
2793	001202	1943	あなたはKhang Nguyenさんにテスト研修TD02が代替登録されました。	2020-02-25
2794	001120	1943	あなたはAnh Ngocさんの代わりに、テスト研修TD02 を登録しました。	2020-02-25
2795	001120	1943	あなたはAnh Ngocさんの代わりに、テスト研修TD02 をキャンセルしました。	2020-02-25
2796	001202	1943	あなたはKhang Nguyenさんにテスト研修TD02がキャンセルされました。	2020-02-25
2798	001120	1938	Javaデータベースプログラミング (JAC0083G)のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-02-25
2799	001120	1938	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-25
2800	001120	1938	Javaデータベースプログラミング (JAC0083G)のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-25
2801	001120	1938	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-02-25
2802	001120	1938	Javaデータベースプログラミング (JAC0083G)のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-02-25
2803	001120	1938	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-25
2804	001120	1938	Javaデータベースプログラミング (JAC0083G)のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-25
2805	001120	1938	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-02-25
2806	001120	1938	Javaデータベースプログラミング (JAC0083G)のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-02-25
2807	001120	1938	Javaデータベースプログラミング (JAC0083G)のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-25
2808	001120	1938	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-25
2809	001120	1938	あなたは Khang Nguyenさんの ステータスを 申込不可に変更しました。	2020-02-25
2810	001120	1938	Javaデータベースプログラミング (JAC0083G)のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-02-25
2811	001120	1836	ＰＭ７つ道具使用手順 をキャンセルしました。	2020-02-25
2812	001120	1944	ＰＭ７つ道具使用手順 に申込をしました。	2020-02-25
2813	000605	1933	Huong dan tao testcase/Test をキャンセルしました。	2020-02-26
2814	001202	1945	あなたはNuong PhamさんにKiến thức cơ bảnが代替登録されました。	2020-02-26
2815	000605	1945	あなたはAnh Ngocさんの代わりに、Kiến thức cơ bản を登録しました。	2020-02-26
2816	000605	1945	あなたはAnh Ngocさんの代わりに、Kiến thức cơ bản をキャンセルしました。	2020-02-26
2817	001202	1945	あなたはNuong PhamさんにKiến thức cơ bảnがキャンセルされました。	2020-02-26
2818	001120	1946	プロジェクトマネジメントの技法 (UAQ41L)  に申込をしました。	2020-02-27
2819	001120	1834	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-27
2820	001120	1834	UNIX／Linux入門（UMI11L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-27
2821	001120	1834	UNIX／Linux入門（UMI11L）のステータスは、Khang Nguyenさんによって承認済みに変更されました	2020-02-27
2822	001120	1834	あなたは Khang Nguyenさんの ステータスを 承認済みに変更しました。	2020-02-27
2823	001120	1834	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-27
2824	001120	1834	UNIX／Linux入門（UMI11L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-27
2825	001120	1834	あなたは Khang Nguyenさんの ステータスを 承認済みに変更しました。	2020-02-27
2826	001120	1834	UNIX／Linux入門（UMI11L）のステータスは、Khang Nguyenさんによって承認済みに変更されました	2020-02-27
2827	001120	1834	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-27
2828	001120	1834	UNIX／Linux入門（UMI11L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-27
2829	001120	1834	あなたは Khang Nguyenさんの ステータスを 承認済みに変更しました。	2020-02-27
2830	001120	1834	UNIX／Linux入門（UMI11L）のステータスは、Khang Nguyenさんによって承認済みに変更されました	2020-02-27
2831	001120	1834	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-27
2832	001120	1834	UNIX／Linux入門（UMI11L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-27
2833	001120	1952	テスト研修TD01 に申込をしました。	2020-02-27
2834	001202	1953	あなたはKhang Nguyenさんにテスト研修TD01が代替登録されました。	2020-02-27
2835	001120	1953	あなたはAnh Ngocさんの代わりに、テスト研修TD01 を登録しました。	2020-02-27
2836	001120	1952	あなたは Khang Nguyenさんの ステータスを 承認済みに変更しました。	2020-02-27
2837	001120	1952	テスト研修TD01のステータスは、Khang Nguyenさんによって承認済みに変更されました	2020-02-27
2838	001120	1953	あなたは Anh Ngocさんの ステータスを 研修先申込中に変更しました。	2020-02-27
2839	001202	1953	テスト研修TD01のステータスは、Khang Nguyenさんによって研修先申込中に変更されました	2020-02-27
2840	001120	1952	あなたは Khang Nguyenさんの ステータスを 申込不可に変更しました。	2020-02-27
2841	001120	1952	テスト研修TD01のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-02-27
2842	001120	1953	あなたは Anh Ngocさんの ステータスを 開始待ちに変更しました。	2020-02-27
2843	001202	1953	テスト研修TD01のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-27
2844	001120	1952	あなたは Khang Nguyenさんの ステータスを アンケート回答待ちに変更しました。	2020-02-27
2845	001120	1952	テスト研修TD01のステータスは、Khang Nguyenさんによってアンケート回答待ちに変更されました	2020-02-27
2846	001120	1953	あなたは Anh Ngocさんの ステータスを 経費精算待ちに変更しました。	2020-02-27
2847	001202	1953	テスト研修TD01のステータスは、Khang Nguyenさんによって経費精算待ちに変更されました	2020-02-27
2848	001120	1952	あなたは Khang Nguyenさんの ステータスを 完了に変更しました。	2020-02-27
2849	001120	1952	テスト研修TD01のステータスは、Khang Nguyenさんによって完了に変更されました	2020-02-27
2850	001120	1953	あなたは Anh Ngocさんの ステータスを キャンセル依頼中に変更しました。	2020-02-27
2851	001202	1953	テスト研修TD01のステータスは、Khang Nguyenさんによってキャンセル依頼中に変更されました	2020-02-27
2852	001120	1952	あなたは Khang Nguyenさんの ステータスを キャンセルに変更しました。	2020-02-27
2853	001120	1952	テスト研修TD01のステータスは、Khang Nguyenさんによってキャンセルに変更されました	2020-02-27
2854	001120	1953	あなたは Anh Ngocさんの ステータスを キャンセル（有償）に変更しました。	2020-02-27
2855	001202	1953	テスト研修TD01のステータスは、Khang Nguyenさんによってキャンセル（有償）に変更されました	2020-02-27
2856	001120	1953	あなたは Anh Ngocさんの ステータスを 削除に変更しました。	2020-02-27
2857	001202	1953	テスト研修TD01のステータスは、Khang Nguyenさんによって削除に変更されました	2020-02-27
2858	001120	1952	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-02-27
2859	001120	1952	テスト研修TD01のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-02-27
2860	001120	1953	あなたは Anh Ngocさんの ステータスを 研修参加申請中に変更しました。	2020-02-27
2861	001202	1953	テスト研修TD01のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-02-27
2862	001120	1952	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-27
2863	001120	1952	テスト研修TD01のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-27
2864	001120	1952	テスト研修TD01 をキャンセルしました。	2020-02-27
2865	001120	1958	テスト研修TD01 に申込をしました。	2020-02-27
2866	001120	1958	テスト研修TD01 をキャンセルしました。	2020-02-27
2867	001120	1959	テスト研修TD01 に申込をしました。	2020-02-27
2868	001120	1959	あなたは Khang Nguyenさんの ステータスを 承認済みに変更しました。	2020-02-27
2869	001120	1959	テスト研修TD01のステータスは、Khang Nguyenさんによって承認済みに変更されました	2020-02-27
2870	001120	1959	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-27
2871	001120	1959	テスト研修TD01のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-27
2872	001120	1959	あなたは Khang Nguyenさんの ステータスを 申込不可に変更しました。	2020-02-27
2873	001120	1959	テスト研修TD01のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-02-27
2874	001120	1959	テスト研修TD01 をキャンセルしました。	2020-02-27
2875	001120	1960	テスト研修TD01 に申込をしました。	2020-02-27
2876	001120	1960	テスト研修TD01 をキャンセルしました。	2020-02-27
2877	001120	1960	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-27
2878	001120	1960	テスト研修TD01のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-27
2879	001120	1960	あなたは Khang Nguyenさんの ステータスを 申込不可に変更しました。	2020-02-27
2880	001120	1960	テスト研修TD01のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-02-27
2881	001120	1953	あなたはAnh Ngocさんの代わりに、テスト研修TD01 をキャンセルしました。	2020-02-27
2882	001202	1953	あなたはKhang Nguyenさんにテスト研修TD01がキャンセルされました。	2020-02-27
2883	001120	1953	あなたは Anh Ngocさんの ステータスを 承認済みに変更しました。	2020-02-27
2884	001202	1953	テスト研修TD01のステータスは、Khang Nguyenさんによって承認済みに変更されました	2020-02-27
2885	001120	1960	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-02-27
2886	001120	1960	テスト研修TD01のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-02-27
2887	001120	1953	あなたは Anh Ngocさんの ステータスを 研修先申込中に変更しました。	2020-02-27
2888	001202	1953	テスト研修TD01のステータスは、Khang Nguyenさんによって研修先申込中に変更されました	2020-02-27
2889	001120	1960	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-27
2890	001120	1960	テスト研修TD01のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-27
2891	001120	1953	あなたは Anh Ngocさんの ステータスを 申込不可に変更しました。	2020-02-27
2892	001202	1953	テスト研修TD01のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-02-27
2893	001120	1960	あなたは Khang Nguyenさんの ステータスを アンケート回答待ちに変更しました。	2020-02-27
2894	001120	1960	テスト研修TD01のステータスは、Khang Nguyenさんによってアンケート回答待ちに変更されました	2020-02-27
2895	001120	1953	あなたは Anh Ngocさんの ステータスを 経費精算待ちに変更しました。	2020-02-27
2896	001202	1953	テスト研修TD01のステータスは、Khang Nguyenさんによって経費精算待ちに変更されました	2020-02-27
2897	001120	1960	あなたは Khang Nguyenさんの ステータスを 完了に変更しました。	2020-02-27
2898	001120	1960	テスト研修TD01のステータスは、Khang Nguyenさんによって完了に変更されました	2020-02-27
2899	001120	1953	あなたは Anh Ngocさんの ステータスを キャンセル依頼中に変更しました。	2020-02-27
2900	001202	1953	テスト研修TD01のステータスは、Khang Nguyenさんによってキャンセル依頼中に変更されました	2020-02-27
2901	001120	1965	テスト研修TD03 に申込をしました。	2020-02-27
2902	001120	1965	テスト研修TD03 をキャンセルしました。	2020-02-27
2903	001120	1960	あなたは Khang Nguyenさんの ステータスを 研修先申込中に変更しました。	2020-02-28
2904	001120	1960	テスト研修TD01のステータスは、Khang Nguyenさんによって研修先申込中に変更されました	2020-02-28
2905	001120	1960	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-02-28
2906	001120	1960	テスト研修TD01のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-02-28
2907	001202	1966	あなたはKhang NguyenさんにITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A)が代替登録されました。	2020-03-02
2908	001120	1966	あなたはAnh Ngocさんの代わりに、ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A) を登録しました。	2020-03-02
2909	001120	1966	あなたは Anh Ngocさんの ステータスを 開始待ちに変更しました。	2020-03-02
2910	001202	1966	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A)のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-02
2911	001120	1966	あなたは Anh Ngocさんの ステータスを 申込不可に変更しました。	2020-03-02
2912	001202	1966	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A)のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-03-02
2913	001120	1966	あなたは Anh Ngocさんの ステータスを 開始待ちに変更しました。	2020-03-02
2914	001202	1966	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A)のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-02
2915	001120	1966	あなたは Anh Ngocさんの ステータスを 申込不可に変更しました。	2020-03-02
2916	001202	1966	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A)のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-03-02
2917	001120	1967	新人研修／基本コンテンツ に申込をしました。	2020-03-02
2918	001120	1967	新人研修／基本コンテンツのステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-02
2919	001120	1967	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-02
2920	001202	1968	あなたはKhang Nguyenさんに新人研修／基本コンテンツが代替登録されました。	2020-03-02
2921	001120	1968	あなたはAnh Ngocさんの代わりに、新人研修／基本コンテンツ を登録しました。	2020-03-02
2922	001120	1968	あなたは Anh Ngocさんの ステータスを 開始待ちに変更しました。	2020-03-02
2923	001202	1968	新人研修／基本コンテンツのステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-02
2924	001120	1969	あなたはAnh Ngocさんに Microsoft AzureによるITインフラの拡張 ～基本から学ぶサーバー構築～(MSC0517V)が代替登録されました。	2020-03-04
2925	001202	1969	あなたはKhang Nguyenさんの代わりに、 Microsoft AzureによるITインフラの拡張 ～基本から学ぶサーバー構築～(MSC0517V) を登録しました。	2020-03-04
2926	001202	1970	あなたはKhang Nguyenさんにシステム設計・実装　　【基礎編】 （後編）が代替登録されました。	2020-03-04
2927	001120	1970	あなたはAnh Ngocさんの代わりに、システム設計・実装　　【基礎編】 （後編） を登録しました。	2020-03-04
2928	001202	1971	あなたはKhang Nguyenさんにアジャイル開発手法によるシステム開発(UBS99L)が代替登録されました。	2020-03-04
2929	001120	1971	あなたはAnh Ngocさんの代わりに、アジャイル開発手法によるシステム開発(UBS99L) を登録しました。	2020-03-04
2930	001120	1971	あなたは Anh Ngocさんの ステータスを 開始待ちに変更しました。	2020-03-04
2931	001202	1971	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-04
2932	001120	1971	あなたはAnh Ngocさんの代わりに、アジャイル開発手法によるシステム開発(UBS99L) をキャンセルしました。	2020-03-04
2933	001202	1971	あなたはKhang Nguyenさんにアジャイル開発手法によるシステム開発(UBS99L)がキャンセルされました。	2020-03-04
2934	001202	1972	あなたはKhang Nguyenさんにアジャイル開発手法によるシステム開発(UBS99L)が代替登録されました。	2020-03-04
2935	001120	1972	あなたはAnh Ngocさんの代わりに、アジャイル開発手法によるシステム開発(UBS99L) を登録しました。	2020-03-04
2936	001202	1972	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-04
2937	001120	1972	あなたは Anh Ngocさんの ステータスを 開始待ちに変更しました。	2020-03-04
2938	001120	1972	あなたは Anh Ngocさんの ステータスを 申込不可に変更しました。	2020-03-04
2939	001202	1972	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-03-04
2940	001120	1972	あなたはAnh Ngocさんの代わりに、アジャイル開発手法によるシステム開発(UBS99L) をキャンセルしました。	2020-03-04
2941	001202	1972	あなたはKhang Nguyenさんにアジャイル開発手法によるシステム開発(UBS99L)がキャンセルされました。	2020-03-04
2942	001202	1973	あなたはKhang Nguyenさんにアジャイル開発手法によるシステム開発(UBS99L)が代替登録されました。	2020-03-04
2943	001120	1973	あなたはAnh Ngocさんの代わりに、アジャイル開発手法によるシステム開発(UBS99L) を登録しました。	2020-03-04
2944	001120	1974	アジャイル開発手法によるシステム開発(UBS99L) に申込をしました。	2020-03-04
2945	001120	1974	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-04
2946	001120	1974	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-04
2947	001120	1974	あなたは Khang Nguyenさんの ステータスを 申込不可に変更しました。	2020-03-04
2948	001120	1974	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-03-04
2949	001120	1974	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-04
2950	001120	1974	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-04
2951	001202	1975	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A) に申込をしました。	2020-03-05
2952	001008	1979	あなたはAnh NgocさんにITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A)が代替登録されました。	2020-03-05
2953	001202	1979	あなたはMy Kimさんの代わりに、ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A) を登録しました。	2020-03-05
2954	001202	1985	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) をキャンセルしました。	2020-03-05
2955	001202	1986	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2020-03-05
2956	001202	1986	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) をキャンセルしました。	2020-03-05
2957	001202	1987	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2020-03-05
2958	001202	1987	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) をキャンセルしました。	2020-03-05
2959	001120	1988	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L） に申込をしました。	2020-03-05
2960	001120	1988	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L） をキャンセルしました。	2020-03-05
2961	001120	1990	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A) に申込をしました。	2020-03-05
2962	001120	1989	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L） をキャンセルしました。	2020-03-05
2963	001120	1993	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2020-03-05
2964	001120	1993	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) をキャンセルしました。	2020-03-05
2965	001202	1994	あなたはKhang NguyenさんにJavaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G)が代替登録されました。	2020-03-05
2966	001120	1994	あなたはAnh Ngocさんの代わりに、Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) を登録しました。	2020-03-05
2967	001120	1994	あなたはAnh Ngocさんの代わりに、Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) をキャンセルしました。	2020-03-05
2968	001202	1994	あなたはKhang NguyenさんにJavaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G)がキャンセルされました。	2020-03-05
2969	001120	1995	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L） に申込をしました。	2020-03-05
2970	001120	1995	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L） をキャンセルしました。	2020-03-05
2971	001202	1996	あなたはKhang Nguyenさんにシェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）が代替登録されました。	2020-03-05
2972	001120	1996	あなたはAnh Ngocさんの代わりに、シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L） を登録しました。	2020-03-05
2973	001120	1996	あなたはAnh Ngocさんの代わりに、シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L） をキャンセルしました。	2020-03-05
2974	001202	1996	あなたはKhang Nguyenさんにシェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）がキャンセルされました。	2020-03-05
2975	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L） に申込をしました。	2020-03-05
2976	001120	1997	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-05
2977	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-05
2978	001120	1997	あなたは Khang Nguyenさんの ステータスを 申込不可に変更しました。	2020-03-05
2979	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-03-05
2980	001120	1997	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-03-05
2981	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-03-05
2982	001120	1990	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-05
2983	001120	1990	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A)のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-05
2984	001120	1990	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-03-05
2985	001120	1990	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A)のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-03-05
2986	001120	1990	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-05
2987	001120	1990	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A)のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-05
2988	001120	1990	あなたは Khang Nguyenさんの ステータスを 申込不可に変更しました。	2020-03-05
2989	001120	1990	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A)のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-03-05
2990	001120	1990	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A) をキャンセルしました。	2020-03-05
2991	001120	1997	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-05
2992	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-05
2993	001120	1997	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-03-05
2994	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-03-05
2995	001120	1997	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-05
2996	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-05
2997	001202	1998	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A) に申込をしました。	2020-03-05
2998	001120	1997	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-03-05
2999	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-03-05
3000	001120	1997	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-05
3001	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-05
3002	001202	1998	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A) をキャンセルしました。	2020-03-05
3003	001120	1997	あなたは Khang Nguyenさんの ステータスを 申込不可に変更しました。	2020-03-05
3004	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-03-05
3005	001120	1997	あなたは Khang Nguyenさんの ステータスを 申込不可に変更しました。	2020-03-05
3006	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-03-05
3007	001120	1999	あなたはAnh NgocさんにITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A)が代替登録されました。	2020-03-05
3008	001202	1999	あなたはKhang Nguyenさんの代わりに、ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A) を登録しました。	2020-03-05
3009	001120	1997	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-05
3010	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-05
3011	001202	1999	あなたはKhang Nguyenさんの代わりに、ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A) をキャンセルしました。	2020-03-05
3012	001120	1999	あなたはAnh NgocさんにITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A)がキャンセルされました。	2020-03-05
3013	001120	1997	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-03-05
3014	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-03-05
3015	001120	1997	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-05
3016	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-05
3017	001202	2000	あなたはKhang NguyenさんにJavaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G)が代替登録されました。	2020-03-05
3018	001120	2000	あなたはAnh Ngocさんの代わりに、Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) を登録しました。	2020-03-05
3019	001120	2000	あなたはAnh Ngocさんの代わりに、Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) をキャンセルしました。	2020-03-05
3064	001202	2022	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) に申込をしました。	2020-03-05
3020	001202	2000	あなたはKhang NguyenさんにJavaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G)がキャンセルされました。	2020-03-05
3021	001202	2001	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A) に申込をしました。	2020-03-05
3022	001202	2001	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A) をキャンセルしました。	2020-03-05
3023	001120	2002	あなたはAnh NgocさんにITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A)が代替登録されました。	2020-03-05
3024	001202	2002	あなたはKhang Nguyenさんの代わりに、ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A) を登録しました。	2020-03-05
3025	001202	2002	あなたはKhang Nguyenさんの代わりに、ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A) をキャンセルしました。	2020-03-05
3026	001120	2002	あなたはAnh NgocさんにITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A)がキャンセルされました。	2020-03-05
3027	001120	1997	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-03-05
3028	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-03-05
3029	001202	2005	Microsoft Azure入門 (UCV42L)  に申込をしました。	2020-03-05
3030	001120	1997	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-05
3031	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-05
3032	001202	2005	Microsoft Azure入門 (UCV42L)  をキャンセルしました。	2020-03-05
3033	001120	2006	あなたはAnh NgocさんにMicrosoft Azure入門 (UCV42L) が代替登録されました。	2020-03-05
3034	001202	2006	あなたはKhang Nguyenさんの代わりに、Microsoft Azure入門 (UCV42L)  を登録しました。	2020-03-05
3035	001120	2006	あなたはAnh NgocさんにMicrosoft Azure入門 (UCV42L) がキャンセルされました。	2020-03-05
3036	001202	2006	あなたはKhang Nguyenさんの代わりに、Microsoft Azure入門 (UCV42L)  をキャンセルしました。	2020-03-05
3037	001120	2007	あなたはAnh NgocさんにMicrosoft Azure入門 (UCV42L) が代替登録されました。	2020-03-05
3038	001202	2007	あなたはKhang Nguyenさんの代わりに、Microsoft Azure入門 (UCV42L)  を登録しました。	2020-03-05
3039	001202	2008	Microsoft Azure入門 (UCV42L)  に申込をしました。	2020-03-05
3040	001202	2015	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A) に申込をしました。	2020-03-05
3041	001202	2015	あなたは Anh Ngocさんの ステータスを 開始待ちに変更しました。	2020-03-05
3042	001202	2015	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A)のステータスは、Anh Ngocさんによって開始待ちに変更されました	2020-03-05
3043	001120	2018	プロジェクトマネジメントの技法 (UAQ41L)  に申込をしました。	2020-03-05
3044	001202	2019	新任管理職研修 に申込をしました。	2020-03-05
3045	001120	2020	あなたはAnh Ngocさんに新任管理職研修が代替登録されました。	2020-03-05
3046	001202	2020	あなたはKhang Nguyenさんの代わりに、新任管理職研修 を登録しました。	2020-03-05
3047	001202	2020	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-05
3048	001120	2020	新任管理職研修のステータスは、Anh Ngocさんによって開始待ちに変更されました	2020-03-05
3049	001202	2019	新任管理職研修のステータスは、Anh Ngocさんによって開始待ちに変更されました	2020-03-05
3050	001202	2019	あなたは Anh Ngocさんの ステータスを 開始待ちに変更しました。	2020-03-05
3051	001202	2020	あなたは Khang Nguyenさんの ステータスを キャンセルに変更しました。	2020-03-05
3052	001120	2020	新任管理職研修のステータスは、Anh Ngocさんによってキャンセルに変更されました	2020-03-05
3053	001202	2020	あなたは Khang Nguyenさんの ステータスを 申込不可に変更しました。	2020-03-05
3054	001120	2020	新任管理職研修のステータスは、Anh Ngocさんによって申込不可に変更されました	2020-03-05
3055	001202	2019	あなたは Anh Ngocさんの ステータスを キャンセル依頼中に変更しました。	2020-03-05
3056	001202	2019	新任管理職研修のステータスは、Anh Ngocさんによってキャンセル依頼中に変更されました	2020-03-05
3057	001202	2019	あなたは Anh Ngocさんの ステータスを 申込不可に変更しました。	2020-03-05
3058	001202	2019	新任管理職研修のステータスは、Anh Ngocさんによって申込不可に変更されました	2020-03-05
3059	001202	2019	新任管理職研修 をキャンセルしました。	2020-03-05
3060	001202	2020	あなたはKhang Nguyenさんの代わりに、新任管理職研修 をキャンセルしました。	2020-03-05
3061	001120	2020	あなたはAnh Ngocさんに新任管理職研修がキャンセルされました。	2020-03-05
3062	001120	2021	あなたはAnh NgocさんにITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A)が代替登録されました。	2020-03-05
3063	001202	2021	あなたはKhang Nguyenさんの代わりに、ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A) を登録しました。	2020-03-05
3065	001120	2023	あなたはAnh NgocさんにJavaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G)が代替登録されました。	2020-03-05
3066	001202	2023	あなたはKhang Nguyenさんの代わりに、Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) を登録しました。	2020-03-05
3067	001202	2023	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-05
3068	001120	2023	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G)のステータスは、Anh Ngocさんによって開始待ちに変更されました	2020-03-05
3069	001202	2022	あなたは Anh Ngocさんの ステータスを 開始待ちに変更しました。	2020-03-05
3070	001202	2022	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G)のステータスは、Anh Ngocさんによって開始待ちに変更されました	2020-03-05
3071	001202	2023	あなたは Khang Nguyenさんの ステータスを 申込不可に変更しました。	2020-03-05
3072	001120	2023	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G)のステータスは、Anh Ngocさんによって申込不可に変更されました	2020-03-05
3073	001202	2022	あなたは Anh Ngocさんの ステータスを 申込不可に変更しました。	2020-03-05
3074	001202	2022	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G)のステータスは、Anh Ngocさんによって申込不可に変更されました	2020-03-05
3075	001202	2023	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-05
3076	001120	2023	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G)のステータスは、Anh Ngocさんによって開始待ちに変更されました	2020-03-05
3077	001202	2022	あなたは Anh Ngocさんの ステータスを 開始待ちに変更しました。	2020-03-05
3078	001202	2022	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G)のステータスは、Anh Ngocさんによって開始待ちに変更されました	2020-03-05
3079	001202	2022	Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) をキャンセルしました。	2020-03-05
3080	001202	2023	あなたはKhang Nguyenさんの代わりに、Javaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G) をキャンセルしました。	2020-03-05
3081	001120	2023	あなたはAnh NgocさんにJavaシステムプログラミング ～ストリーム,コレクション,マルチスレッド～(JAC0082G)がキャンセルされました。	2020-03-05
3082	001202	1975	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A)のステータスは、Anh Ngocさんによって開始待ちに変更されました	2020-03-05
3083	001202	1975	あなたは Anh Ngocさんの ステータスを 開始待ちに変更しました。	2020-03-05
3084	001120	1997	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-03-05
3085	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-03-05
3086	001120	1997	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-05
3087	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-05
3088	001120	1997	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-03-05
3089	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-03-05
3091	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-05
3090	001120	1997	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-05
3092	001120	1997	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-03-05
3093	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-03-05
3094	001120	1997	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-05
3095	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-05
3096	001120	1997	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-03-05
3097	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-03-05
3098	001120	1997	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-05
3099	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-05
3100	001120	1997	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-03-05
3101	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-03-05
3102	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-05
3103	001120	1997	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-05
3104	001120	1997	あなたは Khang Nguyenさんの ステータスを 申込不可に変更しました。	2020-03-05
3105	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-03-05
3106	001120	1997	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-03-05
3107	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-03-05
3108	001120	1997	あなたは Khang Nguyenさんの ステータスを 申込不可に変更しました。	2020-03-05
3109	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-03-05
3110	001120	1997	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-03-05
3111	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-03-05
3112	001120	1997	あなたは Khang Nguyenさんの ステータスを 申込不可に変更しました。	2020-03-05
3113	001120	1997	シェルの機能とプログラミング　～UNIX／Linuxの効率的使用を目指して～（UMI23L）のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-03-05
3114	001120	1974	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-03-06
3115	001120	1974	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-03-06
3116	001120	1974	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-06
3117	001120	1974	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-06
3118	001120	1974	あなたは Khang Nguyenさんの ステータスを 申込不可に変更しました。	2020-03-06
3119	001120	1974	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-03-06
3120	001120	1974	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-03-06
3121	001120	1974	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-03-06
3122	001120	1974	あなたは Khang Nguyenさんの ステータスを 申込不可に変更しました。	2020-03-06
3123	001120	1974	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-03-06
3124	001120	1974	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-03-06
3125	001120	1974	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-03-06
3126	001120	1974	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-06
3127	001120	1974	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-06
3128	001120	1974	あなたは Khang Nguyenさんの ステータスを 申込不可に変更しました。	2020-03-06
3129	001120	1974	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-03-06
3130	001120	1974	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-03-06
3131	001120	1974	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-03-06
3132	001120	1974	あなたは Khang Nguyenさんの ステータスを 申込不可に変更しました。	2020-03-06
3133	001120	1974	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-03-06
3134	001120	1974	あなたは Khang Nguyenさんの ステータスを 研修参加申請中に変更しました。	2020-03-06
3135	001120	1974	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、Khang Nguyenさんによって研修参加申請中に変更されました	2020-03-06
3136	001120	1974	あなたは Khang Nguyenさんの ステータスを 申込不可に変更しました。	2020-03-06
3137	001120	1974	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-03-06
3138	001120	1974	あなたは Khang Nguyenさんの ステータスを 開始待ちに変更しました。	2020-03-06
3139	001120	1974	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、Khang Nguyenさんによって開始待ちに変更されました	2020-03-06
3140	001202	1975	あなたは Anh Ngocさんの ステータスを 申込不可に変更しました。	2020-03-06
3141	001202	1975	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A)のステータスは、Anh Ngocさんによって申込不可に変更されました	2020-03-06
3142	001202	1975	あなたは Anh Ngocさんの ステータスを 開始待ちに変更しました。	2020-03-06
3143	001202	1975	ITプロフェッショナルのためのビジネス思考力養成（入門）～問題解決力とビジネス・コミュニケーションのベースを築く～(CNC0069A)のステータスは、Anh Ngocさんによって開始待ちに変更されました	2020-03-06
3144	001120	1974	あなたは Khang Nguyenさんの ステータスを 申込不可に変更しました。	2020-03-06
3145	001120	1974	アジャイル開発手法によるシステム開発(UBS99L)のステータスは、Khang Nguyenさんによって申込不可に変更されました	2020-03-06
\.


--
-- Name: tbl_checkin_check_in_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_checkin_check_in_id_seq', 11, true);


--
-- Name: tbl_event_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_event_event_id_seq', 27, true);


--
-- Name: tbl_hyouka_hyouka_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_hyouka_hyouka_id_seq', 62, true);


--
-- Name: tbl_kensyuu_nittei_master_nittei_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_kensyuu_nittei_master_nittei_id_seq', 16557, true);


--
-- Name: tbl_kyouiku_shukankikan_id_kyouiku_shukankikan_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_kyouiku_shukankikan_id_kyouiku_shukankikan_seq', 22, true);


--
-- Name: tbl_mail_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_mail_config_id_seq', 1, true);


--
-- Name: tbl_mail_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_mail_log_id_seq', 1, false);


--
-- Name: tbl_moushikomi_moushikomi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_moushikomi_moushikomi_id_seq', 2028, true);


--
-- Name: tbl_permission_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_permission_permission_id_seq', 53, true);


--
-- Name: tbl_qrcode_qrcode_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_qrcode_qrcode_id_seq', 96, true);


--
-- Name: tbl_recommend_template_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_recommend_template_id_seq', 6, true);


--
-- Name: tbl_setting_setting_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_setting_setting_id_seq', 2, true);


--
-- Name: tbl_tags_id_tag_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_tags_id_tag_seq', 35, true);


--
-- Name: tbl_tsuuchi_tsuuchi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tbl_tsuuchi_tsuuchi_id_seq', 3145, true);


--
-- Name: tbl_anketto tbl_anketto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_anketto
    ADD CONSTRAINT tbl_anketto_pkey PRIMARY KEY (anketto_id);


--
-- Name: tbl_checkin tbl_checkin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_checkin
    ADD CONSTRAINT tbl_checkin_pkey PRIMARY KEY (check_in_id);


--
-- Name: tbl_event tbl_event_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_event
    ADD CONSTRAINT tbl_event_pkey PRIMARY KEY (event_id);


--
-- Name: tbl_hyouka tbl_hyouka_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_hyouka
    ADD CONSTRAINT tbl_hyouka_pkey PRIMARY KEY (hyouka_id);


--
-- Name: tbl_kensyuu_master tbl_kensyuu_master_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_kensyuu_master
    ADD CONSTRAINT tbl_kensyuu_master_pkey PRIMARY KEY (kensyuu_id);


--
-- Name: tbl_kensyuu_nittei_master tbl_kensyuu_nittei_master_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_kensyuu_nittei_master
    ADD CONSTRAINT tbl_kensyuu_nittei_master_pkey PRIMARY KEY (nittei_id);


--
-- Name: tbl_kyouiku_shukankikan tbl_kyouiku_shukankikan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_kyouiku_shukankikan
    ADD CONSTRAINT tbl_kyouiku_shukankikan_pkey PRIMARY KEY (id_kyouiku_shukankikan);


--
-- Name: tbl_mail_config tbl_mail_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_mail_config
    ADD CONSTRAINT tbl_mail_config_pkey PRIMARY KEY (id);


--
-- Name: tbl_mail_log tbl_mail_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_mail_log
    ADD CONSTRAINT tbl_mail_log_pkey PRIMARY KEY (id);


--
-- Name: tbl_moushikomi tbl_moushikomi_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_moushikomi
    ADD CONSTRAINT tbl_moushikomi_pk PRIMARY KEY (moushikomi_id);


--
-- Name: tbl_permission tbl_permission_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_permission
    ADD CONSTRAINT tbl_permission_pk PRIMARY KEY (permission_id);


--
-- Name: tbl_qrcode tbl_qrcode_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_qrcode
    ADD CONSTRAINT tbl_qrcode_pkey PRIMARY KEY (qrcode_id);


--
-- Name: tbl_recommend_template tbl_recommend_template_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_recommend_template
    ADD CONSTRAINT tbl_recommend_template_pkey PRIMARY KEY (id);


--
-- Name: tbl_tags tbl_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_tags
    ADD CONSTRAINT tbl_tags_pkey PRIMARY KEY (id_tag);


--
-- Name: tbl_tsuuchi tbl_tsuuchi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_tsuuchi
    ADD CONSTRAINT tbl_tsuuchi_pkey PRIMARY KEY (tsuuchi_id);


--
-- Name: tbl_hyouka chousa_go; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER chousa_go AFTER INSERT ON public.tbl_hyouka FOR EACH ROW EXECUTE PROCEDURE public.chousa_go();


--
-- Name: tbl_moushikomi on_update_moushikomi; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER on_update_moushikomi BEFORE UPDATE ON public.tbl_moushikomi FOR EACH ROW EXECUTE PROCEDURE public.fill_koushinbi();


--
-- PostgreSQL database dump complete
--

