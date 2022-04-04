LACN 2022 Survey
================

This document walks you through the structure, purpose, and output of
this repository. All scripts can be found in the **code** directory.

# File Structure

    ## Contents of lacn directory

    ##  [1] "_site.yml"  "code"       "data"       "docs"       "images"    
    ##  [6] "index.Rmd"  "lacn.RData" "lacn.Rproj" "README.md"  "README.Rmd"

    ## 
    ## Files in code subdirectory

    ## [1] "1_read_data.R"    "2_clean.R"        "3_functions.R"    "4_analysis.R"    
    ## [5] "source.R"         "viz_budget.R"     "viz_engagement.R" "viz_intro.R"     
    ## [9] "viz_reporting.R"

    ## 
    ## Files in data subdirectory

    ## [1] "lacn_2022.csv"    "response_key.csv"

# Load Data

Script: **1\_read\_data.R**

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
    ##     Description_short                                  dim1 dim2
    ## 1                <NA> Name of person completing this survey <NA>
    ## 2                <NA>                           Institution <NA>
    ## 3 Reporting Structure                       Selected Choice <NA>

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

Script: **2\_clean.R**

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
have a nice portable object we can manipulate, explore, and use in later
analysis. Without this list, we would have to repeat ourselves every
time we wanted to extract a single question and analyze it.

Below is a representation of the structure of that list (called
**question\_list**). As you can see, **question\_list**, represented by
the top-most black rectangle, contains within it

    ## █ [1:0x5645e06217c0] <named list> 
    ## ├─Q1 = █ [2:0x5645e2eaa8b8] <tbl_df[,4]> 
    ## │      ├─Institution Name = [3:0x5645e2ead9e8] <chr> 
    ## │      ├─Undergraduate enrollment = [4:0x5645e2ead978] <chr> 
    ## │      ├─Q1_1 = [5:0x5645e2ead908] <chr> 
    ## │      └─Q1_2 = [6:0x5645e2ead898] <chr> 
    ## ├─Q2 = █ [7:0x5645e2eaa728] <tbl_df[,4]> 
    ## │      ├─Institution Name = [8:0x5645e2ead828] <chr> 
    ## │      ├─Undergraduate enrollment = [9:0x5645e2ead7b8] <chr> 
    ## │      ├─Q2 = [10:0x5645e2ead748] <chr> 
    ## │      └─Q2_6_TEXT = [11:0x5645e2ead6d8] <chr> 
    ## ├─Q3 = █ [12:0x5645e2eaa598] <tbl_df[,3]> 
    ## │      ├─Institution Name = [13:0x5645e2ead668] <chr> 
    ## │      ├─Undergraduate enrollment = [14:0x5645e2ead5f8] <chr> 
    ## │      └─Q3 = [15:0x5645e2ead588] <chr> 
    ## ├─Q4 = █ [16:0x5645e2eaf948] <tbl_df[,11]> 
    ## │      ├─Institution Name = [17:0x5645e2ead518] <chr> 
    ## │      ├─Undergraduate enrollment = [18:0x5645e2ead4a8] <chr> 
    ## │      ├─Q4_3 = [19:0x5645e2ead438] <chr> 
    ## │      ├─Q4_4 = [20:0x5645e2ead3c8] <chr> 
    ## │      ├─Q4_5 = [21:0x5645e2ead358] <chr> 
    ## │      ├─Q4_6 = [22:0x5645e2ead2e8] <chr> 
    ## │      ├─Q4_7 = [23:0x5645e2ead278] <chr> 
    ## │      ├─Q4_8 = [24:0x5645e2ead208] <chr> 
    ## │      ├─Q4_9 = [25:0x5645e2ead198] <chr> 
    ## │      ├─Q4_10 = [26:0x5645e2ead128] <chr> 
    ## │      └─Q4_9_TEXT = [27:0x5645e2ead0b8] <chr> 
    ## ├─Q5 = █ [28:0x5645e2eaf7e8] <tbl_df[,14]> 
    ## │      ├─Institution Name = [29:0x5645e2ead048] <chr> 
    ## │      ├─Undergraduate enrollment = [30:0x5645e2eacfd8] <chr> 
    ## │      ├─Q5_6 = [31:0x5645e2eacf68] <chr> 
    ## │      ├─Q5_7 = [32:0x5645e2eacef8] <chr> 
    ## │      ├─Q5_8 = [33:0x5645e2eace88] <chr> 
    ## │      ├─Q5_9 = [34:0x5645e2eace18] <chr> 
    ## │      ├─Q5_10 = [35:0x5645e2eacda8] <chr> 
    ## │      ├─Q5_15 = [36:0x5645e2eacd38] <chr> 
    ## │      ├─Q5_1 = [37:0x5645e2eaccc8] <chr> 
    ## │      ├─Q5_16 = [38:0x5645e2eacc58] <chr> 
    ## │      ├─Q5_11 = [39:0x5645e2eacbe8] <chr> 
    ## │      ├─Q5_12 = [40:0x5645e2eacb78] <chr> 
    ## │      ├─Q5_13 = [41:0x5645e2eacb08] <chr> 
    ## │      └─Q5_13_TEXT = [42:0x5645e2eaca98] <chr> 
    ## ├─Q6 = █ [43:0x5645e2eaca28] <tbl_df[,8]> 
    ## │      ├─Institution Name = [44:0x5645e2eac9b8] <chr> 
    ## │      ├─Undergraduate enrollment = [45:0x5645e2eac948] <chr> 
    ## │      ├─Q6_1_1 = [46:0x5645e2eac8d8] <chr> 
    ## │      ├─Q6_1_2 = [47:0x5645e2eac868] <chr> 
    ## │      ├─Q6_2_1 = [48:0x5645e2eac7f8] <chr> 
    ## │      ├─Q6_2_2 = [49:0x5645e2eac788] <chr> 
    ## │      ├─Q6_3_1 = [50:0x5645e2eac718] <chr> 
    ## │      └─Q6_3_2 = [51:0x5645e2eac6a8] <chr> 
    ## ├─Q7 = █ [52:0x5645e2eac5c8] <tbl_df[,8]> 
    ## │      ├─Institution Name = [53:0x5645e2eac558] <chr> 
    ## │      ├─Undergraduate enrollment = [54:0x5645e2eac4e8] <chr> 
    ## │      ├─Q7_1_9 = [55:0x5645e2eac478] <chr> 
    ## │      ├─Q7_1_2 = [56:0x5645e2eac408] <chr> 
    ## │      ├─Q7_1_3 = [57:0x5645e2eac398] <chr> 
    ## │      ├─Q7_1_4 = [58:0x5645e2eac328] <chr> 
    ## │      ├─Q7_1_5 = [59:0x5645e2eac2b8] <chr> 
    ## │      └─Q7_1_10 = [60:0x5645e2eac248] <chr> 
    ## ├─Q8 = █ [61:0x5645e0633330] <tbl_df[,44]> 
    ## │      ├─Institution Name = [62:0x5645e2eac168] <chr> 
    ## │      ├─Undergraduate enrollment = [63:0x5645e2eac0f8] <chr> 
    ## │      ├─Q8_1_1 = [64:0x5645e2eac088] <chr> 
    ## │      ├─Q8_1_2 = [65:0x5645e2eac018] <chr> 
    ## │      ├─Q8_1_3 = [66:0x5645e2eabfa8] <chr> 
    ## │      ├─Q8_2_1 = [67:0x5645e2eabf38] <chr> 
    ## │      ├─Q8_2_2 = [68:0x5645e2eabec8] <chr> 
    ## │      ├─Q8_2_3 = [69:0x5645e2eabe58] <chr> 
    ## │      ├─Q8_3_1 = [70:0x5645e2eabde8] <chr> 
    ## │      ├─Q8_3_2 = [71:0x5645e2eabd78] <chr> 
    ## │      ├─Q8_3_3 = [72:0x5645e2eabd08] <chr> 
    ## │      ├─Q8_4_1 = [73:0x5645e2eabc98] <chr> 
    ## │      ├─Q8_4_2 = [74:0x5645e2eb1978] <chr> 
    ## │      ├─Q8_4_3 = [75:0x5645e2eb1908] <chr> 
    ## │      ├─Q8_5_1 = [76:0x5645e2eb1898] <chr> 
    ## │      ├─Q8_5_2 = [77:0x5645e2eb1828] <chr> 
    ## │      ├─Q8_5_3 = [78:0x5645e2eb17b8] <chr> 
    ## │      ├─Q8_6_1 = [79:0x5645e2eb1748] <chr> 
    ## │      ├─Q8_6_2 = [80:0x5645e2eb16d8] <chr> 
    ## │      ├─Q8_6_3 = [81:0x5645e2eb1668] <chr> 
    ## │      ├─Q8_7_1 = [82:0x5645e2eb15f8] <chr> 
    ## │      ├─Q8_7_2 = [83:0x5645e2eb1588] <chr> 
    ## │      ├─Q8_7_3 = [84:0x5645e2eb1518] <chr> 
    ## │      ├─Q8_8_1 = [85:0x5645e2eb14a8] <chr> 
    ## │      ├─Q8_8_2 = [86:0x5645e2eb1438] <chr> 
    ## │      ├─Q8_8_3 = [87:0x5645e2eb13c8] <chr> 
    ## │      ├─Q8_9_1 = [88:0x5645e2eb1358] <chr> 
    ## │      ├─Q8_9_2 = [89:0x5645e2eb12e8] <chr> 
    ## │      ├─Q8_9_3 = [90:0x5645e2eb1278] <chr> 
    ## │      ├─Q8_10_1 = [91:0x5645e2eb1208] <chr> 
    ## │      ├─Q8_10_2 = [92:0x5645e2eb1198] <chr> 
    ## │      ├─Q8_10_3 = [93:0x5645e2eb1128] <chr> 
    ## │      ├─Q8_11_1 = [94:0x5645e2eb10b8] <chr> 
    ## │      ├─Q8_11_2 = [95:0x5645e2eb1048] <chr> 
    ## │      ├─Q8_11_3 = [96:0x5645e2eb0fd8] <chr> 
    ## │      ├─Q8_12_1 = [97:0x5645e2eb0f68] <chr> 
    ## │      ├─Q8_12_2 = [98:0x5645e2eb0ef8] <chr> 
    ## │      ├─Q8_12_3 = [99:0x5645e2eb0e88] <chr> 
    ## │      ├─Q8_13_1 = [100:0x5645e2eb0e18] <chr> 
    ## │      ├─Q8_13_2 = [101:0x5645e2eb0da8] <chr> 
    ## │      ├─Q8_13_3 = [102:0x5645e2eb0d38] <chr> 
    ## │      ├─Q8_14_1 = [103:0x5645e2eb0cc8] <chr> 
    ## │      ├─Q8_14_2 = [104:0x5645e2eb0c58] <chr> 
    ## │      └─Q8_14_3 = [105:0x5645e2eb0be8] <chr> 
    ## ├─Q9 = █ [106:0x5645e2eaf688] <tbl_df[,14]> 
    ## │      ├─Institution Name = [107:0x5645e2eb0b78] <chr> 
    ## │      ├─Undergraduate enrollment = [108:0x5645e2eb0b08] <chr> 
    ## │      ├─Q9_1 = [109:0x5645e2eb0a98] <chr> 
    ## │      ├─Q9_2 = [110:0x5645e2eb0a28] <chr> 
    ## │      ├─Q9_3 = [111:0x5645e2eb09b8] <chr> 
    ## │      ├─Q9_4 = [112:0x5645e2eb0948] <chr> 
    ## │      ├─Q9_5 = [113:0x5645e2eb08d8] <chr> 
    ## │      ├─Q9_6 = [114:0x5645e2eb0868] <chr> 
    ## │      ├─Q9_7 = [115:0x5645e2eb07f8] <chr> 
    ## │      ├─Q9_8 = [116:0x5645e2eb0788] <chr> 
    ## │      ├─Q9_9 = [117:0x5645e2eb0718] <chr> 
    ## │      ├─Q9_10 = [118:0x5645e2eb06a8] <chr> 
    ## │      ├─Q9_11 = [119:0x5645e2eb0638] <chr> 
    ## │      └─Q9_11_TEXT = [120:0x5645e2eb05c8] <chr> 
    ## ├─Q10 = █ [121:0x5645e2eaf528] <tbl_df[,14]> 
    ## │       ├─Institution Name = [122:0x5645e2eb0558] <chr> 
    ## │       ├─Undergraduate enrollment = [123:0x5645e2eb04e8] <chr> 
    ## │       ├─Q10_1 = [124:0x5645e2eb0478] <chr> 
    ## │       ├─Q10_3 = [125:0x5645e2eb0408] <chr> 
    ## │       ├─Q10_4 = [126:0x5645e2eb0398] <chr> 
    ## │       ├─Q10_5 = [127:0x5645e2eb0328] <chr> 
    ## │       ├─Q10_6 = [128:0x5645e2eb02b8] <chr> 
    ## │       ├─Q10_7 = [129:0x5645e2eb0248] <chr> 
    ## │       ├─Q10_8 = [130:0x5645e2eb01d8] <chr> 
    ## │       ├─Q10_10 = [131:0x5645e2eb0168] <chr> 
    ## │       ├─Q10_11 = [132:0x5645e2eb00f8] <chr> 
    ## │       ├─Q10_12 = [133:0x5645e2eb0088] <chr> 
    ## │       ├─Q10_13 = [134:0x5645e2eb0018] <chr> 
    ## │       └─Q10_13_TEXT = [135:0x5645e2eaffa8] <chr> 
    ## ├─Q11 = █ [136:0x5645e1ddfe70] <tbl_df[,26]> 
    ## │       ├─Institution Name = [137:0x5645e2eaff38] <chr> 
    ## │       ├─Undergraduate enrollment = [138:0x5645e2eafec8] <chr> 
    ## │       ├─Q11_27 = [139:0x5645e2eafe58] <chr> 
    ## │       ├─Q11_1 = [140:0x5645e2eafde8] <chr> 
    ## │       ├─Q11_2 = [141:0x5645e2eafd78] <chr> 
    ## │       ├─Q11_4 = [142:0x5645e2eafd08] <chr> 
    ## │       ├─Q11_5 = [143:0x5645e2eafc98] <chr> 
    ## │       ├─Q11_6 = [144:0x5645e2eafc28] <chr> 
    ## │       ├─Q11_16 = [145:0x5645e2eafbb8] <chr> 
    ## │       ├─Q11_11 = [146:0x5645e2eafb48] <chr> 
    ## │       ├─Q11_12 = [147:0x5645e2eafad8] <chr> 
    ## │       ├─Q11_7 = [148:0x5645e2eb3898] <chr> 
    ## │       ├─Q11_3 = [149:0x5645e2eb3828] <chr> 
    ## │       ├─Q11_32 = [150:0x5645e2eb37b8] <chr> 
    ## │       ├─Q11_33 = [151:0x5645e2eb3748] <chr> 
    ## │       ├─Q11_34 = [152:0x5645e2eb36d8] <chr> 
    ## │       ├─Q11_31 = [153:0x5645e2eb3668] <chr> 
    ## │       ├─Q11_13 = [154:0x5645e2eb35f8] <chr> 
    ## │       ├─Q11_14 = [155:0x5645e2eb3588] <chr> 
    ## │       ├─Q11_8 = [156:0x5645e2eb3518] <chr> 
    ## │       ├─Q11_28 = [157:0x5645e2eb34a8] <chr> 
    ## │       ├─Q11_9 = [158:0x5645e2eb3438] <chr> 
    ## │       ├─Q11_10 = [159:0x5645e2eb33c8] <chr> 
    ## │       ├─Q11_15 = [160:0x5645e2eb3358] <chr> 
    ## │       ├─Q11_29 = [161:0x5645e2eb32e8] <chr> 
    ## │       └─Q11_29_TEXT = [162:0x5645e2eb3278] <chr> 
    ## ├─Q12 = █ [163:0x5645e2eaa228] <tbl_df[,3]> 
    ## │       ├─Institution Name = [164:0x5645e2eb3208] <chr> 
    ## │       ├─Undergraduate enrollment = [165:0x5645e2eb3198] <chr> 
    ## │       └─Q12 = [166:0x5645e2eb3128] <chr> 
    ## ├─Q13 = █ [167:0x5645e2eb30b8] <tbl_df[,7]> 
    ## │       ├─Institution Name = [168:0x5645e2eb3048] <chr> 
    ## │       ├─Undergraduate enrollment = [169:0x5645e2eb2fd8] <chr> 
    ## │       ├─Q13_1 = [170:0x5645e2eb2f68] <chr> 
    ## │       ├─Q13_2 = [171:0x5645e2eb2ef8] <chr> 
    ## │       ├─Q13_3 = [172:0x5645e2eb2e88] <chr> 
    ## │       ├─Q13_4 = [173:0x5645e2eb2e18] <chr> 
    ## │       └─Q13_4_TEXT = [174:0x5645e2eb2da8] <chr> 
    ## ├─Q14 = █ [175:0x5645e2eaa0e8] <tbl_df[,3]> 
    ## │       ├─Institution Name = [176:0x5645e2eb2cc8] <chr> 
    ## │       ├─Undergraduate enrollment = [177:0x5645e2eb2c58] <chr> 
    ## │       └─Q14 = [178:0x5645e2eb2be8] <chr> 
    ## ├─Q15 = █ [179:0x5645e2ea9ff8] <tbl_df[,3]> 
    ## │       ├─Institution Name = [180:0x5645e2eb2b78] <chr> 
    ## │       ├─Undergraduate enrollment = [181:0x5645e2eb2b08] <chr> 
    ## │       └─Q15 = [182:0x5645e2eb2a98] <chr> 
    ## ├─Q16 = █ [183:0x5645e2ea9e18] <tbl_df[,4]> 
    ## │       ├─Institution Name = [184:0x5645e2eb29b8] <chr> 
    ## │       ├─Undergraduate enrollment = [185:0x5645e2eb2948] <chr> 
    ## │       ├─Q16 = [186:0x5645e2eb28d8] <chr> 
    ## │       └─Q16_2_TEXT = [187:0x5645e2eb2868] <chr> 
    ## ├─Q36 = █ [188:0x5645e2eaf3c8] <tbl_df[,14]> 
    ## │       ├─Institution Name = [189:0x5645e2eb27f8] <chr> 
    ## │       ├─Undergraduate enrollment = [190:0x5645e2eb2788] <chr> 
    ## │       ├─Q36_1_1 = [191:0x5645e2eb2718] <chr> 
    ## │       ├─Q36_1_2 = [192:0x5645e2eb26a8] <chr> 
    ## │       ├─Q36_2_1 = [193:0x5645e2eb2638] <chr> 
    ## │       ├─Q36_2_2 = [194:0x5645e2eb25c8] <chr> 
    ## │       ├─Q36_3_1 = [195:0x5645e2eb2558] <chr> 
    ## │       ├─Q36_3_2 = [196:0x5645e2eb24e8] <chr> 
    ## │       ├─Q36_4_1 = [197:0x5645e2eb2478] <chr> 
    ## │       ├─Q36_4_2 = [198:0x5645e2eb2408] <chr> 
    ## │       ├─Q36_5_1 = [199:0x5645e2eb2398] <chr> 
    ## │       ├─Q36_5_2 = [200:0x5645e2eb2328] <chr> 
    ## │       ├─Q36_6_1 = [201:0x5645e2eb22b8] <chr> 
    ## │       └─Q36_6_2 = [202:0x5645e2eb2248] <chr> 
    ## ├─Q37 = █ [203:0x5645e2eaf268] <tbl_df[,10]> 
    ## │       ├─Institution Name = [204:0x5645e2eb21d8] <chr> 
    ## │       ├─Undergraduate enrollment = [205:0x5645e2eb2168] <chr> 
    ## │       ├─Q37_1_1 = [206:0x5645e2eb20f8] <chr> 
    ## │       ├─Q37_1_2 = [207:0x5645e2eb2088] <chr> 
    ## │       ├─Q37_2_1 = [208:0x5645e2eb2018] <chr> 
    ## │       ├─Q37_2_2 = [209:0x5645e2eb1fa8] <chr> 
    ## │       ├─Q37_3_1 = [210:0x5645e2eb1f38] <chr> 
    ## │       ├─Q37_3_2 = [211:0x5645e2eb1ec8] <chr> 
    ## │       ├─Q37_4_1 = [212:0x5645e2eb1e58] <chr> 
    ## │       └─Q37_4_2 = [213:0x5645e2eb1de8] <chr> 
    ## ├─Q19 = █ [214:0x5645e2eb1d78] <tbl_df[,6]> 
    ## │       ├─Institution Name = [215:0x5645e2eb1d08] <chr> 
    ## │       ├─Undergraduate enrollment = [216:0x5645e2eb1c98] <chr> 
    ## │       ├─Q19_1 = [217:0x5645e2eb1c28] <chr> 
    ## │       ├─Q19_2 = [218:0x5645e2eb1bb8] <chr> 
    ## │       ├─Q19_3 = [219:0x5645e2eb1b48] <chr> 
    ## │       └─Q19_4 = [220:0x5645e2eb1ad8] <chr> 
    ## ├─Q20 = █ [221:0x5645e2eaf108] <tbl_df[,14]> 
    ## │       ├─Institution Name = [222:0x5645e2eb19f8] <chr> 
    ## │       ├─Undergraduate enrollment = [223:0x5645e2eb76d8] <chr> 
    ## │       ├─Q20_1_1 = [224:0x5645e2eb7668] <chr> 
    ## │       ├─Q20_1_2 = [225:0x5645e2eb75f8] <chr> 
    ## │       ├─Q20_2_1 = [226:0x5645e2eb7588] <chr> 
    ## │       ├─Q20_2_2 = [227:0x5645e2eb7518] <chr> 
    ## │       ├─Q20_3_1 = [228:0x5645e2eb74a8] <chr> 
    ## │       ├─Q20_3_2 = [229:0x5645e2eb7438] <chr> 
    ## │       ├─Q20_4_1 = [230:0x5645e2eb73c8] <chr> 
    ## │       ├─Q20_4_2 = [231:0x5645e2eb7358] <chr> 
    ## │       ├─Q20_5_1 = [232:0x5645e2eb72e8] <chr> 
    ## │       ├─Q20_5_2 = [233:0x5645e2eb7278] <chr> 
    ## │       ├─Q20_6_1 = [234:0x5645e2eb7208] <chr> 
    ## │       └─Q20_6_2 = [235:0x5645e2eb7198] <chr> 
    ## ├─Q21 = █ [236:0x5645e0633780] <tbl_df[,22]> 
    ## │       ├─Institution Name = [237:0x5645e2eb7128] <chr> 
    ## │       ├─Undergraduate enrollment = [238:0x5645e2eb70b8] <chr> 
    ## │       ├─Q21_1_5 = [239:0x5645e2eb7048] <chr> 
    ## │       ├─Q21_1_2 = [240:0x5645e2eb6fd8] <chr> 
    ## │       ├─Q21_1_3 = [241:0x5645e2eb6f68] <chr> 
    ## │       ├─Q21_1_4 = [242:0x5645e2eb6ef8] <chr> 
    ## │       ├─Q21_2_5 = [243:0x5645e2eb6e88] <chr> 
    ## │       ├─Q21_2_2 = [244:0x5645e2eb6e18] <chr> 
    ## │       ├─Q21_2_3 = [245:0x5645e2eb6da8] <chr> 
    ## │       ├─Q21_2_4 = [246:0x5645e2eb6d38] <chr> 
    ## │       ├─Q21_3_5 = [247:0x5645e2eb6cc8] <chr> 
    ## │       ├─Q21_3_2 = [248:0x5645e2eb6c58] <chr> 
    ## │       ├─Q21_3_3 = [249:0x5645e2eb6be8] <chr> 
    ## │       ├─Q21_3_4 = [250:0x5645e2eb6b78] <chr> 
    ## │       ├─Q21_4_5 = [251:0x5645e2eb6b08] <chr> 
    ## │       ├─Q21_4_2 = [252:0x5645e2eb6a98] <chr> 
    ## │       ├─Q21_4_3 = [253:0x5645e2eb6a28] <chr> 
    ## │       ├─Q21_4_4 = [254:0x5645e2eb69b8] <chr> 
    ## │       ├─Q21_5_5 = [255:0x5645e2eb6948] <chr> 
    ## │       ├─Q21_5_2 = [256:0x5645e2eb68d8] <chr> 
    ## │       ├─Q21_5_3 = [257:0x5645e2eb6868] <chr> 
    ## │       └─Q21_5_4 = [258:0x5645e2eb67f8] <chr> 
    ## ├─Q22 = █ [259:0x5645e2eb6788] <tbl_df[,8]> 
    ## │       ├─Institution Name = [260:0x5645e2eb6718] <chr> 
    ## │       ├─Undergraduate enrollment = [261:0x5645e2eb66a8] <chr> 
    ## │       ├─Q22_1_1 = [262:0x5645e2eb6638] <chr> 
    ## │       ├─Q22_2_1 = [263:0x5645e2eb65c8] <chr> 
    ## │       ├─Q22_3_1 = [264:0x5645e2eb6558] <chr> 
    ## │       ├─Q22_4_1 = [265:0x5645e2eb64e8] <chr> 
    ## │       ├─Q22_5_1 = [266:0x5645e2eb6478] <chr> 
    ## │       └─Q22_6_1 = [267:0x5645e2eb6408] <chr> 
    ## ├─Q23 = █ [268:0x5645e2eb6328] <tbl_df[,5]> 
    ## │       ├─Institution Name = [269:0x5645e2eb62b8] <chr> 
    ## │       ├─Undergraduate enrollment = [270:0x5645e2eb6248] <chr> 
    ## │       ├─Q23_1 = [271:0x5645e2eb61d8] <chr> 
    ## │       ├─Q23_4 = [272:0x5645e2eb6168] <chr> 
    ## │       └─Q23_2 = [273:0x5645e2eb60f8] <chr> 
    ## ├─Q24 = █ [274:0x5645e2eaefa8] <tbl_df[,11]> 
    ## │       ├─Institution Name = [275:0x5645e2eb6018] <chr> 
    ## │       ├─Undergraduate enrollment = [276:0x5645e2eb5fa8] <chr> 
    ## │       ├─Q24_1_1 = [277:0x5645e2eb5f38] <chr> 
    ## │       ├─Q24_1_2 = [278:0x5645e2eb5ec8] <chr> 
    ## │       ├─Q24_1_5 = [279:0x5645e2eb5e58] <chr> 
    ## │       ├─Q24_2_1 = [280:0x5645e2eb5de8] <chr> 
    ## │       ├─Q24_2_2 = [281:0x5645e2eb5d78] <chr> 
    ## │       ├─Q24_2_5 = [282:0x5645e2eb5d08] <chr> 
    ## │       ├─Q24_3_1 = [283:0x5645e2eb5c98] <chr> 
    ## │       ├─Q24_3_2 = [284:0x5645e2eb5c28] <chr> 
    ## │       └─Q24_3_5 = [285:0x5645e2eb5bb8] <chr> 
    ## └─Q25 = █ [286:0x5645e2eb5538] <tbl_df[,3]> 
    ##         ├─Institution Name = [287:0x5645e2eb5b48] <chr> 
    ##         ├─Undergraduate enrollment = [288:0x5645e2eb5ad8] <chr> 
    ##         └─Q25 = [289:0x5645e2eb5a68] <chr>

# Functions for Analysis

Script: **3\_functions.R**

## Motivation

To get a sense for why the following custom functions are useful, let’s
inspect some of the raw data.

Below are several questions from the survey.

    ## Question 2

    ## # A data frame: 5 × 4
    ##   `Institution Name`            `Undergraduate enrollment` Q2          Q2_6_TEXT
    ## * <chr>                         <chr>                      <chr>       <chr>    
    ## 1 Vassar College                2439                       Student Af… <NA>     
    ## 2 Williams College              2094                       Other:      Office o…
    ## 3 Brandeis College              3688                       Student Af… <NA>     
    ## 4 College of the Holy Cross     2963                       Academic A… <NA>     
    ## 5 Franklin and Marshall College 2315                       Student Af… <NA>

    ## 
    ## Question 4

    ## # A data frame: 5 × 11
    ##   `Institution Name`  `Undergraduate…` Q4_3  Q4_4  Q4_5  Q4_6  Q4_7  Q4_8  Q4_9 
    ## * <chr>               <chr>            <chr> <chr> <chr> <chr> <chr> <chr> <chr>
    ## 1 Vassar College      2439             <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA> 
    ## 2 Williams College    2094             <NA>  Alum… <NA>  <NA>  <NA>  <NA>  <NA> 
    ## 3 Brandeis College    3688             <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA> 
    ## 4 College of the Hol… 2963             <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA> 
    ## 5 Franklin and Marsh… 2315             <NA>  <NA>  <NA>  <NA>  <NA>  <NA>  <NA> 
    ## # … with 2 more variables: Q4_10 <chr>, Q4_9_TEXT <chr>

    ## 
    ## Question 5

    ## # A data frame: 5 × 14
    ##   `Institution Name`  `Undergraduate…` Q5_6  Q5_7  Q5_8  Q5_9  Q5_10 Q5_15 Q5_1 
    ## * <chr>               <chr>            <chr> <chr> <chr> <chr> <chr> <chr> <chr>
    ## 1 Vassar College      2439             2     9     6     8     3     4     1    
    ## 2 Williams College    2094             1     7     6     9     4     3     5    
    ## 3 Brandeis College    3688             1     6     5     7     3     4     8    
    ## 4 College of the Hol… 2963             2     3     9     7     1     4     8    
    ## 5 Franklin and Marsh… 2315             2     4     3     8     5     6     1    
    ## # … with 5 more variables: Q5_16 <chr>, Q5_11 <chr>, Q5_12 <chr>, Q5_13 <chr>,
    ## #   Q5_13_TEXT <chr>

    ## 
    ## Question 6

    ## # A data frame: 5 × 8
    ##   `Institution Name`  `Undergraduate…` Q6_1_1 Q6_1_2 Q6_2_1 Q6_2_2 Q6_3_1 Q6_3_2
    ## * <chr>               <chr>            <chr>  <chr>  <chr>  <chr>  <chr>  <chr> 
    ## 1 Vassar College      2439             5      0      4      0      0      0     
    ## 2 Williams College    2094             8      0      16     0      0      0     
    ## 3 Brandeis College    3688             6      0      3      1      0      0     
    ## 4 College of the Hol… 2963             8      0      0      0      0      0     
    ## 5 Franklin and Marsh… 2315             0      0      10     0      0      0

    ## 
    ## Question 7

    ## # A data frame: 5 × 8
    ##   `Institution Name` `Undergraduate…` Q7_1_9 Q7_1_2 Q7_1_3 Q7_1_4 Q7_1_5 Q7_1_10
    ## * <chr>              <chr>            <chr>  <chr>  <chr>  <chr>  <chr>  <chr>  
    ## 1 Vassar College     2439             9      8      0      0      1      8.25   
    ## 2 Williams College   2094             11     10     0      0      1      10     
    ## 3 Brandeis College   3688             15     14     1      0      0      14.85  
    ## 4 College of the Ho… 2963             11     8      0.83   0.5    0.42   9.75   
    ## 5 Franklin and Mars… 2315             10     7      3      0      0      10

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

The challenge with this approach is building the functions. Custom
functions can be a bit intimidating at first, but what they lack in
simplicity they make up for in speed.

## Functions

Script: **3\_functions.R**

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
    ##   `Institution Name`            `Undergraduate enrollment` Q2          Q2_6_TEXT
    ## * <chr>                         <chr>                      <chr>       <chr>    
    ## 1 Vassar College                2439                       Student Af… <NA>     
    ## 2 Williams College              2094                       Other:      Office o…
    ## 3 Brandeis College              3688                       Student Af… <NA>     
    ## 4 College of the Holy Cross     2963                       Academic A… <NA>     
    ## 5 Franklin and Marshall College 2315                       Student Af… <NA>

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
    ##   `Institution Name`  `Undergraduate…` Q6_1_1 Q6_1_2 Q6_2_1 Q6_2_2 Q6_3_1 Q6_3_2
    ## * <chr>               <chr>            <chr>  <chr>  <chr>  <chr>  <chr>  <chr> 
    ## 1 Vassar College      2439             5      0      4      0      0      0     
    ## 2 Williams College    2094             8      0      16     0      0      0     
    ## 3 Brandeis College    3688             6      0      3      1      0      0     
    ## 4 College of the Hol… 2963             8      0      0      0      0      0     
    ## 5 Franklin and Marsh… 2315             0      0      10     0      0      0

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
    ##   `Institution Name` `Undergraduate…` Q7_1_9 Q7_1_2 Q7_1_3 Q7_1_4 Q7_1_5 Q7_1_10
    ## * <chr>              <chr>            <chr>  <chr>  <chr>  <chr>  <chr>  <chr>  
    ## 1 Vassar College     2439             9      8      0      0      1      8.25   
    ## 2 Williams College   2094             11     10     0      0      1      10     
    ## 3 Brandeis College   3688             15     14     1      0      0      14.85  
    ## 4 College of the Ho… 2963             11     8      0.83   0.5    0.42   9.75   
    ## 5 Franklin and Mars… 2315             10     7      3      0      0      10

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

Script: **4\_analysis.R**

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

    ## █ [1:0x5645e2ee00d8] <named list> 
    ## ├─single = █ [2:0x5645e2ee0068] <named list> 
    ## │          ├─Q2 = █ [3:0x5645e2edb6a8] <tbl_df[,3]> 
    ## │          │      ├─Q2 = [4:0x5645e2edb658] <chr> 
    ## │          │      ├─n = [5:0x5645e2ed6bd8] <int> 
    ## │          │      └─freq = [6:0x5645e2edb608] <dbl> 
    ## │          ├─Q3 = █ [7:0x5645e2edb518] <tbl_df[,3]> 
    ## │          │      ├─Q3 = [8:0x5645e2ed6b98] <chr> 
    ## │          │      ├─n = [9:0x5645e1cf0358] <int> 
    ## │          │      └─freq = [10:0x5645e2ed6b58] <dbl> 
    ## │          ├─Q12 = █ [11:0x5645e2edb428] <tbl_df[,3]> 
    ## │          │       ├─Q12 = [12:0x5645e2edb3d8] <chr> 
    ## │          │       ├─n = [13:0x5645e2ed6b18] <int> 
    ## │          │       └─freq = [14:0x5645e2edb388] <dbl> 
    ## │          ├─Q14 = █ [15:0x5645e2edb298] <tbl_df[,3]> 
    ## │          │       ├─Q14 = [16:0x5645e1cf02b0] <chr> 
    ## │          │       ├─n = [17:0x5645e1cf0278] <int> 
    ## │          │       └─freq = [18:0x5645e1cf0240] <dbl> 
    ## │          ├─Q16 = █ [19:0x5645e2edb1a8] <tbl_df[,3]> 
    ## │          │       ├─Q16 = [20:0x5645e1cf01d0] <chr> 
    ## │          │       ├─n = [21:0x5645e1cf0198] <int> 
    ## │          │       └─freq = [22:0x5645e1cf0160] <dbl> 
    ## │          └─Q25 = █ [23:0x5645e2edb0b8] <tbl_df[,3]> 
    ## │                  ├─Q25 = [24:0x5645e1cf00f0] <chr> 
    ## │                  ├─n = [25:0x5645e1cf00b8] <int> 
    ## │                  └─freq = [26:0x5645e1cf0080] <dbl> 
    ## ├─multi = █ [27:0x5645e2edff88] <named list> 
    ## │         ├─Q4 = █ [28:0x5645e2edafc8] <tbl_df[,3]> 
    ## │         │      ├─value = [29:0x5645e2ed6ad8] <chr> 
    ## │         │      ├─n = [30:0x5645e1cf0010] <int> 
    ## │         │      └─freq = [31:0x5645e2ed6a98] <dbl> 
    ## │         ├─Q9 = █ [32:0x5645e2edaed8] <tbl_df[,3]> 
    ## │         │      ├─value = [33:0x5645e2edff18] <chr> 
    ## │         │      ├─n = [34:0x5645e2edae88] <int> 
    ## │         │      └─freq = [35:0x5645e2edfea8] <dbl> 
    ## │         ├─Q10 = █ [36:0x5645e2edad98] <tbl_df[,3]> 
    ## │         │       ├─value = [37:0x5645e2edfe38] <chr> 
    ## │         │       ├─n = [38:0x5645e2edad48] <int> 
    ## │         │       └─freq = [39:0x5645e2edfdc8] <dbl> 
    ## │         ├─Q11 = █ [40:0x5645e2edac58] <tbl_df[,3]> 
    ## │         │       ├─value = [41:0x5645e2ee0150] <chr> 
    ## │         │       ├─n = [42:0x5645e2ed7f08] <int> 
    ## │         │       └─freq = [43:0x5645e2ee0240] <dbl> 
    ## │         ├─Q13 = █ [44:0x5645e2edab68] <tbl_df[,3]> 
    ## │         │       ├─value = [45:0x5645e2ed6a58] <chr> 
    ## │         │       ├─n = [46:0x5645e1cefef8] <int> 
    ## │         │       └─freq = [47:0x5645e2ed6a18] <dbl> 
    ## │         └─Q15 = █ [48:0x5645e2edaa78] <tbl_df[,3]> 
    ## │                 ├─value = [49:0x5645e2edaa28] <chr> 
    ## │                 ├─n = [50:0x5645e2ed69d8] <int> 
    ## │                 └─freq = [51:0x5645e2eda9d8] <dbl> 
    ## ├─matrix = █ [52:0x5645e2edfce8] <named list> 
    ## │          ├─Q6 = █ [53:0x5645e2eda8e8] <df[,4]> 
    ## │          │      ├─dim2 = [54:0x5645e2ed6998] <chr> 
    ## │          │      ├─Students in paraprofessional roles = [55:0x5645e2ed6958] <dbl> 
    ## │          │      ├─Students in administrative roles = [56:0x5645e2ed6918] <dbl> 
    ## │          │      └─Students in "hybrid" roles (e.g., student workers have both paraprofessional and administrative duties) = [57:0x5645e2ed68d8] <dbl> 
    ## │          ├─Q8 = █ [58:0x5645e2ed7e58] <df[,15]> 
    ## │          │      ├─dim2 = [59:0x5645e2eda848] <chr> 
    ## │          │      ├─Student Counseling/Advising = [60:0x5645e2eda7f8] <dbl> 
    ## │          │      ├─Health Professions Advising = [61:0x5645e2eda7a8] <dbl> 
    ## │          │      ├─Alumni Counseling/Advising = [62:0x5645e2eda758] <dbl> 
    ## │          │      ├─Fellowship Advising = [63:0x5645e2eda708] <dbl> 
    ## │          │      ├─Pre-Law Advising = [64:0x5645e2eda6b8] <dbl> 
    ## │          │      ├─Program/Event Planning = [65:0x5645e2eda668] <dbl> 
    ## │          │      ├─Marketing/Communications = [66:0x5645e2eda618] <dbl> 
    ## │          │      ├─Employer Relations = [67:0x5645e2eda5c8] <dbl> 
    ## │          │      ├─Internship Funding = [68:0x5645e2eda578] <dbl> 
    ## │          │      ├─Office Management/Front Desk = [69:0x5645e2eda528] <dbl> 
    ## │          │      ├─Supervision of Professional Staff = [70:0x5645e2eda4d8] <dbl> 
    ## │          │      ├─Budget Management = [71:0x5645e2eda488] <dbl> 
    ## │          │      ├─Technology Management = [72:0x5645e2eda438] <dbl> 
    ## │          │      └─Assessment (Data, Outcomes, Program) = [73:0x5645e2eda3e8] <dbl> 
    ## │          ├─Q36 = █ [74:0x5645e2edfc78] <df[,7]> 
    ## │          │       ├─dim2 = [75:0x5645e2ed6898] <chr> 
    ## │          │       ├─Number of career fairs offered on-campus or only for students at your institution (not including grad/prof school fairs) = [76:0x5645e2ed6858] <dbl> 
    ## │          │       ├─Number of information sessions offered by employers (coordinated by your office) = [77:0x5645e2ed6818] <dbl> 
    ## │          │       ├─Number of interviews conducted on-campus or virtual interviews coordinated by your office (total number, not unique students) *record interviews affiliated with consortia/off-campus events below = [78:0x5645e2ed67d8] <dbl> 
    ## │          │       ├─Number of interviews conducted through consortia/off-campus events (total number, not unique students) = [79:0x5645e2ed6798] <dbl> 
    ## │          │       ├─Number of career "treks" (immersion trips lasting at least one day) = [80:0x5645e2ed6758] <dbl> 
    ## │          │       └─Number of job shadows (total number, not unique students) = [81:0x5645e2ed6718] <dbl> 
    ## │          ├─Q37 = █ [82:0x5645e2edfb98] <df[,5]> 
    ## │          │       ├─dim2 = [83:0x5645e2ed66d8] <chr> 
    ## │          │       ├─Number of employers who attended career fairs offered on-campus or only for students at your institution (not including graduate/professional school fairs) = [84:0x5645e2ed6698] <dbl> 
    ## │          │       ├─Number of employers who offered information sessions coordinated by your office = [85:0x5645e2ed6658] <dbl> 
    ## │          │       ├─Number of employers who conducted interviews on-campus or virtual interviews coordinated by your office = [86:0x5645e2ed6618] <dbl> 
    ## │          │       └─Number of employers who conducted interviews through consortia/off-campus events = [87:0x5645e2ed65d8] <dbl> 
    ## │          ├─Q20 = █ [88:0x5645e2edfab8] <df[,7]> 
    ## │          │       ├─dim2 = [89:0x5645e2ed6598] <chr> 
    ## │          │       ├─# appointments with first-year students by professional staff = [90:0x5645e2ed6558] <dbl> 
    ## │          │       ├─# appointments with sophomore students by professional staff = [91:0x5645e2ed6518] <dbl> 
    ## │          │       ├─# appointments with junior students by professional staff = [92:0x5645e2ed64d8] <dbl> 
    ## │          │       ├─# appointments with senior students by professional staff = [93:0x5645e2ed6498] <dbl> 
    ## │          │       ├─TOTAL #  appointments with students by professional staff = [94:0x5645e2ed6458] <dbl> 
    ## │          │       └─# appointments with alumni by professional staff = [95:0x5645e2ed6418] <dbl> 
    ## │          ├─Q21 = █ [96:0x5645e2edf9d8] <df[,6]> 
    ## │          │       ├─dim2 = [97:0x5645e2ee21d8] <chr> 
    ## │          │       ├─First-Year = [98:0x5645e2ee2188] <dbl> 
    ## │          │       ├─Sophomore = [99:0x5645e2ee2138] <dbl> 
    ## │          │       ├─Junior = [100:0x5645e2ee20e8] <dbl> 
    ## │          │       ├─Senior = [101:0x5645e2ee2098] <dbl> 
    ## │          │       └─TOTAL (all classes) = [102:0x5645e2ee2048] <dbl> 
    ## │          └─Q24 = █ [103:0x5645e2ee1ff8] <df[,4]> 
    ## │                  ├─dim2 = [104:0x5645e2ee1fa8] <chr> 
    ## │                  ├─Income from endowed funds = [105:0x5645e2ee1f58] <dbl> 
    ## │                  ├─Expendable gifts = [106:0x5645e2ee1f08] <dbl> 
    ## │                  └─Other = [107:0x5645e2ee1eb8] <dbl> 
    ## ├─continuous = █ [108:0x5645e2ee1e18] <named list> 
    ## │              ├─Q7 = █ [109:0x5645e2ed63d8] <tbl_df[,2]> 
    ## │              │      ├─dim2 = [110:0x5645e2edf888] <chr> 
    ## │              │      └─mean = [111:0x5645e2edf818] <dbl> 
    ## │              ├─Q19 = █ [112:0x5645e2ed6358] <tbl_df[,2]> 
    ## │              │       ├─dim1 = [113:0x5645e2ee1d78] <chr> 
    ## │              │       └─mean = [114:0x5645e2ee1d28] <dbl> 
    ## │              ├─Q22 = █ [115:0x5645e2ed62d8] <tbl_df[,2]> 
    ## │              │       ├─dim1 = [116:0x5645e2edf7a8] <chr> 
    ## │              │       └─mean = [117:0x5645e2edf738] <dbl> 
    ## │              └─Q23 = █ [118:0x5645e2ed6258] <tbl_df[,2]> 
    ## │                      ├─dim1 = [119:0x5645e2ee1c38] <chr> 
    ## │                      └─mean = [120:0x5645e2ee1be8] <dbl> 
    ## └─ranking = █ [121:0x5645e1cefa60] <named list> 
    ##             └─Q5 = █ [122:0x5645e2ee1af8] <tbl_df[,3]> 
    ##                    ├─Question = [123:0x5645e2ee4098] <chr> 
    ##                    ├─dim1 = [124:0x5645e2ee3fe8] <chr> 
    ##                    └─ranking_avg = [125:0x5645e2ee3f38] <dbl>

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

Script: **5\_viz.R**

*In progress. Please check back later.*

![example-plot](images/rank_plot.PNG)

# IPEDS Data

*In progress. Please check back later.*
