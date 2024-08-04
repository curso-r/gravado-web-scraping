library(purrr)
library(furrr)
library(progressr)

walk(1:10, \(x) Sys.sleep(1), .progress = TRUE)


plan(multisession, workers = 4)
dormir <- function(x, p) {
  p()
  Sys.sleep(1)
}

with_progress({
  p <- progressor(16)
  future_walk(
    1:16,
    \(x) dormir(x, p)
  )
})




