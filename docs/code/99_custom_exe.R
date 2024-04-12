library(purrr)
library(glue)
library(stringr)
library(here)

# Load the data
load("lacn.RData")

# Extract the college names from the loaded data
colleges <- as.list(question_list$Q1$`Institution Name`)

# Define a function to render R Markdown and manage file connections
render_custom_template <- function(college) {
  # Define output file path based on college name
  output_file <- file.path(here::here(), "docs/custom", glue("{str_remove_all(college, '[:blank:]')}.html"))
  
  # Open file connection
  file_con <- file(output_file, "w")
  
  # Render R Markdown document
  rmarkdown::render(
    input = "docs/custom_template.Rmd",
    params = list(college = college),
    output_file = file_con,
    clean = TRUE  # Clean intermediate files after rendering
  )
  
  # Close file connection
  close(file_con)
}

# Use purrr::walk() to iterate through colleges and render R Markdown
purrr::walk(
  .x = colleges,
  ~ render_custom_template(.x)
)
