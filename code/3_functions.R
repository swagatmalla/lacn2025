#### ---------- FUNCTIONS FOR LACN ANALYSIS ----------- ####



#### SELECTION FUNCTION ####

selectFunction <- function(type) {
  
  question_type |>
    dplyr::filter(q_type == type) |>
    dplyr::pull(unique)
  
}


####-----------QUESTION KEY Function------------####

keyFunction <- function(question, ...) {
  key <- response_key |> 
    dplyr::filter(main == question) |> 
    dplyr::select(Question, ...) |>
    dplyr::distinct()
  
  return(key)
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





####-----------Viz Functions------------------####


library(tidyverse)

rankViz <- function(college) {
  
  indiv <- question_list$Q5 |>
    filter(`Institution Name` == college) |>
    dplyr::mutate_at(vars(Q5_6:Q5_13), as.numeric) |>
    dplyr::select(Q5_6:Q5_13) |>
    tidyr::pivot_longer(
      cols = everything(),
      names_to = "Question",
      values_to = "ranking"
    ) |>
    dplyr::left_join(rank_key)
  
  
  rank_compare <- all_list$ranking$Q5 |>
    left_join(indiv) |>
    mutate(gap = ranking_avg - ranking) |>
    arrange(ranking_avg)
  
  ggplot(rank_compare, aes(x = ranking, xend = ranking_avg, y = reorder(dim1, -ranking_avg)))+ 
    ggplot2::geom_hline(yintercept = rank_compare$dim1, colour = "grey90")+
    ggalt::geom_dumbbell(colour = "#dddddd",
                         size = 2.5,
                         colour_x = "deepskyblue2",
                         colour_xend = "grey")+
    scale_x_reverse(breaks = rev(seq_len(11)), limits = c(11,1))+
    scale_y_discrete(labels = function(x) stringr::str_wrap(x, width = 25))+
    labs(
      title = paste0("Top Priorities: ", college, " v. Average"),
      y = NULL,
      x = "Importance to Senior Staff \n(1=highest)"
    )+
    theme(
      axis.ticks.y = element_blank(),
      panel.background = element_blank(),
      plot.margin = unit(c(1,1,1,1), "cm")
    )
  
}

matrixPlot <- function(data, college, title=NULL) {
  
  
  seq <- c(0, 
           ceiling(max(data['n'])/3), 
           ceiling((2/3)*max(data['n'])), 
           ceiling(max(data['n'])))
  
  plot <- ggplot2::ggplot(data = data, mapping = ggplot2::aes(reorder(`Institution Name`,n),n))+
    ggplot2::geom_hline(yintercept = seq,
                        colour = "grey")+
    ggplot2::scale_y_continuous(breaks = seq)+
    ggplot2::geom_bar(stat = 'identity', fill = "#7CBCE8")+
    ggplot2::labs(
      title = title,
      x = NULL,
      y = "Total"
    )+
    ggplot2::theme(
      axis.text.x = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      panel.background = ggplot2::element_blank(),
      text = element_text(size = 15)
    )
  
  
  if(!missing(college)) {
    
    indiv <- data |>
      dplyr::filter(`Institution Name` == college)
    
    return(
      
      plot + 
        ggplot2::geom_bar(data = indiv, stat = 'identity', fill = "#217DBB")+
        ggplot2::geom_label(data = indiv,
                            ggplot2::aes(label = `Institution Name`))
    )
    
    
  } else {
    
    return(plot)
    
  }
  
}

singlePlot <- function(data, q, title = NULL, college=NULL, string_rem) {
  
  viz <- ggplot2::ggplot(data = data, 
                         mapping = ggplot2::aes(reorder(.data[[q]], freq), freq))+
    ggplot2::geom_hline(yintercept = seq(0,1,by=0.2), colour = "grey")+
    ggplot2::geom_col(width = rel(0.5), fill = "#7CBCE8")+
    ggplot2::scale_y_continuous(limits=c(0,1), 
                                breaks = seq(0,1,by=0.2))+
    scale_x_discrete(labels = function(x) stringr::str_wrap(x, width = 20))+
    ggplot2::coord_flip()+
    ggplot2::labs(
      title = title,
      x = NULL,
      y = "\nFrequency"
    )+
    ggplot2::theme(
      axis.ticks = ggplot2::element_blank(),
      panel.background = ggplot2::element_blank(),
      text = element_text(size = 15)
    )
  
  if(!missing(college)) {
    
    college_chr <- as.character(college)
    
    indiv <- question_list[[q]][
      question_list[[q]]['Institution Name'] == college_chr,] |>
      dplyr::select(`Institution Name`, tidyselect::all_of(q))
    
    if(!missing(string_rem)) {
      suppressMessages(
        
        indiv[q] <- stringr::str_replace(string = indiv[q], pattern = string_rem, replacement = "")
        
      )
      
    }
    
    suppressMessages(
      indiv <- indiv |>
        dplyr::left_join(data)
    )
   
    
    return(
      viz + 
        ggplot2::geom_col(data = indiv, fill = "#217DBB", width = rel(0.5))+
        geom_label(data = indiv, 
                   ggplot2::aes(label = `Institution Name`),
                   nudge_y = .05)
    )
    
  } else {
    
    return(viz)
    
  }
  
}

tableViz <- function(data, var, college = NULL) {
  
  if(missing(college)){
    labels <- c('N','Mean','Median','Max','Min')
  } else {
    labels <- c('N','Mean','Median','Max','Min', college)
  }

  variable <- tibble::deframe(data[var])
  
  N <- as.integer(sum(!is.na(variable)))
  Mean <- mean(variable)
  Median <- median(variable)
  Max <- max(variable)
  Min <- min(variable)
  
  if(!missing(college)){
    College <- data |> 
      dplyr::filter(`Institution Name` == college) |>
      dplyr::pull(.data[[var]])
  }

  
  if(missing(college)){
    stats <- c(N, Mean, Median, Max, Min)
  } else {
    stats <- c(N, Mean, Median, Max, Min, College)
  }

  
  return(
    data.frame(labels, stats) |>
      gt::gt() |>
      gt::tab_header("Summary") |>
      gt::cols_label(labels="",stats="") |>
      gt::fmt_number(
        columns = stats,
        decimals = 0
      ) |>
      gt::tab_options(
        container.width = gt::pct(75)
      )
  )
  
}

nTab <- function(var) {
  
  glue::glue("N = {as.integer(sum(!is.na(var)))}")
  
  
}



