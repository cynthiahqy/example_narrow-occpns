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
