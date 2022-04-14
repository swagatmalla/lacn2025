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



#### Endowed Funds ####

endow_exp_data <- question_list$Q24 |>
  tidyr::pivot_longer(
    cols = !(1:2),
    names_to = "Question",
    values_to = "amount"
  ) |>
  dplyr::left_join(
    keyFunction('Q24',dim1,dim2)
  ) |>
  dplyr::mutate(
    dim1 = stringr::str_to_title(
      stringr::str_remove(dim1, "Income from[:blank:]")
      ),
    amount = as.numeric(amount)
    ) |>
  
  dplyr::filter(dim1 == "Endowed Funds" & dim2 != "Total") |>
  
  dplyr::group_by(`Institution Name`, dim2) |>
  dplyr::summarise(amount = sum(amount)) |>
  
  tidyr::pivot_wider(
    names_from = dim2,
    values_from = amount
  ) |>
  
  dplyr::filter(
    dplyr::if_any(`Amount utilized for funded internships ($)`:`Other ($)`,
                  ~ .x > 0 & !is.na(.x)
                  )
    ) |>
  
  tidyr::pivot_longer(
    cols = !(1),
    names_to = "dim2",
    values_to = "amount"
  ) |>
  
  dplyr::mutate(amount_mil = amount/1e+06,
                dim2 = stringr::str_to_title(
                  stringr::str_remove(dim2, 
                                      "Amount.+for[:blank:]"
                                      )
                  ),
                dim2 = stringr::str_remove(dim2,
                                           "[:blank:]\\([:symbol:]\\)"
                                           )
                )
                



#### Expendable Gifts ####

gift_data <- question_list$Q24 |>
  tidyr::pivot_longer(
    cols = !(1:2),
    names_to = "Question",
    values_to = "amount"
  ) |>
  dplyr::left_join(
    keyFunction('Q24',dim1,dim2)
  ) |>
  
  dplyr::filter(dim1 == "Expendable gifts" & dim2 != "Total") |>
  
  dplyr::mutate(amount = tidyr::replace_na(as.numeric(amount),0)) |>
  
  dplyr::group_by(`Institution Name`, dim2) |>
  dplyr::summarise(amount = sum(amount)) |>
  
  dplyr::mutate(dim2 = stringr::str_to_title(
                  stringr::str_remove(dim2, 
                                      "Amount.+for[:blank:]"
                  )
                ),
                dim2 = stringr::str_remove(dim2,
                                           "[:blank:]\\([:symbol:]\\)"
                )
  ) |>
  
  tidyr::pivot_wider(
    names_from = dim2,
    values_from = amount
  ) |>
  
  dplyr::filter(
    dplyr::if_any((1:2), ~ .x > 0 & !is.na(.x)
    )
  ) |>
  
  tidyr::pivot_longer(
    cols = !(1),
    names_to = "dim2",
    values_to = "amount") |>
  
  dplyr::mutate(
    amount_thou = amount/1e+03
  )







