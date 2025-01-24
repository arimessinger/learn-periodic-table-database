#!/bin/bash

# Check if no argument is provided
if [ -z "$1" ]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Define the database connection details (using the provided database name and user)
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Escape special characters in the input argument to prevent SQL injection
ELEMENT_ARG=$(echo "$1" | sed "s/'/''/g")   # Escape any single quotes in the input

# Function to check if a string is numeric (i.e., if the input is a number)
is_number() {
  # Check if the string is numeric (only contains digits)
  [[ "$1" =~ ^[0-9]+$ ]]
}

# Check if the input is numeric (atomic number) or a string (symbol/name)
if is_number "$ELEMENT_ARG"; then
  # If the input is a number (atomic number), query based on atomic_number
  SQL_QUERY="SELECT e.atomic_number, e.symbol, e.name, p.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
  FROM elements e
  JOIN properties p ON e.atomic_number = p.atomic_number
  WHERE e.atomic_number = $ELEMENT_ARG;"
else
  # If the input is not a number (symbol or name), query based on symbol or name
  SQL_QUERY="SELECT e.atomic_number, e.symbol, e.name, p.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
  FROM elements e
  JOIN properties p ON e.atomic_number = p.atomic_number
  WHERE LOWER(e.symbol) = LOWER('$ELEMENT_ARG') OR LOWER(e.name) = LOWER('$ELEMENT_ARG');"
fi

# Run the SQL query using PSQL variable
RESULT=$(psql --username=freecodecamp --dbname=periodic_table -t --no-align -c "$SQL_QUERY")

# Check if the result is empty (no matching element)
if [ -z "$RESULT" ]; then
  echo "I could not find that element in the database."
else
  # Process the result into variables (atomic_number, symbol, name, type, atomic_mass, melting_point, boiling_point)
  IFS="|" read -r atomic_number symbol name type atomic_mass melting_point boiling_point <<< "$RESULT"

  # Format and output the result
  echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
fi
