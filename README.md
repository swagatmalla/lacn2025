
# File Structure

```{r file structure, echo=FALSE}
cat('Contents of lacn directory \n')
list.files("~/piper analysis/lacn")

cat('\nFiles in code subdirectory\n')
list.files("~/piper analysis/lacn/code")

cat('\nFiles in data subdirectory\n')
list.files("~/piper analysis/lacn/data")
```


# Load Data

File: **read_data.R**

The raw survey data ("lacn_2022.csv") resides in the data subdirectory of the lacn folder. The first several lines of this script load this data and remove several redundant rows. 

Next, we specify the Gooogle Sheets spreadsheet we want to connect with (this will come in handy a bit later).

The next task is creating a reference lookup table for all the questions, their descriptions, and response descriptions. We will call this our "Response Key." First we create a somewhat messy version from the raw data (**response_key_messy**). Then we send it over to Sheets for some manual cleaning before bringing it back into R, now calling it **response_key**. This will be crucial for maintaining consistent references throughout analysis and visualization.

Our final task in this initial section is creating a table of question types. Some LACN questions are single-response, some are multi-choice (more than one can be selected), some allow for a matrix of responses per college, some a continuous numeric input, and one a ordinal ranking. If we want to automate the cleaning and analysis of the survey questions, we need to be able to separate out the single-response questions from the matrix questions, etc. The **question_type** dataframe, built manually in Google Sheets and then imported into R.

Now we can move to analyzing each question on its own terms.

# Functions for Analysis

File: **lacn_functions.R**

To get a sense for why the following custom functions are useful, let's inspect some of the raw data.

# Analysis

File: **analysis.R**


Now, we have a "list" object, which is a hierarchical structure containing the cleaned and summarised data for each type of question (single, multi, matrix, continuous, ranking). See the structure map below to get a sense of how the final data is stored. It can look a bit chaotic at first, but the basic idea is this: the master list contains different question types, which each contain the relevant questions, which each contain the actual variables and data for each summarised and aggregated response. 
```{r list structure, echo=FALSE}
lobstr::ref(all_list)
```

Let's say you wanted to investigate conference attendance rates (Q9). You would note that Q9 is a multi-response question:

```{r q9 type, paged.print=FALSE}
question_type |> dplyr::filter(unique=="Q9")
```
Next, you would key into the master list in the following order: master list --> question type --> question. The '$' in the code below are how R digs into a deeper level of some object, like a list or a dataframe. Think of it as opening a door into an inner room of a house.

```{r list explore, paged.print=FALSE}
all_list$multi$Q9
```


# Visualization

File: **lacn_viz.R**



