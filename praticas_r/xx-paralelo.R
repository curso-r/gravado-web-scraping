library(future)
library(furrr)

# para medir os tempos
library(tictoc)
library(purrr)

tic()
walk(1:4, \(x) Sys.sleep(1))
toc()


plan(multisession, workers = 8)
tic()
future_walk(1:8, \(x) Sys.sleep(1))
toc()





