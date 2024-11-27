#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
# insert team to teams table
if [[ $WINNER != 'winner'  && $OPPONENT != 'opponent' ]]
then
WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
  if [[ -z $WINNER_ID ]]
  then
  INSERT_WINNER_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")"
    if [[ $INSERT_WINNER_RESULT == 'INSERT 0 1' ]]
    then
    echo Unique team:$WINNER inserted
    fi
  WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
  fi

OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT' ")"
  if [[ -z $OPPONENT_ID ]]
  then
  INSERT_OPPONENT_RESULT="$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")"
    if [[ $INSERT_OPPONENT_RESULT == 'INSERT 0 1' ]]
    then
    echo Unique team:$OPPONENT inserted
    fi
  OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT' ")"
  fi
fi

# insert all data into games table
if [[ $YEAR != 'year' && $ROUND != 'round' && $W_GOALS != 'winner_goals' && $O_GOALS != 'opponent_goals' ]]
then
GAME_ID="$($PSQL "SELECT game_id FROM games WHERE year=$YEAR AND round='$ROUND' AND winner_id=$WINNER_ID AND winner_goals=$W_GOALS AND opponent_id=$OPPONENT_ID AND opponent_goals=$O_GOALS")"
 if [[ -z $GAME_ID ]]
 then
 INSERT_GAME_RESULT="$($PSQL "INSERT INTO games(year, round, winner_id, winner_goals, opponent_id, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $W_GOALS, $OPPONENT_ID, $O_GOALS)")"
 if [[ $INSERT_GAME_RESULT == 'INSERT 0 1' ]]
 then 
 echo game in $YEAR $ROUND inserted, winner is $WINNER
 fi
 GAME_ID="$($PSQL "SELECT game_id FROM games WHERE year=$YEAR AND round='$ROUND' AND winner_id=$WINNER_ID AND winner_goals=$W_GOALS AND opponent_id=$OPPONENT_ID AND opponent_goals=$O_GOALS")"
 fi
fi

done

