% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils_scatter.R
\name{gg_scatter_color_facet}
\alias{gg_scatter_color_facet}
\title{Colored point plot (scatter-plot) with facets}
\usage{
gg_scatter_color_facet(df, x_var, y_var, col_var = NULL, facet_var = NULL, ...)
}
\arguments{
\item{df}{input dataset (tibble or data.frame)}

\item{x_var}{x variable (supplied to \code{ggplot2::aes(x = )})}

\item{y_var}{y variable (supplied to \code{ggplot2::aes(y = )})}

\item{col_var}{color variable (supplied to \code{ggplot2::geom_point(ggplot2::aes(color = ))})}

\item{facet_var}{facet variable (supplied to \code{ggplot2::geom_point(ggplot2::aes(color = ))})}

\item{...}{other arguments passed to (\code{ggplot2::facet_wrap(vars())})}
}
\value{
A \code{ggplot2} plot object
}
\description{
Colored point plot (scatter-plot) with facets
}
\examples{
diamonds <- ggplot2::diamonds
mini_dmnds <- diamonds[sample(nrow(diamonds), 10000), ]
gg_scatter_color_facet(
  df = mini_dmnds,
  x_var = "carat",
  y_var = "price",
  col_var = "cut",
  facet_var = "cut",
  alpha = 1 / 3,
  size = 2
)
# compare with
ggplot2::ggplot(
  data = mini_dmnds,
  mapping = ggplot2::aes(x = carat, y = price)
) +
  ggplot2::geom_point(ggplot2::aes(color = cut, group = cut),
    size = 2, alpha = 1 / 3
  ) +
  ggplot2::facet_wrap(. ~ cut) +
  ggplot2::theme_minimal() +
  ggplot2::theme(legend.position = "bottom")
gg_scatter_color_facet(
  df = mini_dmnds,
  x_var = "carat",
  y_var = "price",
  col_var = "cut",
  facet_var = NULL,
  alpha = 1 / 3,
  size = 2
)
# compare with
ggplot2::ggplot(
  data = mini_dmnds,
  mapping = ggplot2::aes(x = carat, y = price)
) +
  ggplot2::geom_point(ggplot2::aes(color = cut, group = cut),
    size = 2, alpha = 1 / 3
  ) +
  ggplot2::theme_minimal() +
  ggplot2::theme(legend.position = "bottom")
gg_scatter_color_facet(
  df = mini_dmnds,
  x_var = "carat",
  y_var = "price",
  col_var = NULL,
  facet_var = NULL,
  alpha = 1 / 3,
  size = 2
)
# compare with
ggplot2::ggplot(
  data = mini_dmnds,
  mapping = ggplot2::aes(x = carat, y = price)
) +
  ggplot2::geom_point(size = 2, alpha = 1 / 3) +
  ggplot2::theme_minimal() +
  ggplot2::theme(legend.position = "bottom")
}
