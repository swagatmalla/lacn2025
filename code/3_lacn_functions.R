#### ---------- FUNCTIONS FOR LACN ANALYSIS ----------- ####



#### SELECTION FUNCTION ####

select_function <- function(type) {
  
  question_type |>
    dplyr::filter(q_type == type) |>
    dplyr::pull(unique)
  
}



####-----------QUESTION KEY Function------------####

key_function <- function(question, ...) {
  key <- response_key |> 
    dplyr::filter(main == question) |> 
    dplyr::select(Question, ...) |>
    dplyr::distinct()
  
  return(key)
}




####----------------SINGLE FUNCTION------------------####

single_function <- function(list, element) {
  
  
  dplyr::count(get(list)[[element]], .data[[element]]) |>
    dplyr::mutate(freq = n / sum(n)) |>
    dplyr::select(.data[[element]], n, freq)
  
}


####-------------MULTI FUNCTION--------------------####

multi_function <- function(list, element) {
  
  tidyr::pivot_longer(
    data = get(list)[[element]],
    cols = !(1:2),
  ) |>
    dplyr::filter(!is.na(value)) |>
    group_by(value) |>
    summarise(n = n()) |>
    mutate(freq = n / n_distinct(get(list)[[element]][1]))
  
}


####-----------MATRIX FUNCTION-----------------####

matrix_function <- function(list, element, sep = "_", cols_exclude = (1:2), method = "mean") {
  
  
  
  pivot_data <- tidyr::pivot_longer(
    data = get(list)[[element]],
    cols = !all_of(cols_exclude),
    names_to = c('a','b','c'),
    names_sep = "_"
  ) |>
    dplyr::mutate(
      value = as.numeric(value)
    ) |>
    tidyr::pivot_wider(
      names_from = b,
      values_from = value
    ) |>
    dplyr::group_by(c)
  
  vars_to_summarise <- base::names(pivot_data)[
    (match(
      'c',
      base::names(pivot_data)
    )+1
    ):length(
      names(pivot_data)
    )
  ]
  
  summarise_data <- pivot_data |>
    dplyr::summarise_at(
      dplyr::vars(vars_to_summarise[1]:vars_to_summarise[length(vars_to_summarise)]),
      get(method),
      na.rm = TRUE)
  
  q_key1 <- response_key |> 
    dplyr::filter(main == element) |> 
    dplyr::select(sub1, dim1) |>
    dplyr::distinct()
  
  q_key2 <- response_key |>
    dplyr::filter(main == element) |>
    dplyr::select(sub2, dim2) |>
    dplyr::distinct()
  
  
  colnames(summarise_data) <- c('c',q_key1$dim1)
  
  merged_df <- merge(summarise_data, q_key2, by.x = "c", by.y = "sub2") |>
    dplyr::select(!c) |>
    dplyr::relocate(dim2, .before = dplyr::everything())
  
  return(merged_df)

}


####-----------CONTINUOUS functions-------------####

continuous_function <- function(list, element, method = "mean") {
  
  initial_key <- key_function(element, dim1, dim2)
  
  if(length(unique(initial_key$dim1))==1) {
    q_key <- initial_key |>
      dplyr::select(Question,dim2)
  } else {
    q_key <- initial_key |>
      dplyr::select(Question,dim1)
  }
  
  joined_df <- get(list)[[element]] |>
    tidyr::pivot_longer(
      cols = !(1:2),
      names_to = 'Question',
      values_to = 'Response'
    ) |>
    dplyr::left_join(q_key) |>
    dplyr::mutate(Response = as.numeric(Response))
  
  columns <- colnames(joined_df)[ncol(joined_df)]
  
  summed_df <- joined_df |>
    dplyr::group_by(get(columns)) |>
    dplyr::summarise(mean = get(method)(Response, na.rm = TRUE))
  
  names(summed_df)[names(summed_df) == "get(columns)"] <- columns
  
  return(summed_df)
}





####---------ANALYZE Function--------------####


analyze_function <- function(type, list = "question_list") {
  
  
  questions <- select_function(type)
  
  list <- map(questions,
                ~ get(paste0(type,"_function"))(
                  list,
                  element = .x
                )
              )
  
  names(list) <- questions
  
  return(list)
  
}









