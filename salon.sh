#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Salon ~~~"

SERVICE_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  SERVICES=$($PSQL "SELECT service_id, name FROM services;")
  echo -e "\nHow can I help you?"
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
   echo "$SERVICE_ID) $NAME"
  done
}
  
SERVICE_MENU
read SERVICE_ID_SELECTED
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE '$SERVICE_ID_SELECTED'=service_id;")

# check if service exists
HAVE_SERVICE=$($PSQL "SELECT service_id, name FROM services WHERE service_id='$SERVICE_ID_SELECTED';")

# if service does not exist
if [[ -z $HAVE_SERVICE ]]
then
  echo 'Please enter one of our available services.'
  SERVICE_MENU
else
  # get phone number
  echo -e "\nPlease enter your phone number."
  read CUSTOMER_PHONE
  HAVE_PHONE=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")

  # if customer is not in system
  if [[ -z $HAVE_PHONE ]]
  then
    echo -e "\nPlease enter your name."
    read CUSTOMER_NAME

    # insert new customer info
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    if [[ $INSERT_CUSTOMER_RESULT == 'INSERT 0 1' ]]
    then
      echo -e "\nNew customer $CUSTOMER_NAME added!"
    fi
  else
    # if they are in system, just assign their name so we can use it
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
  fi

  # get appointment time
  echo -e "\nWhat time would you like your appointment,$CUSTOMER_NAME?"
  read SERVICE_TIME
  
  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME');")

  # insert into appointments table
  if [[ $INSERT_APPOINTMENT_RESULT == 'INSERT 0 1' ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
fi


