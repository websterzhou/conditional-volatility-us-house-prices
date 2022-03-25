import delimited ""


gen dlhp= d.lhp
tsline lhp if time>=113
gr save lhp.gph
tsline d.lhp if time>=113
gr save dlhp.gph
gr combine lhp.gph dlhp.gph
gr save hp_combined.gph
gr export hp_combined.png

*checking if d.lhp is stationary
varsoc d.lhp, maxlag(5)
dfuller d.lhp, lag(3)  regress //yes, it is stationary @ 10%

*step 1: identify best fitting model for d.lhp
	varsoc d.lhp, maxlag(5) //best is 4 lags (AR(4))
	arima dlhp, arima(1,0,1)
	predict ar_res, resid
	
*step 2: analyse the residuals for SC: SC, skewness and kurtosis
	*eyeballing using ac and pac
	ac ar_res
	gr save ac_ar_res.gph, replace
	pac ar_res
	gr save pac_ar_res.gph, replace
	gr combine ac_ar_res.gph pac_ar_res.gph
	gr export acf_pacf_arma11.png	
	
	*testing for SC
	tsline ar_res if time>=113
	estat bgodfrey, lags(1,2,3,4) //no SC
	*normality and skewness
	su ar_res, d
	sktest ar_res //not normal at all
*step 3: detecting non linear dependence
	gen ressq=ar_res*ar_res
	*looking at the plot of sq residuals
	tsline ressq if time>=113, xtitle("Time") ytitle("Squared residuals")
	gr save ressq_tsline.gph, replace
	gr export ressq_tsline.png, replace
	
	*performing archlm test
	regress ar_res
	estat archlm, lags(1/15)
	
*step 4 specification of arch(1)
	arch dlhp, arch(1/1) arima(1,0,1)
	* predicting the variance
	predict var_arch, variance
	tsline var_arch if time>=113 , xtitle("Time")
	gr save arch1.gph
	gr export arch1.png
	
	
















