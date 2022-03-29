LACN 2022 Survey
================

This document walks you through the structure, purpose, and output of
this repository. All scripts can be found in the **code** directory.

# File Structure

    ## Contents of lacn directory

    ## [1] "code"       "data"       "lacn.RData" "lacn.Rproj" "output"    
    ## [6] "README.md"  "README.Rmd"

    ## 
    ## Files in code subdirectory

    ## [1] "1_read_data.R" "2_clean.R"     "3_functions.R" "4_analysis.R" 
    ## [5] "5_viz.R"

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

    ## Reference Lookup Table:

    ##   Question main sub1 sub2
    ## 1     Q1_1   Q1    1 <NA>
    ## 2     Q1_2   Q1    2 <NA>
    ## 3       Q2   Q2 <NA> <NA>
    ##                                                                                            Description
    ## 1 On behalf of the LACN Benchmarking Committee, thank you for taking the time to complete this requ...
    ## 2 On behalf of the LACN Benchmarking Committee, thank you for taking the time to complete this requ...
    ## 3                                                                               To whom do you report?
    ##        Description_short                                  dim1 dim2
    ## 1                   <NA> Name of person completing this survey <NA>
    ## 2                   <NA>                           Institution <NA>
    ## 3 To whom do you report?                       Selected Choice <NA>

Our final task in this initial section is creating a table of question
types. Some LACN questions are single-response, some are multi-choice
(more than one can be selected), some allow for a matrix of responses
per college, some a continuous numeric input, and one a ordinal ranking.
If we want to automate the cleaning and analysis of the survey
questions, we need to be able to separate out the single-response
questions from the matrix questions, etc. The **question\_type**
dataframe, built manually in Google Sheets and then imported into R.

Now we can move to analyzing each question on its own terms.

# Cleaning

File: **clean.R**

One of the challenges with this data is how *wide* it is. The raw survey
dataframe contains 257 variables. If we want to speed up our analysis,
we need to break the dataset up by question. That way, when we want to
analyze Q8, we can simply handle the Q8 dataset without having to sift
through the entire 257-column raw dataset.

**clean.R** loops through each question and extracts its columns from
the master dataset, along with the name of each respondent and their
size category, following Lauren’s style last year. We then deposit each
of those question-specific dataframes (specified as
**current\_question** in the for loop) into a “list,” which is an object
capable of containing other objects (like dataframes) within it. Now, we
have a nice portable object we can manipulation, explore, and use in
later analysis. Without this list, we would have to repeat ourselves
every time we wanted to extract a single question and analyze it.

Below is a representation of the structure of that list (called
**question\_list**). As you can see, **question\_list**, represented by
the top-most black rectangle, contains within it

    ## █ [1:0x56007c656bb0] <named list> 
    ## ├─Q1 = █ [2:0x56007eed5628] <tbl_df[,4]> 
    ## │      ├─Institution Name = [3:0x56007eed8598] <chr> 
    ## │      ├─Institution size category = [4:0x56007eed8528] <chr> 
    ## │      ├─Q1_1 = [5:0x56007eed84b8] <chr> 
    ## │      └─Q1_2 = [6:0x56007eed8448] <chr> 
    ## ├─Q2 = █ [7:0x56007eed52b8] <tbl_df[,4]> 
    ## │      ├─Institution Name = [8:0x56007eed83d8] <chr> 
    ## │      ├─Institution size category = [9:0x56007eed8368] <chr> 
    ## │      ├─Q2 = [10:0x56007eed82f8] <chr> 
    ## │      └─Q2_6_TEXT = [11:0x56007eed8288] <chr> 
    ## ├─Q3 = █ [12:0x56007eeea1b8] <tbl_df[,3]> 
    ## │      ├─Institution Name = [13:0x56007eed8218] <chr> 
    ## │      ├─Institution size category = [14:0x56007eed81a8] <chr> 
    ## │      └─Q3 = [15:0x56007eed8138] <chr> 
    ## ├─Q4 = █ [16:0x56007eee7cb8] <tbl_df[,11]> 
    ## │      ├─Institution Name = [17:0x56007eed80c8] <chr> 
    ## │      ├─Institution size category = [18:0x56007eed8058] <chr> 
    ## │      ├─Q4_3 = [19:0x56007eed7fe8] <chr> 
    ## │      ├─Q4_4 = [20:0x56007eed7f78] <chr> 
    ## │      ├─Q4_5 = [21:0x56007eed7f08] <chr> 
    ## │      ├─Q4_6 = [22:0x56007eed7e98] <chr> 
    ## │      ├─Q4_7 = [23:0x56007eed7e28] <chr> 
    ## │      ├─Q4_8 = [24:0x56007eed7db8] <chr> 
    ## │      ├─Q4_9 = [25:0x56007eed7d48] <chr> 
    ## │      ├─Q4_10 = [26:0x56007eed7cd8] <chr> 
    ## │      └─Q4_9_TEXT = [27:0x56007eed7c68] <chr> 
    ## ├─Q5 = █ [28:0x56007eee7b58] <tbl_df[,14]> 
    ## │      ├─Institution Name = [29:0x56007eed7bf8] <chr> 
    ## │      ├─Institution size category = [30:0x56007eed7b88] <chr> 
    ## │      ├─Q5_6 = [31:0x56007eed7b18] <chr> 
    ## │      ├─Q5_7 = [32:0x56007eed7aa8] <chr> 
    ## │      ├─Q5_8 = [33:0x56007eed7a38] <chr> 
    ## │      ├─Q5_9 = [34:0x56007eed79c8] <chr> 
    ## │      ├─Q5_10 = [35:0x56007eed7958] <chr> 
    ## │      ├─Q5_15 = [36:0x56007eed78e8] <chr> 
    ## │      ├─Q5_1 = [37:0x56007eed7878] <chr> 
    ## │      ├─Q5_16 = [38:0x56007eed7808] <chr> 
    ## │      ├─Q5_11 = [39:0x56007eed7798] <chr> 
    ## │      ├─Q5_12 = [40:0x56007eed7728] <chr> 
    ## │      ├─Q5_13 = [41:0x56007eed76b8] <chr> 
    ## │      └─Q5_13_TEXT = [42:0x56007eed7648] <chr> 
    ## ├─Q6 = █ [43:0x56007eed75d8] <tbl_df[,8]> 
    ## │      ├─Institution Name = [44:0x56007eed7568] <chr> 
    ## │      ├─Institution size category = [45:0x56007eed74f8] <chr> 
    ## │      ├─Q6_1_1 = [46:0x56007eed7488] <chr> 
    ## │      ├─Q6_1_2 = [47:0x56007eed7418] <chr> 
    ## │      ├─Q6_2_1 = [48:0x56007eed73a8] <chr> 
    ## │      ├─Q6_2_2 = [49:0x56007eed7338] <chr> 
    ## │      ├─Q6_3_1 = [50:0x56007eed72c8] <chr> 
    ## │      └─Q6_3_2 = [51:0x56007eed7258] <chr> 
    ## ├─Q7 = █ [52:0x56007eed7178] <tbl_df[,8]> 
    ## │      ├─Institution Name = [53:0x56007eed7108] <chr> 
    ## │      ├─Institution size category = [54:0x56007eed7098] <chr> 
    ## │      ├─Q7_1_9 = [55:0x56007eeec0d8] <chr> 
    ## │      ├─Q7_1_2 = [56:0x56007eeec068] <chr> 
    ## │      ├─Q7_1_3 = [57:0x56007eeebff8] <chr> 
    ## │      ├─Q7_1_4 = [58:0x56007eeebf88] <chr> 
    ## │      ├─Q7_1_5 = [59:0x56007eeebf18] <chr> 
    ## │      └─Q7_1_10 = [60:0x56007eeebea8] <chr> 
    ## ├─Q8 = █ [61:0x56007c656cb0] <tbl_df[,44]> 
    ## │      ├─Institution Name = [62:0x56007eeebdc8] <chr> 
    ## │      ├─Institution size category = [63:0x56007eeebd58] <chr> 
    ## │      ├─Q8_1_1 = [64:0x56007eeebce8] <chr> 
    ## │      ├─Q8_1_2 = [65:0x56007eeebc78] <chr> 
    ## │      ├─Q8_1_3 = [66:0x56007eeebc08] <chr> 
    ## │      ├─Q8_2_1 = [67:0x56007eeebb98] <chr> 
    ## │      ├─Q8_2_2 = [68:0x56007eeebb28] <chr> 
    ## │      ├─Q8_2_3 = [69:0x56007eeebab8] <chr> 
    ## │      ├─Q8_3_1 = [70:0x56007eeeba48] <chr> 
    ## │      ├─Q8_3_2 = [71:0x56007eeeb9d8] <chr> 
    ## │      ├─Q8_3_3 = [72:0x56007eeeb968] <chr> 
    ## │      ├─Q8_4_1 = [73:0x56007eeeb8f8] <chr> 
    ## │      ├─Q8_4_2 = [74:0x56007eeeb888] <chr> 
    ## │      ├─Q8_4_3 = [75:0x56007eeeb818] <chr> 
    ## │      ├─Q8_5_1 = [76:0x56007eeeb7a8] <chr> 
    ## │      ├─Q8_5_2 = [77:0x56007eeeb738] <chr> 
    ## │      ├─Q8_5_3 = [78:0x56007eeeb6c8] <chr> 
    ## │      ├─Q8_6_1 = [79:0x56007eeeb658] <chr> 
    ## │      ├─Q8_6_2 = [80:0x56007eeeb5e8] <chr> 
    ## │      ├─Q8_6_3 = [81:0x56007eeeb578] <chr> 
    ## │      ├─Q8_7_1 = [82:0x56007eeeb508] <chr> 
    ## │      ├─Q8_7_2 = [83:0x56007eeeb498] <chr> 
    ## │      ├─Q8_7_3 = [84:0x56007eeeb428] <chr> 
    ## │      ├─Q8_8_1 = [85:0x56007eeeb3b8] <chr> 
    ## │      ├─Q8_8_2 = [86:0x56007eeeb348] <chr> 
    ## │      ├─Q8_8_3 = [87:0x56007eeeb2d8] <chr> 
    ## │      ├─Q8_9_1 = [88:0x56007eeeb268] <chr> 
    ## │      ├─Q8_9_2 = [89:0x56007eeeb1f8] <chr> 
    ## │      ├─Q8_9_3 = [90:0x56007eeeb188] <chr> 
    ## │      ├─Q8_10_1 = [91:0x56007eeeb118] <chr> 
    ## │      ├─Q8_10_2 = [92:0x56007eeeb0a8] <chr> 
    ## │      ├─Q8_10_3 = [93:0x56007eeeb038] <chr> 
    ## │      ├─Q8_11_1 = [94:0x56007eeeafc8] <chr> 
    ## │      ├─Q8_11_2 = [95:0x56007eeeaf58] <chr> 
    ## │      ├─Q8_11_3 = [96:0x56007eeeaee8] <chr> 
    ## │      ├─Q8_12_1 = [97:0x56007eeeae78] <chr> 
    ## │      ├─Q8_12_2 = [98:0x56007eeeae08] <chr> 
    ## │      ├─Q8_12_3 = [99:0x56007eeead98] <chr> 
    ## │      ├─Q8_13_1 = [100:0x56007eeead28] <chr> 
    ## │      ├─Q8_13_2 = [101:0x56007eeeacb8] <chr> 
    ## │      ├─Q8_13_3 = [102:0x56007eeeac48] <chr> 
    ## │      ├─Q8_14_1 = [103:0x56007eeeabd8] <chr> 
    ## │      ├─Q8_14_2 = [104:0x56007eeeab68] <chr> 
    ## │      └─Q8_14_3 = [105:0x56007eeeaaf8] <chr> 
    ## ├─Q9 = █ [106:0x56007eee79f8] <tbl_df[,14]> 
    ## │      ├─Institution Name = [107:0x56007eeeaa88] <chr> 
    ## │      ├─Institution size category = [108:0x56007eeeaa18] <chr> 
    ## │      ├─Q9_1 = [109:0x56007eeea9a8] <chr> 
    ## │      ├─Q9_2 = [110:0x56007eeea938] <chr> 
    ## │      ├─Q9_3 = [111:0x56007eeea8c8] <chr> 
    ## │      ├─Q9_4 = [112:0x56007eeea858] <chr> 
    ## │      ├─Q9_5 = [113:0x56007eeea7e8] <chr> 
    ## │      ├─Q9_6 = [114:0x56007eeea778] <chr> 
    ## │      ├─Q9_7 = [115:0x56007eeea708] <chr> 
    ## │      ├─Q9_8 = [116:0x56007eeea698] <chr> 
    ## │      ├─Q9_9 = [117:0x56007eeea628] <chr> 
    ## │      ├─Q9_10 = [118:0x56007eeea5b8] <chr> 
    ## │      ├─Q9_11 = [119:0x56007eeea548] <chr> 
    ## │      └─Q9_11_TEXT = [120:0x56007eeea4d8] <chr> 
    ## ├─Q10 = █ [121:0x56007eee7898] <tbl_df[,14]> 
    ## │       ├─Institution Name = [122:0x56007eeea468] <chr> 
    ## │       ├─Institution size category = [123:0x56007eeea3f8] <chr> 
    ## │       ├─Q10_1 = [124:0x56007eeea388] <chr> 
    ## │       ├─Q10_3 = [125:0x56007eeea318] <chr> 
    ## │       ├─Q10_4 = [126:0x56007eeea2a8] <chr> 
    ## │       ├─Q10_5 = [127:0x56007eeea238] <chr> 
    ## │       ├─Q10_6 = [128:0x56007eeedff8] <chr> 
    ## │       ├─Q10_7 = [129:0x56007eeedf88] <chr> 
    ## │       ├─Q10_8 = [130:0x56007eeedf18] <chr> 
    ## │       ├─Q10_10 = [131:0x56007eeedea8] <chr> 
    ## │       ├─Q10_11 = [132:0x56007eeede38] <chr> 
    ## │       ├─Q10_12 = [133:0x56007eeeddc8] <chr> 
    ## │       ├─Q10_13 = [134:0x56007eeedd58] <chr> 
    ## │       └─Q10_13_TEXT = [135:0x56007eeedce8] <chr> 
    ## ├─Q11 = █ [136:0x56007d149f70] <tbl_df[,26]> 
    ## │       ├─Institution Name = [137:0x56007eeedc78] <chr> 
    ## │       ├─Institution size category = [138:0x56007eeedc08] <chr> 
    ## │       ├─Q11_27 = [139:0x56007eeedb98] <chr> 
    ## │       ├─Q11_1 = [140:0x56007eeedb28] <chr> 
    ## │       ├─Q11_2 = [141:0x56007eeedab8] <chr> 
    ## │       ├─Q11_4 = [142:0x56007eeeda48] <chr> 
    ## │       ├─Q11_5 = [143:0x56007eeed9d8] <chr> 
    ## │       ├─Q11_6 = [144:0x56007eeed968] <chr> 
    ## │       ├─Q11_16 = [145:0x56007eeed8f8] <chr> 
    ## │       ├─Q11_11 = [146:0x56007eeed888] <chr> 
    ## │       ├─Q11_12 = [147:0x56007eeed818] <chr> 
    ## │       ├─Q11_7 = [148:0x56007eeed7a8] <chr> 
    ## │       ├─Q11_3 = [149:0x56007eeed738] <chr> 
    ## │       ├─Q11_32 = [150:0x56007eeed6c8] <chr> 
    ## │       ├─Q11_33 = [151:0x56007eeed658] <chr> 
    ## │       ├─Q11_34 = [152:0x56007eeed5e8] <chr> 
    ## │       ├─Q11_31 = [153:0x56007eeed578] <chr> 
    ## │       ├─Q11_13 = [154:0x56007eeed508] <chr> 
    ## │       ├─Q11_14 = [155:0x56007eeed498] <chr> 
    ## │       ├─Q11_8 = [156:0x56007eeed428] <chr> 
    ## │       ├─Q11_28 = [157:0x56007eeed3b8] <chr> 
    ## │       ├─Q11_9 = [158:0x56007eeed348] <chr> 
    ## │       ├─Q11_10 = [159:0x56007eeed2d8] <chr> 
    ## │       ├─Q11_15 = [160:0x56007eeed268] <chr> 
    ## │       ├─Q11_29 = [161:0x56007eeed1f8] <chr> 
    ## │       └─Q11_29_TEXT = [162:0x56007eeed188] <chr> 
    ## ├─Q12 = █ [163:0x56007eee9e48] <tbl_df[,3]> 
    ## │       ├─Institution Name = [164:0x56007eeed118] <chr> 
    ## │       ├─Institution size category = [165:0x56007eeed0a8] <chr> 
    ## │       └─Q12 = [166:0x56007eeed038] <chr> 
    ## ├─Q13 = █ [167:0x56007eeecfc8] <tbl_df[,7]> 
    ## │       ├─Institution Name = [168:0x56007eeecf58] <chr> 
    ## │       ├─Institution size category = [169:0x56007eeecee8] <chr> 
    ## │       ├─Q13_1 = [170:0x56007eeece78] <chr> 
    ## │       ├─Q13_2 = [171:0x56007eeece08] <chr> 
    ## │       ├─Q13_3 = [172:0x56007eeecd98] <chr> 
    ## │       ├─Q13_4 = [173:0x56007eeecd28] <chr> 
    ## │       └─Q13_4_TEXT = [174:0x56007eeeccb8] <chr> 
    ## ├─Q14 = █ [175:0x56007eee9d08] <tbl_df[,3]> 
    ## │       ├─Institution Name = [176:0x56007eeecbd8] <chr> 
    ## │       ├─Institution size category = [177:0x56007eeecb68] <chr> 
    ## │       └─Q14 = [178:0x56007eeecaf8] <chr> 
    ## ├─Q15 = █ [179:0x56007eee9c18] <tbl_df[,3]> 
    ## │       ├─Institution Name = [180:0x56007eeeca88] <chr> 
    ## │       ├─Institution size category = [181:0x56007eeeca18] <chr> 
    ## │       └─Q15 = [182:0x56007eeec9a8] <chr> 
    ## ├─Q16 = █ [183:0x56007eee9a38] <tbl_df[,4]> 
    ## │       ├─Institution Name = [184:0x56007eeec8c8] <chr> 
    ## │       ├─Institution size category = [185:0x56007eeec858] <chr> 
    ## │       ├─Q16 = [186:0x56007eeec7e8] <chr> 
    ## │       └─Q16_2_TEXT = [187:0x56007eeec778] <chr> 
    ## ├─Q36 = █ [188:0x56007eee7738] <tbl_df[,14]> 
    ## │       ├─Institution Name = [189:0x56007eeec708] <chr> 
    ## │       ├─Institution size category = [190:0x56007eeec698] <chr> 
    ## │       ├─Q36_1_1 = [191:0x56007eeec628] <chr> 
    ## │       ├─Q36_1_2 = [192:0x56007eeec5b8] <chr> 
    ## │       ├─Q36_2_1 = [193:0x56007eeec548] <chr> 
    ## │       ├─Q36_2_2 = [194:0x56007eeec4d8] <chr> 
    ## │       ├─Q36_3_1 = [195:0x56007eeec468] <chr> 
    ## │       ├─Q36_3_2 = [196:0x56007eeec3f8] <chr> 
    ## │       ├─Q36_4_1 = [197:0x56007eeec388] <chr> 
    ## │       ├─Q36_4_2 = [198:0x56007eeec318] <chr> 
    ## │       ├─Q36_5_1 = [199:0x56007eeec2a8] <chr> 
    ## │       ├─Q36_5_2 = [200:0x56007eeec238] <chr> 
    ## │       ├─Q36_6_1 = [201:0x56007eeec1c8] <chr> 
    ## │       └─Q36_6_2 = [202:0x56007eeec158] <chr> 
    ## ├─Q37 = █ [203:0x56007eee75d8] <tbl_df[,10]> 
    ## │       ├─Institution Name = [204:0x56007eeeff18] <chr> 
    ## │       ├─Institution size category = [205:0x56007eeefea8] <chr> 
    ## │       ├─Q37_1_1 = [206:0x56007eeefe38] <chr> 
    ## │       ├─Q37_1_2 = [207:0x56007eeefdc8] <chr> 
    ## │       ├─Q37_2_1 = [208:0x56007eeefd58] <chr> 
    ## │       ├─Q37_2_2 = [209:0x56007eeefce8] <chr> 
    ## │       ├─Q37_3_1 = [210:0x56007eeefc78] <chr> 
    ## │       ├─Q37_3_2 = [211:0x56007eeefc08] <chr> 
    ## │       ├─Q37_4_1 = [212:0x56007eeefb98] <chr> 
    ## │       └─Q37_4_2 = [213:0x56007eeefb28] <chr> 
    ## ├─Q19 = █ [214:0x56007eeefab8] <tbl_df[,6]> 
    ## │       ├─Institution Name = [215:0x56007eeefa48] <chr> 
    ## │       ├─Institution size category = [216:0x56007eeef9d8] <chr> 
    ## │       ├─Q19_1 = [217:0x56007eeef968] <chr> 
    ## │       ├─Q19_2 = [218:0x56007eeef8f8] <chr> 
    ## │       ├─Q19_3 = [219:0x56007eeef888] <chr> 
    ## │       └─Q19_4 = [220:0x56007eeef818] <chr> 
    ## ├─Q20 = █ [221:0x56007eee7478] <tbl_df[,14]> 
    ## │       ├─Institution Name = [222:0x56007eeef738] <chr> 
    ## │       ├─Institution size category = [223:0x56007eeef6c8] <chr> 
    ## │       ├─Q20_1_1 = [224:0x56007eeef658] <chr> 
    ## │       ├─Q20_1_2 = [225:0x56007eeef5e8] <chr> 
    ## │       ├─Q20_2_1 = [226:0x56007eeef578] <chr> 
    ## │       ├─Q20_2_2 = [227:0x56007eeef508] <chr> 
    ## │       ├─Q20_3_1 = [228:0x56007eeef498] <chr> 
    ## │       ├─Q20_3_2 = [229:0x56007eeef428] <chr> 
    ## │       ├─Q20_4_1 = [230:0x56007eeef3b8] <chr> 
    ## │       ├─Q20_4_2 = [231:0x56007eeef348] <chr> 
    ## │       ├─Q20_5_1 = [232:0x56007eeef2d8] <chr> 
    ## │       ├─Q20_5_2 = [233:0x56007eeef268] <chr> 
    ## │       ├─Q20_6_1 = [234:0x56007eeef1f8] <chr> 
    ## │       └─Q20_6_2 = [235:0x56007eeef188] <chr> 
    ## ├─Q21 = █ [236:0x56007c7189d0] <tbl_df[,22]> 
    ## │       ├─Institution Name = [237:0x56007eeef118] <chr> 
    ## │       ├─Institution size category = [238:0x56007eeef0a8] <chr> 
    ## │       ├─Q21_1_5 = [239:0x56007eeef038] <chr> 
    ## │       ├─Q21_1_2 = [240:0x56007eeeefc8] <chr> 
    ## │       ├─Q21_1_3 = [241:0x56007eeeef58] <chr> 
    ## │       ├─Q21_1_4 = [242:0x56007eeeeee8] <chr> 
    ## │       ├─Q21_2_5 = [243:0x56007eeeee78] <chr> 
    ## │       ├─Q21_2_2 = [244:0x56007eeeee08] <chr> 
    ## │       ├─Q21_2_3 = [245:0x56007eeeed98] <chr> 
    ## │       ├─Q21_2_4 = [246:0x56007eeeed28] <chr> 
    ## │       ├─Q21_3_5 = [247:0x56007eeeecb8] <chr> 
    ## │       ├─Q21_3_2 = [248:0x56007eeeec48] <chr> 
    ## │       ├─Q21_3_3 = [249:0x56007eeeebd8] <chr> 
    ## │       ├─Q21_3_4 = [250:0x56007eeeeb68] <chr> 
    ## │       ├─Q21_4_5 = [251:0x56007eeeeaf8] <chr> 
    ## │       ├─Q21_4_2 = [252:0x56007eeeea88] <chr> 
    ## │       ├─Q21_4_3 = [253:0x56007eeeea18] <chr> 
    ## │       ├─Q21_4_4 = [254:0x56007eeee9a8] <chr> 
    ## │       ├─Q21_5_5 = [255:0x56007eeee938] <chr> 
    ## │       ├─Q21_5_2 = [256:0x56007eeee8c8] <chr> 
    ## │       ├─Q21_5_3 = [257:0x56007eeee858] <chr> 
    ## │       └─Q21_5_4 = [258:0x56007eeee7e8] <chr> 
    ## ├─Q22 = █ [259:0x56007eeee778] <tbl_df[,8]> 
    ## │       ├─Institution Name = [260:0x56007eeee708] <chr> 
    ## │       ├─Institution size category = [261:0x56007eeee698] <chr> 
    ## │       ├─Q22_1_1 = [262:0x56007eeee628] <chr> 
    ## │       ├─Q22_2_1 = [263:0x56007eeee5b8] <chr> 
    ## │       ├─Q22_3_1 = [264:0x56007eeee548] <chr> 
    ## │       ├─Q22_4_1 = [265:0x56007eeee4d8] <chr> 
    ## │       ├─Q22_5_1 = [266:0x56007eeee468] <chr> 
    ## │       └─Q22_6_1 = [267:0x56007eeee3f8] <chr> 
    ## ├─Q23 = █ [268:0x56007eeee318] <tbl_df[,5]> 
    ## │       ├─Institution Name = [269:0x56007eeee2a8] <chr> 
    ## │       ├─Institution size category = [270:0x56007eeee238] <chr> 
    ## │       ├─Q23_1 = [271:0x56007eeee1c8] <chr> 
    ## │       ├─Q23_4 = [272:0x56007eeee158] <chr> 
    ## │       └─Q23_2 = [273:0x56007eeee0e8] <chr> 
    ## ├─Q24 = █ [274:0x56007eee7318] <tbl_df[,11]> 
    ## │       ├─Institution Name = [275:0x56007eef1e38] <chr> 
    ## │       ├─Institution size category = [276:0x56007eef1dc8] <chr> 
    ## │       ├─Q24_1_1 = [277:0x56007eef1d58] <chr> 
    ## │       ├─Q24_1_2 = [278:0x56007eef1ce8] <chr> 
    ## │       ├─Q24_1_5 = [279:0x56007eef1c78] <chr> 
    ## │       ├─Q24_2_1 = [280:0x56007eef1c08] <chr> 
    ## │       ├─Q24_2_2 = [281:0x56007eef1b98] <chr> 
    ## │       ├─Q24_2_5 = [282:0x56007eef1b28] <chr> 
    ## │       ├─Q24_3_1 = [283:0x56007eef1ab8] <chr> 
    ## │       ├─Q24_3_2 = [284:0x56007eef1a48] <chr> 
    ## │       └─Q24_3_5 = [285:0x56007eef19d8] <chr> 
    ## └─Q25 = █ [286:0x56007eee96c8] <tbl_df[,3]> 
    ##         ├─Institution Name = [287:0x56007eef1968] <chr> 
    ##         ├─Institution size category = [288:0x56007eef18f8] <chr> 
    ##         └─Q25 = [289:0x56007eef1888] <chr>

# Functions for Analysis

File: **lacn\_functions.R**

## Motivation

To get a sense for why the following custom functions are useful, let’s
inspect some of the raw data.

Below are several questions from the survey.

    ## Question 2

    ## # A data frame: 5 × 4
    ##   `Institution Name`            `Institution size category` Q2         Q2_6_TEXT
    ## * <chr>                         <chr>                       <chr>      <chr>    
    ## 1 Vassar College                2                           Student A… <NA>     
    ## 2 Williams College              2                           Other:     Office o…
    ## 3 Brandeis College              3                           Student A… <NA>     
    ## 4 College of the Holy Cross     2                           Academic … <NA>     
    ## 5 Franklin and Marshall College 2                           Student A… <NA>

    ## 
    ## Question 4

    ## # A data frame: 5 × 11
    ##   `Institution Name`  `Institution s…` Q4_3  Q4_4  Q4_5  Q4_6  Q4_7  Q4_8  Q4_9 
    ## * <chr>               <chr>            <chr> <chr> <chr> <chr> <chr> <chr> <chr>
    ## 1 Vassar College      2                <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA> 
    ## 2 Williams College    2                <NA>  Alum… <NA>  <NA>  <NA>  <NA>  <NA> 
    ## 3 Brandeis College    3                <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA> 
    ## 4 College of the Hol… 2                <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA> 
    ## 5 Franklin and Marsh… 2                <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA> 
    ## # … with 2 more variables: Q4_10 <chr>, Q4_9_TEXT <chr>

    ## 
    ## Question 5

    ## # A data frame: 5 × 14
    ##   `Institution Name`  `Institution s…` Q5_6  Q5_7  Q5_8  Q5_9  Q5_10 Q5_15 Q5_1 
    ## * <chr>               <chr>            <chr> <chr> <chr> <chr> <chr> <chr> <chr>
    ## 1 Vassar College      2                2     9     6     8     3     4     1    
    ## 2 Williams College    2                1     7     6     9     4     3     5    
    ## 3 Brandeis College    3                1     6     5     7     3     4     8    
    ## 4 College of the Hol… 2                2     3     9     7     1     4     8    
    ## 5 Franklin and Marsh… 2                2     4     3     8     5     6     1    
    ## # … with 5 more variables: Q5_16 <chr>, Q5_11 <chr>, Q5_12 <chr>, Q5_13 <chr>,
    ## #   Q5_13_TEXT <chr>

    ## 
    ## Question 6

    ## # A data frame: 5 × 8
    ##   `Institution Name`  `Institution s…` Q6_1_1 Q6_1_2 Q6_2_1 Q6_2_2 Q6_3_1 Q6_3_2
    ## * <chr>               <chr>            <chr>  <chr>  <chr>  <chr>  <chr>  <chr> 
    ## 1 Vassar College      2                5      0      4      0      0      0     
    ## 2 Williams College    2                8      0      16     0      0      0     
    ## 3 Brandeis College    3                6      0      3      1      0      0     
    ## 4 College of the Hol… 2                8      0      0      0      0      0     
    ## 5 Franklin and Marsh… 2                0      0      10     0      0      0

    ## 
    ## Question 7

    ## # A data frame: 5 × 8
    ##   `Institution Name` `Institution s…` Q7_1_9 Q7_1_2 Q7_1_3 Q7_1_4 Q7_1_5 Q7_1_10
    ## * <chr>              <chr>            <chr>  <chr>  <chr>  <chr>  <chr>  <chr>  
    ## 1 Vassar College     2                9      8      0      0      1      8.25   
    ## 2 Williams College   2                11     10     0      0      1      10     
    ## 3 Brandeis College   3                15     14     1      0      0      14.85  
    ## 4 College of the Ho… 2                11     8      0.83   0.5    0.42   9.75   
    ## 5 Franklin and Mars… 2                10     7      3      0      0      10

A brief inspection of these questions (and the original survey format)
reveals their widely varying structure. Question 2 allows for only one
response per participant, while Question 4 allows for multiple
responses. Question 5 requires each respondent to rank a list of items,
Question 6 provides a matrix for the respondent to fill in, and Question
7 asks for an unbounded numeric input reflecting the number of FTE
professional staff.

Here, we’re faced with a choice. First, we could analyze each of the 23
questions individually. While that is the most attractive option up
front, pursuing that path quickly presents a problem: we will end up
duplicating work when one question has the same form as an earlier one
and therefore can be analyzed using essentially the same method.
Questions 2 and 3, for example, are both single-response items. If we
analyzed them separately, we would probably just copy and paste the code
from Question 2 in order to work with Question 3.

Our second option, then, is to build some functions that can deal with
each of these question types efficiently. There are only five types:
single, multi, matrix, continuous, and ranking. That is a much more
manageable problem.

The challenge with this approach is building those functions. Custom
functions can be a bit intimidating at first, but what they lack in
simplicity they make up for in speed.

## Functions

Note: the summarising method of the functions can be adjusted. Currently
they return averages when relevant, but we can change this to, for
example, sum with little difficulty.

### Helper Functions

In **lacn\_functions.R**, we find a handful of functions. First up are
two helper functions: *selectionFunction*, which returns a vector of
questions (e.g., c(“Q4”,“Q7”,“Q2”…)) that belong to a certain question
type, like “matrix”, and *keyFunction*, which returns a reference table
for response labels. Don’t worry too much about these; they just end up
getting wrapped into the main functions below.

### Analysis Functions

The four main types of question each get their own function (single,
multi, matrix, and continuous). *Ranking* does not, as there is only one
such question; building a function would be more trouble than it’s
worth. Without getting into too much detail, here’s how each of them
works

#### Single Function and Multi Function

Both of these merely group and aggregate the number of times each
response was selected, then add a variable for the relative frequency of
each response (with the denominator being the total number of
respondents).

    ## Original data:

    ## # A data frame: 5 × 4
    ##   `Institution Name`            `Institution size category` Q2         Q2_6_TEXT
    ## * <chr>                         <chr>                       <chr>      <chr>    
    ## 1 Vassar College                2                           Student A… <NA>     
    ## 2 Williams College              2                           Other:     Office o…
    ## 3 Brandeis College              3                           Student A… <NA>     
    ## 4 College of the Holy Cross     2                           Academic … <NA>     
    ## 5 Franklin and Marshall College 2                           Student A… <NA>

    ## 
    ## Aggregated data:

    ## # A data frame: 3 × 3
    ##   Q2                   n  freq
    ## * <chr>            <int> <dbl>
    ## 1 Academic Affairs     1   0.2
    ## 2 Other:               1   0.2
    ## 3 Student Affairs      3   0.6

#### Matrix Function

The matrix function pivots then unpivots each question so that the
matrix format of the original survey is recovered. It then summarises
the responses in each cell.

    ## Original data:

    ## # A data frame: 5 × 8
    ##   `Institution Name`  `Institution s…` Q6_1_1 Q6_1_2 Q6_2_1 Q6_2_2 Q6_3_1 Q6_3_2
    ## * <chr>               <chr>            <chr>  <chr>  <chr>  <chr>  <chr>  <chr> 
    ## 1 Vassar College      2                5      0      4      0      0      0     
    ## 2 Williams College    2                8      0      16     0      0      0     
    ## 3 Brandeis College    3                6      0      3      1      0      0     
    ## 4 College of the Hol… 2                8      0      0      0      0      0     
    ## 5 Franklin and Marsh… 2                0      0      10     0      0      0

    ## 
    ## Aggregated data:

    ##            dim2 Students in paraprofessional roles
    ## 1 Undergraduate                                5.4
    ## 2      Graduate                                0.0
    ##   Students in administrative roles
    ## 1                              6.6
    ## 2                              0.2
    ##   Students in "hybrid" roles (e.g., student workers have both paraprofessional and administrative duties)
    ## 1                                                                                                       0
    ## 2                                                                                                       0

#### Continuous Function

The continuous function pivots and aggregates data by response to return
some statistic on each response category.

    ## Original data:

    ## # A data frame: 5 × 8
    ##   `Institution Name` `Institution s…` Q7_1_9 Q7_1_2 Q7_1_3 Q7_1_4 Q7_1_5 Q7_1_10
    ## * <chr>              <chr>            <chr>  <chr>  <chr>  <chr>  <chr>  <chr>  
    ## 1 Vassar College     2                9      8      0      0      1      8.25   
    ## 2 Williams College   2                11     10     0      0      1      10     
    ## 3 Brandeis College   3                15     14     1      0      0      14.85  
    ## 4 College of the Ho… 2                11     8      0.83   0.5    0.42   9.75   
    ## 5 Franklin and Mars… 2                10     7      3      0      0      10

    ## 
    ## Aggregated data:

    ## # A data frame: 6 × 2
    ##   dim2                                                 mean
    ## * <chr>                                               <dbl>
    ## 1 # FT staff, academic year (or less than 12 months)  0.966
    ## 2 # FT staff, full year (12 months)                   9.4  
    ## 3 # PT Staff, academic year (or less than 12 months)  0.484
    ## 4 # PT staff, full year (12 months)                   0.1  
    ## 5 Total # of staff (headcount)                       11.2  
    ## 6 Total FTE                                          10.6

#### Ranking Analysis

The ranking question (Q5) doesn’t get its own function. Here’s how the
analysis works (see **analysis.R**). We simply compute the desired
statistic for the ranking of each “priority” (student engagment, first
destination data) and then pivot the resultant dataset in anticipation
of visualization.

#### Analyze Function

Finally, the analyze function allows us to do all of the above analysis
for each question type in just a few lines of code (see next section).

# Analysis

File: **analysis.R**

Next, we apply the functions we built to the original data we have
stored in **question\_list**. The analyzeFunction that we built above
allows us analyze any set of questions. That is, if we choose only the
“single” questions, it will apply the singleFunction to them.

The map function (see [purrr](https://purrr.tidyverse.org/) for more)
allows us to do exactly this. Let me explain the code below:

    ## all_questions:

    ## [1] "single"     "multi"      "matrix"     "continuous"

``` r
all_list <- map(all_questions,
                ~ analyzeFunction(
                  .x
                )
)
```

The first argument in the map function is the **all\_questions** vector.
The second argument is the function we want to apply to each element in
that vector (the ‘.x’ is just a placeholder to represent each element in
the vector). So first it will apply the singleFunction to the single
questions, then the multiFunction to the multi questions, and so on,
storing each question type separately in the list we’re calling
**all\_list**. After this code, the **analysis.R** script goes on to add
the ranking question into **all\_list** separately, as it did not have a
function.

## What did we create?

We now have a list containing the cleaned and summarised data for each
type of question (single, multi, matrix, continuous, ranking). See the
structure map below to get a sense of how the final data is stored. It
can look a bit chaotic at first, but the basic idea is this: the master
list contains different question types, which each contain the relevant
questions, which each contain the actual variables and data for each
summarised and aggregated response.

    ## █ [1:0x56007eef1818] <named list> 
    ## ├─single = █ [2:0x56007eef17a8] <named list> 
    ## │          ├─Q2 = █ [3:0x56007eee95d8] <tbl_df[,3]> 
    ## │          │      ├─Q2 = [4:0x56007eee9588] <chr> 
    ## │          │      ├─n = [5:0x56007eed1938] <int> 
    ## │          │      └─freq = [6:0x56007eee9538] <dbl> 
    ## │          ├─Q3 = █ [7:0x56007eee9448] <tbl_df[,3]> 
    ## │          │      ├─Q3 = [8:0x56007eed18f8] <chr> 
    ## │          │      ├─n = [9:0x56007de21b98] <int> 
    ## │          │      └─freq = [10:0x56007eed18b8] <dbl> 
    ## │          ├─Q12 = █ [11:0x56007eee9358] <tbl_df[,3]> 
    ## │          │       ├─Q12 = [12:0x56007eee9308] <chr> 
    ## │          │       ├─n = [13:0x56007eed1878] <int> 
    ## │          │       └─freq = [14:0x56007eee92b8] <dbl> 
    ## │          ├─Q14 = █ [15:0x56007eee91c8] <tbl_df[,3]> 
    ## │          │       ├─Q14 = [16:0x56007de21af0] <chr> 
    ## │          │       ├─n = [17:0x56007de21ab8] <int> 
    ## │          │       └─freq = [18:0x56007de21a80] <dbl> 
    ## │          ├─Q16 = █ [19:0x56007eee90d8] <tbl_df[,3]> 
    ## │          │       ├─Q16 = [20:0x56007de21a10] <chr> 
    ## │          │       ├─n = [21:0x56007de219d8] <int> 
    ## │          │       └─freq = [22:0x56007de219a0] <dbl> 
    ## │          └─Q25 = █ [23:0x56007eee8fe8] <tbl_df[,3]> 
    ## │                  ├─Q25 = [24:0x56007de21930] <chr> 
    ## │                  ├─n = [25:0x56007de218f8] <int> 
    ## │                  └─freq = [26:0x56007de218c0] <dbl> 
    ## ├─multi = █ [27:0x56007eef16c8] <named list> 
    ## │         ├─Q4 = █ [28:0x56007eee8ef8] <tbl_df[,3]> 
    ## │         │      ├─value = [29:0x56007eed1838] <chr> 
    ## │         │      ├─n = [30:0x56007de21850] <int> 
    ## │         │      └─freq = [31:0x56007eed17f8] <dbl> 
    ## │         ├─Q9 = █ [32:0x56007eee8e08] <tbl_df[,3]> 
    ## │         │      ├─value = [33:0x56007eef1658] <chr> 
    ## │         │      ├─n = [34:0x56007eee8db8] <int> 
    ## │         │      └─freq = [35:0x56007eef15e8] <dbl> 
    ## │         ├─Q10 = █ [36:0x56007eee8cc8] <tbl_df[,3]> 
    ## │         │       ├─value = [37:0x56007eef1578] <chr> 
    ## │         │       ├─n = [38:0x56007eee8c78] <int> 
    ## │         │       └─freq = [39:0x56007eef1508] <dbl> 
    ## │         ├─Q11 = █ [40:0x56007eee8b88] <tbl_df[,3]> 
    ## │         │       ├─value = [41:0x56007dc32ce0] <chr> 
    ## │         │       ├─n = [42:0x56007eee71b8] <int> 
    ## │         │       └─freq = [43:0x56007dc32dd0] <dbl> 
    ## │         ├─Q13 = █ [44:0x56007eee8a98] <tbl_df[,3]> 
    ## │         │       ├─value = [45:0x56007eed17b8] <chr> 
    ## │         │       ├─n = [46:0x56007de21738] <int> 
    ## │         │       └─freq = [47:0x56007eed1778] <dbl> 
    ## │         └─Q15 = █ [48:0x56007eee89a8] <tbl_df[,3]> 
    ## │                 ├─value = [49:0x56007eee8958] <chr> 
    ## │                 ├─n = [50:0x56007eed1738] <int> 
    ## │                 └─freq = [51:0x56007eee8908] <dbl> 
    ## ├─matrix = █ [52:0x56007eef1428] <named list> 
    ## │          ├─Q6 = █ [53:0x56007eee8818] <df[,4]> 
    ## │          │      ├─dim2 = [54:0x56007eed16f8] <chr> 
    ## │          │      ├─Students in paraprofessional roles = [55:0x56007eed16b8] <dbl> 
    ## │          │      ├─Students in administrative roles = [56:0x56007eed1678] <dbl> 
    ## │          │      └─Students in "hybrid" roles (e.g., student workers have both paraprofessional and administrative duties) = [57:0x56007eed1638] <dbl> 
    ## │          ├─Q8 = █ [58:0x56007eee7108] <df[,15]> 
    ## │          │      ├─dim2 = [59:0x56007eee8778] <chr> 
    ## │          │      ├─Student Counseling/Advising = [60:0x56007eee8728] <dbl> 
    ## │          │      ├─Health Professions Advising = [61:0x56007eee86d8] <dbl> 
    ## │          │      ├─Alumni Counseling/Advising = [62:0x56007eee8688] <dbl> 
    ## │          │      ├─Fellowship Advising = [63:0x56007eee8638] <dbl> 
    ## │          │      ├─Pre-Law Advising = [64:0x56007eee85e8] <dbl> 
    ## │          │      ├─Program/Event Planning = [65:0x56007eee8598] <dbl> 
    ## │          │      ├─Marketing/Communications = [66:0x56007eee8548] <dbl> 
    ## │          │      ├─Employer Relations = [67:0x56007eee84f8] <dbl> 
    ## │          │      ├─Internship Funding = [68:0x56007eee84a8] <dbl> 
    ## │          │      ├─Office Management/Front Desk = [69:0x56007eee8458] <dbl> 
    ## │          │      ├─Supervision of Professional Staff = [70:0x56007eee8408] <dbl> 
    ## │          │      ├─Budget Management = [71:0x56007eee83b8] <dbl> 
    ## │          │      ├─Technology Management = [72:0x56007eee8368] <dbl> 
    ## │          │      └─Assessment (Data, Outcomes, Program) = [73:0x56007eee8318] <dbl> 
    ## │          ├─Q36 = █ [74:0x56007eef13b8] <df[,7]> 
    ## │          │       ├─dim2 = [75:0x56007eed15f8] <chr> 
    ## │          │       ├─Number of career fairs offered on-campus or only for students at your institution (not including grad/prof school fairs) = [76:0x56007eed15b8] <dbl> 
    ## │          │       ├─Number of information sessions offered by employers (coordinated by your office) = [77:0x56007eed1578] <dbl> 
    ## │          │       ├─Number of interviews conducted on-campus or virtual interviews coordinated by your office (total number, not unique students) *record interviews affiliated with consortia/off-campus events below = [78:0x56007eed1538] <dbl> 
    ## │          │       ├─Number of interviews conducted through consortia/off-campus events (total number, not unique students) = [79:0x56007eed14f8] <dbl> 
    ## │          │       ├─Number of career "treks" (immersion trips lasting at least one day) = [80:0x56007eed14b8] <dbl> 
    ## │          │       └─Number of job shadows (total number, not unique students) = [81:0x56007eed1478] <dbl> 
    ## │          ├─Q37 = █ [82:0x56007eef12d8] <df[,5]> 
    ## │          │       ├─dim2 = [83:0x56007eed1438] <chr> 
    ## │          │       ├─Number of employers who attended career fairs offered on-campus or only for students at your institution (not including graduate/professional school fairs) = [84:0x56007eed13f8] <dbl> 
    ## │          │       ├─Number of employers who offered information sessions coordinated by your office = [85:0x56007eed13b8] <dbl> 
    ## │          │       ├─Number of employers who conducted interviews on-campus or virtual interviews coordinated by your office = [86:0x56007eed1378] <dbl> 
    ## │          │       └─Number of employers who conducted interviews through consortia/off-campus events = [87:0x56007eed1338] <dbl> 
    ## │          ├─Q20 = █ [88:0x56007eef11f8] <df[,7]> 
    ## │          │       ├─dim2 = [89:0x56007eef3d78] <chr> 
    ## │          │       ├─# appointments with first-year students by professional staff = [90:0x56007eef3d38] <dbl> 
    ## │          │       ├─# appointments with sophomore students by professional staff = [91:0x56007eef3cf8] <dbl> 
    ## │          │       ├─# appointments with junior students by professional staff = [92:0x56007eef3cb8] <dbl> 
    ## │          │       ├─# appointments with senior students by professional staff = [93:0x56007eef3c78] <dbl> 
    ## │          │       ├─TOTAL #  appointments with students by professional staff = [94:0x56007eef3c38] <dbl> 
    ## │          │       └─# appointments with alumni by professional staff = [95:0x56007eef3bf8] <dbl> 
    ## │          ├─Q21 = █ [96:0x56007eef1118] <df[,6]> 
    ## │          │       ├─dim2 = [97:0x56007eef5c78] <chr> 
    ## │          │       ├─First-Year = [98:0x56007eef5c28] <dbl> 
    ## │          │       ├─Sophomore = [99:0x56007eef5bd8] <dbl> 
    ## │          │       ├─Junior = [100:0x56007eef5b88] <dbl> 
    ## │          │       ├─Senior = [101:0x56007eef5b38] <dbl> 
    ## │          │       └─TOTAL (all classes) = [102:0x56007eef5ae8] <dbl> 
    ## │          └─Q24 = █ [103:0x56007eef5a98] <df[,4]> 
    ## │                  ├─dim2 = [104:0x56007eef5a48] <chr> 
    ## │                  ├─Income from endowed funds = [105:0x56007eef59f8] <dbl> 
    ## │                  ├─Expendable gifts = [106:0x56007eef59a8] <dbl> 
    ## │                  └─Other = [107:0x56007eef5958] <dbl> 
    ## ├─continuous = █ [108:0x56007eef58b8] <named list> 
    ## │              ├─Q7 = █ [109:0x56007eef3bb8] <tbl_df[,2]> 
    ## │              │      ├─dim2 = [110:0x56007eef0fc8] <chr> 
    ## │              │      └─mean = [111:0x56007eef0f58] <dbl> 
    ## │              ├─Q19 = █ [112:0x56007eef3b38] <tbl_df[,2]> 
    ## │              │       ├─dim1 = [113:0x56007eef5818] <chr> 
    ## │              │       └─mean = [114:0x56007eef57c8] <dbl> 
    ## │              ├─Q22 = █ [115:0x56007eef3ab8] <tbl_df[,2]> 
    ## │              │       ├─dim1 = [116:0x56007eef0ee8] <chr> 
    ## │              │       └─mean = [117:0x56007eef0e78] <dbl> 
    ## │              └─Q23 = █ [118:0x56007eef3a38] <tbl_df[,2]> 
    ## │                      ├─dim1 = [119:0x56007eef56d8] <chr> 
    ## │                      └─mean = [120:0x56007eef5688] <dbl> 
    ## └─ranking = █ [121:0x56007de212a0] <named list> 
    ##             └─Q5 = █ [122:0x56007eef5598] <tbl_df[,3]> 
    ##                    ├─Question = [123:0x56007eee6fa8] <chr> 
    ##                    ├─dim1 = [124:0x56007eee6ef8] <chr> 
    ##                    └─ranking_avg = [125:0x56007eee6e48] <dbl>

Let’s say you wanted to investigate conference attendance rates (Q9).
You would note that Q9 is a multi-response question:

    ## # A tibble: 1 × 3
    ##   unique q_type Notes                        
    ##   <chr>  <chr>  <chr>                        
    ## 1 Q9     multi  Conferences attended by staff

Next, you would key into the master list in the following order: master
list –&gt; question type –&gt; question. The ‘$’ in the code below are
how R digs into a deeper level of some object, like a list or a
dataframe. Think of it as opening a door into an inner room of a house.

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

*In progress. Please check back later.*
