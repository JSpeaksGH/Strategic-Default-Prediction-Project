#Creating timestamp and tagging name of user
Sys.time()
name <- "Insert Name Here"
name

#Install necessary packages into R and load them
install.packages("ResourceSelection") #Goodness of fit for Logistic Regression Model
install.packages('caret') #Creating confusion matrix from Prediction and Default data
install.packages("rms")
install.packages("corrplot") #Correlation matrix to assess collinearity risk
install.packages("pROC") #Plot ROC/AUC Curve
install.packages("Metrics") #Compute recall, precision, and F1 - Score
library(pROC)
library(corrplot)
library(rms)
library(caret)
library(ResourceSelection)
library(Metrics)


## DATA CLEANING, PREPARATION, AND EXPLORATORY DATA ANALYSIS

#Read training data into R
gecred <- read.csv("~/Cred_Default_Pred/Data/CreditRisk_Train_Data.csv") #Read data into R
View(gecred) #View dataset
summary(gecred) #Summarize the data

#Review DataSet
head(gecred) #First 5 rows of data
tail(gecred) #Last 5 rows of data
str(gecred) #Structure of fields

#Check for missing values
anyNA(gecred)

#Check for duplicates
duplicated(gecred)

#Create a correlation matrix for variables to determine if collinearity is an issue
cor.cred = cor(gecred)
corrplot(cor.cred, method = "number") 

#Plot numerical values to identify outliers
par(mfrow = c(1,2))
boxplot(gecred$DURATION, data = gecred, main = "Duration of Credit", ylab = "Months")
boxplot(gecred$AMOUNT, data = gecred, main = "Credit Amount", ylab = "Dollars")
boxplot(gecred$INSTALL_RATE, data = gecred, main = "Installment Rate", ylab = "Percentage", ylim = c(0, 6))
boxplot(gecred$AGE, data = gecred, main = "Age of Borrower", ylab = "Years")

#Use IQR Method to remove outliers from each
lim_outl <- function(x) {
  Q1 <- quantile(x, 0.25, na.rm = TRUE)
  Q3 <- quantile(x, 0.75, na.rm = TRUE)
  IQR_val <- Q3- Q1
  lower <- Q1 - 1.5*IQR_val
  upper <- Q3 + 1.5*IQR_val
  x <- pmin(pmax(x, lower), upper)
  return(x)
}

#Apply function to Numerical Variables
gecred$DURATION <- lim_outl(gecred$DURATION)
gecred$AMOUNT <- lim_outl(gecred$AMOUNT)
gecred$AGE <- lim_outl(gecred$AGE)

#Plot w/o Outliers
boxplot(gecred$DURATION, data = gecred, main = "Duration of Credit", ylab = "Months")
boxplot(gecred$AMOUNT, data = gecred, main = "Credit Amount", ylab = "Dollars")
boxplot(gecred$INSTALL_RATE, data = gecred, main = "Installment Rate", ylab = "Percentage", ylim = c(0, 6))
boxplot(gecred$AGE, data = gecred, main = "Age of Borrower", ylab = "Years")

#Summarize numerical variables to verify outlier removal
summary(gecred$DURATION)
summary(gecred$AMOUNT)
summary(gecred$AGE)

#Min-max Scaling for entirety of Dataframe
scaled_gecred <- as.data.frame(
  lapply(gecred, function(x) (x - min(x))/ (max(x) - min(x)))
)

scaled_gecred
str(scaled_gecred)

#Principal Component Analysis to reduce dimensionality
sc_gecred <- scaled_gecred[, -c(1,32)]
str(sc_gecred)
pc.cred <- prcomp(sc_gecred,
                  center = TRUE,
                  scale = TRUE)

print(pc.cred)
summary(pc.cred)

#Information Output from Principal Component Analysis (PCA)
names(pc.cred)

#Extract Eigen values and Eigenvectors from the PCA Object
eigenvalues <- pc.cred$sdev^2
eigenvectors <- pc.cred$rotation

#Correlation Matrix for PCs and Variables
round(cor(sc_gecred,pc.cred$x[,1:12]), 3)

#Create Scree plot to determine Optimal Number of Components
plot(eigenvalues, type = "b", main = "Scree Plot of Principal Components",
     xlab = "Principal Component",
     ylab = "Eigenvalue")

#Add line at y = 1 to indicate elbow (Elbow = Optimal Number of Components)
abline(h = 1, col = "blue", lty = 2)


#Extract Principal Components (12, 10 PCs to compare results with each level)
pca.cred <- as.data.frame(pc.cred$x[, 1:12])
pca.cred2 <- as.data.frame(pc.cred$x[, 1:10])


#Add Target Variable into dataset
pca.cred$DEFAULT <- scaled_gecred$DEFAULT
pca.cred2$DEFAULT <- scaled_gecred$DEFAULT

head(pca.cred)

## MODELING

#Logistic Regression Model
logit.cred <- glm(DEFAULT ~ PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10 + PC11 + PC12, 
                  data = pca.cred,
                  family = 'binomial')
logit.cred2 <- glm(DEFAULT ~ PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10, 
                   data = pca.cred2,
                   family = 'binomial')


summary(logit.cred)
summary(logit.cred2)

#Hosmer and Lemeshow Goodness of Fit Test for Model
pc_gof10 <- hoslem.test(pca.cred2$DEFAULT, fitted(logit.cred2), g=10) 
pc_gof10

gof10 <- lrm(DEFAULT ~ PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PC7 + PC8 + PC9 + PC10, data = pca.cred2)
print(gof10)


#Run on Train Data
sc.gecred.train <- pca.cred2[, c(-11)]

#Use model to output predictions on training (.30)
def.prob.train <- predict(logit.cred2, newdata = sc.gecred.train , type = "response")
par(mfrow = c(1,1))

#Use probability,cutoff to classify as "default" (Train) (.30)
def.pred.train <- ifelse(def.prob.train > .30, "Yes","No")
def.pred.train2 <- factor(def.pred.train, levels = c("No", "Yes"))

#Recode Default to "Yes" and "No" (Train) (.30)
def.results.train <- ifelse(pca.cred2$DEFAULT == 1, "Yes", "No")
def.results.train2 <- factor(def.results.train, levels = c("No", "Yes"))

#Confusion Matrix (.3 cutoff)
cmatrix.train1 <- confusionMatrix(data = def.pred.train2, reference = def.results.train2, positive = "Yes")
cmatrix.train1

#Plot ROC Curve using Training Data
roc.curve.train <- roc(pca.cred$DEFAULT, def.prob.train)
plot(roc.curve.train, col = "blue", main = "ROC Curve(Training Data)", print.auc = TRUE)
abline(a = 0, b = 1, lty = 2, col = "red")

#Use ROC Curve to determine the threshold for strongest model results for training Data
coords(roc.curve.train, "best", input = "threshold", ret=c("accuracy", "threshold", "specificity", "sensitivity", "ppv"))



#Use model to output predictions on training (.35)
def.prob.train.35 <- predict(logit.cred2, newdata = sc.gecred.train , type = "response")
par(mfrow = c(1,1))

#Use .35,cutoff to classify as "default" (Train) (.35)
def.pred.train.35 <- ifelse(def.prob.train.35 > .35, "Yes","No")
def.pred.train.35.2<- factor(def.pred.train.35, levels = c("No", "Yes"))

#Confusion Matrix (.35 cutoff)
cmatrix.train2 <- confusionMatrix(data = def.pred.train.35.2, reference = def.results.train2, positive = "Yes")
cmatrix.train2

#Upload test data and replicate steps for transformation
gecred.test <- read.csv("~/Cred_Default_Pred/Data/CreditRisk_Verify_Test.csv")

#Min-max Scaling for test data
scaled_gecred.test <- as.data.frame(
  lapply(gecred.test, function(x) (x - min(x))/ (max(x) - min(x)))
)

scaled_gecred.test
str(scaled_gecred.test)

#Principal Component Analysis Test data
sc_gecred.test <- scaled_gecred.test[, -c(1,32)]
str(sc_gecred.test)
pc.cred.test <- predict(pc.cred, newdata=sc_gecred.test)

#Extract Principal Components from Test Data
pca.cred.test2 <- as.data.frame(pc.cred.test[, 1:10])

#Use model to output predictions on Test Data (10 Principal Components (PCs))
def.prob.10 <- predict(logit.cred2, newdata = pca.cred.test2, type = "response")
par(mfrow = c(1,1))

#Recode Default to "Yes" and "No" (Test Data)
def.results.test <- ifelse(scaled_gecred.test$DEFAULT == 1, "Yes", "No")
def.results.test <- factor(def.results.test, levels = c("No", "Yes"))

#Use prob cutoff to classify as "default" (10 PCs)
def.pred.10 <- ifelse(def.prob.10 > .3, "Yes","No")
def.pred.test.10 <- factor(def.pred.10, levels = c("No", "Yes"))

#Plot ROC Curve using 10 Principal Components
roc.curve.10 <- roc(scaled_gecred.test$DEFAULT, def.prob.10)
plot(roc.curve.10, col = "blue", main = "ROC Curve (10 PCs)", print.auc = TRUE)
abline(a = 0, b = 1, lty = 2, col = "red")


#Use ROC Curve to determine the threshold for strongest model results for Test (10 PCs)
coords(roc.curve.10, "best", input = "threshold", ret=c("accuracy","threshold", "specificity", "sensitivity", "ppv"))


#Use model to output predictions on Test Data (10 PCs using ROC Optimal Threshold)
def.prob.opt.10 <- predict(logit.cred2, newdata = pca.cred.test2, type = "response")
par(mfrow = c(1,1))

#Use probability cutoff to classify as "default" (10 PCs using ROC Optimal Threshold)
def.pred.opt <- ifelse(def.prob.opt.10 > .2485, "Yes","No")
def.pred.test.opt <- factor(def.pred.opt, levels = c("No", "Yes"))


#Create confusion matrix from Prediction and Default data (TEST) (10)
cmatrix.10 <- confusionMatrix(data = def.pred.test.10, reference = def.results.test, positive = "Yes")
cmatrix.10

#Create confusion matrix from Prediction and Default data (TEST) (10 using ROC Optimal Threshold)
cmatrix.10.opt <- confusionMatrix(data = def.pred.test.opt, reference = def.results.test, positive = "Yes")
cmatrix.10.opt

## MODEL EVALUATION (May have to call Metrics due to similar naming in caret for "recall" and "precision" function)

#Compute recall, precision, and F1 - Scores
pred.10 <- ifelse(def.prob.10 > .2485, 1, 0)
pred.train1 <- ifelse(def.prob.train >.3, 1, 0)
pred.train2 <- ifelse(def.prob.train >.35, 1, 0)


#Compute recall
recall.test.train1 <- Metrics::recall(pca.cred2$DEFAULT, pred.train1)
recall.test.train2 <- Metrics::recall(pca.cred2$DEFAULT, pred.train2)
recall.test.10 <- Metrics::recall(scaled_gecred.test$DEFAULT, pred.10)

#Compute precision
precision.test.train1 <- Metrics::precision(pca.cred2$DEFAULT, pred.train1)
precision.test.train2 <- Metrics::precision(pca.cred2$DEFAULT, pred.train2)
precision.test.10 <- Metrics::precision(scaled_gecred.test$DEFAULT, pred.10)

#Compute F1-score
f1.test.train1 <- 2*(precision.test.train1*recall.test.train1)/(precision.test.train1+recall.test.train1)
f1.test.train2 <- 2*(precision.test.train2*recall.test.train2)/(precision.test.train2+recall.test.train2)
f1.test.10 <- 2*(precision.test.10*recall.test.10)/(precision.test.10+recall.test.10)


#Place results from different models in datafram for comparison
results <- data.frame("Principal Components" = c("Train", "Train (Optimal)", "10 (Optimal)"),
                      "Recall" = c(recall.test.train1, recall.test.train2,recall.test.10),
                      "Precision" = c(precision.test.train1, precision.test.train2, precision.test.10),
                      "F1" = c(f1.test.train1, f1.test.train2,  f1.test.10))