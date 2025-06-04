library(here)
library(readr)
library(dplyr)
library(ggplot2)
library(ggraph)

# remotes::install_github("cynthiahqy/conformr-xmap-project@xmap-v0.0.1.9002", subdir = "xmap")
## can't check duplicates if factor?

## convert to xmap

links <- readr::read_csv(here("output", "dta_links.csv"),
    col_types = cols(
        from = col_character(),
        to = col_character(),
        weights = col_double()
    )
)

## validate as xmap

xmap::diagnose_as_xmap_tbl(links, from, to, weights)

## summarise
paper_example <- links |>
    xmap::as_xmap_tbl(from, to, weights) |>
    purrr::flatten_df() |>
    dplyr::mutate(from2 = substr(from, 1, 2), from3 = substr(from, 1, 3)) |>
    dplyr::group_by(to) |>
    dplyr::summarise(
        n_from = n(),
        n_unique = n_distinct(from),
        parts_from3 = glue::glue_collapse(unique(from3), ","),
        parts_from = glue::glue_collapse(from, ",")
    ) |>
    arrange(desc(n_from))

write_csv(paper_example, here("output", "paper_example_stata-agg.csv"))
