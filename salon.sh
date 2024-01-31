#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"


MAIN_MENU(){
    if [[ $1 ]]
    then
        echo -e "\n$1"
    fi

    # chose a service
    CHOSEN_SERVICE=$($PSQL "SELECT * FROM services")

    echo "$CHOSEN_SERVICE" | while read SERVICE_ID BAR NAME
    do
        echo "$SERVICE_ID) $NAME"
    done
    read SERVICE_ID_SELECTED

    # if avialibile service
    SERVICE_AVIILABILITY=$($PSQL "SELECT service_id FROM services WHERE service_id="$SERVICE_ID_SELECTED"")

    if [[ -z $SERVICE_AVIILABILITY ]]
    then 
        MAIN_MENU "I could not find that service. What would you like today?"

    else
        # customer phone number
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

        HAVE_CUS=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | sed -r 's/ //g')


        # if phone is not regesterd
        if [[ -z $HAVE_CUS ]]
        then 
            # customer name
            echo -e "\nI don't have a record for that phone number, what's your name?"
            read CUSTOMER_NAME

            ADD_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
            
            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

            # selected time
            echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
            read SERVICE_TIME

            # add appointments
            ADD_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

            echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

        else
            # if the customer is regesterd
            echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"

            ADD_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

            echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME".

        fi
    fi
}

MAIN_MENU