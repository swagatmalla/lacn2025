#### ---------- FUNCTIONS FOR LACN ANALYSIS ----------- ####


####-----------QUESTION KEY Function------------####

keyFunction <- function(question, ...) {
  key <- response_key |> 
    dplyr::filter(main == question) |> 
    dplyr::select(Question, ...) |>
    dplyr::distinct()
  
  return(key)
}


####-----------Viz Functions------------------####

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

matrixPlot <- function(data, breaks = NULL, college, title=NULL, font = "Source Sans Pro", size = 45) {
  
  sysfonts::font_add_google(font)
  
  showtext::showtext_auto()
  
  if(!missing(breaks)) {
    
    stopifnot(length(breaks) > 1)
    
  }
  
  
  if(missing(breaks)) {
    
    seq <- c(0, 
             ceiling(max(data['n'])/3), 
             ceiling((2/3)*max(data['n'])), 
             ceiling(max(data['n']))
    )
    
  } else {
    
    seq <- breaks
    
  }
  
  
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
      text = element_text(size = size, family = font)
    )
  
  
  if(!missing(college)) {
    
    indiv <- data |>
      dplyr::filter(`Institution Name` == college)
    
    return(
      
      plot + 
        ggplot2::geom_bar(data = indiv, stat = 'identity', fill = "#217DBB")+
        ggplot2::geom_label(data = indiv,
                            ggplot2::aes(label = `Institution Name`),
                            label.size = 1)
    )
    
    
  } else {
    
    return(plot)
    
  }
  
}

singlePlot <- function(data, q, college=NULL, title = NULL, string_rem, font = "Lato", size = 45, lineheight = 0.5) {
  
  viz <- ggplot2::ggplot(data = data, 
                         mapping = ggplot2::aes(reorder(.data[[q]], freq), freq))+
    
    ggplot2::geom_hline(yintercept = seq(0,1,by=0.2), colour = "grey")+
    ggplot2::geom_bar(width = 0.6, 
                      stat = 'identity',
                      fill = "#7CBCE8")+
    
    ggplot2::scale_y_continuous(limits=c(0,1), 
                                breaks = seq(0,1,by=0.2),
                                labels = c('0%','20%','40%','60%','80%','100%'))+
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
      text = element_text(size = size, family = font, lineheight = lineheight)
    )
  
  if(!missing(college)) {
    
    college_chr <- as.character(college)
    
    indiv <- question_list[[q]][
      question_list[[q]]['Institution Name'] == college_chr,] |>
      dplyr::select(`Institution Name`, tidyselect::all_of(q))
    
    if(!missing(string_rem)) {
      suppressMessages(
        
        indiv[q] <- stringr::str_replace(string = tibble::deframe(indiv[q]), pattern = string_rem, replacement = "")
        
      )
      
    }
    
    suppressMessages(
      indiv <- indiv |>
        dplyr::left_join(data)
    )
    
    
    return(
      viz + 
        geom_bar(data = indiv,
                 width = 0.6,
                 stat = 'identity', fill = "#217DBB") +
        ggrepel::geom_text_repel(
          data = indiv,
          aes(label="Your School"),
          color = "black",
          size = size/2,
          angle = 270,
          family = font
        )
    )
    
  } else {
    
    return(viz)
    
  }
  
}

tableViz <- function(data, var, college = NULL, title = "Summary", subtitle = NULL, ...) {
  
  if(!missing(college)){
    labels <- c('N','Mean','Median','Max','Min', college)
  } else {
    labels <- c('N','Mean','Median','Max','Min')
  }
  
  variable <- tibble::deframe(data[var])
  
  N <- as.integer(sum(!is.na(variable)))
  Mean <- mean(variable, ...)
  Median <- median(variable, ...)
  Max <- max(variable, ...)
  Min <- min(variable, ...)
  
  if(!missing(college)){
    College <- data |> 
      dplyr::filter(`Institution Name` == college) |>
      dplyr::pull(.data[[var]])
    
    if(purrr::is_empty(College)) {
      College <- 0
    }
  }
  
  
  if(!missing(college)){
    stats <- c(N, Mean, Median, Max, Min, College)
  } else {
    stats <- c(N, Mean, Median, Max, Min)
  }
  
  
  return(
    data.frame(labels, stats) |>
      gt::gt() |>
      gt::tab_header(title = title, subtitle = subtitle) |>
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


# Service/Program Table

serviceTab <- function(data, q, title = "Title", subtitle = "Subtitle", offer) {
  
  if(missing(offer)) {
    warning("Offer missing. Enter program, service, conference, or other.")
  }
  
  q_n <- question_list[[q]] |>
    
    dplyr::filter(dplyr::if_any(.cols = !(1:2), .fns = ~ !is.na(.x))) |>
    
    nrow()
  
  tab <- data |>
    
    gt::gt() |>
    
    gt::tab_header(title = title,
                   subtitle = glue::glue("{subtitle} (n = {q_n})")
    ) |>
    gt::cols_label(value = offer,
                   n = "N",
                   freq = "Frequency") |>
    
    gt::fmt_number(
      columns = freq,
      pattern = "{x}%",
      n_sigfig = 2
    ) |>
    
    gt::cols_width(
      value ~ px(500)
    ) |>
    
    gt::cols_align(
      align = "center",
      columns = n:freq
    ) |>
    
    gt::tab_style(
      style = list(
        gt::cell_fill(color = "aliceblue")),
      locations = gt::cells_body(
        columns = dplyr::everything(),
        rows = as.numeric(row.names(data)) %% 2 == 0
      )
    ) |>
    
    gt::tab_style(
      style = list(
        gt::cell_text(weight = "bold")
      ),
      locations = gt::cells_column_labels(
        columns = everything()
      )
    ) |>
    
    gt::tab_style(
      style = list(
        gt::cell_text(style = "italic")
      ),
      locations = gt::cells_title(groups = "subtitle")
    )
  
  
  return(tab)
  
}






