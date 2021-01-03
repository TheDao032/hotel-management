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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: tbl_employee_permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbl_employee_permission (
    employee_id character varying(10) NOT NULL,
    employee_name text NOT NULL,
    employee_status integer,
    mail_address text NOT NULL,
    permission integer NOT NULL,
    create_date date,
    update_date date,
    password character varying(20),
    begin_date date,
    expired_date date
);


ALTER TABLE public.tbl_employee_permission OWNER TO postgres;

--
-- Data for Name: tbl_employee_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tbl_employee_permission (employee_id, employee_name, employee_status, mail_address, permission, create_date, update_date, password, begin_date, expired_date) FROM stdin;
htm001	thedao	1	thedao@gmail.com	99	2021-01-02	2021-01-02	thedao	2021-01-01	2022-01-01
\.


--
-- Name: tbl_employee_permission tbl_employee_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbl_employee_permission
    ADD CONSTRAINT tbl_employee_permission_pkey PRIMARY KEY (employee_id);


--
-- PostgreSQL database dump complete
--

