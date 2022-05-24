library(tidyverse)

info_no_data <- question_list$Q36 |>
  pivot_longer(
    cols = !(1:2),
    names_to = "Question",
    values_to = "amount"
  )|>
  
  mutate(amount = as.numeric(amount)) |>
  
  filter(Question %in% c('Q36_2_1','Q36_2_2')) |>
  
  left_join(
    keyFunction('Q36', dim1, dim2)
  ) |>
  
  mutate(dim2 = str_remove(dim2, "#[:blank:]"),
         amount = replace_na(amount,0)) |>
  
  select(!Question)|>
  
  pivot_wider(
    names_from = dim2,
    values_from = amount
  ) |>
  
  filter(
    if_any((4:5), ~ .x > 0 & !is.na(.x)
    )
  ) |>
  
  pivot_longer(
    cols = (4:5),
    names_to = "dim2",
    values_to = "amount"
  ) |>
  
  mutate(
    amount = case_when(
      `Institution Name` == "Pomona College" ~ 28,
      TRUE ~ amount
    )
  )






info_employ_data <- question_list$Q37 |>
  pivot_longer(
    cols = !(1:2),
    names_to = "Question",
    values_to = "amount"
  )|>
  
  mutate(amount = as.numeric(amount)) |>
  
  filter(Question %in% c('Q37_2_1','Q37_2_2')) |>
  
  left_join(
    keyFunction('Q37',dim1,dim2)
  )  |>
  
  mutate(dim2 = str_remove(dim2, "#[:blank:]"),
            amount = replace_na(amount,0)) |>
  
  select(!Question) |>
  
  pivot_wider(
    names_from = dim2,
    values_from = amount
  ) |>
  
  filter(
    if_any((4:5), ~ .x > 0 & !is.na(.x)
           )
  ) |>
  
  pivot_longer(
    cols = (4:5),
    names_to = "dim2",
    values_to = "amount"
  ) |>
  
  mutate(
    amount = case_when(
      `Institution Name` == "Pomona College" ~ 28,
      TRUE ~ amount
    )
  )



