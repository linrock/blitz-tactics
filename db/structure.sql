SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
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


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: completed_rounds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.completed_rounds (
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

CREATE SEQUENCE public.completed_rounds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: completed_rounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.completed_rounds_id_seq OWNED BY public.completed_rounds.id;


--
-- Name: infinity_levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.infinity_levels (
    id bigint NOT NULL,
    difficulty character varying NOT NULL,
    puzzle_id_array jsonb DEFAULT '[]'::jsonb NOT NULL,
    puzzle_id_map jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: infinity_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.infinity_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: infinity_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.infinity_levels_id_seq OWNED BY public.infinity_levels.id;


--
-- Name: level_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.level_attempts (
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

CREATE SEQUENCE public.level_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: level_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.level_attempts_id_seq OWNED BY public.level_attempts.id;


--
-- Name: levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.levels (
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

CREATE SEQUENCE public.levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.levels_id_seq OWNED BY public.levels.id;


--
-- Name: lichess_puzzles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lichess_puzzles (
    id integer NOT NULL,
    puzzle_id integer NOT NULL,
    data jsonb NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: lichess_puzzles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lichess_puzzles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lichess_puzzles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lichess_puzzles_id_seq OWNED BY public.lichess_puzzles.id;


--
-- Name: new_lichess_puzzles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.new_lichess_puzzles (
    id bigint NOT NULL,
    puzzle_id integer NOT NULL,
    data jsonb NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: new_lichess_puzzles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.new_lichess_puzzles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: new_lichess_puzzles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.new_lichess_puzzles_id_seq OWNED BY public.new_lichess_puzzles.id;


--
-- Name: positions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.positions (
    id integer NOT NULL,
    user_id integer,
    fen character varying NOT NULL,
    goal character varying,
    name character varying,
    description text,
    configuration jsonb DEFAULT '"{}"'::jsonb NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: positions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.positions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: positions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.positions_id_seq OWNED BY public.positions.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
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
    username character varying,
    profile jsonb
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: completed_rounds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.completed_rounds ALTER COLUMN id SET DEFAULT nextval('public.completed_rounds_id_seq'::regclass);


--
-- Name: infinity_levels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.infinity_levels ALTER COLUMN id SET DEFAULT nextval('public.infinity_levels_id_seq'::regclass);


--
-- Name: level_attempts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.level_attempts ALTER COLUMN id SET DEFAULT nextval('public.level_attempts_id_seq'::regclass);


--
-- Name: levels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.levels ALTER COLUMN id SET DEFAULT nextval('public.levels_id_seq'::regclass);


--
-- Name: lichess_puzzles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lichess_puzzles ALTER COLUMN id SET DEFAULT nextval('public.lichess_puzzles_id_seq'::regclass);


--
-- Name: new_lichess_puzzles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.new_lichess_puzzles ALTER COLUMN id SET DEFAULT nextval('public.new_lichess_puzzles_id_seq'::regclass);


--
-- Name: positions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.positions ALTER COLUMN id SET DEFAULT nextval('public.positions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: completed_rounds completed_rounds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.completed_rounds
    ADD CONSTRAINT completed_rounds_pkey PRIMARY KEY (id);


--
-- Name: infinity_levels infinity_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.infinity_levels
    ADD CONSTRAINT infinity_levels_pkey PRIMARY KEY (id);


--
-- Name: level_attempts level_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.level_attempts
    ADD CONSTRAINT level_attempts_pkey PRIMARY KEY (id);


--
-- Name: levels levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.levels
    ADD CONSTRAINT levels_pkey PRIMARY KEY (id);


--
-- Name: lichess_puzzles lichess_puzzles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lichess_puzzles
    ADD CONSTRAINT lichess_puzzles_pkey PRIMARY KEY (id);


--
-- Name: new_lichess_puzzles new_lichess_puzzles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.new_lichess_puzzles
    ADD CONSTRAINT new_lichess_puzzles_pkey PRIMARY KEY (id);


--
-- Name: positions positions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT positions_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_infinity_levels_on_difficulty; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_infinity_levels_on_difficulty ON public.infinity_levels USING btree (difficulty);


--
-- Name: index_level_attempts_on_level_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_level_attempts_on_level_id ON public.level_attempts USING btree (level_id);


--
-- Name: index_level_attempts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_level_attempts_on_user_id ON public.level_attempts USING btree (user_id);


--
-- Name: index_levels_on_secret_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_levels_on_secret_key ON public.levels USING btree (secret_key);


--
-- Name: index_levels_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_levels_on_slug ON public.levels USING btree (slug);


--
-- Name: index_lichess_puzzles_on_puzzle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_lichess_puzzles_on_puzzle_id ON public.lichess_puzzles USING btree (puzzle_id);


--
-- Name: index_new_lichess_puzzles_on_puzzle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_new_lichess_puzzles_on_puzzle_id ON public.new_lichess_puzzles USING btree (puzzle_id);


--
-- Name: index_positions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_positions_on_user_id ON public.positions USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_lowercase_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_lowercase_username ON public.users USING btree (lower((username)::text));


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20160223082005'),
('20160313063315'),
('20160313063553'),
('20160313074604'),
('20160313074949'),
('20160313200604'),
('20160313213221'),
('20160411003705'),
('20160417190025'),
('20161125221817'),
('20180619172700'),
('20180620032206');


