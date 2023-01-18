echo #! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  WINNER_TEAMS=$($PSQL "SELECT name FROM teams WHERE name=('$WINNER')")
  if [[ $WINNER != 'winner' ]]
   then
   if [[ -z $WINNER_TEAMS ]]
    then
       INSERT_WINNER_TEAMS=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
       if [[ $INSERT_WINNER_TEAMS == "INSERT 0 1" ]]
       then
       Inserted into teams, $WINNER
       fi
    fi
  fi
  OPPONENT_TEAMS=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")
  if [[ $OPPONENT != 'opponent' ]]
  then
  if [[ -z $OPPONENT_TEAMS ]]
  then
  INSERT_OPPONENT_TEAMS=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
  if [[ $INSERT_OPPONENT_TEAMS == 'INSERT 0 1' ]]
  then
  echo Inserted opponent, $OPPONENT
  fi
  fi
  fi
  WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
   if [[ -n $WIN_ID || -n $OPP_ID ]]
   then
    if [[ $YEAR != 'year' ]]
    then
    INSERT_GAMES=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WIN_ID, $OPP_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    fi
   fi
done

#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=worldcup --no-align --tuples-only -c"

# Do not change code above this line. Use the PSQL variable above to query your database.

echo -e "\nTotal number of goals in all games from winning teams:"
echo "$($PSQL "SELECT SUM(winner_goals) FROM games")"

echo -e "\nTotal number of goals in all games from both teams combined:"
echo "$($PSQL "SELECT SUM(winner_goals) + SUM(opponent_goals) FROM games")"

echo -e "\nAverage number of goals in all games from the winning teams:"
echo "$($PSQL "SELECT AVG(winner_goals) FROM games")"

echo -e "\nAverage number of goals in all games from the winning teams rounded to two decimal places:"
echo "$($PSQL "SELECT ROUND(AVG(winner_goals),2) FROM games")"

echo -e "\nAverage number of goals in all games from both teams:"
echo "$($PSQL "SELECT AVG(winner_goals + opponent_goals) FROM games")"

echo -e "\nMost goals scored in a single game by one team:"
echo "$($PSQL "SELECT MAX(winner_goals) FROM games")"

echo -e "\nNumber of games where the winning team scored more than two goals:"
echo "$($PSQL "SELECT COUNT(game_id) FROM games WHERE winner_goals > 2")"

echo -e "\nWinner of the 2018 tournament team name:"
echo "$($PSQL "SELECT name FROM teams INNER JOIN games ON teams.team_id = games.winner_id WHERE round ='Final' AND year= 2018")"

echo -e "\nList of teams who played in the 2014 'Eighth-Final' round:"
echo "$($PSQL "SELECT name FROM games LEFT JOIN teams ON teams.team_id = games.winner_id WHERE round = 'Eighth-Final' AND year = 2014 UNION SELECT name FROM games LEFT JOIN teams ON teams.team_id = games.opponent_id WHERE round='Eighth-Final' AND year = 2014 ORDER BY name ASC")"

echo -e "\nList of unique winning team names in the whole data set:"
echo "$($PSQL "SELECT DISTINCT(name) FROM games LEFT JOIN teams ON teams.team_id = games.winner_id ORDER BY name ASC")"

echo -e "\nYear and team name of all the champions:"
echo "$($PSQL "SELECT year, name FROM games LEFT JOIN teams ON teams.team_id = games.winner_id WHERE round = 'Final' ORDER BY year")"

echo -e "\nList of teams that start with 'Co':"
echo "$($PSQL "SELECT name FROM teams WHERE name LIKE 'Co%'")"



--
-- PostgreSQL database dump
--

-- Dumped from database version 12.9 (Ubuntu 12.9-2.pgdg20.04+1)
-- Dumped by pg_dump version 12.9 (Ubuntu 12.9-2.pgdg20.04+1)

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

DROP DATABASE worldcup;
--
-- Name: worldcup; Type: DATABASE; Schema: -; Owner: freecodecamp
--

CREATE DATABASE worldcup WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C.UTF-8' LC_CTYPE = 'C.UTF-8';


ALTER DATABASE worldcup OWNER TO freecodecamp;

\connect worldcup

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
-- Name: games; Type: TABLE; Schema: public; Owner: freecodecamp
--

CREATE TABLE public.games (
    game_id integer NOT NULL,
    year integer NOT NULL,
    round character varying(40) NOT NULL,
    winner_id integer NOT NULL,
    opponent_id integer NOT NULL,
    winner_goals integer NOT NULL,
    opponent_goals integer NOT NULL
);


ALTER TABLE public.games OWNER TO freecodecamp;

--
-- Name: games_game_id_seq; Type: SEQUENCE; Schema: public; Owner: freecodecamp
--

CREATE SEQUENCE public.games_game_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.games_game_id_seq OWNER TO freecodecamp;

--
-- Name: games_game_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: freecodecamp
--

ALTER SEQUENCE public.games_game_id_seq OWNED BY public.games.game_id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: freecodecamp
--

CREATE TABLE public.teams (
    team_id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.teams OWNER TO freecodecamp;

--
-- Name: teams_team_id_seq; Type: SEQUENCE; Schema: public; Owner: freecodecamp
--

CREATE SEQUENCE public.teams_team_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.teams_team_id_seq OWNER TO freecodecamp;

--
-- Name: teams_team_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: freecodecamp
--

ALTER SEQUENCE public.teams_team_id_seq OWNED BY public.teams.team_id;


--
-- Name: games game_id; Type: DEFAULT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.games ALTER COLUMN game_id SET DEFAULT nextval('public.games_game_id_seq'::regclass);


--
-- Name: teams team_id; Type: DEFAULT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.teams ALTER COLUMN team_id SET DEFAULT nextval('public.teams_team_id_seq'::regclass);


--
-- Data for Name: games; Type: TABLE DATA; Schema: public; Owner: freecodecamp
--

INSERT INTO public.games VALUES (33, 2018, 'Final', 682, 683, 4, 2);
INSERT INTO public.games VALUES (34, 2018, 'Third Place', 684, 685, 2, 0);
INSERT INTO public.games VALUES (35, 2018, 'Semi-Final', 683, 685, 2, 1);
INSERT INTO public.games VALUES (36, 2018, 'Semi-Final', 682, 684, 1, 0);
INSERT INTO public.games VALUES (37, 2018, 'Quarter-Final', 683, 686, 3, 2);
INSERT INTO public.games VALUES (38, 2018, 'Quarter-Final', 685, 687, 2, 0);
INSERT INTO public.games VALUES (39, 2018, 'Quarter-Final', 684, 688, 2, 1);
INSERT INTO public.games VALUES (40, 2018, 'Quarter-Final', 682, 689, 2, 0);
INSERT INTO public.games VALUES (41, 2018, 'Eighth-Final', 685, 690, 2, 1);
INSERT INTO public.games VALUES (42, 2018, 'Eighth-Final', 687, 691, 1, 0);
INSERT INTO public.games VALUES (43, 2018, 'Eighth-Final', 684, 692, 3, 2);
INSERT INTO public.games VALUES (44, 2018, 'Eighth-Final', 688, 693, 2, 0);
INSERT INTO public.games VALUES (45, 2018, 'Eighth-Final', 683, 694, 2, 1);
INSERT INTO public.games VALUES (46, 2018, 'Eighth-Final', 686, 695, 2, 1);
INSERT INTO public.games VALUES (47, 2018, 'Eighth-Final', 689, 696, 2, 1);
INSERT INTO public.games VALUES (48, 2018, 'Eighth-Final', 682, 697, 4, 3);
INSERT INTO public.games VALUES (49, 2014, 'Final', 698, 697, 1, 0);
INSERT INTO public.games VALUES (50, 2014, 'Third Place', 699, 688, 3, 0);
INSERT INTO public.games VALUES (51, 2014, 'Semi-Final', 697, 699, 1, 0);
INSERT INTO public.games VALUES (52, 2014, 'Semi-Final', 698, 688, 7, 1);
INSERT INTO public.games VALUES (53, 2014, 'Quarter-Final', 699, 700, 1, 0);
INSERT INTO public.games VALUES (54, 2014, 'Quarter-Final', 697, 684, 1, 0);
INSERT INTO public.games VALUES (55, 2014, 'Quarter-Final', 688, 690, 2, 1);
INSERT INTO public.games VALUES (56, 2014, 'Quarter-Final', 698, 682, 1, 0);
INSERT INTO public.games VALUES (57, 2014, 'Eighth-Final', 688, 701, 2, 1);
INSERT INTO public.games VALUES (58, 2014, 'Eighth-Final', 690, 689, 2, 0);
INSERT INTO public.games VALUES (59, 2014, 'Eighth-Final', 682, 702, 2, 0);
INSERT INTO public.games VALUES (60, 2014, 'Eighth-Final', 698, 703, 2, 1);
INSERT INTO public.games VALUES (61, 2014, 'Eighth-Final', 699, 693, 2, 1);
INSERT INTO public.games VALUES (62, 2014, 'Eighth-Final', 700, 704, 2, 1);
INSERT INTO public.games VALUES (63, 2014, 'Eighth-Final', 697, 691, 1, 0);
INSERT INTO public.games VALUES (64, 2014, 'Eighth-Final', 684, 705, 2, 1);


--
-- Data for Name: teams; Type: TABLE DATA; Schema: public; Owner: freecodecamp
--

INSERT INTO public.teams VALUES (682, 'France');
INSERT INTO public.teams VALUES (683, 'Croatia');
INSERT INTO public.teams VALUES (684, 'Belgium');
INSERT INTO public.teams VALUES (685, 'England');
INSERT INTO public.teams VALUES (686, 'Russia');
INSERT INTO public.teams VALUES (687, 'Sweden');
INSERT INTO public.teams VALUES (688, 'Brazil');
INSERT INTO public.teams VALUES (689, 'Uruguay');
INSERT INTO public.teams VALUES (690, 'Colombia');
INSERT INTO public.teams VALUES (691, 'Switzerland');
INSERT INTO public.teams VALUES (692, 'Japan');
INSERT INTO public.teams VALUES (693, 'Mexico');
INSERT INTO public.teams VALUES (694, 'Denmark');
INSERT INTO public.teams VALUES (695, 'Spain');
INSERT INTO public.teams VALUES (696, 'Portugal');
INSERT INTO public.teams VALUES (697, 'Argentina');
INSERT INTO public.teams VALUES (698, 'Germany');
INSERT INTO public.teams VALUES (699, 'Netherlands');
INSERT INTO public.teams VALUES (700, 'Costa Rica');
INSERT INTO public.teams VALUES (701, 'Chile');
INSERT INTO public.teams VALUES (702, 'Nigeria');
INSERT INTO public.teams VALUES (703, 'Algeria');
INSERT INTO public.teams VALUES (704, 'Greece');
INSERT INTO public.teams VALUES (705, 'United States');


--
-- Name: games_game_id_seq; Type: SEQUENCE SET; Schema: public; Owner: freecodecamp
--

SELECT pg_catalog.setval('public.games_game_id_seq', 64, true);


--
-- Name: teams_team_id_seq; Type: SEQUENCE SET; Schema: public; Owner: freecodecamp
--

SELECT pg_catalog.setval('public.teams_team_id_seq', 705, true);


--
-- Name: games games_pkey; Type: CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_pkey PRIMARY KEY (game_id);


--
-- Name: teams teams_name_key; Type: CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_name_key UNIQUE (name);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (team_id);


--
-- Name: games games_opponent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_opponent_id_fkey FOREIGN KEY (opponent_id) REFERENCES public.teams(team_id);


--
-- Name: games games_winner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: freecodecamp
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_winner_id_fkey FOREIGN KEY (winner_id) REFERENCES public.teams(team_id);


--
-- PostgreSQL database dump complete
--


