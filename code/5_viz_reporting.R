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

all_list$multi$Q4 |>
  
  dplyr::filter(n>1) |>
  
  arrange(-n) |>
  
  mutate(freq = format(round(freq,2), nsmall = 2)) |>
  
  mutate(value = stringr::str_replace(value, "^My career.+boards$","No Advisory Boards"),
         value = stringr::str_replace(value, "^We report.+reps$","Academic Programs & Standards Committee")) |>
  
  serviceTab(q = "Q4", title = "Advisory Boards",
             subtitle = "Subtitle",
             offer = "To Whom Do You Report?")





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




rank_data |>
  ggplot(aes(reorder(dim1,-ranking_avg), ranking, colour = ranking))+
  geom_vline(xintercept = rank_data$dim1, colour = "grey")+
  geom_jitter(alpha = 0.5, width = 0, size = 3)+
  # geom_point(aes(reorder(dim1,-ranking_avg), ranking_avg), 
  #           colour = "grey",
  #           size = 5)+
  coord_flip()+
  scale_y_reverse(breaks = seq(1,11))+
  scale_color_gradientn(colours = c('chartreuse4','grey','hotpink2'))+
  
  labs(
    title = "Performance Metrics: Importance Ranking",
    subtitle = "Subtitle (n = n_respond)",
    y = "Importance Ranking\n (1=highest)"
  )+
  theme(
    panel.background = element_blank(),
    text = element_text(family = "Source Sans Pro", size = 15),
    axis.ticks.y = element_blank(),
    axis.title.y = element_blank(),
    axis.title.x = element_text(size = 13),
    legend.position = "none"
  )





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

question_list$Q9

all_list$multi$Q9 |>
  
  dplyr::filter(n > 1) |>
  
  dplyr::mutate(freq = format(round(freq,2), nsmall = 2))|>
  
  arrange(-n) |>
  
  serviceTab(q = 'Q9', title = "Conferences Attended by Staff", 
             subtitle = "Conferences with more than one response", 
             offer = "Conferences")

