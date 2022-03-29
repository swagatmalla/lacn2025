lacn_dir <- "~/piper analysis/lacn/code"
source(file.path(lacn_dir, "read_data.R"))
source(file.path(lacn_dir, "lacn_functions.R"))



#### -------- ANALYZE responses ----- ####


all_questions <- unique(question_type$q_type)[c(2,3,5,6)]

all_list <- map(all_questions,
                ~ analyze_function(
                  .x
                )
)

names(all_list) <- all_questions


#### Rank - summarise ####

rank_questions <- select_function("ranking")

rank_key <- key_function(rank_questions, dim1) |>
  dplyr::slice(-12)

rank_list <- question_list$Q5 |>
  dplyr::mutate_at(vars(Q5_6:Q5_13), as.numeric) |>
  dplyr::summarise_at(
    dplyr::vars(Q5_6:Q5_13),
    mean,
    na.rm = TRUE
  ) |>
  tidyr::pivot_longer(
    cols = everything(),
    names_to = "Question",
    values_to = "ranking_avg"
  ) |>
  dplyr::left_join(rank_key)|>
  dplyr::relocate(dim1, .before = ranking_avg)

ranking <- list('Q5' = rank_list)

all_list[['ranking']] <- ranking


# save global environment in project directory
save.image(file = "lacn.RData")
