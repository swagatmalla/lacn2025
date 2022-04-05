library(tidyverse)

#### Enrollment Plot ####

enroll_data <- question_list$Q1 |>
  select(1:2) |>
  mutate(enroll = as.numeric(`Undergraduate enrollment`))

enrollPlot <- function(data = enroll_data, college = NULL, title = NULL) {
  
  enroll_viz <- enroll_data |>
    ggplot(mapping = aes(reorder(`Institution Name`,enroll), enroll))+
    geom_hline(yintercept = c(0,1000,2000,3000,4000), 
               colour = 'grey')+
    geom_bar(stat="identity", fill = "#7CBCE8")+
    labs(
      title = title,
      x = NULL,
      y = "Total"
    )+
    theme(
      axis.text.x = element_blank(),
      axis.ticks = element_blank(),
      panel.background = element_blank(),
      plot.margin = unit(c(1,1,1,1), "cm"),
      text = element_text(size = 15)
    )
  
  if(!missing(college)) {
    return(enroll_viz + 
             geom_bar(data = subset(enroll_data, `Institution Name` == college),
                      stat = 'identity', fill = "#217DBB") +
             ggrepel::geom_text_repel(
               data = subset(
                 enroll_data,
                 `Institution Name` == college
               ),
               aes(
                 label=`Institution Name`
               ),
               nudge_y=500,
               color = "black",
               size = 5
             )
             
           )
  } else {
    return(enroll_viz)
  }
  
  
}

#### Endowment Plot ####


endow_data <- lacn_master |>
  dplyr::select(
    `Institution Name`, 
    `Value of endowment assets`) |>
  dplyr::slice(-1) |>
  mutate(endow = as.numeric(`Value of endowment assets`)) |>
  mutate(endow_bil = endow/1e+09)


endowPlot <- function(data = endow_data, college = NULL, title = NULL) {

  
  endow_viz <- endow_data |>
    ggplot(mapping = aes(reorder(`Institution Name`,endow_bil), endow_bil))+
    geom_hline(yintercept = c(0,1,2,3), colour = "grey")+
    geom_bar(stat="identity", fill = "#7CBCE8")+
    labs(
      title = title,
      x = NULL,
      y = "Total (in billions)"
    )+
    theme(
      axis.text.x = element_blank(),
      axis.ticks = element_blank(),
      panel.background = element_blank(),
      text = element_text(size = 15)
    )
  
  if(!missing(college)){
    return(endow_viz + 
             geom_bar(data = subset(endow_data, `Institution Name` == college),
                      stat = 'identity', fill = "#217DBB") +
             geom_label(data = subset(endow_data, `Institution Name` == college), 
                        aes(label = `Institution Name`))
    )
  } else {
    return(endow_viz)
  }
  
  
}

