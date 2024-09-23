# Example
#
# $ Rscript --vanilla \
#     bench/scripts/plot_bench_results.R \
#     bench/bench_out/bench_full__*.txt.gz

library(tidyverse)
library(scales)

read_bench <- function(filename) {
  read_delim(filename, delim = "|") |>
    # mutate(group = 2) |>
    filter(func != "ignore")
}

filenames <- commandArgs(trailingOnly = TRUE)

dat <- filenames |>
  purrr::map(read_bench) |>
  bind_rows()

draw_plot <- function(dat) {
  dat |>
    mutate(monotime = monotime / 1e3) |>
    group_by(func, id) |>
    summarise(
      time = mean(monotime),
      time_sd = sd(monotime),
      category = unique(category)
    ) |>
    ggplot(aes(y = func, x = time, fill = id)) +
    geom_col(
      position = position_dodge2(
        width = NULL, reverse = TRUE, preserve = "single"
      )
    ) +
    geom_errorbar(
      aes(xmin = time - (2 * time_sd), xmax = time + (2 * time_sd)),
      position = position_dodge2(
        width = 0.5,
        reverse = TRUE,
        preserve = "total",
        padding = 0.85
      )
    ) +
    scale_y_discrete(
      limits = rev,
      labels = function(y) {
        y |>
          str_replace_all("_", " ") |>
          str_replace_all("\\(", " (") |>
          str_replace_all("\\)", ") ") |>
          str_wrap(width = 15)
      }
    ) +
    scale_fill_viridis_d(begin = 0.1, end = 0.9) +
    scale_x_continuous(labels = comma) +
    ylab("Function") +
    xlab("Time (ms)") +
    facet_wrap(~category, scales = "free", nrow = 2) +
    guides(fill = guide_legend(title = "Implementation"))
}

plt <- dat |> draw_plot()

ggsave(
  "bench/bench_out/bench_full__XYZ__charts.svg",
  plt,
  width = 18, heigh = 9
)


plt <- dat |>
  filter(category %in% c("Characters", "Collections", "Strings")) |>
  draw_plot()

ggsave(
  "bench/bench_out/bench_full__XYZ__charts_subset.svg",
  plt,
  width = 18, heigh = 9
)
