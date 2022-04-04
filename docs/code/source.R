
# clear global env
rm(list = ls())

# specify code location in parent dir
code_location <- "~/piper analysis/lacn/code"

# source basic cleaning and set-up
source(file.path(code_location, "1_read_data.R"))
source(file.path(code_location, "2_clean.R"))
source(file.path(code_location, "3_functions.R"))
source(file.path(code_location, "4_analysis.R"))


# source viz set-up scripts
source(file.path(code_location, "viz_intro.R"))
source(file.path(code_location, "viz_reporting.R"))
source(file.path(code_location, "viz_engagement.R"))


# save global environment in project directory
save.image(file = "lacn.RData")
