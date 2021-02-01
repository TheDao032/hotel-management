--
-- PostgreSQL database dump
--

-- Dumped from database version 12.5 (Ubuntu 12.5-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.5 (Ubuntu 12.5-0ubuntu0.20.04.1)

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
-- Name: check_existed_id(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_existed_id(id text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
   result text;
begin
    if (id IN (SELECT id_acc FROM tbl_account WHERE id_acc = id )) then
        result := '';
    else
        result := id;
    end if;
	return result;
end
$$;


ALTER FUNCTION public.check_existed_id(id text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: tbl_customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_customer (
    id_cus integer NOT NULL,
    name_cus text,
    cardid_cus text,
    birth_cus date,
    phonenumber_cus text,
    status_cus integer,
    isforeigner_cus integer
);


ALTER TABLE public.tbl_customer OWNER TO postgres;

--
-- Name: tbl_Customer_ID_cus_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."tbl_Customer_ID_cus_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."tbl_Customer_ID_cus_seq" OWNER TO postgres;

--
-- Name: tbl_Customer_ID_cus_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tbl_Customer_ID_cus_seq" OWNED BY public.tbl_customer.id_cus;


--
-- Name: tbl_permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_permission (
    id_per integer NOT NULL,
    name_per text,
    status_per integer
);


ALTER TABLE public.tbl_permission OWNER TO postgres;

--
-- Name: tbl_Permission_ID_per_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."tbl_Permission_ID_per_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."tbl_Permission_ID_per_seq" OWNER TO postgres;

--
-- Name: tbl_Permission_ID_per_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tbl_Permission_ID_per_seq" OWNED BY public.tbl_permission.id_per;


--
-- Name: tbl_account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_account (
    id_acc text NOT NULL,
    username_acc text,
    pass_acc text,
    id_per_acc integer,
    status_acc integer,
    datebegin_acc date,
    dateexpired_acc date,
    id_emp_acc text
);


ALTER TABLE public.tbl_account OWNER TO postgres;

--
-- Name: tbl_check_in; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_check_in (
    id_ci integer NOT NULL,
    id_cus_ci integer,
    id_room_ci integer,
    numpeople_ci integer,
    datecheckin_ci date,
    status_ci integer,
    id_emp_ci text
);


ALTER TABLE public.tbl_check_in OWNER TO postgres;

--
-- Name: tbl_check_in_ID_ci_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."tbl_check_in_ID_ci_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."tbl_check_in_ID_ci_seq" OWNER TO postgres;

--
-- Name: tbl_check_in_ID_ci_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tbl_check_in_ID_ci_seq" OWNED BY public.tbl_check_in.id_ci;


--
-- Name: tbl_check_out; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_check_out (
    id_co integer NOT NULL,
    id_ci_co integer,
    price_co integer,
    datecreate_co date,
    status_co integer,
    id_emp_co text
);


ALTER TABLE public.tbl_check_out OWNER TO postgres;

--
-- Name: tbl_check_out_ID_co_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."tbl_check_out_ID_co_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."tbl_check_out_ID_co_seq" OWNER TO postgres;

--
-- Name: tbl_check_out_ID_co_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tbl_check_out_ID_co_seq" OWNED BY public.tbl_check_out.id_co;


--
-- Name: tbl_employee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_employee (
    id_emp integer NOT NULL,
    name_emp text,
    cardid_emp text,
    phonenumber_emp text,
    mail_emp text,
    address_emp text,
    birth_emp date,
    datecreate_emp date,
    dateupdate_emp date,
    status_emp integer
);


ALTER TABLE public.tbl_employee OWNER TO postgres;

--
-- Name: tbl_employee_permission_ID_emp_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."tbl_employee_permission_ID_emp_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."tbl_employee_permission_ID_emp_seq" OWNER TO postgres;

--
-- Name: tbl_employee_permission_ID_emp_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tbl_employee_permission_ID_emp_seq" OWNED BY public.tbl_employee.id_emp;


--
-- Name: tbl_food; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_food (
    id_fo integer NOT NULL,
    name_fo text,
    price_fo integer,
    quantity_fo integer,
    status_fo integer
);


ALTER TABLE public.tbl_food OWNER TO postgres;

--
-- Name: tbl_food_ID_fo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."tbl_food_ID_fo_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."tbl_food_ID_fo_seq" OWNER TO postgres;

--
-- Name: tbl_food_ID_fo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tbl_food_ID_fo_seq" OWNED BY public.tbl_food.id_fo;


--
-- Name: tbl_rank_room; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_rank_room (
    id_rr integer NOT NULL,
    rank_rr text,
    numpeople_room integer,
    price_room integer,
    status_room integer
);


ALTER TABLE public.tbl_rank_room OWNER TO postgres;

--
-- Name: tbl_rank_room_ID_rr_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."tbl_rank_room_ID_rr_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."tbl_rank_room_ID_rr_seq" OWNER TO postgres;

--
-- Name: tbl_rank_room_ID_rr_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tbl_rank_room_ID_rr_seq" OWNED BY public.tbl_rank_room.id_rr;


--
-- Name: tbl_room; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_room (
    id_room integer NOT NULL,
    id_rr_room integer,
    name_room text,
    status_room integer
);


ALTER TABLE public.tbl_room OWNER TO postgres;

--
-- Name: tbl_room_ID_room_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."tbl_room_ID_room_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."tbl_room_ID_room_seq" OWNER TO postgres;

--
-- Name: tbl_room_ID_room_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tbl_room_ID_room_seq" OWNED BY public.tbl_room.id_room;


--
-- Name: tbl_use_food; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_use_food (
    id_uf integer NOT NULL,
    id_fo_uf integer,
    numuse_uf integer,
    id_cus_uf integer,
    dateuse_uf date,
    status_uf integer
);


ALTER TABLE public.tbl_use_food OWNER TO postgres;

--
-- Name: tbl_use_food_ID_uf_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."tbl_use_food_ID_uf_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."tbl_use_food_ID_uf_seq" OWNER TO postgres;

--
-- Name: tbl_use_food_ID_uf_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."tbl_use_food_ID_uf_seq" OWNED BY public.tbl_use_food.id_uf;


--
-- Name: tbl_check_in id_ci; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_check_in ALTER COLUMN id_ci SET DEFAULT nextval('public."tbl_check_in_ID_ci_seq"'::regclass);


--
-- Name: tbl_check_out id_co; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_check_out ALTER COLUMN id_co SET DEFAULT nextval('public."tbl_check_out_ID_co_seq"'::regclass);


--
-- Name: tbl_customer id_cus; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_customer ALTER COLUMN id_cus SET DEFAULT nextval('public."tbl_Customer_ID_cus_seq"'::regclass);


--
-- Name: tbl_employee id_emp; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_employee ALTER COLUMN id_emp SET DEFAULT nextval('public."tbl_employee_permission_ID_emp_seq"'::regclass);


--
-- Name: tbl_food id_fo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_food ALTER COLUMN id_fo SET DEFAULT nextval('public."tbl_food_ID_fo_seq"'::regclass);


--
-- Name: tbl_permission id_per; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_permission ALTER COLUMN id_per SET DEFAULT nextval('public."tbl_Permission_ID_per_seq"'::regclass);


--
-- Name: tbl_rank_room id_rr; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_rank_room ALTER COLUMN id_rr SET DEFAULT nextval('public."tbl_rank_room_ID_rr_seq"'::regclass);


--
-- Name: tbl_room id_room; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_room ALTER COLUMN id_room SET DEFAULT nextval('public."tbl_room_ID_room_seq"'::regclass);


--
-- Name: tbl_use_food id_uf; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_use_food ALTER COLUMN id_uf SET DEFAULT nextval('public."tbl_use_food_ID_uf_seq"'::regclass);


--
-- Data for Name: tbl_account; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_account (id_acc, username_acc, pass_acc, id_per_acc, status_acc, datebegin_acc, dateexpired_acc, id_emp_acc) FROM stdin;
htm0001	admin	123	1	1	2021-01-10	2022-01-15	\N
htm0002	employee_001	1	2	1	2021-01-10	2022-01-15	\N
htm2165	tester	htm2021	2	0	2021-01-18	2022-01-18	\N
\.


--
-- Data for Name: tbl_check_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_check_in (id_ci, id_cus_ci, id_room_ci, numpeople_ci, datecheckin_ci, status_ci, id_emp_ci) FROM stdin;
2	1	1	5	\N	0	htm0001
1	1	1	4	\N	0	htm0001
\.


--
-- Data for Name: tbl_check_out; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_check_out (id_co, id_ci_co, price_co, datecreate_co, status_co, id_emp_co) FROM stdin;
1	1	100000	\N	\N	htm0001
\.


--
-- Data for Name: tbl_customer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_customer (id_cus, name_cus, cardid_cus, birth_cus, phonenumber_cus, status_cus, isforeigner_cus) FROM stdin;
1	test	123456789	2021-01-19	2021/01/19	0	0
\.


--
-- Data for Name: tbl_employee; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_employee (id_emp, name_emp, cardid_emp, phonenumber_emp, mail_emp, address_emp, birth_emp, datecreate_emp, dateupdate_emp, status_emp) FROM stdin;
1	admin	123456789	0289999333	admin@gmail.com	\N	\N	2021-01-08	2021-01-08	1
2	Lê Kiên	999999999	0981112222	licthsento.379@gmail.com	Hồ Chí Minh	1999-07-03	2021-01-08	2021-01-08	1
\.


--
-- Data for Name: tbl_food; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_food (id_fo, name_fo, price_fo, quantity_fo, status_fo) FROM stdin;
2	Tiger	30000	200	1
3	Snack bắp	10000	200	1
4	coca	10000	5	1
1	\N	1000	5	1
\.


--
-- Data for Name: tbl_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_permission (id_per, name_per, status_per) FROM stdin;
1	admin	1
2	employee	1
\.


--
-- Data for Name: tbl_rank_room; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_rank_room (id_rr, rank_rr, numpeople_room, price_room, status_room) FROM stdin;
1	A	2	300000	1
2	A	4	600000	1
3	B	2	200000	1
4	B	4	400000	1
5	C	2	100000	1
6	C	4	200000	1
\.


--
-- Data for Name: tbl_room; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_room (id_room, id_rr_room, name_room, status_room) FROM stdin;
3	1	601	1
4	2	602	1
5	1	501	1
6	2	502	1
7	3	401	1
8	4	402	1
9	3	301	1
10	4	302	1
12	6	202	1
11	5	201	1
13	5	101	1
14	6	102	1
\.


--
-- Data for Name: tbl_use_food; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_use_food (id_uf, id_fo_uf, numuse_uf, id_cus_uf, dateuse_uf, status_uf) FROM stdin;
1	1	1	5	2021-01-22	\N
\.


--
-- Name: tbl_Customer_ID_cus_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tbl_Customer_ID_cus_seq"', 1, true);


--
-- Name: tbl_Permission_ID_per_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tbl_Permission_ID_per_seq"', 2, true);


--
-- Name: tbl_check_in_ID_ci_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tbl_check_in_ID_ci_seq"', 2, true);


--
-- Name: tbl_check_out_ID_co_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tbl_check_out_ID_co_seq"', 1, true);


--
-- Name: tbl_employee_permission_ID_emp_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tbl_employee_permission_ID_emp_seq"', 2, true);


--
-- Name: tbl_food_ID_fo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tbl_food_ID_fo_seq"', 4, true);


--
-- Name: tbl_rank_room_ID_rr_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tbl_rank_room_ID_rr_seq"', 6, true);


--
-- Name: tbl_room_ID_room_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tbl_room_ID_room_seq"', 14, true);


--
-- Name: tbl_use_food_ID_uf_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."tbl_use_food_ID_uf_seq"', 1, true);


--
-- Name: tbl_customer tbl_Customer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_customer
    ADD CONSTRAINT "tbl_Customer_pkey" PRIMARY KEY (id_cus);


--
-- Name: tbl_permission tbl_Permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_permission
    ADD CONSTRAINT "tbl_Permission_pkey" PRIMARY KEY (id_per);


--
-- Name: tbl_account tbl_account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_account
    ADD CONSTRAINT tbl_account_pkey PRIMARY KEY (id_acc);


--
-- Name: tbl_check_in tbl_check_in_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_check_in
    ADD CONSTRAINT tbl_check_in_pkey PRIMARY KEY (id_ci);


--
-- Name: tbl_check_out tbl_check_out_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_check_out
    ADD CONSTRAINT tbl_check_out_pkey PRIMARY KEY (id_co);


--
-- Name: tbl_employee tbl_employee_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_employee
    ADD CONSTRAINT tbl_employee_permission_pkey PRIMARY KEY (id_emp);


--
-- Name: tbl_food tbl_food_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_food
    ADD CONSTRAINT tbl_food_pkey PRIMARY KEY (id_fo);


--
-- Name: tbl_rank_room tbl_rank_room_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_rank_room
    ADD CONSTRAINT tbl_rank_room_pkey PRIMARY KEY (id_rr);


--
-- Name: tbl_room tbl_room_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_room
    ADD CONSTRAINT tbl_room_pkey PRIMARY KEY (id_room);


--
-- Name: tbl_use_food tbl_use_food_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_use_food
    ADD CONSTRAINT tbl_use_food_pkey PRIMARY KEY (id_uf);


--
-- PostgreSQL database dump complete
--

