

# select college to compare against averages
colleges <- question_list$Q1$`Institution Name`

current_college <- colleges[2]



#### single viz ####

n <- 2
{
  
  q <- paste0('Q',n)
  
  
  single_data <- all_list[['single']][[q]]
  
  ggplot(data = single_data, mapping = aes(.data[[names(single_data)[1]]], freq))+
    geom_bar(stat = 'identity', width = rel(0.5))+
    labs(
      x = tibble::deframe(unique(response_key[response_key$main == q, 'Description_short'])),
      y = "Frequency"
    )+
    piperr::theme_piper()
  
}



#### multi viz ####
multi_q <- 'Q10'
{
  multi_data <- all_list$multi[[multi_q]]
  
  multi_title <- response_key |>
    dplyr::filter(main == multi_q) |>
    dplyr::select(Description_short) |>
    unique() |>
    tibble::deframe()
  
  
  ggplot(data = multi_data, mapping = aes(reorder(value, freq), freq))+
    geom_bar(stat = 'identity', width = rel(0.5))+
    labs(
      title = multi_title,
      x = NULL,
      y = "Frequency"
    ) +
    scale_x_discrete(labels = function(x) stringr::str_wrap(x, width = 25))+
    ggplot2::coord_flip()+
    piperr::theme_piper()
  
  }


#### matrix viz ####
matrix_q <- "Q6"

{
matrix_data <- all_list$matrix[[matrix_q]]

matrix_title <- response_key |>
  dplyr::filter(main == matrix_q) |>
  dplyr::select(Description_short) |>
  unique() |>
  tibble::deframe()

matrix_data |>
  tidyr::pivot_longer(
    cols = !dim2,
    names_to = "response",
    values_to = "mean") |>
  ggplot2::ggplot(mapping = aes(response,mean))+
  geom_bar(aes(fill = dim2),
           position = "dodge",
           stat = "identity")+
  scale_x_discrete(labels = function(x) stringr::str_wrap(x, width = 17.5))+
  labs(
    title = matrix_title,
    x = NULL
  )+

  piperr::theme_piper()

}
  




#### ranked viz ####

{
indiv <- question_list$Q5 |>
  filter(`Institution Name` == current_college) |>
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
    title = paste0("Top Priorities: ", current_college, " v. Average"),
    y = NULL,
    x = "Importance to Senior Staff \n(1=highest)"
  )+
  theme(
    axis.ticks.y = element_blank(),
    panel.background = element_blank(),
    plot.margin = unit(c(1,1,1,1), "cm")
  )

ggsave("rank_plot.PNG", path = "output", width = 7.5, height = 5, units = "in")
}




View(question_list$Q6)
all_list$matrix$Q6



