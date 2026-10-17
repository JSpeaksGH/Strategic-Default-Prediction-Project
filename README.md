# Strategic Default Prevention

## Project Overview

As part of the capstone experience at Southern New Hampshire University (SNHU), graduates are tasked with completing an end-to-end data analytics project. For my submission, I took on the role of a data scientist within the Credit Risk Department of an unnamed employer.

For this analysis, I examined 800 records containing 32 dimensions with the goal of predicting credit default using historical data. During my analysis, I used R to conduct exploratory data analysis, principal component analysis (PCA), logistic regression, and ROC/AUC model evaluation and optimization.

My analysis resulted in 73% overall accuracy and a 78% true positive rate (recall), balancing the identification of potential defaulters against false positive predictions to help prevent financial losses.

## Business Objective

- **Primary Business Problem:** Prevent financial losses from borrowers failing to settle their credit obligations with the company.
- **Primary Objective:** Predict credit risk using historical data to identify borrowers who pose the greatest risk of default.
- **Success Criteria:** Achieve a model with at least 70% prediction accuracy.
- **Business Value:** Support more informed lending decisions and reduce the potential for financial losses.

## Tools & Technologies

**Programming Language**
- R

**R Libraries**
- `Metrics`
- `pROC`
- `corrplot`
- `rms`
- `caret`
- `ResourceSelection`

**Analytical Techniques**
- Exploratory Data Analysis (EDA)
- Min-Max Scaling
- Principal Component Analysis (PCA)
- Logistic Regression
- Confusion Matrix Analysis
- ROC/AUC Evaluation and Optimization

## Dataset Description

Due to academic integrity standards at Southern New Hampshire University (SNHU), the original CSV files will not be included in this repository.

The data provided through the program was intended to simulate real-world credit department data and contained variables such as duration of credit in months, credit amount, credit history, and borrower characteristics.

- **Data Source:** SNHU-provided credit-risk datasets (training and test data)
- **Dataset Size:** 800 observations and 32 variables
- **Data Types:** Numerical and binary
- **Target Variable:** `DEFAULT` (0 = No Default, 1 = Default)
- **Data Availability:** The original datasets are not publicly available through this repository.

## Methodology

During this project, I followed the Cross-Industry Standard Process for Data Mining (CRISP-DM), which includes the following six stages:

1. Business Understanding
2. Data Understanding
3. Data Preparation
4. Modeling
5. Evaluation
6. Deployment

Exploratory analysis took place during the data understanding and preparation stages and included identifying null values (if any), duplicates (if any), and outliers. After treating outliers, I moved on to Principal Component Analysis (PCA) to reduce dimensionality within the dataset. After extracting 10 principal components, I moved on to modeling, utilizing logistic regression to classify defaulters.

Upon completion of the modeling phase, I utilized confusion matrices and various metrics, including accuracy, precision, recall, F1-score, and ROC-AUC, to evaluate and optimize the model. After assessing model effectiveness using the training data, I evaluated its performance using the test data to assess production readiness.

Based on the results yielded from the test model, which exceeded the project's accuracy objective, I determined that the model was suitable for consideration for production deployment.

## Key Findings & Model Performance

Utilizing logistic regression, I determined that the model was capable of fulfilling the project's objective of achieving 70% or greater accuracy, with the following results on test data prior to ROC/AUC optimization:

- **Accuracy:** 72.5%
- **Recall:** 65.5%
- **Precision:** 51%

However, based on my research, I determined that it was important to maximize recall to ensure that the model prioritizes identifying true positives (actual defaulters). I used ROC/AUC evaluation and optimization to accomplish this goal and found that further improvements in model performance were possible.

The optimal default probability threshold for balancing the true positive rate and false positive rate was approximately 24.84% (0.2484). At this threshold, the model yielded the following results:

- **Accuracy:** 73%
- **Recall:** 78.2%
- **Precision:** 51%

## Business Recommendations

Based on the model's performance, I recommend the following actions to minimize credit risk and prevent potential financial losses:

**1. Improve Credit Applications and Risk Assessment**
- Implement a standardized credit application to collect relevant borrower information through questionnaires and credit reports.
- Utilize raw default probability values to support lending decisions.
- Require managerial review for potential borrowers with predicted default probabilities within ±0.025 of the current classification threshold, targeting a 24–48-hour approval window.

**2. Implement Risk-Based Lending Decisions**
- Consider higher interest rates and minimal initial credit limits for borrowers identified as higher risk until creditworthiness is established.
- Allow automatic approval for qualified low-risk borrowers, subject to established lending requirements.
- Adjust lending criteria during periods of higher default risk to minimize potential losses, while allowing greater lending flexibility during less risky periods.

**3. Monitor Borrower Risk and Model Performance**
- Request updated borrower information semiannually (every six months) and run new submissions through the model to reassess default risk.
- Create a dashboard to track model performance and optimal classification thresholds.
- Monitor the following performance targets:
  - **ROC-AUC:** Greater than 0.77
  - **Accuracy:** 70% or greater
  - **Recall:** 70% or greater
  - **Optimal Threshold:** Monitor sensitivity, specificity, and predictive performance as thresholds change.

## Project Deliverables

- **R Analysis Script:** Complete code covering data preparation, PCA, logistic regression, and model evaluation.
- **Analytical Presentation (PDF):** Visual summary of the project methodology, findings, and business recommendations.

**Note:** The full analytical report is available upon request for professional evaluation.
