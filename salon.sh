#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~ Welcome to the Salon ~~~\n"

# Función para mostrar servicios disponibles
SHOW_SERVICES() {
  echo -e "Here are the services we offer:\n"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Mostrar servicios y pedir selección válida
SERVICE_ID_SELECTED=""
while [[ -z $SERVICE_ID_SELECTED ]]; do
  SHOW_SERVICES
  echo -e "\nEnter the service ID you want:"
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\nInvalid service. Please try again."
    SERVICE_ID_SELECTED=""
  fi
done

# Pedir teléfono
echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

# Buscar cliente
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_NAME ]]; then
  echo -e "\nNew customer! Enter your name:"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
fi

# Obtener customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Pedir hora
echo -e "\nEnter the time for your appointment:"
read SERVICE_TIME

# Crear cita
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Confirmar cita
if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]; then
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
fi
