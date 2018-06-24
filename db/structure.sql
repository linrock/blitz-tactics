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
-- Name: completed_speedruns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.completed_speedruns (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    speedrun_level_id integer NOT NULL,
    elapsed_time_ms integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: completed_speedruns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.completed_speedruns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: completed_speedruns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.completed_speedruns_id_seq OWNED BY public.completed_speedruns.id;


--
-- Name: infinity_levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.infinity_levels (
    id bigint NOT NULL,
    difficulty character varying NOT NULL,
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
-- Name: infinity_puzzles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.infinity_puzzles (
    id bigint NOT NULL,
    infinity_level_id integer NOT NULL,
    new_lichess_puzzle_id integer NOT NULL,
    index integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: infinity_puzzles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.infinity_puzzles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: infinity_puzzles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.infinity_puzzles_id_seq OWNED BY public.infinity_puzzles.id;


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
-- Name: solved_infinity_puzzles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.solved_infinity_puzzles (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    new_lichess_puzzle_id integer NOT NULL,
    difficulty character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: solved_infinity_puzzles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.solved_infinity_puzzles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: solved_infinity_puzzles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.solved_infinity_puzzles_id_seq OWNED BY public.solved_infinity_puzzles.id;


--
-- Name: speedrun_levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.speedrun_levels (
    id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: speedrun_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.speedrun_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: speedrun_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.speedrun_levels_id_seq OWNED BY public.speedrun_levels.id;


--
-- Name: speedrun_puzzles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.speedrun_puzzles (
    id bigint NOT NULL,
    speedrun_level_id integer NOT NULL,
    new_lichess_puzzle_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: speedrun_puzzles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.speedrun_puzzles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: speedrun_puzzles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.speedrun_puzzles_id_seq OWNED BY public.speedrun_puzzles.id;


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
    profile jsonb,
    tagline character varying
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
-- Name: completed_speedruns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.completed_speedruns ALTER COLUMN id SET DEFAULT nextval('public.completed_speedruns_id_seq'::regclass);


--
-- Name: infinity_levels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.infinity_levels ALTER COLUMN id SET DEFAULT nextval('public.infinity_levels_id_seq'::regclass);


--
-- Name: infinity_puzzles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.infinity_puzzles ALTER COLUMN id SET DEFAULT nextval('public.infinity_puzzles_id_seq'::regclass);


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
-- Name: solved_infinity_puzzles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solved_infinity_puzzles ALTER COLUMN id SET DEFAULT nextval('public.solved_infinity_puzzles_id_seq'::regclass);


--
-- Name: speedrun_levels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.speedrun_levels ALTER COLUMN id SET DEFAULT nextval('public.speedrun_levels_id_seq'::regclass);


--
-- Name: speedrun_puzzles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.speedrun_puzzles ALTER COLUMN id SET DEFAULT nextval('public.speedrun_puzzles_id_seq'::regclass);


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
-- Name: completed_speedruns completed_speedruns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.completed_speedruns
    ADD CONSTRAINT completed_speedruns_pkey PRIMARY KEY (id);


--
-- Name: infinity_levels infinity_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.infinity_levels
    ADD CONSTRAINT infinity_levels_pkey PRIMARY KEY (id);


--
-- Name: infinity_puzzles infinity_puzzles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.infinity_puzzles
    ADD CONSTRAINT infinity_puzzles_pkey PRIMARY KEY (id);


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
-- Name: solved_infinity_puzzles solved_infinity_puzzles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.solved_infinity_puzzles
    ADD CONSTRAINT solved_infinity_puzzles_pkey PRIMARY KEY (id);


--
-- Name: speedrun_levels speedrun_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.speedrun_levels
    ADD CONSTRAINT speedrun_levels_pkey PRIMARY KEY (id);


--
-- Name: speedrun_puzzles speedrun_puzzles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.speedrun_puzzles
    ADD CONSTRAINT speedrun_puzzles_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_completed_speedruns_on_user_id_and_speedrun_level_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_completed_speedruns_on_user_id_and_speedrun_level_id ON public.completed_speedruns USING btree (user_id, speedrun_level_id);


--
-- Name: index_infinity_levels_on_difficulty; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_infinity_levels_on_difficulty ON public.infinity_levels USING btree (difficulty);


--
-- Name: index_infinity_puzzles_on_infinity_level_id_and_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_infinity_puzzles_on_infinity_level_id_and_index ON public.infinity_puzzles USING btree (infinity_level_id, index);


--
-- Name: index_infinity_puzzles_on_level_and_puzzle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_infinity_puzzles_on_level_and_puzzle_id ON public.infinity_puzzles USING btree (infinity_level_id, new_lichess_puzzle_id);


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
-- Name: index_solved_infinity_puzzles_on_user_and_puzzle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solved_infinity_puzzles_on_user_and_puzzle_id ON public.solved_infinity_puzzles USING btree (user_id, new_lichess_puzzle_id);


--
-- Name: index_solved_infinity_puzzles_on_user_id_and_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solved_infinity_puzzles_on_user_id_and_updated_at ON public.solved_infinity_puzzles USING btree (user_id, updated_at);


--
-- Name: index_speedrun_puzzles_on_speedrun_level_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_speedrun_puzzles_on_speedrun_level_id ON public.speedrun_puzzles USING btree (speedrun_level_id);


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
('20180620032206'),
('20180620084825'),
('20180621081826'),
('20180623113358'),
('20180623114045'),
('20180623125613'),
('20180624063512');


