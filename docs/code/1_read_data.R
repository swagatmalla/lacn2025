library(tidyverse)

#### ---------- LOAD DATA ------------- ####
list.files("data")
# lacn_location <- file.path("data","OpsSurveyRawData4.14.22.csv")

lacn_location <- file.path("data","RawData4.13.23.csv")

# Read in the data
lacn_master <- readr::read_csv(lacn_location, col_select = c(-(227:236))) # getting rid of duplicate columns

# Update column names so that the numeric columns start with Q and not a number
colnames(lacn_master) <- ifelse(stringr::str_detect(colnames(lacn_master), "^[0-9]"), stringr::str_c("Q", colnames(lacn_master)), colnames(lacn_master))

# Update column names so that coding at the end of names is taken out
colnames(lacn_master) <- ifelse(stringr::str_detect(colnames(lacn_master), ".*\\(.*\\)$"), stringr::str_replace(colnames(lacn_master), " \\(.*\\)$", ""), colnames(lacn_master))

lacn_master <- lacn_master |>
  dplyr::slice(-(2)) |> 
  dplyr::mutate(
    `Institution Name` = dplyr::case_when(
      is.na(`Institution Name`) ~ Q1_2,
      `Institution Name` == "Brandeis College" ~ "Brandeis University",
      TRUE ~ `Institution Name`
    )
  )

# jenny <- lacn_master[lacn_master$Q1_2 == "Mount Holyoke College",] |>
#   tidyr::pivot_longer(
#     cols = !Q1_1,
#     names_to = "questions",
#     values_to = "response"
#   ) |>
#   dplyr::filter(Q1_1 == "Jenny Watermill")
# 
# roshonda <- lacn_master[lacn_master$Q1_2 == "Mount Holyoke College",] |>
#   tidyr::pivot_longer(
#     cols = !Q1_1,
#     names_to = "questions",
#     values_to = "response"
#   ) |>
#   dplyr::filter(Q1_1 == "Roshonda DeGraffenreid")
# 
# holyoke <- jenny |>
#   dplyr::left_join(roshonda, by = "questions") |> 
#   dplyr::relocate(response.x, .after = "response.y") |>
#   dplyr::rename(roshonda_rep = "response.y",
#                 jenny_rep = "response.x") |>
#   dplyr::mutate(
#     responses = dplyr::case_when(
#       stringr::str_detect(questions, "Q24") ~ jenny_rep,
#       TRUE ~ as.character(roshonda_rep)
#     )
#   ) |>
#   dplyr::select(questions,responses) |>
#   
#   tidyr::pivot_wider(
#     names_from = "questions",
#     values_from = "responses"
#   ) |>
#   cbind("Q1_1" = "Roshonda DeGraffenreid") |>
#   dplyr::relocate(Q1_1, .before = "Q1_2")
# 
# lacn_master <- lacn_master |>
#   dplyr::filter(`Institution Name` != "Mount Holyoke College") |>
#   rbind(holyoke)
# 
# remove(holyoke,jenny,roshonda)
  

# specify google sheets location
ss <- "17gmSm6hF_T10sGQAjzDxztzWBsFNpWdfxYZMkZwFvSQ"

googlesheets4::gs4_auth(email = "noecke2@stolaf.edu", token=ss)



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
#                           sheet = 'response_key_23')
#--------------------------------------------------------------


# retrieve manually cleaned response_key from google sheets
response_key <- googlesheets4::read_sheet(ss = ss,
                                          sheet = "response_key_23")

# save response key to csv in data subdirectory
readr::write_csv(response_key, file.path("data/response_key_23.csv"))



#### REFERENCE TABLE of question types ####
question_type <- googlesheets4::range_read(ss = "17gmSm6hF_T10sGQAjzDxztzWBsFNpWdfxYZMkZwFvSQ",
                                        sheet = "progress_23",
                                        range = "A1:C26") |>
  dplyr::rename(q_type = "# selections possible")


