library(tidyverse)



#### Enrollment Plot ####

enroll_title <- "Undergraduate Enrollment"

enroll_data <- question_list$Q1 |>
  select(1:2) |>
  mutate(enroll = as.numeric(`Undergraduate enrollment`))

enroll_viz <- enroll_data |>
  ggplot(mapping = aes(reorder(`Institution Name`,enroll), enroll))+
  geom_hline(yintercept = c(0,1000,2000,3000,4000), colour = "grey")+
  geom_bar(stat="identity")+
  labs(
  title = enroll_title,
  x = NULL,
  y = "Total"
)+
  theme(
    axis.text.x = element_blank(),
    axis.ticks = element_blank(),
    panel.background = element_blank(),
    plot.margin = unit(c(1,1,1,1), "cm")
  )


#### Enrollment Table ####

enroll_table <- tableViz(enroll_data,"enroll")





#### Endowment Plot ####

endow_title <- "Endowment"

endow_data <- lacn_master |>
  dplyr::select(
    `Institution Name`, 
    `Value of endowment assets`) |>
  dplyr::slice(-1) |>
  mutate(endow = as.numeric(`Value of endowment assets`)) |>
  mutate(endow_bil = endow/1e+09)

endow_viz <- endow_data |>
  ggplot(mapping = aes(reorder(`Institution Name`,endow_bil), endow_bil))+
  geom_hline(yintercept = c(0,1,2,3), colour = "grey")+
  geom_bar(stat="identity")+
  labs(
    title = endow_title,
    x = NULL,
    y = "Total (in billions)"
  )+
  theme(
    axis.text.x = element_blank(),
    axis.ticks = element_blank(),
    panel.background = element_blank(),
    #plot.margin = unit(c(1,1,1,1), "cm")
  )


#### Endowment Table ####

endow_table <- tableViz(endow_data, "endow")



