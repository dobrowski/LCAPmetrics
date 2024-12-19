
#. LCAP Reds with DAshbaord estimates 

library(tidyverse)
library(googlesheets4)
library(here)
library(MCOE) # Toggle this on an off.  It doesn't work on shiny with this enabled


options(scipen = 999)


lcap.reds.cde <- read_sheet("https://docs.google.com/spreadsheets/d/1vqUg655oph_cA8x9UpUHvuieb3FdCOwVxYeITmMYqzE/edit?gid=0#gid=0")


lcap.reds.cde2 <- lcap.reds.cde |>
    pivot_longer(c(ELA:Susp)) |>
    filter(value == "Y") |>
    mutate(schoolname = if_else(schoolname == "*",districtname,schoolname),
           value = "Red")


write_sheet(lcap.reds.cde2 ,ss = "https://docs.google.com/spreadsheets/d/1vqUg655oph_cA8x9UpUHvuieb3FdCOwVxYeITmMYqzE/edit?gid=0#gid=0",
            sheet = "Reds")
