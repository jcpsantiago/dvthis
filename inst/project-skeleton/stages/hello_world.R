#!/usr/bin/env Rscript
#
this_stage <- dvthis::stage_header("Hello and welcome to this DVC pipeline!")

# do some meaningful work
set.seed(84573920)
dvthis::log_stage_step("Generating some random numbers because it's important!")
random_numbers <- rnorm(100, 1, 1)

dvthis::log_stage_step("Here's a summary of those numbers")
summary(random_numbers)

dvthis::log_stage_step("Saving `random numbers` as an intermediate result")
dvthis::save_intermediate_result(random_numbers)

dvthis::stage_footer()
