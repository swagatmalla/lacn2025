#### ------- LIST of dfs for each question ------- ####

# preallocate list vector
question_list <- vector(mode = "list", length = 28)


for(i in seq_len(nrow(question_type))) {
  
  question <- question_type$unique[i]
  
  current_question <- lacn_master |>
    dplyr::select(
      `Institution Name`, 
      `Undergraduate enrollment`, 
      dplyr::starts_with(question)
    ) |>
    dplyr::slice(-1)
  
  question_list[[i]] <- current_question
  
  remove(current_question, question, i)
}

names(question_list) <- question_type$unique

# clean questions 1, 2 and 3
#This is done because of the nature of starts_with(). For instance Q1 and Q10 are
#identified as same questions. Hence the cleaning. 

question_list$Q1 <- question_list$Q1[, 1:4]
question_list$Q2 <- question_list$Q2[, 1:4]
question_list$Q3 <- question_list$Q3[, 1:3] #technically not needed this year since there are only 25 questions. 



