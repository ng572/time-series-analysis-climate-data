data = read.csv(file.choose())
#length of time series is 239
i <- 1:length(data$Sea.Level)
plot(i,data$Sea.Level,type="l",xlab="",ylab="Sea.Level",xaxt="n")
axis(1,at=seq(1,length(data$Sea.Level),4),labels=1961:2020)
abline(v = 157, col=2)

#reduced length is 83
TIME <- 1:83
SL2 <- data$Sea.Level[c(157:239)]

# Model Identification, Estimation and Checking *************************************

Y.lag1 <- c(NA,SL2[-83])
Y.diff <- c(NA,diff(SL2))
Y.diff.lag1 <- c(NA,NA,diff(SL2)[-82])
Y.diff.lag2 <- c(NA,NA,NA,diff(SL2)[-(81:82)])
cbind(TIME,SL2,Y.lag1,Y.diff,Y.diff.lag1,Y.diff.lag2)

# Dickey-Fuller Test with Trend
summary(lm(Y.diff~Y.lag1+TIME))

# Augmented Dickey-Fuller Test with Trend and p = 1
summary(lm(Y.diff~Y.lag1+TIME+Y.diff.lag1))

# Augmented Dickey-Fuller Test with Trend and p = 2
summary(lm(Y.diff~Y.lag1+TIME+Y.diff.lag1+Y.diff.lag2))

# Linear Regression against time
summary(lm(SL2~TIME))
Box.test(residuals(lm(SL2~TIME)),lag=22,fitdf=0)
acf(residuals(lm(SL2~TIME)), ylim=c(-1,1), lag.max=20, xaxt="n")
axis(1,at=seq(0,20,2))
pacf(residuals(lm(SL2~TIME)), ylim=c(-1,1), lag.max=20, xaxt="n")
axis(1,at=seq(0,20,2))

# AIC Grid Search for ARMA(p, q)
AICtable = matrix(nrow=10, ncol=10)
for (p in 1:10) {
  for (q in 1:10) {
    if (p==4 & q==3) next #avoid error
    if (p==9 & q==3) next #avoid error
    if (p==9 & q==8) next #avoid error
    Sea.Level.arima101 <- arima(residuals(lm(SL2~TIME)),c(p,0,q))
    boo1 = Box.test(residuals(Sea.Level.arima101),lag=22,fitdf=p+q)
    boo2 = Box.test(residuals(Sea.Level.arima101),lag=22,type="Ljung-Box",fitdf=p+q)
    if (boo1$p.value > 0.05 & boo2$p.value > 0.05) {
      AICtable[p, q] = AIC(Sea.Level.arima101)
    }
  }
}
AICtable

# BIC Grid Search for ARMA(p, q)
BICtable = matrix(nrow=10, ncol=10)
for (p in 1:10) {
  for (q in 1:10) {
    if (p==4 & q==3) next #avoid error
    if (p==9 & q==3) next #avoid error
    if (p==9 & q==8) next #avoid error
    Sea.Level.arima101 <- arima(residuals(lm(SL2~TIME)),c(p,0,q))
    boo1 = Box.test(residuals(Sea.Level.arima101),lag=22,fitdf=p+q)
    boo2 = Box.test(residuals(Sea.Level.arima101),lag=22,type="Ljung-Box",fitdf=p+q)
    if (boo1$p.value > 0.05 & boo2$p.value > 0.05) {
      BICtable[p, q] = BIC(Sea.Level.arima101)
    }
  }
}
BICtable

#ARMA(7,7) summary
Sea.Level.arima707 <- arima(residuals(lm(SL2~TIME)),c(7,0,7))
Sea.Level.arima707
AIC(Sea.Level.arima707)
BIC(Sea.Level.arima707)
Box.test(residuals(Sea.Level.arima707),lag=22,fitdf=14)
Box.test(residuals(Sea.Level.arima707),lag=22,type="Ljung-Box",fitdf=14)

#ARMA(1,7) summary
Sea.Level.arima107 <- arima(residuals(lm(SL2~TIME)),c(1,0,7))
Sea.Level.arima107
AIC(Sea.Level.arima107)
BIC(Sea.Level.arima107)
Box.test(residuals(Sea.Level.arima107),lag=22,fitdf=8)
Box.test(residuals(Sea.Level.arima107),lag=22,type="Ljung-Box",fitdf=8)

# Forecasting **********************************************************************
# residual ARMA(1,7) model
Sea.Level.arima107.pred <- predict(Sea.Level.arima107,n.ahead=24)
Sea.Level.arima107.pred
i <- 1:length(residuals(lm(SL2~TIME)))
plot(i,residuals(lm(SL2~TIME)),type="l",xlab="",xaxt="n",xlim=c(1,(length(residuals(lm(SL2~TIME)))+24)))
abline(a=0,b=0)
axis(1,at=seq(1,(length(residuals(lm(SL2~TIME)))+24),4),labels=2000:2026)
i <- (length(residuals(lm(SL2~TIME)))+1):(length(residuals(lm(SL2~TIME)))+24)
lines(i,Sea.Level.arima107.pred$pred,col=2,lty=2)
lines(i,Sea.Level.arima107.pred$pred+1.96*Sea.Level.arima107.pred$se,col=3,lty=3)
lines(i,Sea.Level.arima107.pred$pred-1.96*Sea.Level.arima107.pred$se,col=3,lty=3)
legend(96,13,legend=c("residuals(lm(SL2~TIME))","Forecasts","Forecast Intervals"),lty=c(1,2,3),col=c(1,2,3))

# linear model
Sea.Level.2050pred <- (-0.164787) + (83 + 4 * 30) * (0.035906)
Sea.Level.2050pred
