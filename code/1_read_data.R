library(tidyverse)

#### ---------- LOAD DATA ------------- ####
list.files("data")
# lacn_location <- file.path("data","OpsSurveyRawData4.14.22.csv")

lacn_location <- file.path("data","OpsSurveyRawData5.28.25.csv")

# Read in the data

# the line below also removes duplicate columns from the master data
# if the questions/ number of questions change, then you might have to change the numbers
# be sure to use `identical(df1$colname, df2$colname)` to verify 
# that the columns are indeeed duplicated

lacn_master <- readr::read_csv(lacn_location, col_select = c(-(234:243))) 

# Update column names so that the numeric columns start with Q and not a number
colnames(lacn_master) <- ifelse(stringr::str_detect(colnames(lacn_master), "^[0-9]"), stringr::str_c("Q", colnames(lacn_master)), colnames(lacn_master))

# Update column names so that coding at the end of names is taken out
colnames(lacn_master) <- ifelse(stringr::str_detect(colnames(lacn_master), ".*\\(.*\\)$"), stringr::str_replace(colnames(lacn_master), " \\(.*\\)$", ""), colnames(lacn_master))

lacn_master <- lacn_master |>
  dplyr::slice(-(2)) |> 
  dplyr::mutate(
    `Institution Name` = dplyr::case_when(
      is.na(`Institution Name`) ~ Q1_2, # If missing, pull from Q1_2
      `Institution Name` == "Brandeis College" ~ "Brandeis University", # correction
      TRUE ~ `Institution Name`
    )
  )


# specify google sheets location
ss <- "1e_5OqPASswQ_5BQmehN_PABwaZtgoYl4xOqGXlgT3uU"

googlesheets4::gs4_auth(email = "malla1@stolaf.edu", token=ss)

# Authorize the API and check if you are logged using: 
# googlesheets4::gs4_user()
# should say --> Logged in to googlesheets4 as <your email>



#### ---------- CREATE RESPONSE KEY ----------- ####
response_key_messy <- lacn_master |>
 dplyr::select(Q1_1:Q28) |>  #was Q:25 before
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
 #send response_key_messy to google sheets for manual clean-up
# googlesheets4::sheet_write(ss = ss,
#                        response_key_messy,
 #                         sheet = 'response_key_25')
#--------------------------------------------------------------


# retrieve manually cleaned response_key from google sheets
response_key <- googlesheets4::read_sheet(ss = ss,
                                         sheet = "response_key_25")

# save response key to csv in data subdirectory
readr::write_csv(response_key, file.path("data/response_key_25.csv"))



#### REFERENCE TABLE of question types ####
question_type <- googlesheets4::range_read(ss = "1e_5OqPASswQ_5BQmehN_PABwaZtgoYl4xOqGXlgT3uU",
                                        sheet = "progress_25",
                                        range = "A1:C29") |>
  dplyr::rename(q_type = "# selections possible")


