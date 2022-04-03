
#### Student Engagement by Class Year ####


## See sengage-year-plot code chunk




#### Student Engagement by Type ####

sengage_type_data <- question_list$Q21 |>
  tidyr::pivot_longer(
    cols = !(1:2),
    names_to = c('main','sub1','sub2'),
    values_to = "engage",
    names_sep = "_"
  ) |>
  dplyr::mutate(Question = paste(main,sub1,sub2, sep = "_")) |>
  dplyr::left_join(
    keyFunction('Q21',dim2)
  )

question_list$Q21 |>
  tidyr::pivot_longer(
    cols = !(1:2),
    names_to = c('main','sub1','sub2'),
    values_to = "engage",
    names_sep = "_"
  ) |>
  dplyr::mutate(sub2 = as.numeric(sub2)) |>
  dplyr::arrange(sub2) |>
  dplyr::filter(sub2==4 & !is.na(sub2)) #|>
  dplyr::group_by(`Institution Name`) |>
  dplyr::summarise(
    unique = n()
  )


tableViz(data = sengage_type_data, var = "engage")



