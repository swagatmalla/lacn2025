LACN 2022 Survey
================

# File Structure

    ## Contents of lacn directory

    ## [1] "code"           "data"           "lacn_env.RData" "lacn.Rproj"    
    ## [5] "output"         "README.Rmd"

    ## 
    ## Files in code subdirectory

    ## [1] "analysis.R"       "clean.R"          "lacn_functions.R" "read_data.R"     
    ## [5] "viz.R"

    ## 
    ## Files in data subdirectory

    ## [1] "lacn_2022.csv"    "response_key.csv"

# Load Data

File: **read\_data.R**

The raw survey data (“lacn\_2022.csv”) resides in the data subdirectory
of the lacn folder. The first several lines of this script load this
data and remove several redundant rows.

Next, we specify the Gooogle Sheets spreadsheet we want to connect with
(this will come in handy a bit later).

The next task is creating a reference lookup table for all the
questions, their descriptions, and response descriptions. We will call
this our “Response Key.” First we create a somewhat messy version from
the raw data (**response\_key\_messy**). Then we send it over to Sheets
for some manual cleaning before bringing it back into R, now calling it
**response\_key**. This will be crucial for maintaining consistent
references throughout analysis and visualization.

Our final task in this initial section is creating a table of question
types. Some LACN questions are single-response, some are multi-choice
(more than one can be selected), some allow for a matrix of responses
per college, some a continuous numeric input, and one a ordinal ranking.
If we want to automate the cleaning and analysis of the survey
questions, we need to be able to separate out the single-response
questions from the matrix questions, etc. The **question\_type**
dataframe, built manually in Google Sheets and then imported into R.

Now we can move to analyzing each question on its own terms.

# Functions for Analysis

File: **lacn\_functions.R**

To get a sense for why the following custom functions are useful, let’s
inspect some of the raw data.

# Analysis

File: **analysis.R**

Now, we have a “list” object, which is a hierarchical structure
containing the cleaned and summarised data for each type of question
(single, multi, matrix, continuous, ranking). See the structure map
below to get a sense of how the final data is stored. It can look a bit
chaotic at first, but the basic idea is this: the master list contains
different question types, which each contain the relevant questions,
which each contain the actual variables and data for each summarised and
aggregated response.

    ## █ [1:0x5602a1a45a28] <named list> 
    ## ├─single = █ [2:0x5602a1a45b08] <named list> 
    ## │          ├─Q2 = █ [3:0x5602a2fbbf68] <tbl_df[,3]> 
    ## │          │      ├─Q2 = [4:0x5602a2fbbf18] <chr> 
    ## │          │      ├─n = [5:0x5602a26c3ca8] <int> 
    ## │          │      └─freq = [6:0x5602a2fbbe78] <dbl> 
    ## │          ├─Q3 = █ [7:0x5602a2fbbd88] <tbl_df[,3]> 
    ## │          │      ├─Q3 = [8:0x5602a26c3de8] <chr> 
    ## │          │      ├─n = [9:0x5602a27dd4a0] <int> 
    ## │          │      └─freq = [10:0x5602a26c4028] <dbl> 
    ## │          ├─Q12 = █ [11:0x5602a2fbbc98] <tbl_df[,3]> 
    ## │          │       ├─Q12 = [12:0x5602a2fbbc48] <chr> 
    ## │          │       ├─n = [13:0x5602a26c4128] <int> 
    ## │          │       └─freq = [14:0x5602a2fbbbf8] <dbl> 
    ## │          ├─Q14 = █ [15:0x5602a2fbb748] <tbl_df[,3]> 
    ## │          │       ├─Q14 = [16:0x5602a27dd548] <chr> 
    ## │          │       ├─n = [17:0x5602a27dd580] <int> 
    ## │          │       └─freq = [18:0x5602a27dd5b8] <dbl> 
    ## │          ├─Q16 = █ [19:0x5602a32b9848] <tbl_df[,3]> 
    ## │          │       ├─Q16 = [20:0x5602a27dd628] <chr> 
    ## │          │       ├─n = [21:0x5602a27dd660] <int> 
    ## │          │       └─freq = [22:0x5602a27dd698] <dbl> 
    ## │          └─Q25 = █ [23:0x5602a3308568] <tbl_df[,3]> 
    ## │                  ├─Q25 = [24:0x5602a27dd708] <chr> 
    ## │                  ├─n = [25:0x5602a27dd740] <int> 
    ## │                  └─freq = [26:0x5602a27dd778] <dbl> 
    ## ├─multi = █ [27:0x5602a1a45da8] <named list> 
    ## │         ├─Q4 = █ [28:0x5602a33f59d8] <tbl_df[,3]> 
    ## │         │      ├─value = [29:0x5602a26c41a8] <chr> 
    ## │         │      ├─n = [30:0x5602a27dd7e8] <int> 
    ## │         │      └─freq = [31:0x5602a26c42a8] <dbl> 
    ## │         ├─Q9 = █ [32:0x5602a33f5708] <tbl_df[,3]> 
    ## │         │      ├─value = [33:0x5602a1a46278] <chr> 
    ## │         │      ├─n = [34:0x5602a37b4e58] <int> 
    ## │         │      └─freq = [35:0x5602a1a462e8] <dbl> 
    ## │         ├─Q10 = █ [36:0x5602a3811c48] <tbl_df[,3]> 
    ## │         │       ├─value = [37:0x5602a1a46358] <chr> 
    ## │         │       ├─n = [38:0x5602a3811608] <int> 
    ## │         │       └─freq = [39:0x5602a1a463c8] <dbl> 
    ## │         ├─Q11 = █ [40:0x5602a3876a18] <tbl_df[,3]> 
    ## │         │       ├─value = [41:0x5602a11f5060] <chr> 
    ## │         │       ├─n = [42:0x5602a26094b8] <int> 
    ## │         │       └─freq = [43:0x5602a11d07c0] <dbl> 
    ## │         ├─Q13 = █ [44:0x5602a3a0edc8] <tbl_df[,3]> 
    ## │         │       ├─value = [45:0x5602a26c43a8] <chr> 
    ## │         │       ├─n = [46:0x5602a27dd900] <int> 
    ## │         │       └─freq = [47:0x5602a26c44e8] <dbl> 
    ## │         └─Q15 = █ [48:0x5602a3a68a98] <tbl_df[,3]> 
    ## │                 ├─value = [49:0x5602a3a688b8] <chr> 
    ## │                 ├─n = [50:0x5602a26c46e8] <int> 
    ## │                 └─freq = [51:0x5602a3aa09d8] <dbl> 
    ## ├─matrix = █ [52:0x5602a1a466d8] <named list> 
    ## │          ├─Q6 = █ [53:0x5602a30e16f8] <df[,4]> 
    ## │          │      ├─dim2 = [54:0x5602a26c47e8] <chr> 
    ## │          │      ├─Students in paraprofessional roles = [55:0x5602a26c4a28] <dbl> 
    ## │          │      ├─Students in administrative roles = [56:0x5602a26c4b28] <dbl> 
    ## │          │      └─Students in "hybrid" roles (e.g., student workers have both paraprofessional and administrative duties) = [57:0x5602a26c4ce8] <dbl> 
    ## │          ├─Q8 = █ [58:0x5602a25df3c8] <df[,15]> 
    ## │          │      ├─dim2 = [59:0x5602a3ca01c8] <chr> 
    ## │          │      ├─Student Counseling/Advising = [60:0x5602a3ca00d8] <dbl> 
    ## │          │      ├─Health Professions Advising = [61:0x5602a3c9fef8] <dbl> 
    ## │          │      ├─Alumni Counseling/Advising = [62:0x5602a3c9f1d8] <dbl> 
    ## │          │      ├─Fellowship Advising = [63:0x5602a3c0ad88] <dbl> 
    ## │          │      ├─Pre-Law Advising = [64:0x5602a2c943e8] <dbl> 
    ## │          │      ├─Program/Event Planning = [65:0x5602a2c93cb8] <dbl> 
    ## │          │      ├─Marketing/Communications = [66:0x5602a2c959f8] <dbl> 
    ## │          │      ├─Employer Relations = [67:0x5602a2c95598] <dbl> 
    ## │          │      ├─Internship Funding = [68:0x5602a31101b8] <dbl> 
    ## │          │      ├─Office Management/Front Desk = [69:0x5602a3110168] <dbl> 
    ## │          │      ├─Supervision of Professional Staff = [70:0x5602a3110118] <dbl> 
    ## │          │      ├─Budget Management = [71:0x5602a31100c8] <dbl> 
    ## │          │      ├─Technology Management = [72:0x5602a3110028] <dbl> 
    ## │          │      └─Assessment (Data, Outcomes, Program) = [73:0x5602a3bcaee8] <dbl> 
    ## │          ├─Q36 = █ [74:0x5602a1a177d8] <df[,7]> 
    ## │          │       ├─dim2 = [75:0x5602a26c51e8] <chr> 
    ## │          │       ├─Number of career fairs offered on-campus or only for students at your institution (not including grad/prof school fairs) = [76:0x5602a26a7f88] <dbl> 
    ## │          │       ├─Number of information sessions offered by employers (coordinated by your office) = [77:0x5602a26a8148] <dbl> 
    ## │          │       ├─Number of interviews conducted on-campus or virtual interviews coordinated by your office (total number, not unique students) *record interviews affiliated with consortia/off-campus events below = [78:0x5602a26a8348] <dbl> 
    ## │          │       ├─Number of interviews conducted through consortia/off-campus events (total number, not unique students) = [79:0x5602a26a8588] <dbl> 
    ## │          │       ├─Number of career "treks" (immersion trips lasting at least one day) = [80:0x5602a26a8708] <dbl> 
    ## │          │       └─Number of job shadows (total number, not unique students) = [81:0x5602a26a8808] <dbl> 
    ## │          ├─Q37 = █ [82:0x5602a1a178b8] <df[,5]> 
    ## │          │       ├─dim2 = [83:0x5602a26a8948] <chr> 
    ## │          │       ├─Number of employers who attended career fairs offered on-campus or only for students at your institution (not including graduate/professional school fairs) = [84:0x5602a26a8a88] <dbl> 
    ## │          │       ├─Number of employers who offered information sessions coordinated by your office = [85:0x5602a26a8bc8] <dbl> 
    ## │          │       ├─Number of employers who conducted interviews on-campus or virtual interviews coordinated by your office = [86:0x5602a26a8d08] <dbl> 
    ## │          │       └─Number of employers who conducted interviews through consortia/off-campus events = [87:0x5602a26a8e08] <dbl> 
    ## │          ├─Q20 = █ [88:0x5602a1a17b58] <df[,7]> 
    ## │          │       ├─dim2 = [89:0x5602a26a8f08] <chr> 
    ## │          │       ├─# appointments with first-year students by professional staff = [90:0x5602a26a9008] <dbl> 
    ## │          │       ├─# appointments with sophomore students by professional staff = [91:0x5602a26a9148] <dbl> 
    ## │          │       ├─# appointments with junior students by professional staff = [92:0x5602a26a9248] <dbl> 
    ## │          │       ├─# appointments with senior students by professional staff = [93:0x5602a26a9388] <dbl> 
    ## │          │       ├─TOTAL #  appointments with students by professional staff = [94:0x5602a26a9488] <dbl> 
    ## │          │       └─# appointments with alumni by professional staff = [95:0x5602a26a9588] <dbl> 
    ## │          ├─Q21 = █ [96:0x5602a1a18178] <df[,6]> 
    ## │          │       ├─dim2 = [97:0x5602a3bcada8] <chr> 
    ## │          │       ├─First-Year = [98:0x5602a3bc9f48] <dbl> 
    ## │          │       ├─Sophomore = [99:0x5602a3bc9db8] <dbl> 
    ## │          │       ├─Junior = [100:0x5602a3bc9ae8] <dbl> 
    ## │          │       ├─Senior = [101:0x5602a36369a8] <dbl> 
    ## │          │       └─TOTAL (all classes) = [102:0x5602a36363b8] <dbl> 
    ## │          └─Q24 = █ [103:0x5602a3537af8] <df[,4]> 
    ## │                  ├─dim2 = [104:0x5602a35376e8] <chr> 
    ## │                  ├─Income from endowed funds = [105:0x5602a2d8f238] <dbl> 
    ## │                  ├─Expendable gifts = [106:0x5602a2d8f008] <dbl> 
    ## │                  └─Other = [107:0x5602a2d8ef18] <dbl> 
    ## ├─continuous = █ [108:0x5602a2d8ea68] <named list> 
    ## │              ├─Q7 = █ [109:0x5602a26a9688] <tbl_df[,2]> 
    ## │              │      ├─dim2 = [110:0x5602a1a18b88] <chr> 
    ## │              │      └─mean = [111:0x5602a1a18f78] <dbl> 
    ## │              ├─Q19 = █ [112:0x5602a26a98c8] <tbl_df[,2]> 
    ## │              │       ├─dim1 = [113:0x5602a2d8e6f8] <chr> 
    ## │              │       └─mean = [114:0x5602a2d8e2e8] <dbl> 
    ## │              ├─Q22 = █ [115:0x5602a26a9b08] <tbl_df[,2]> 
    ## │              │       ├─dim1 = [116:0x5602a1a193d8] <chr> 
    ## │              │       └─mean = [117:0x5602a1a19448] <dbl> 
    ## │              └─Q23 = █ [118:0x5602a2649718] <tbl_df[,2]> 
    ## │                      ├─dim1 = [119:0x5602a2d8dca8] <chr> 
    ## │                      └─mean = [120:0x5602a3c44008] <dbl> 
    ## └─ranking = █ [121:0x5602a27ddd98] <named list> 
    ##             └─Q5 = █ [122:0x5602a3c43ba8] <tbl_df[,3]> 
    ##                    ├─Question = [123:0x5602a25c05d8] <chr> 
    ##                    ├─dim1 = [124:0x5602a25c09f8] <chr> 
    ##                    └─ranking_avg = [125:0x5602a25c10d8] <dbl>

Let’s say you wanted to investigate conference attendance rates (Q9).
You would note that Q9 is a multi-response question:

``` r
question_type |> dplyr::filter(unique=="Q9")
```

    ## # A tibble: 1 × 3
    ##   unique q_type Notes                        
    ##   <chr>  <chr>  <chr>                        
    ## 1 Q9     multi  Conferences attended by staff

Next, you would key into the master list in the following order: master
list –&gt; question type –&gt; question. The ‘$’ in the code below are
how R digs into a deeper level of some object, like a list or a
dataframe. Think of it as opening a door into an inner room of a house.

``` r
all_list$multi$Q9
```

    ## # A tibble: 7 × 3
    ##   value                                                                  n  freq
    ##   <chr>                                                              <int> <dbl>
    ## 1 Health Professions Advising (e.g., National Association of Adviso…     2   0.4
    ## 2 National Association of Colleges & Employers (NACE)                    5   1  
    ## 3 National Career Development Association (NCDA)                         2   0.4
    ## 4 National Society for Experiential Education (NSEE)                     1   0.2
    ## 5 Pre-Law Advising (e.g., NAPLA)                                         2   0.4
    ## 6 Regional Associations of Colleges & Employers (e.g., EACE, SWACE)      2   0.4
    ## 7 Small College Career Alliance (SCCA)                                   4   0.8

# Visualization

File: **lacn\_viz.R**
