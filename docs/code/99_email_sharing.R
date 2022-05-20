# load packages
library(googledrive)
library(tidyverse)
library(googlesheets4)

# specify google sheets tab with college rep emails
college_ss <- "17gmSm6hF_T10sGQAjzDxztzWBsFNpWdfxYZMkZwFvSQ"

# read in college rep email dataframe
email_df <- read_sheet(ss = college_ss,
                       sheet = "sharing",
                       range = "A1:B") |>
  mutate(filename = paste0(str_remove_all(college, "[:blank:]"),".html")) |>
  relocate(filename, .after = "college") |>
  arrange(filename)

# authorize google drive connection
drive_auth(email = "gold1@stolaf.edu")

# specify shared drive location
shared_drive <- as_id("https://drive.google.com/drive/folders/1lremRL77g8nJRwOveRCbj_Euks9BeKuo")



# college_dir <- drive_mkdir(name = email_df$college[i],
#            path = shared_drive)

# college_dir_id <- college_dir[[2]]

for (i in seq_len(nrow(email_df))) {
  
  html_file <- file.path(here::here(),"docs/custom", email_df$filename[i])
  
  drive_upload(html_file,
               shared_drive, overwrite = TRUE)
}

drive_share(
  drive_file,
  role = "writer",
  type = "user",
  #emailAddress = email_df$email[i]
)



