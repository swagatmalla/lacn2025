code_location <- "~/piper analysis/lacn/code"


source(file.path(code_location, "1_read_data.R"))
source(file.path(code_location, "2_clean.R"))
source(file.path(code_location, "3_functions.R"))
source(file.path(code_location, "4_analysis.R"))


source(file.path(code_location, "viz_intro.R"))
source(file.path(code_location, "viz_reporting.R"))

# save global environment in project directory
save.image(file = "lacn.RData")
