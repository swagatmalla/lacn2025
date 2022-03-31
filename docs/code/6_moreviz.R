

colleges <- question_list$Q1$`Institution Name`

current_college <- colleges[2]

q <- "Q24"
{
key <- keyFunction(q, dim1,dim2)

indiv <- question_list[[q]] |>
  filter(`Institution Name` == current_college)|>
  tidyr::pivot_longer(
    cols = !(1:2),
    names_to = "Question",
    values_to = "response"
  ) |>
  left_join(key) |>
  mutate(response = as.numeric(response)) |>
  group_by(`Institution Name`) |>
  dplyr::summarise(n = sum(response, na.rm = TRUE))

plot_title <- response_key |>
  dplyr::filter(main == q) |>
  dplyr::select(Description_short) |>
  unique() |>
  tibble::deframe()

full <- question_list[[q]] |>
  tidyr::pivot_longer(
    cols = !(1:2),
    names_to = "Question",
    values_to = "response"
  ) |>
  left_join(key) |>
  mutate(response = as.numeric(response)) |>
  group_by(`Institution Name`) |>
  dplyr::summarise(n = sum(response, na.rm = TRUE))

max <- plyr::round_any(max(full$n), 10, f = ceiling)
by <- round_any(max/5, 10, f = ceiling)
seq <- seq(0, max, by = by)


ggplot(data = full, mapping = aes(reorder(`Institution Name`,n),n))+
  geom_hline(yintercept = seq, colour = "grey")+
  scale_y_continuous(breaks = seq)+
  geom_bar(stat = 'identity')+
  geom_bar(data = indiv, stat = 'identity', fill = "deepskyblue2")+
  geom_label(data = indiv, aes(label = `Institution Name`))+
  labs(
    title = plot_title,
    x = NULL,
    y = "Total"
  )+
    theme(
      axis.text.x = element_blank(),
      #axis.ticks = element_blank(),
      panel.background = element_blank(),
      plot.margin = unit(c(1,1,1,1), "cm")
    )
}












para <- example |>
  filter(stringr::str_detect(dim1, pattern = "paraprofessional"))



