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
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: completed_countdown_levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.completed_countdown_levels (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    countdown_level_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: completed_countdown_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.completed_countdown_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: completed_countdown_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.completed_countdown_levels_id_seq OWNED BY public.completed_countdown_levels.id;


--
-- Name: completed_haste_rounds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.completed_haste_rounds (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: completed_haste_rounds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.completed_haste_rounds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: completed_haste_rounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.completed_haste_rounds_id_seq OWNED BY public.completed_haste_rounds.id;


--
-- Name: completed_repetition_levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.completed_repetition_levels (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    repetition_level_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: completed_repetition_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.completed_repetition_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: completed_repetition_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.completed_repetition_levels_id_seq OWNED BY public.completed_repetition_levels.id;


--
-- Name: completed_repetition_rounds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.completed_repetition_rounds (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    repetition_level_id integer NOT NULL,
    elapsed_time_ms integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: completed_repetition_rounds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.completed_repetition_rounds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: completed_repetition_rounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.completed_repetition_rounds_id_seq OWNED BY public.completed_repetition_rounds.id;


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
    AS integer
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
-- Name: completed_three_rounds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.completed_three_rounds (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: completed_three_rounds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.completed_three_rounds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: completed_three_rounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.completed_three_rounds_id_seq OWNED BY public.completed_three_rounds.id;


--
-- Name: countdown_levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.countdown_levels (
    id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: countdown_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.countdown_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countdown_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.countdown_levels_id_seq OWNED BY public.countdown_levels.id;


--
-- Name: countdown_puzzles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.countdown_puzzles (
    id bigint NOT NULL,
    countdown_level_id integer NOT NULL,
    data jsonb NOT NULL,
    puzzle_hash character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: countdown_puzzles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.countdown_puzzles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countdown_puzzles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.countdown_puzzles_id_seq OWNED BY public.countdown_puzzles.id;


--
-- Name: haste_puzzles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.haste_puzzles (
    id bigint NOT NULL,
    data jsonb NOT NULL,
    difficulty integer NOT NULL,
    color character varying NOT NULL,
    puzzle_hash character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: haste_puzzles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.haste_puzzles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: haste_puzzles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.haste_puzzles_id_seq OWNED BY public.haste_puzzles.id;


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
    data jsonb NOT NULL,
    puzzle_hash character varying NOT NULL,
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
    AS integer
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
    AS integer
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
-- Name: positions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.positions (
    id integer NOT NULL,
    user_id integer,
    fen character varying NOT NULL,
    goal character varying,
    name character varying,
    description text,
    configuration jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: positions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.positions_id_seq
    AS integer
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
-- Name: puzzle_reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.puzzle_reports (
    id bigint NOT NULL,
    puzzle_id integer NOT NULL,
    user_id integer NOT NULL,
    message character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: puzzle_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.puzzle_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: puzzle_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.puzzle_reports_id_seq OWNED BY public.puzzle_reports.id;


--
-- Name: puzzles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.puzzles (
    id bigint NOT NULL,
    puzzle_id character varying NOT NULL,
    puzzle_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    notes text,
    puzzle_data_hash character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: puzzles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.puzzles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: puzzles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.puzzles_id_seq OWNED BY public.puzzles.id;


--
-- Name: rated_puzzle_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rated_puzzle_attempts (
    id bigint NOT NULL,
    user_rating_id integer NOT NULL,
    rated_puzzle_id integer NOT NULL,
    uci_moves jsonb NOT NULL,
    outcome character varying NOT NULL,
    pre_user_rating double precision NOT NULL,
    pre_user_rating_deviation double precision NOT NULL,
    pre_user_rating_volatility double precision NOT NULL,
    pre_puzzle_rating double precision NOT NULL,
    pre_puzzle_rating_deviation double precision NOT NULL,
    pre_puzzle_rating_volatility double precision NOT NULL,
    post_user_rating double precision NOT NULL,
    post_user_rating_deviation double precision NOT NULL,
    post_user_rating_volatility double precision NOT NULL,
    post_puzzle_rating double precision NOT NULL,
    post_puzzle_rating_deviation double precision NOT NULL,
    post_puzzle_rating_volatility double precision NOT NULL,
    elapsed_time_ms integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: rated_puzzle_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rated_puzzle_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rated_puzzle_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rated_puzzle_attempts_id_seq OWNED BY public.rated_puzzle_attempts.id;


--
-- Name: rated_puzzles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rated_puzzles (
    id bigint NOT NULL,
    data jsonb NOT NULL,
    color character varying NOT NULL,
    puzzle_hash character varying NOT NULL,
    initial_rating double precision NOT NULL,
    initial_rating_deviation double precision NOT NULL,
    initial_rating_volatility double precision NOT NULL,
    rating double precision NOT NULL,
    rating_deviation double precision NOT NULL,
    rating_volatility double precision NOT NULL,
    rated_puzzle_attempts_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: rated_puzzles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rated_puzzles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rated_puzzles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rated_puzzles_id_seq OWNED BY public.rated_puzzles.id;


--
-- Name: repetition_levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repetition_levels (
    id bigint NOT NULL,
    number integer NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: repetition_levels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repetition_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repetition_levels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repetition_levels_id_seq OWNED BY public.repetition_levels.id;


--
-- Name: repetition_puzzles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repetition_puzzles (
    id bigint NOT NULL,
    repetition_level_id integer NOT NULL,
    data jsonb NOT NULL,
    puzzle_hash character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: repetition_puzzles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repetition_puzzles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repetition_puzzles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repetition_puzzles_id_seq OWNED BY public.repetition_puzzles.id;


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
    infinity_puzzle_id integer NOT NULL,
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
    data jsonb NOT NULL,
    puzzle_hash character varying NOT NULL,
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
-- Name: user_chessboards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_chessboards (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    light_square_color character varying,
    dark_square_color character varying,
    selected_square_color character varying,
    opponent_from_square_color character varying,
    opponent_to_square_color character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_chessboards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_chessboards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_chessboards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_chessboards_id_seq OWNED BY public.user_chessboards.id;


--
-- Name: user_ratings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_ratings (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    initial_rating double precision NOT NULL,
    initial_rating_deviation double precision NOT NULL,
    initial_rating_volatility double precision NOT NULL,
    rating double precision NOT NULL,
    rating_deviation double precision NOT NULL,
    rating_volatility double precision NOT NULL,
    rated_puzzle_attempts_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_ratings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_ratings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_ratings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_ratings_id_seq OWNED BY public.user_ratings.id;


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
    AS integer
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
-- Name: completed_countdown_levels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.completed_countdown_levels ALTER COLUMN id SET DEFAULT nextval('public.completed_countdown_levels_id_seq'::regclass);


--
-- Name: completed_haste_rounds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.completed_haste_rounds ALTER COLUMN id SET DEFAULT nextval('public.completed_haste_rounds_id_seq'::regclass);


--
-- Name: completed_repetition_levels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.completed_repetition_levels ALTER COLUMN id SET DEFAULT nextval('public.completed_repetition_levels_id_seq'::regclass);


--
-- Name: completed_repetition_rounds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.completed_repetition_rounds ALTER COLUMN id SET DEFAULT nextval('public.completed_repetition_rounds_id_seq'::regclass);


--
-- Name: completed_rounds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.completed_rounds ALTER COLUMN id SET DEFAULT nextval('public.completed_rounds_id_seq'::regclass);


--
-- Name: completed_speedruns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.completed_speedruns ALTER COLUMN id SET DEFAULT nextval('public.completed_speedruns_id_seq'::regclass);


--
-- Name: completed_three_rounds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.completed_three_rounds ALTER COLUMN id SET DEFAULT nextval('public.completed_three_rounds_id_seq'::regclass);


--
-- Name: countdown_levels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countdown_levels ALTER COLUMN id SET DEFAULT nextval('public.countdown_levels_id_seq'::regclass);


--
-- Name: countdown_puzzles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countdown_puzzles ALTER COLUMN id SET DEFAULT nextval('public.countdown_puzzles_id_seq'::regclass);


--
-- Name: haste_puzzles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.haste_puzzles ALTER COLUMN id SET DEFAULT nextval('public.haste_puzzles_id_seq'::regclass);


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
-- Name: positions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.positions ALTER COLUMN id SET DEFAULT nextval('public.positions_id_seq'::regclass);


--
-- Name: puzzle_reports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.puzzle_reports ALTER COLUMN id SET DEFAULT nextval('public.puzzle_reports_id_seq'::regclass);


--
-- Name: puzzles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.puzzles ALTER COLUMN id SET DEFAULT nextval('public.puzzles_id_seq'::regclass);


--
-- Name: rated_puzzle_attempts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rated_puzzle_attempts ALTER COLUMN id SET DEFAULT nextval('public.rated_puzzle_attempts_id_seq'::regclass);


--
-- Name: rated_puzzles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rated_puzzles ALTER COLUMN id SET DEFAULT nextval('public.rated_puzzles_id_seq'::regclass);


--
-- Name: repetition_levels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repetition_levels ALTER COLUMN id SET DEFAULT nextval('public.repetition_levels_id_seq'::regclass);


--
-- Name: repetition_puzzles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repetition_puzzles ALTER COLUMN id SET DEFAULT nextval('public.repetition_puzzles_id_seq'::regclass);


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
-- Name: user_chessboards id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_chessboards ALTER COLUMN id SET DEFAULT nextval('public.user_chessboards_id_seq'::regclass);


--
-- Name: user_ratings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_ratings ALTER COLUMN id SET DEFAULT nextval('public.user_ratings_id_seq'::regclass);


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
-- Name: completed_countdown_levels completed_countdown_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.completed_countdown_levels
    ADD CONSTRAINT completed_countdown_levels_pkey PRIMARY KEY (id);


--
-- Name: completed_haste_rounds completed_haste_rounds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.completed_haste_rounds
    ADD CONSTRAINT completed_haste_rounds_pkey PRIMARY KEY (id);


--
-- Name: completed_repetition_levels completed_repetition_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.completed_repetition_levels
    ADD CONSTRAINT completed_repetition_levels_pkey PRIMARY KEY (id);


--
-- Name: completed_repetition_rounds completed_repetition_rounds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.completed_repetition_rounds
    ADD CONSTRAINT completed_repetition_rounds_pkey PRIMARY KEY (id);


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
-- Name: completed_three_rounds completed_three_rounds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.completed_three_rounds
    ADD CONSTRAINT completed_three_rounds_pkey PRIMARY KEY (id);


--
-- Name: countdown_levels countdown_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countdown_levels
    ADD CONSTRAINT countdown_levels_pkey PRIMARY KEY (id);


--
-- Name: countdown_puzzles countdown_puzzles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countdown_puzzles
    ADD CONSTRAINT countdown_puzzles_pkey PRIMARY KEY (id);


--
-- Name: haste_puzzles haste_puzzles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.haste_puzzles
    ADD CONSTRAINT haste_puzzles_pkey PRIMARY KEY (id);


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
-- Name: positions positions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT positions_pkey PRIMARY KEY (id);


--
-- Name: puzzle_reports puzzle_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.puzzle_reports
    ADD CONSTRAINT puzzle_reports_pkey PRIMARY KEY (id);


--
-- Name: puzzles puzzles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.puzzles
    ADD CONSTRAINT puzzles_pkey PRIMARY KEY (id);


--
-- Name: rated_puzzle_attempts rated_puzzle_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rated_puzzle_attempts
    ADD CONSTRAINT rated_puzzle_attempts_pkey PRIMARY KEY (id);


--
-- Name: rated_puzzles rated_puzzles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rated_puzzles
    ADD CONSTRAINT rated_puzzles_pkey PRIMARY KEY (id);


--
-- Name: repetition_levels repetition_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repetition_levels
    ADD CONSTRAINT repetition_levels_pkey PRIMARY KEY (id);


--
-- Name: repetition_puzzles repetition_puzzles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repetition_puzzles
    ADD CONSTRAINT repetition_puzzles_pkey PRIMARY KEY (id);


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
-- Name: user_chessboards user_chessboards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_chessboards
    ADD CONSTRAINT user_chessboards_pkey PRIMARY KEY (id);


--
-- Name: user_ratings user_ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_ratings
    ADD CONSTRAINT user_ratings_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_completed_countdown_levels_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_completed_countdown_levels_on_user_id ON public.completed_countdown_levels USING btree (user_id);


--
-- Name: index_completed_haste_rounds_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_completed_haste_rounds_on_created_at ON public.completed_haste_rounds USING btree (created_at);


--
-- Name: index_completed_haste_rounds_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_completed_haste_rounds_on_user_id ON public.completed_haste_rounds USING btree (user_id);


--
-- Name: index_completed_speedruns_on_user_id_and_speedrun_level_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_completed_speedruns_on_user_id_and_speedrun_level_id ON public.completed_speedruns USING btree (user_id, speedrun_level_id);


--
-- Name: index_completed_three_rounds_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_completed_three_rounds_on_created_at ON public.completed_three_rounds USING btree (created_at);


--
-- Name: index_completed_three_rounds_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_completed_three_rounds_on_user_id ON public.completed_three_rounds USING btree (user_id);


--
-- Name: index_countdown_puzzles_on_countdown_level_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_countdown_puzzles_on_countdown_level_id ON public.countdown_puzzles USING btree (countdown_level_id);


--
-- Name: index_countdown_puzzles_on_countdown_level_id_and_puzzle_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_countdown_puzzles_on_countdown_level_id_and_puzzle_hash ON public.countdown_puzzles USING btree (countdown_level_id, puzzle_hash);


--
-- Name: index_haste_puzzles_on_difficulty_and_color; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_haste_puzzles_on_difficulty_and_color ON public.haste_puzzles USING btree (difficulty, color);


--
-- Name: index_haste_puzzles_on_puzzle_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_haste_puzzles_on_puzzle_hash ON public.haste_puzzles USING btree (puzzle_hash);


--
-- Name: index_infinity_levels_on_difficulty; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_infinity_levels_on_difficulty ON public.infinity_levels USING btree (difficulty);


--
-- Name: index_infinity_puzzles_on_infinity_level_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_infinity_puzzles_on_infinity_level_id ON public.infinity_puzzles USING btree (infinity_level_id);


--
-- Name: index_infinity_puzzles_on_puzzle_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_infinity_puzzles_on_puzzle_hash ON public.infinity_puzzles USING btree (puzzle_hash);


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
-- Name: index_positions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_positions_on_user_id ON public.positions USING btree (user_id);


--
-- Name: index_puzzle_reports_on_puzzle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_puzzle_reports_on_puzzle_id ON public.puzzle_reports USING btree (puzzle_id);


--
-- Name: index_puzzle_reports_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_puzzle_reports_on_user_id ON public.puzzle_reports USING btree (user_id);


--
-- Name: index_puzzles_on_puzzle_data_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_puzzles_on_puzzle_data_hash ON public.puzzles USING btree (puzzle_data_hash);


--
-- Name: index_puzzles_on_puzzle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_puzzles_on_puzzle_id ON public.puzzles USING btree (puzzle_id);


--
-- Name: index_rated_puzzle_attempts_on_rated_puzzle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rated_puzzle_attempts_on_rated_puzzle_id ON public.rated_puzzle_attempts USING btree (rated_puzzle_id);


--
-- Name: index_rated_puzzle_attempts_on_user_rating_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rated_puzzle_attempts_on_user_rating_id ON public.rated_puzzle_attempts USING btree (user_rating_id);


--
-- Name: index_rated_puzzles_on_puzzle_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_rated_puzzles_on_puzzle_hash ON public.rated_puzzles USING btree (puzzle_hash);


--
-- Name: index_rated_puzzles_on_rating; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rated_puzzles_on_rating ON public.rated_puzzles USING btree (rating);


--
-- Name: index_repetition_levels_on_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_repetition_levels_on_number ON public.repetition_levels USING btree (number);


--
-- Name: index_repetition_puzzles_on_puzzle_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_repetition_puzzles_on_puzzle_hash ON public.repetition_puzzles USING btree (puzzle_hash);


--
-- Name: index_repetition_puzzles_on_repetition_level_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_repetition_puzzles_on_repetition_level_id ON public.repetition_puzzles USING btree (repetition_level_id);


--
-- Name: index_solved_infinity_puzzles_on_user_id_and_infinity_puzzle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_solved_infinity_puzzles_on_user_id_and_infinity_puzzle_id ON public.solved_infinity_puzzles USING btree (user_id, infinity_puzzle_id);


--
-- Name: index_solved_infinity_puzzles_on_user_id_and_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_solved_infinity_puzzles_on_user_id_and_updated_at ON public.solved_infinity_puzzles USING btree (user_id, updated_at);


--
-- Name: index_speedrun_puzzles_on_speedrun_level_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_speedrun_puzzles_on_speedrun_level_id ON public.speedrun_puzzles USING btree (speedrun_level_id);


--
-- Name: index_speedrun_puzzles_on_speedrun_level_id_and_puzzle_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_speedrun_puzzles_on_speedrun_level_id_and_puzzle_hash ON public.speedrun_puzzles USING btree (speedrun_level_id, puzzle_hash);


--
-- Name: index_user_chessboards_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_chessboards_on_user_id ON public.user_chessboards USING btree (user_id);


--
-- Name: index_user_ratings_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_ratings_on_user_id ON public.user_ratings USING btree (user_id);


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
('20180620032206'),
('20180620084825'),
('20180621081826'),
('20180623113358'),
('20180623114045'),
('20180623125613'),
('20180624063512'),
('20180625160707'),
('20180625160722'),
('20180626024019'),
('20180626024026'),
('20180626052132'),
('20181206064113'),
('20181206064149'),
('20181207065925'),
('20181207070038'),
('20181207070049'),
('20181211070754'),
('20181211073138'),
('20190220052623'),
('20190221152057'),
('20190221152105'),
('20190221152109'),
('20201002022940'),
('20201021035332'),
('20201207014332');


