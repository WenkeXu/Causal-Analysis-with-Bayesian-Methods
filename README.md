# Causal-Analysis-with-Bayesian-Methods
Constructing a Bayesian generalized linear mixed-effects model to investigate the impact of two variables—film genre and production company—on predicted movie box office revenue.
## data_process.ipynb 
A streamlined Python data science pipeline demonstrating how to efficiently preprocess raw data, apply conditional labeling, and generate production-ready statistical visualizations.
* **Advanced Data Filtering:**
Leveraging `pandas` query and boolean indexing for rapid data subsetting. 
* **Dynamic Labeling & Feature Engineering:**
Implementing conditional logic to categorize and prepare features.
* **Statistical Visualization:**
Utilizing `seaborn` to create publication-quality plots (distribution, categorical, and corelation analysis).
## new_model.R
### Features & Workflow

* **Data Engineering:** Log-transformation of highly skewed revenue data ($log1p$) and train-test splitting (80/20).
* **Bayesian Hierarchical Modeling:** Group-level (random) effects grouped by `decade` to control for macroeconomic/industry shifts over time.
* **Model Comparison Pipeline:** Comprehensive model selection using **Leave-One-Out Cross-Validation (LOO-CV)** and **Bayes Factors (BF)** via Bridge Sampling.
* **Post-Estimation Diagnostics:** High-quality uncertainty visualizations of parameter posterior distributions and out-of-sample posterior predictive checks (PPC).
