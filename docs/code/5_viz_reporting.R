library(tidyverse)
library(RColorBrewer)
library(showtext)
library(sysfonts)

# load fonts
font_add_google("Source Sans Pro")

showtext_auto()


#### Reporting Structure ####

reporting_data <- all_list$single$Q2 |>
  mutate(Q2 = stringr::str_remove(Q2,":"))



#### Steps Removed ####

steps_data <- all_list$single$Q3 |>
  mutate(Q3 = stringr::str_remove(Q3, "[:blank:]\\(.+\\)"))


#### Advisory Boards ####




#### Performance Metrics ####

rank_data <- question_list$Q5 |>
  
  dplyr::filter(dplyr::if_any(.cols = !(1:2), .fns = ~ !is.na(.x))) |>
  
  tidyr::pivot_longer(
    cols = !(1:2),
    names_to = "Question",
    values_to = "ranking"
  ) |>
  
  dplyr::left_join(keyFunction('Q5', dim1)) |>
  
  dplyr::left_join(all_list$ranking$Q5) |>
  
  dplyr::filter(Question != "Q5_13_TEXT") |>
  
  dplyr::mutate(ranking = as.numeric(ranking),
                dim1 = stringr::str_remove(dim1, "[:blank:]\\(.+\\)"))







#### Student Staff (Total) ####

student_staff_data <- question_list[['Q6']] |>
  tidyr::pivot_longer(
    cols = !(1:2),
    names_to = "Question",
    values_to = "response"
  ) |>
  dplyr::left_join(
    keyFunction('Q6', dim1,dim2)
    ) |>
  dplyr::mutate(response = as.numeric(response)) |>
  dplyr::group_by(`Institution Name`) |>
  dplyr::summarise(n = sum(response, na.rm = TRUE)) |>
  dplyr::filter(n > 0 & !is.na(n))



#### Student Staff (Paraprofessional) ####

student_para_data <- question_list[['Q6']] |>
  tidyr::pivot_longer(
    cols = !(1:2),
    names_to = "Question",
    values_to = "response"
  ) |>
  dplyr::left_join(
    keyFunction('Q6', dim1,dim2)
  ) |>
  dplyr::mutate(response = as.numeric(response)) |>
  dplyr::filter(dim1 == "Students in paraprofessional roles") |>
  dplyr::group_by(`Institution Name`) |>
  dplyr::summarise(n = sum(response, na.rm = TRUE)) |>
  dplyr::filter(n > 0 & !is.na(n))


#### Student to Student Staff Ratio ####

student_stustaff_ratio <- student_staff_data |>
  
  left_join(question_list$Q6[1:2]) |>
  
  mutate(ratio = as.numeric(`Undergraduate enrollment`)/n) |>
  
  dplyr::select(`Institution Name`,
                ratio) |>
  dplyr::mutate(n=ratio, .keep = "unused") |>
  dplyr::filter(!is.na(n) & n > 0 & !is.infinite(n))

#### Professional Staff ####

prof_staff_data <- question_list[['Q7']] |>
  dplyr::select(`Institution Name`,Q7_1_10) |>
  dplyr::mutate(n = as.numeric(Q7_1_10), .keep = "unused") |>
  dplyr::filter(n > 0 & !is.na(n) & !is.infinite(n))



#### Student to Professional Staff Ratio ####

student_prof_ratio <- question_list[['Q7']] |>
  dplyr::select(`Institution Name`,
                `Undergraduate enrollment`,
                Q7_1_10) |>
  dplyr::mutate(n = as.numeric(Q7_1_10),
                enroll = as.numeric(`Undergraduate enrollment`),
                ratio = round(enroll/n),
                .keep = "unused") |>
  dplyr::select(`Institution Name`,
                ratio) |>
  dplyr::mutate(n=ratio, .keep = "unused") |>
  dplyr::filter(!is.na(n) & n > 0 & !is.infinite(n))


#### Professional Advising (any amount of time) ####

prof_advising_data <- question_list$Q8 |>
  dplyr::select(`Institution Name`,Q8_1_1:Q8_7_3) |>
  dplyr::mutate_at(vars(Q8_1_1:Q8_7_3), as.numeric) |>
  dplyr::rowwise() |>
  dplyr::mutate(n = sum(Q8_1_1:Q8_7_3)) |>
  dplyr::select(`Institution Name`, n) |>
  dplyr::filter(!is.na(n) & n > 0 & !is.infinite(n))



#### Professional Employer Relations ####

prof_employer_data <- question_list$Q8 |>
  dplyr::select(`Institution Name`, Q8_8_1:Q8_14_3) |>
  dplyr::mutate_at(vars(Q8_8_1:Q8_14_3), as.numeric) |>
  dplyr::rowwise() |>
  dplyr::mutate(n = sum(Q8_8_1:Q8_14_3)) |>
  dplyr::select(`Institution Name`, n) |>
  dplyr::filter(n > 0 & !is.na(n) & !is.infinite(n))



#### Conferences #### 



