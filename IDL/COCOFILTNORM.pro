;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function COCOFILTNORM, wavelengths, prof_mean, prof_sigma
nlambda=n_elements(wavelengths)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; function called by filters to generate normal distribution style filters
unifprof=make_array(nlambda,/double,value=1)
filter_temp=exp(-(double(wavelengths)-prof_mean)^2/(2D*prof_sigma^2))
filt_max=transpose(unifprof) # filter_temp
filt_norm=1D/filt_max[0]
filter_temp=filt_norm*filter_temp
return, filter_temp
end
