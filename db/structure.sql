--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.2
-- Dumped by pg_dump version 9.5.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: completed_rounds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE completed_rounds (
    id integer NOT NULL,
    level_attempt_id integer NOT NULL,
    time_elapsed integer,
    errors_count integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: completed_rounds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE completed_rounds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: completed_rounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE completed_rounds_id_seq OWNED BY completed_rounds.id;


--
-- Name: level_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE level_attempts (
    id integer NOT NULL,
    user_id integer NOT NULL,
    level_id integer NOT NULL,
    last_attempt_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: level_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE level_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: level_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE level_attempts_id_seq OWNED BY level_attempts.id;


--
-- Name: levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE levels (
    id integer NOT NULL,
    slug character varying,
    name character varying,
    next_level_id integer,
    secret_key character varying,
    puzzle_ids integer[],
    options jsonb,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: levels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE levels_id_seq OWNED BY levels.id;


--
-- Name: lichess_puzzles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE lichess_puzzles (
    id integer NOT NULL,
    puzzle_id integer NOT NULL,
    data jsonb NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: lichess_puzzles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lichess_puzzles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lichess_puzzles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lichess_puzzles_id_seq OWNED BY lichess_puzzles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    profile jsonb,
    username character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY completed_rounds ALTER COLUMN id SET DEFAULT nextval('completed_rounds_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY level_attempts ALTER COLUMN id SET DEFAULT nextval('level_attempts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY levels ALTER COLUMN id SET DEFAULT nextval('levels_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY lichess_puzzles ALTER COLUMN id SET DEFAULT nextval('lichess_puzzles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: completed_rounds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY completed_rounds
    ADD CONSTRAINT completed_rounds_pkey PRIMARY KEY (id);


--
-- Name: level_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY level_attempts
    ADD CONSTRAINT level_attempts_pkey PRIMARY KEY (id);


--
-- Name: levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY levels
    ADD CONSTRAINT levels_pkey PRIMARY KEY (id);


--
-- Name: lichess_puzzles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY lichess_puzzles
    ADD CONSTRAINT lichess_puzzles_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_level_attempts_on_level_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_level_attempts_on_level_id ON level_attempts USING btree (level_id);


--
-- Name: index_level_attempts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_level_attempts_on_user_id ON level_attempts USING btree (user_id);


--
-- Name: index_levels_on_secret_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_levels_on_secret_key ON levels USING btree (secret_key);


--
-- Name: index_levels_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_levels_on_slug ON levels USING btree (slug);


--
-- Name: index_lichess_puzzles_on_puzzle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_lichess_puzzles_on_puzzle_id ON lichess_puzzles USING btree (puzzle_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_lowercase_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_lowercase_username ON users USING btree (lower((username)::text));


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20160223082005');

INSERT INTO schema_migrations (version) VALUES ('20160313063315');

INSERT INTO schema_migrations (version) VALUES ('20160313063553');

INSERT INTO schema_migrations (version) VALUES ('20160313074604');

INSERT INTO schema_migrations (version) VALUES ('20160313074949');

INSERT INTO schema_migrations (version) VALUES ('20160313200604');

INSERT INTO schema_migrations (version) VALUES ('20160313213221');

INSERT INTO schema_migrations (version) VALUES ('20160411003705');

INSERT INTO schema_migrations (version) VALUES ('20160417182231');

INSERT INTO schema_migrations (version) VALUES ('20160417190025');

