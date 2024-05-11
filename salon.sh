#! /bin/bash

# Define the PSQL command for PostgreSQL interaction
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n ~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?"

# Global variables for customer name and phone, and list of services
CUSTOMER_NAME=""
CUSTOMER_PHONE=""
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

# Function to create an appointment
CREATE_APPOINTMENT(){
    # Retrieve service name, customer name, and customer ID for formatting
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    CUST_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CUST_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    FORMAT_SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/\s//g' -E)
    FORMAT_CUSTOMER_NAME=$(echo $CUST_NAME | sed 's/\s//g' -E)

    # Prompt for appointment time and insert data into appointments table
    echo -e "\nWhat time would you like your $FORMAT_SERVICE_NAME, $FORMAT_CUSTOMER_NAME?"
    read SERVICE_TIME
    INSERT_DATA=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUST_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $FORMAT_SERVICE_NAME at $SERVICE_TIME, $FORMAT_CUSTOMER_NAME."
}

# Main menu function
MAIN_MENU() {
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CHECK_CUSTOMER_PHONE=$($PSQL "SELECT customer_id, name FROM customers WHERE phone ='$CUSTOMER_PHONE'")

    if [[ -z $CHECK_CUSTOMER_PHONE ]]
    then
        echo -e "I don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        CUSTOMER_DATA=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")

        # Call appointment creation function
        CREATE_APPOINTMENT
    else
        # Call appointment creation function
        CREATE_APPOINTMENT   
    fi
}

# Function to list services and handle service selection
LIST_OF_SERVICES(){
    if [[ $1 ]]
    then
        echo -e "\n$1"
    fi

    # Display available services
    echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do
        echo "$SERVICE_ID) $NAME Service"
    done

    read SERVICE_ID_SELECTED

    # Validate service selection
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
        LIST_OF_SERVICES "Invalid input. Please enter a valid service ID."
    else
        # Check if selected service exists
        HAVE_SERVICE=$($PSQL "SELECT service_id, name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

        if [[ -z $HAVE_SERVICE ]]
        then 
            LIST_OF_SERVICES "Invalid service ID. Please select from the available services."
        else
            # Proceed to main menu for customer interaction
            MAIN_MENU
        fi
    fi
}

# Initial call to list services and start the program
LIST_OF_SERVICES
