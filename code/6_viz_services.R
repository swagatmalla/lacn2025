library(gt)
library(tidyverse)

service_ug_data

question_list$Q10 |> View()

n <- question_list$Q10 |>
  
  dplyr::filter(dplyr::if_any(.cols = !(1:2), .fns = ~ !is.na(.x))) |>
  
  nrow()

all_list$multi$Q10 |>
  
  dplyr::mutate(
    value = dplyr::case_when(
      value == "Other:" ~ "Other",
      TRUE ~ as.character(value)
    ),
    freq_format = format(round(freq,2), nsmall = 2), .keep = "unused"
    ) |>
  dplyr::arrange(-n)|>
  
  
  gt::gt() |>
  
  gt::tab_header(title = "Services Offered to Undergraduates",
                 subtitle = glue::glue("Some subtitle text (n = {n})")
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
        rows = as.numeric(row.names(all_list$multi$Q10)) %% 2 == 0)
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


