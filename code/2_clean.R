#### ------- LIST of dfs for each question ------- ####

# preallocate list vector
question_list <- vector(mode = "list", length = 25)


for(i in seq_len(nrow(question_type))) {
  
  question <- question_type$unique[i]
  
  current_question <- lacn_master |>
    dplyr::select(
      `Institution Name`, 
      `Institution size category`, 
      dplyr::starts_with(question)
    ) |>
    dplyr::slice(-1)
  
  question_list[[i]] <- current_question
  
  remove(current_question, question, i)
}

names(question_list) <- question_type$unique

# clean questions 1, 2 and 3
question_list$Q1 <- question_list$Q1[, 1:4]
question_list$Q2 <- question_list$Q2[, 1:4]
question_list$Q3 <- question_list$Q3[, 1:3]



