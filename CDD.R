data = read.csv(file.choose())
#length of time series is 239
plot(1:239,data$CDD,type="l",xlab="year",ylab="CDD",xaxt="n")
axis(1,at=seq(1,length(data$Rx5Day),4),labels=1961:2020)

y.acf <- acf(data$CDD,main="",ylim=c(-1,1))
y.pacf <- pacf(data$CDD,main="",ylim=c(-1,1))

#Model Identification *****************************
CDD.ma10 <- arima(data$CDD,c(0,0,10))
CDD.ma10
#Diagnostic Checking *********************************
AIC(CDD.ma10)
BIC(CDD.ma10)
acf(residuals(CDD.ma10),ylim=c(-1,1))
pacf(residuals(CDD.ma10),ylim=c(-1,1))
Box.test(residuals(CDD.ma10),lag=22,fitdf=10)
Box.test(residuals(CDD.ma10),lag=22,type="Ljung-Box",fitdf=10)
hist(residuals(CDD.ma10)/sqrt(CDD.ma10$sigma2))
qqnorm(residuals(CDD.ma10))
qqline(residuals(CDD.ma10))
tsdiag(CDD.ma10,gof.lag=22)

#ARCH ******************************
error <- residuals(CDD.ma10)
plot(1:length(error),error,type="l",xlab="",ylab="Residuals")
abline(a=0,b=0)
error.2 <- error^2
plot(1:length(error.2),error.2,type="l",xlab="",ylab="Squared Residuals")
acf(error.2,ylab="Squared Residual Autcorrelation",main="",ylim=c(-1,1))
# Lagrange-Multipler Test with p = 5
y <- error.2[6:239]
x1 <- error.2[5:238]
x2 <- error.2[4:237]
x3 <- error.2[3:236]
x4 <- error.2[2:235]
x5 <- error.2[1:234]
round(cbind(y,x1,x2,x3,x4,x5),4)
summary(lm(y~x1+x2+x3+x4+x5))
(LM.stat <- 239*summary(lm(y~x1+x2+x3+x4+x5))$r.squared)
qchisq(0.95,5)
# Portmanteau Test
Box.test(error.2,lag=10,type="Ljung-Box",fitdf=0)

#Forecasting ***********************************

CDD.ma10.pred <- predict(CDD.ma10,n.ahead=16)
CDD.ma10.pred
i <- 1:length(data$CDD)
plot(i,data$CDD,type="l",xlab="",xaxt="n",xlim=c(1,(length(data$CDD)+16)))
abline(a=0,b=0)
axis(1,at=seq(1,(length(data$CDD)+16),4),labels=1961:2024)
i <- (length(data$CDD)+1):(length(data$CDD)+16)
lines(i,CDD.ma10.pred$pred,col=2,lty=2)
lines(i,CDD.ma10.pred$pred+1.96*CDD.ma10.pred$se,col=3,lty=3)
lines(i,CDD.ma10.pred$pred-1.96*CDD.ma10.pred$se,col=3,lty=3)
legend(96,13,legend=c("data$CDD","Forecasts","Forecast Intervals"),lty=c(1,2,3),col=c(1,2,3))