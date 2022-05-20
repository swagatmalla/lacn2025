#### SELECTION FUNCTION ####

selectFunction <- function(type) {
  
  question_type |>
    dplyr::filter(q_type == type) |>
    dplyr::pull(unique)
  
}




####----------------SINGLE FUNCTION------------------####

singleFunction <- function(list, element) {
  
  
  dplyr::count(get(list)[[element]], .data[[element]]) |>
    dplyr::mutate(freq = n / sum(n)) |>
    dplyr::select(.data[[element]], n, freq)
  
}


####-------------MULTI FUNCTION--------------------####

multiFunction <- function(list, element) {
  
  tidyr::pivot_longer(
    data = get(list)[[element]],
    cols = !(1:2),
  ) |>
    dplyr::filter(!is.na(value)) |>
    dplyr::group_by(value) |>
    dplyr::summarise(n = dplyr::n()) |>
    dplyr::mutate(freq = n / n_distinct(get(list)[[element]][1]))
  
}


####-----------MATRIX FUNCTION-----------------####

matrixFunction <- function(list, element, sep = "_", cols_exclude = (1:2), method = "mean", ...) {
  
  
  
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
      na.rm = TRUE,
      ...)
  
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

continuousFunction <- function(list, element, method = "mean", ...) {
  
  initial_key <- keyFunction(element, dim1, dim2)
  
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
  
  dim <- colnames(joined_df)[ncol(joined_df)]
  
  summed_df <- joined_df |>
    dplyr::group_by(get(dim)) |>
    dplyr::summarise(stat = get(method)(Response, na.rm = TRUE, ...))
  
  names(summed_df)[names(summed_df) == "get(dim)"] <- dim
  
  names(summed_df)[names(summed_df) == "stat"] <- method
  
  return(summed_df)
}


####---------ANALYZE Function--------------####


analyzeFunction <- function(type, list = "question_list") {
  
  
  questions <- selectFunction(type)
  
  list <- map(questions,
              ~ get(paste0(type,"Function"))(
                list,
                element = .x
              )
  )
  
  names(list) <- questions
  
  return(list)
  
}




