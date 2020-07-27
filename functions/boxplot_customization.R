#' Calculate custom positions of boxplot elements
#' 
#' @param x          vector of numeric data
#' @param probs      vector of probabilities of interest
#' @param prob_names character vector of names for probabilities
#' 
#' @details For use with \code{\link[ggplot2]{stat_summary}} for creating a 
#' boxplot with non-default positions of whiskers. See 
#' \url{https://stackoverflow.com/questions/21310609/ggplot2-box-whisker-plot-show-95-confidence-intervals-remove-outliers}
boxplot_quantiles <- function(x, 
                              probs = c(0.05, 0.25, 0.5, 0.75, 0.95),
                              prob_names = c("ymin", "lower", "middle", "upper", "ymax")) {
  q_vec <- quantile(x, probs = probs)
  names(q_vec) <- prob_names
  return(q_vec)
}

#' Add outliers to boxplots
#' 
#' @param x       vector of numeric data
#' @param limits  vector indicating minimum and maximum values for identifying 
#' outliers
#' 
#' @details Using \code{\link[ggplot2]{stat_summary}} with 
#' \code{boxplot_quantiles()} will not plot outliers, so we subset those data 
#' into a separate geom. See \url{https://stackoverflow.com/questions/35274849/error-in-stat-summaryfun-y-when-plotting-outliers-in-a-modified-ggplot-boxplot}
boxplot_outliers <- function(x, limits = c(0.05, 0.95)) {
  outliers <- subset(x = x,
                     x < quantile(x = x, probs = limits[1]) | 
                       x > quantile(x = x, probs = limits[2]))
  return(outliers)
}
