## install packages
install.packages(c(
  "tidyverse",
  "brms",
  "rstan",
  "tidybayes",
  "bayesplot",
  "shinystan",
  "bridgesampling",
  "emmeans"
))
library(tidyverse)
library(brms)
## load, process the data
data_film <- read_csv("C:/Users/kekekeke/Desktop/nlp_project/revenue.csv")

data_film <- data_film %>%
  mutate(top_genre_decade  = factor(top_genre_decade, levels = c(FALSE, TRUE)), 
         top_genre_production = factor(top_genre_production, levels = c(FALSE, TRUE)),
         log_revenue = log1p(revenue),
         decade = factor(decade),
         company = factor(production_companies)
  )
# check
head(data_film)
## fitting a model
fit_film <- 
  brms::brm(
    formula = log_revenue ~ top_genre_decade * top_genre_production,
    data    = data_film,
    chains = 4,
    iter = 2000,
    warmup = 500
  )
# quick-plot for conditional effects
brms::conditional_effects(fit_film)
brms::conditional_effects(fit_film, method = "posterior_predict")
#summary of the basic model
summary(fit_film)

#fitting the multi-level model
fit_ml <- 
  brms::brm(
    formula = log_revenue ~ top_genre_decade * top_genre_production + (1 | decade + company),
    data    = data_film,
    chains = 4,
    iter = 2000,
    warmup = 500
  )
#summary of the multi-level model
summary(fit_ml)

