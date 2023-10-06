function [feedforward_coeff, feedback_coeff]=get_HDFE_coeff(chan_coeff,sigma_sqr);
global FFT_SIZE TAP_DELAY NUM_TAP

temp_channel=zeros(TAP_DELAY(NUM_TAP)+1,1);
temp_channel(TAP_DELAY(1:NUM_TAP)+1)=chan_coeff(:,1);
Hf=fft(temp_channel,FFT_SIZE);
inv_chan=1./((Hf.*conj(Hf))+sigma_sqr);
vector=FFT_SIZE*ifft(inv_chan,FFT_SIZE);


K=-vector(2:TAP_DELAY(NUM_TAP)+1);
A=toeplitz(vector(1:TAP_DELAY(NUM_TAP))');
feedback_coeff=A\K;

Bf=fft([0;feedback_coeff],FFT_SIZE);
num=conj(Hf).*(1+Bf);
den=Hf.*conj(Hf)+sigma_sqr;
feedforward_coeff=num./den;
