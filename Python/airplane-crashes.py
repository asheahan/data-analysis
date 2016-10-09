#!/usr/bin/python
import pandas as pd
import numpy as np
import mysql.connector
from datetime import datetime
import re

# connect to db
# TODO: use config file
cn = mysql.connector.connect(user='root', password='password', host='localhost', database='data_analysis')

df = pd.read_sql('SELECT * FROM airplane_crashes', con=cn)
print('Loaded ' + str(len(df)) + ' records')

# close the db connection
cn.close()

# print column names
# print(df.columns)

# --------- CRASHES/FATALITIES BY YEAR -------------------
# function to get year from date field
def getYear (row):
  dt = datetime.strptime(row["Date"], "%m/%d/%Y")
  return dt.year

# apply function to create new column in dataframe
df["Year"] = df.apply (lambda row: getYear(row), axis=1)

years = df.groupby('Year')

# get crashes per year and export results for vis
crashes_by_year = years.size()
# crashes_by_year.to_csv("./crashes_by_year.csv")

# get fatalities per year and export results for vis
fatalities_by_year = years['Fatalities'].sum()
# fatalities_by_year.to_csv("./fatalities_by_year.csv")

# --------- COUNTRIES ------------------------------------
# states list
# TODO: add to separate file and import
us_states = [
  "Alaska",
  "Alabama",
  "Arizona",
  "Arkansas",
  "California",
  "Colorado",
  "Connecticut",
  "Delaware",
  "Florida",
  "Georgia",
  "Hawaii",
  "Idaho",
  "Illinois",
  "Indiana",
  "Iowa",
  "Kansas",
  "Kentucky",
  "Louisiana",
  "Maine",
  "Maryland",
  "Massachusetts",
  "Michigan",
  "Minnesota",
  "Mississippi",
  "Missouri",
  "Montana",
  "Nebraska",
  "Nevada",
  "New Hampshire",
  "New Jersey",
  "New Mexico",
  "New York",
  "North Carolina",
  "North Dakota",
  "Ohio",
  "Oklahoma",
  "Oregon",
  "Pennsylvania",
  "Rhode Island",
  "South Carolina",
  "South Dakota",
  "Tennessee",
  "Texas",
  "Utah",
  "Vermont",
  "Virginia",
  "Washington",
  "Washington D.C.",
  "West Virginia",
  "Wisconsin",
  "Wyoming"
]

# function to get country from location
def getCountry (row):
  c = re.search(',\s[a-zA-Z\s]+$', row["Location"])
  if c:
    country = c.group(0)[2:].strip()
    if country in us_states:
      return "United States"
    return country
  else:
    if row["Location"] in us_states:
      return "United States"
    return row["Location"].strip()

# apply function to create new column in dataframe
df["Country"] = df.apply (lambda row: getCountry(row), axis=1)

countries = df.groupby('Country')

# get crashes per country and export results for vis
crashes_by_country = countries.size()
# crashes_by_country.to_csv("./crashes_by_country.csv")
