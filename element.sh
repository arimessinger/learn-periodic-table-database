#!/bin/bash

# Check if no argument is provided
if [ -z "$1" ]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Define the database connection details (using the provided database name and user)
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Escape special characters in the input argument
ELEMENT_ARG=$(echo "$1" | sed "s/'/''/g")   # Escape any single quotes in the input

# SQL query to fetch data from the database based on the argument (atomic_number, symbol, or name)
SQL_QUERY="SELECT e.atomic_number, e.symbol, e.name, p.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
FROM elements e
JOIN properties p ON e.atomic_number = p.atomic_number
WHERE e.atomic_number = '$ELEMENT_ARG' OR e.symbol = '$ELEMENT_ARG' OR e.name = '$ELEMENT_ARG';"

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
