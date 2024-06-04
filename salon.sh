#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_SERVICE(){
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  fi 

  SERVICES=$($PSQL "select * from services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME 
  do 
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done

  echo -e "\nWhich one do you want to choose?"
  read SERVICE_ID_SELECTED 

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then 
    MAIN_SERVICE "Invalid input. Please enter a number."
    return
  fi 

  ID_FIND=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")
  if [[ -z $ID_FIND ]]
  then
    MAIN_SERVICE "This service does not exist."
    return
  fi 

  echo -e "\nEnter your phone number:"
  read CUSTOMER_PHONE 

  CUSTOMER_FIND=$($PSQL "select * from customers where phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_FIND ]]
  then 
    echo -e "\nEnter your name:"
    read CUSTOMER_NAME
    INSERT_STATUS=$($PSQL "insert into customers(name,phone) values('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
  fi 

  echo -e "\nEnter service time:"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
  INSERT_STATUS=$($PSQL "insert into appointments(customer_id,service_id,time) values($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
  SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")

  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
}

MAIN_SERVICE
