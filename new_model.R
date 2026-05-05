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
library(aida)
library(faintr)
library(tidybayes)
library(bayesplot)
library(shinystan)
library(loo)
library(bridgesampling)

## load, process the data
data_film <- read_csv("C:/Users/kekekeke/Desktop/nlp_project/film.csv")

data_film <- data_film %>%
  mutate(top_genre = factor(is_top_genre, levels = c(FALSE, TRUE)), 
         major_company = factor(is_major_company, levels = c(FALSE, TRUE)),
         log_revenue = log1p(revenue),
         decade = factor(decade),
         main_genre = factor(main_genre)
  )
# check
head(data_film)

#split the training and test data
set.seed(123)
n <- nrow(data_film)
train_idx <- sample(seq_len(n), size = round(0.8*n))
train_data <- data_film[train_idx, ]
test_data <- data_film[-train_idx, ]

## fitting a baseline model by training data with the interaction term
fit_coef <- 
  brms::brm(
    formula = log_revenue ~ top_genre * major_company + (1 | decade),
    data    = train_data,
    chains = 4,
    iter = 2000,
    warmup = 500,
    save_pars = save_pars(all = TRUE)
  )

#summary and plot of the baseline model 
summary(fit_coef)


#compare the effect of the different condition
#within major company, compare genre effect
faintr::compare_groups(
  fit = fit_coef,
  higher = major_company == TRUE & top_genre == TRUE,
  lower  = major_company == TRUE & top_genre == FALSE
)
#without major company, compare the effect of top genre
faintr::compare_groups(
  fit = fit_coef,
  higher = major_company == FALSE & top_genre == TRUE,
  lower  = major_company == FALSE & top_genre == FALSE
)

#results: the effect of major company is signification, but genre not
#further compare the signification of the factor genre
#without genre factor
fit_no_genre <- 
  brms::brm(
    formula = log_revenue ~ major_company + (1 | decade),
    data    = train_data,
    chains = 4,
    iter = 2000,
    warmup = 500,
    save_pars = save_pars(all = TRUE)
  )
#with genre factor
fit_with_genre <- 
  brms::brm(
    formula = log_revenue ~ top_genre + major_company + (1 | decade),
    data    = train_data,
    chains = 4,
    iter = 2000,
    warmup = 500,
    save_pars = save_pars(all = TRUE)
  )

#compare by loo
loo_no <- loo(fit_no_genre)
loo_with <- loo(fit_with_genre)
loo_compare(loo_with, loo_no)

#compare by BF
bridge_no <- bridge_sampler(fit_no_genre)
bridge_with <- bridge_sampler(fit_with_genre)
bridgesampling::bf(bridge_with, bridge_no)

#prove that genre do effect the revenue
#so the problem goes to maybe interaction term influence the effect of genre
#compare model use interaction term and without it.

#compare by loo
loo_normal <- loo(fit_with_genre)
loo_inter <- loo(fit_coef)

loo_compare(loo_normal, loo_inter)

#compare by BF
bridge_normal <- bridge_sampler(fit_with_genre)
bridge_inter <- bridge_sampler(fit_coef)
bridgesampling::bf(bridge_inter, bridge_normal)

#keep interaction is better 
#parameter's posterior distribution
posterior <- as_draws_df(fit_coef)
mcmc_areas(posterior,
           pars = c("b_top_genreTRUE", "b_major_companyTRUE",
                    "b_top_genreTRUE:major_companyTRUE"),
           prob = 0.95)
#posterior prediction on test data
y_pred <- posterior_predict(fit_coef, newdata = test_data)
y_pred_mean <- colMeans(y_pred)
#rmse
rmse <- sqrt(mean((test_data$log_revenue - y_pred_mean)^2))
rmse
#coverage (95% credible interval)
pred_interval <- apply(y_pred, 2, quantile, probs = c(0.025, 0.975))
coverage <- mean(test_data$log_revenue >= pred_interval[1,] & 
                   test_data$log_revenue <= pred_interval[2,])
coverage
#plot
bayesplot::ppc_dens_overlay(test_data$log_revenue, y_pred[1:100, ])



