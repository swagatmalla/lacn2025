load("lacn.RData")

# Extract and subset college names
colleges <- as.list(question_list$Q1$`Institution Name`)
colleges <- colleges[37:length(colleges)]

# Define a function to sanitize college names (remove all whitespace)
remove_whitespace <- function(x) gsub("\\s+", "", x)

# Get the working directory (similar to here::here())
output_dir <- file.path(getwd(), "docs", "custom")

# Loop through colleges and render Rmd
for (college in colleges) {
  output_file <- file.path(
    output_dir,
    paste0(remove_whitespace(college), ".html")
  )
  
  rmarkdown::render(
    input = "docs/custom_template.Rmd",
    params = list(college = college),
    output_file = output_file,
    clean = TRUE
  )
}

