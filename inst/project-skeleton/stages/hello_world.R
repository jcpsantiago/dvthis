#!/usr/bin/env Rscript
#
this_stage <- dvcru::stage_header("Hello and welcome to this DVC pipeline!")

# do some meaningful work
set.seed(84573920)
dvcru::log_stage_step("Generating some random numbers because it's important!")
random_numbers <- rnorm(100, 1, 1)

dvcru::log_stage_step("Here's a summary of those numbers")
summary(random_numbers)

dvcru::log_stage_step("Saving `random numbers` as an intermediate result")
dvcru::save_intermediate_result(random_numbers)

dvcru::stage_footer()
