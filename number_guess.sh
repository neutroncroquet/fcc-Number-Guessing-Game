#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
declare -i GAMES_PLAYED
echo -e "\nEnter your username:"
read USERNAME
USER_QUERY=$($PSQL "SELECT games_played, best_game FROM users WHERE username = '$USERNAME';")
if [[ $USER_QUERY ]]
then
  IFS="|" read GAMES_PLAYED BEST_GAME <<< $USER_QUERY
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  USER_ADD=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi
echo "Guess the secret number between 1 and 1000:"
declare -i NUMBER_OF_GUESSES
guessing_game(){
  read GUESS
  #checks if guess is a number
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    NUMBER_OF_GUESSES+=1
    if [[ $GUESS -eq $SECRET_NUMBER ]]
    then
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      GAMES_PLAYED+=1
      if [[ -z $BEST_GAME || $BEST_GAME -gt $NUMBER_OF_GUESSES ]]
      then
        BEST_GAME=$NUMBER_OF_GUESSES
      fi
      USER_UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $BEST_GAME WHERE username = '$USERNAME';")
    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      guessing_game
    else
      echo "It's higher than that, guess again:"
      guessing_game
    fi
  else
    echo "That is not an integer, guess again:"
    guessing_game
  fi
}
guessing_game
