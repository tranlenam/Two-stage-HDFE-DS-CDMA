function [Ch_output, chan_coeff]=channel_static(input,sqr_sigma,time_index)
global NUM_TAP TAP_DELAY_POWER TAP_DELAY
chan_coeff=zeros(NUM_TAP,1);
Ch_output=zeros(length(input)+TAP_DELAY(NUM_TAP),1);
mean = 0;    
sigma = sqrt(sqr_sigma/2);
% Generate channel coefficients 
for k=1:NUM_TAP
	chan_coeff(k)=generate_jake_fading_static(TAP_DELAY_POWER(k), time_index, k);
end
% add fading 
for k=1:length(input)
    for path=1:NUM_TAP
       Ch_output(k+TAP_DELAY(path))=Ch_output(k+TAP_DELAY(path))+input(k)*...
           chan_coeff(path);
    end
end

% add noise
Ch_output(1:length(input))=Ch_output(1:length(input))+sigma*(randn(length(input),1)+sqrt(-1)*randn(length(input),1));
