function [coeff]=get_LE_coeff(chan_coeff,sigma_sqr)
global FFT_SIZE TAP_DELAY NUM_TAP

temp_channel=zeros(TAP_DELAY(NUM_TAP)+1,1);
temp_channel(TAP_DELAY(1:NUM_TAP)+1)=chan_coeff(:,1);
Hf=fft(temp_channel,FFT_SIZE);

num=conj(Hf);
den=Hf.*conj(Hf)+sigma_sqr;
coeff=num./den;
