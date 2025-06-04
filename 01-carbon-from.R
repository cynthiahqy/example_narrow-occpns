library(readr)
library(dplyr)
read_csv("inbox/occupation-data.csv") -> default_df
default_df |>
  distinct(occupn) |>
  arrange(occupn) |>
  write_csv("interim/occupn-vector.csv")
