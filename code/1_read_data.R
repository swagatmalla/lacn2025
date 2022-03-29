library(tidyverse)

#### ---------- LOAD DATA ------------- ####
lacn_location <- file.path("~/piper analysis/lacn/data/lacn_2022.csv")

lacn_master <- readr::read_csv(lacn_location) |>
  dplyr::slice(-(2:3))

# specify google sheets location
ss <- "17gmSm6hF_T10sGQAjzDxztzWBsFNpWdfxYZMkZwFvSQ"


#### ---------- CREATE RESPONSE KEY ----------- ####
response_key_messy <- lacn_master |>
  dplyr::select(Q1_1:Q25) |>
  dplyr::slice(1L)|>
  tidyr::pivot_longer(
    cols = dplyr::everything(),
    names_to = "Question",
    values_to = "Description"
  ) |>
  tidyr::separate(col = Description, into = c("1","2","3","4"), 
                  sep = " - ", extra = "drop", fill = "right", remove = FALSE) |>
  tidyr::separate(col = Question, into = c('main','sub','sub2'),
                  sep = "_", extra = "drop", fill = "right", remove = FALSE)


#---------------ONLY RUN ONCE----------------------------------
# send response_key_messy to google sheets for manual clean-up 
# googlesheets4::sheet_write(ss = ss,
#                           response_key_messy,
#                           sheet = 'response_key')
#--------------------------------------------------------------


# retrieve manually cleaned response_key from google sheets
response_key <- googlesheets4::read_sheet(ss = ss,
                                          sheet = "response_key")

# save response key to csv in data subdirectory
readr::write_csv(response_key, file.path("~/piper analysis/lacn/data/response_key.csv"))



#### REFERENCE TABLE of question types ####
question_type <- googlesheets4::range_read(ss = "17gmSm6hF_T10sGQAjzDxztzWBsFNpWdfxYZMkZwFvSQ",
                                        sheet = "progress",
                                        range = "A1:C26") |>
  dplyr::rename(q_type = "# selections possible")


