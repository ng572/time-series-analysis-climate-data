data = read.csv(file.choose())
#length of time series is 239

# Time series plots of original series
i <- 1:length(data$Rx5Day)
plot(i,data$Rx5Day,type="l",xlab="",ylab="Rx5Day",xaxt="n")
axis(1,at=seq(1,length(data$Rx5Day),4),labels=1961:2020)
#ts.plot(diff(data$Rx5Day),type="l",xlab="") # not shown

# ACF and PACf of original and 1st differenced series
acf(data$Rx5Day,ylim=c(-1,1),lag.max=20,xaxt="n")
axis(1,at=seq(0,20,2))
pacf(data$Rx5Day,ylim=c(-1,1),lag.max=20,xaxt="n")
axis(1,at=seq(0,20,2))

acf(diff(data$Rx5Day),ylim=c(-1,1),lag.max=60,xaxt="n")
axis(1,at=seq(0,60,2))
pacf(diff(data$Rx5Day),ylim=c(-1,1),lag.max=60,xaxt="n")
axis(1,at=seq(0,60,2))

# Model Estimation ****************************************

#AR(6)
Rx5Day.ar6 <- arima(data$Rx5Day,c(6,0,0))
Rx5Day.ar6

#ARIMA(0,1,1)
Rx5Day.arima011 <- arima(data$Rx5Day,c(0,1,1))
Rx5Day.arima011

# Diagnostic Checking ************************************

AIC(Rx5Day.ar6)
BIC(Rx5Day.ar6)

AIC(Rx5Day.arima011)
BIC(Rx5Day.arima011)

acf(residuals(Rx5Day.arima011),ylim=c(-1,1))
pacf(residuals(Rx5Day.arima011),ylim=c(-1,1))

Box.test(residuals(Rx5Day.arima011),lag=22,fitdf=3)
Box.test(residuals(Rx5Day.arima011),lag=22,type="Ljung-Box",fitdf=3)

hist(residuals(Rx5Day.arima011)/sqrt(Rx5Day.arima011$sigma2))
qqnorm(residuals(Rx5Day.arima011))
qqline(residuals(Rx5Day.arima011))

#Forecasting **********************************************

Rx5Day.arima011.pred <- predict(Rx5Day.arima011,n.ahead=24)
Rx5Day.arima011.pred
i <- 1:length(data$Rx5Day)
plot(i,data$Rx5Day,type="l",xlab="",xaxt="n",xlim=c(1,(length(data$Rx5Day)+24)))
abline(a=0,b=0)
axis(1,at=seq(1,(length(data$Rx5Day)+24),4),labels=1961:2026)
i <- (length(data$Rx5Day)+1):(length(data$Rx5Day)+24)
lines(i,Rx5Day.arima011.pred$pred,col=2,lty=2)
lines(i,Rx5Day.arima011.pred$pred+1.96*Rx5Day.arima011.pred$se,col=3,lty=3)
lines(i,Rx5Day.arima011.pred$pred-1.96*Rx5Day.arima011.pred$se,col=3,lty=3)
legend(96,13,legend=c("data$Rx5Day","Forecasts","Forecast Intervals"),lty=c(1,2,3),col=c(1,2,3))