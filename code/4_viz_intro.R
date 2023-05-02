library(tidyverse)

#### Enrollment Plot ####

enroll_data <- question_list$Q1 |>
  select(1:2) |>
  mutate(enroll = as.numeric(`Undergraduate enrollment`)) |>
  filter(!is.na(enroll))

      

#### Endowment Plot ####


endow_data <- lacn_master |>
  dplyr::select(
    `Institution Name`, 
    `Value of endowment assets at the beginning of the fiscal year`) |>
  dplyr::slice(-1) |>
  mutate(endow = as.numeric(`Value of endowment assets at the beginning of the fiscal year`)) |>
  mutate(endow_bil = endow/1e+09) |>
  dplyr::filter(!is.na(endow))

