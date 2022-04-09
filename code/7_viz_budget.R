library(tidyverse)



#### Total Funding ####
funding_data <- question_list$Q24 |>
  tidyr::pivot_longer(
    cols = !(1:2),
    names_to = "Question",
    values_to = "amount"
  ) |>
  dplyr::left_join(
    keyFunction('Q24',dim1)
    ) |>
  dplyr::select(`Institution Name`,dim1,amount) |>
  dplyr::mutate(amount = as.numeric(amount)) |>
  dplyr::group_by(`Institution Name`, dim1) |>
  dplyr::summarise(total = sum(amount, na.rm = TRUE)) |>
  tidyr::pivot_wider(
    names_from = dim1,
    values_from = total
  ) |>
  dplyr::filter(if_any(`Expendable gifts`:Other, ~ .x > 0)) |>
  tidyr::pivot_longer(
    cols = !(1),
    names_to = "dim1",
    values_to = "total"
  ) |>
  dplyr::mutate(total_mil = total/1e+06) |>
  dplyr::mutate(
    dim1 = stringr::str_to_title(
      stringr::str_remove(dim1, "Income from[:blank:]")
      )
  )



expend_data <- all_list$matrix$Q24 |>
  tidyr::pivot_longer(
    cols = !dim2,
    names_to = "dim1",
    values_to = "mean"
  ) |>
  dplyr::filter(dim2 != "Total") |>
  dplyr::mutate(
    dim1 = stringr::str_to_title(
      stringr::str_remove(dim1, "Income from[:blank:]")
    ),
    dim2 = stringr::str_to_title(
      stringr::str_remove(dim2,
                          "Amount utilized for[:blank:]"
                          )
      ),
    dim2 = stringr::str_remove(dim2, "[:blank:]\\([:symbol:]\\)"),
    mean_thou = mean/1000
  )


