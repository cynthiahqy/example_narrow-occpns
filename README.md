# Using the xmap structure to explore STATA aggregation script


## Setup

``` r
install.packages("xmap")
```

## Extract transformation

The first step is creating the “carbon copy” object that stands in for
original data:

<div class="code-with-filename">

**01-carbon-from.R**

``` r
library(tidyverse)
read_csv("inbox/occupation-data.csv") -> default_df
default_df |>
  distinct(occupn) |>
  arrange(occupn) |>
  write_csv("interim/occupn-vector.csv")
```

</div>

This is done by extracting all the unique values of `occupn` codes from
the `occupation-data.csv` data:

``` r
readr::read_csv("interim/occupn-vector.csv", show_col_types = FALSE) |> glimpse()
```

    Rows: 330
    Columns: 1
    $ occupn <dbl> 110, 120, 140, 190, 1110, 1120, 1130, 1141, 1142, 1143, 1210, 1…

Pass this “carbon paper” vector into a modified version of the data
aggregation script (`inbox/occupations do file.docx`) instead of the
original data and save the output. See
[`02-trace-do-file.log`](02-trace-do-file.log) for the output of the
STATA script.

<div class="code-with-filename">

**02-trace-do-file.do**

``` stata
/* merged data occupation*/
/* professional, manager, teacher, assprofclerk, svcsales, armforces, 
xefe, farmer, craftrademach, labourer, driver, notclass */

// use "C:\Users\binder\Dropbox\brett folders\Census 2015\Unit Record Data files\merged data.dta", clear
import delimited "/Users/chua0032/Library/CloudStorage/Dropbox/Conformr/brett_occupations/interim/occupn-vector.csv", varnames(1) numericcols(_all)

gen farmer=0
replace farmer=1 if occupn>6000 & occupn<7000
gen teacher=0
replace teacher=1 if occupn>2400 & occupn<2500
gen professional=0
replace professional=1 if occupn>2000 & occupn<3000 & teacher==0
gen manager=0
replace manager=1 if occupn>1000 & occupn<1129
replace manager=1 if occupn>1131 & occupn<2000
gen armforces=0
replace armforces=1 if occupn<200 
gen xefe=0
replace xefe=1 if occupn==1130
gen assprofclerk=0
replace assprofclerk=1 if occupn>3000 & occupn<5000
gen svcsales=0
replace svcsales=1 if occupn>5000 & occupn<6000
replace svcsales=1 if occupn>9000 & occupn<9200
gen labourer=0
replace labourer=1 if occupn>9200 & occupn<9320
gen driver=0
replace driver=1 if occupn>8320 & occupn<8330
replace driver=1 if occupn>9330 & occupn<9340
gen craftrademach=0
replace craftrademach=1 if occupn>7000 & occupn<9000 & driver==0
gen notclass=0
replace notclass=1 if occupn>9990 & occupn<10000

// sum professional manager teacher assprofclerk svcsales armforces xefe farmer craftrademach labourer driver notclass if p3p30_school_level==6

save "/Users/chua0032/Library/CloudStorage/Dropbox/Conformr/brett_occupations/interim/occupn-inc-matrix.dta"
```

</div>

The output STATA data file contains the xmap in matrix form:

``` r
haven::read_dta("interim/occupn-inc-matrix.dta")
```

    # A tibble: 330 × 13
       occupn farmer teacher professional manager armforces  xefe assprofclerk
        <dbl>  <dbl>   <dbl>        <dbl>   <dbl>     <dbl> <dbl>        <dbl>
     1    110      0       0            0       0         1     0            0
     2    120      0       0            0       0         1     0            0
     3    140      0       0            0       0         1     0            0
     4    190      0       0            0       0         1     0            0
     5   1110      0       0            0       1         0     0            0
     6   1120      0       0            0       1         0     0            0
     7   1130      0       0            0       0         0     1            0
     8   1141      0       0            0       1         0     0            0
     9   1142      0       0            0       1         0     0            0
    10   1143      0       0            0       1         0     0            0
    # ℹ 320 more rows
    # ℹ 5 more variables: svcsales <dbl>, labourer <dbl>, driver <dbl>,
    #   craftrademach <dbl>, notclass <dbl>

Extract the transformation links from the output of the previous step:

<div class="code-with-filename">

**03a-extract-links-from-dta.R**

``` r
dta <- haven::read_dta("interim/occupn-inc-matrix.dta")

inc_mtx_dta <- as.matrix(dta[-1])
rownames(inc_mtx_dta) <- dta[[1]]

## TODO: add fnc to the xmap package
links_from_matrix <- function(inc_mtx, rownames = "from") {
    stopifnot(is.matrix(inc_mtx))
    stopifnot(!is.null(rownames(inc_mtx)))
    stopifnot(!is.null(colnames(inc_mtx)))

    # from <- rownames(inc_mtx)
    # to <- colnames(inc_mtx)

    inc_mtx |>
        tibble::as_tibble(rownames = rownames) |>
        tidyr::pivot_longer(
            cols = !any_of(rownames),
            values_to = "weights",
            names_to = "to"
        ) |>
        dplyr::filter(weights != 0)
}

dta_links <- links_from_matrix(inc_mtx_dta)

dta_links |> readr::write_csv("output/dta_links.csv")
```

</div>

The extracted links can be found in
[`output/dta_links.csv`](output/dta_links.csv):

``` r
readr::read_csv("output/dta_links.csv", show_col_types = FALSE)
```

    # A tibble: 329 × 3
        from to        weights
       <dbl> <chr>       <dbl>
     1   110 armforces       1
     2   120 armforces       1
     3   140 armforces       1
     4   190 armforces       1
     5  1110 manager         1
     6  1120 manager         1
     7  1130 xefe            1
     8  1141 manager         1
     9  1142 manager         1
    10  1143 manager         1
    # ℹ 319 more rows

From here, we can:

- visualise/summarise the links
- verify the transformation is correct (i.e. the links form a valid
  xmap)
- apply the xmap to the original data and compare it with data produced
  by the STATA script
