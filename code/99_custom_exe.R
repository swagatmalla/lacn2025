load("lacn.RData")

colleges <- as.list(question_list$Q1$`Institution Name`)[2:3]

purrr::walk(
  .x = colleges,
  ~ rmarkdown::render(
    input = "docs/custom_template.Rmd",
    output_file = file.path(here::here(),"docs/custom",glue::glue("{str_remove_all(.x,\"[:blank:]\")}.html")),
    params = list(college = {.x})
  )
)


