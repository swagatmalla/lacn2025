load("lacn.RData")

colleges <- as.list(question_list$Q1$`Institution Name`)[36:40]

purrr::walk(
  .x = colleges,
  ~ rmarkdown::render(
    input = "docs/custom_template.Rmd",
    params = list(college = {.x}),
    output_file = file.path(here::here(),"docs/custom",glue::glue("{str_remove_all(.x,\"[:blank:]\")}.html")),
    clean = TRUE
  ) 
)

