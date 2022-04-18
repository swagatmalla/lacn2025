library(dplyr)
library(gt)
library(tidyverse)



#### Undergrad Services ####

# no of responses
q10_n <- question_list$Q10 |>
  
  dplyr::filter(dplyr::if_any(.cols = !(1:2), .fns = ~ !is.na(.x))) |>
  
  nrow()


# gt table
all_list$multi$Q10 |>
  
  # cleaning
  
  dplyr::mutate(
    value = dplyr::case_when(
      value == "Other:" ~ "Other",
      TRUE ~ as.character(value)
    ),
    freq_format = format(round(freq,2), nsmall = 2), .keep = "unused"
    ) |>
  dplyr::arrange(-n)|>
  
  dplyr::filter(n > 1) |>
  
  # init table
  
  gt::gt() |>
  
  gt::tab_header(title = "Services Offered to Undergraduates",
                 subtitle = glue::glue("Services with more than one response (n = {q10_n})")
  ) |>
  gt::cols_label(value = "Service",
                 n = "N",
                 freq_format = "Frequency") |>
  
  gt::cols_width(
    value ~ px(500)
  ) |>
  
  gt::cols_align(
    align = "center",
    columns = n:freq_format
  ) |>
  
  gt::tab_style(
    style = list(
      cell_fill(color = "aliceblue")),
    locations = cells_body(
        columns = everything(),
        rows = as.numeric(row.names(all_list$multi$Q10 |> dplyr::filter(n > 1))) %% 2 == 0)
    ) |>
  
  gt::tab_style(
    style = list(
      cell_text(weight = "bold")
    ),
    locations = cells_column_labels(
      columns = everything()
    )
  ) |>
  
  gt::tab_style(
    style = list(
      cell_text(style = "italic")
    ),
    locations = cells_title(groups = "subtitle")
  )



#### Undergrad Programs ####

all_list$multi$Q11

q11_n <- question_list$Q11 |>
  
  dplyr::filter(dplyr::if_any(.cols = !(1:2), .fns = ~ !is.na(.x))) |>
  
  nrow()

all_list$multi$Q11 |>
  
  dplyr::mutate(
    value = dplyr::case_when(
      value == "Other:" ~ "Other",
      TRUE ~ as.character(value)
    ),
    freq_format = format(round(freq,2), nsmall = 2), .keep = "unused"
  ) |>
  dplyr::arrange(-n)|>
  
  dplyr::filter(n > 1) |>
  
  
  gt::gt() |>
  
  gt::tab_header(title = "Programs Offered to Undergraduates",
                 subtitle = glue::glue("Programs with more than one response (n = {q11_n})")
  ) |>
  gt::cols_label(value = "Program",
                 n = "N",
                 freq_format = "Frequency") |>
  
  gt::cols_width(
    value ~ px(500)
  ) |>
  
  gt::cols_align(
    align = "center",
    columns = n:freq_format
  ) |>
  
  gt::tab_style(
    style = list(
      cell_fill(color = "aliceblue")),
    locations = cells_body(
      columns = everything(),
      rows = as.numeric(row.names(all_list$multi$Q11 |> dplyr::filter(n > 1))) %% 2 == 0)
  ) |>
  
  gt::tab_style(
    style = list(
      cell_text(weight = "bold")
    ),
    locations = cells_column_labels(
      columns = everything()
    )
  ) |>
  
  gt::tab_style(
    style = list(
      cell_text(style = "italic")
    ),
    locations = cells_title(groups = "subtitle")
  )




#### Grad Services ####

# Question 12: Yes or no grad services

all_list$single$Q12|>
  
  ggplot(aes(Q12,n))+
  
  geom_bar(stat = "identity")


# Question 13: grad services offered


q13_n <- question_list$Q13 |>
  
  dplyr::filter(dplyr::if_any(.cols = !(1:2), .fns = ~ !is.na(.x))) |>
  
  nrow()

all_list$multi$Q13 |>
  
  mutate(value = stringr::str_to_title(value),
         freq = n/q13_n,
         freq = format(round(freq,2), nsmall = 2)) |>
  
  dplyr::arrange(-n) |>
  
  gt::gt() |>
  
  gt::tab_header(title = "Services Offered to Grad Students",
                 subtitle = glue::glue("Services with more than one response (n = {q13_n})")
  ) |>
  gt::cols_label(value = "Service",
                 n = "N",
                 freq = "Frequency") |>
  
  gt::cols_width(
    value ~ px(500)
  ) |>
  
  gt::cols_align(
    align = "center",
    columns = n:freq
  ) |>
  
  gt::tab_style(
    style = list(
      cell_fill(color = "aliceblue")),
    locations = cells_body(
      columns = everything(),
      rows = as.numeric(row.names(all_list$multi$Q13 #|> dplyr::filter(n > 1)
                                  )) %% 2 == 0)
  ) |>
  
  gt::tab_style(
    style = list(
      cell_text(weight = "bold")
    ),
    locations = cells_column_labels(
      columns = everything()
    )
  ) |>
  
  gt::tab_style(
    style = list(
      cell_text(style = "italic")
    ),
    locations = cells_title(groups = "subtitle")
  )
  

#### Alum Services ####


# Question 14
all_list$single$Q14 # all 39 offer alum services; probably skip the viz? Ask Nate



# Question 15

q15_n <- question_list$Q15 |>
  
  dplyr::filter(dplyr::if_any(.cols = !(1:2), .fns = ~ !is.na(.x))) |>
  
  nrow()

all_list$multi$Q15 |>
  
  mutate(value = stringr::str_to_title(value),
         freq = n/q15_n,
         freq = format(round(freq,2), nsmall = 2)) |>
  
  dplyr::arrange(-n) |>
  
  gt::gt() |>
  
  gt::tab_header(title = "Services Offered to Alumni",
                 subtitle = glue::glue("Services with more than one response (n = {q15_n})")
  ) |>
  gt::cols_label(value = "Service",
                 n = "N",
                 freq = "Frequency") |>
  
  gt::cols_width(
    value ~ px(500)
  ) |>
  
  gt::cols_align(
    align = "center",
    columns = n:freq
  ) |>
  
  gt::tab_style(
    style = list(
      cell_fill(color = "aliceblue")),
    locations = cells_body(
      columns = everything(),
      rows = as.numeric(row.names(all_list$multi$Q15)) %% 2 == 0)
  ) |>
  
  gt::tab_style(
    style = list(
      cell_text(weight = "bold")
    ),
    locations = cells_column_labels(
      columns = everything()
    )
  ) |>
  
  gt::tab_style(
    style = list(
      cell_text(style = "italic")
    ),
    locations = cells_title(groups = "subtitle")
  )


