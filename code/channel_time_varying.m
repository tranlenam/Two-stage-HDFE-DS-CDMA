function [Ch_output, chan_coeff]=channel_time_varying(input,sqr_sigma,time_index)
global NUM_TAP TAP_DELAY_POWER TAP_DELAY SAMPLING_INTERVAL

chan_coeff=zeros(NUM_TAP,length(input));
Ch_output=zeros(length(input)+TAP_DELAY(NUM_TAP),1);

mean = 0;    
sigma = sqrt(sqr_sigma/2);


for k=1:1:NUM_TAP
    % Generate channel coefficients 
	chan_coeff(k,:)=generate_jake_fading_time_varying(length(input),TAP_DELAY_POWER(k),time_index+TAP_DELAY(k)*SAMPLING_INTERVAL*10^(-9), k);

    % add fading 
    for m=1:length(input)
           Ch_output(m+TAP_DELAY(k))=Ch_output(m+TAP_DELAY(k))+input(m)*...
                                               chan_coeff(k,m);
    end
end

% add noise
Ch_output(1:length(input))=Ch_output(1:length(input))+sigma*(randn(length(input),1)+...
                                      sqrt(-1)*randn(length(input),1));
