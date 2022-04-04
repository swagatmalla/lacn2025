
#### Student Engagement by Class Year ####


## See sengage-year-plot code chunk

sengage_year_data <- question_list$Q21 |>
  tidyr::pivot_longer(
    cols = !(1:2),
    names_to = c('main','sub1','sub2'),
    values_to = "engage",
    names_sep = "_"
  ) |>
  dplyr::filter(sub2==4) |>
  dplyr::mutate(Question = paste(main,sub1,sub2, sep = "_")) |>
  dplyr::left_join(
    keyFunction('Q21',dim1)
  ) |>
  dplyr::select(!c(main:sub2,Question))  |>
  dplyr::mutate(across(`Undergraduate enrollment`:engage, as.numeric)) |>
  dplyr::group_by(dim1) |>
  dplyr::summarise(Mean = mean(engage), 
                   Median = median(engage),
                   Max = max(engage),
                   #`Your School` = mean(engage[`Institution Name`==params$college])
  ) |>
  dplyr::mutate(dim1 = stringr::str_replace(dim1, regex("TOTAL"),"Total\n")) |>
  tidyr::pivot_longer(
    cols = !dim1,
    names_to = "measure",
    values_to = "engage"
  ) |>
  
  dplyr::mutate(dim1 = factor(dim1, levels = c(
    "First-Year",
    "Sophomore",
    "Junior",
    "Senior",
    "Total\n (all classes)"
  )
  )
  )



#### Student Engagement by Type ####

sengage_type_data <- question_list$Q21 |>
  tidyr::pivot_longer(
    cols = !(1:2),
    names_to = c('main','sub1','sub2'),
    values_to = "engage",
    names_sep = "_"
  ) |>
  dplyr::mutate(Question = paste(main,sub1,sub2, sep = "_")) |>
  dplyr::left_join(
    keyFunction('Q21',dim2)
  )




#### Appt w/ Student (dist) ####


appt_student_data <- question_list$Q20 |>
  
  #initial matrix cleaning
  tidyr::pivot_longer(
    cols = !(1:2),
    names_to = c('main','sub1','sub2'),
    values_to = "engage",
    names_sep = "_"
  ) |>
  dplyr::mutate(Question = paste(main,sub1,sub2, sep = "_")) |>
  dplyr::left_join(
    keyFunction('Q20',dim1, dim2)
  ) |> 
  
  # mutate strings and engage chr to num
  dplyr::mutate(Year = stringr::str_to_title(
    stringr::str_extract(dim1,"(?<=with[:blank:]).+(?=[:blank:]by)")
  )
  )|>
  dplyr::mutate(Year = stringr::str_replace(Year, 
                                            "(?<![:blank:])Students", 
                                            "Total (all classes)")) |>
  dplyr::mutate(Year = stringr::str_remove(Year, "[:blank:]Students")) |>
  
  #filter out alum and total
  dplyr::filter(Year != "Alumni" & Year != "Total (all classes)") |>
  
  dplyr::mutate(Year = factor(Year, levels = c(
    "First-Year",
    "Sophomore",
    "Junior",
    "Senior")
  )
  ) |>
  dplyr::mutate(engage = as.numeric(engage)) |>
  
  
  # group and summarise total appts at each college by year
  dplyr::group_by(`Institution Name`, Year) |>
  dplyr::summarise(Appt = sum(engage))


# stacked bar chart (see appt-student-dist-plot code chunk)

# specify hline breaks
seq <- c(0, 
         ceiling((max(appt_student_data$Appt)*4)/3), 
         ceiling((2/3)*max(appt_student_data$Appt)*4), 
         ceiling(max(appt_student_data$Appt)*4)
)






#### Appt Alumni ####

appt_alum_data <- question_list$Q20 |>
  
  #initial matrix cleaning
  tidyr::pivot_longer(
    cols = !(1:2),
    names_to = c('main','sub1','sub2'),
    values_to = "engage",
    names_sep = "_"
  ) |>
  dplyr::mutate(Question = paste(main,sub1,sub2, sep = "_")) |>
  dplyr::left_join(
    keyFunction('Q20',dim1, dim2)
  ) |> 
  
  # mutate strings and engage chr to num
  dplyr::mutate(Year = stringr::str_to_title(
    stringr::str_extract(dim1,"(?<=with[:blank:]).+(?=[:blank:]by)")))|>
  
  dplyr::mutate(Year = stringr::str_replace(Year, 
                                            "(?<![:blank:])Students", 
                                            "Total (all classes)")) |>
  dplyr::mutate(Year = stringr::str_remove(Year, "[:blank:]Students")) |>
  
  dplyr::mutate(dim2 = stringr::str_to_title(
    stringr::str_remove(dim2, "Total # of[:blank:]"))
  )|>
  
  dplyr::mutate(dim2 = stringr::str_replace(dim2, "[:blank:]\\(In-Person, Phone, Video Chat\\)","\\*")) |>
  
  dplyr::mutate(engage = as.numeric(engage)) |>
  
  #filter to only alumni
  dplyr::filter(Year == "Alumni")



#### Prof Staff Appts + Emails per FTE ####



appt_fte_data <- question_list$Q20 |> 
  tidyr::pivot_longer(
    cols = !(1:2),
    names_to = "Question",
    values_to = "Appt"
  ) |>
  dplyr::mutate(Appt = as.numeric(Appt)) |>
  
  dplyr::group_by(`Institution Name`) |>
  dplyr::summarise(Appt = sum(Appt)) |>
  
  dplyr::left_join(prof_staff_data) |>
  
  dplyr::mutate(ratio = Appt/n)
  


  
