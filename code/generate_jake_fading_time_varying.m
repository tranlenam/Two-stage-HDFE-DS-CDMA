function jake_fading=generate_jake_fading_time_varying(len,tap_delay_power,time,theta_index);
jake_fading=zeros(1,len);
global NUM_TERMS1  NUM_TERMS2 theta1 theta2 SAMPLING_INTERVAL;
global f_m % 
c_in1 = sqrt(tap_delay_power/NUM_TERMS1);
c_in2 = sqrt(tap_delay_power/NUM_TERMS2);

n=(1:NUM_TERMS1)';
f_in1 = f_m * sin(pi * (n-0.5) / (2*NUM_TERMS1));
n=(1:NUM_TERMS1)';
f_in2 = f_m * sin(pi * (n-0.5) / (2*NUM_TERMS2));

for m=1:1:len
    time_m=time+SAMPLING_INTERVAL*m*10^(-9);
    n=(1:NUM_TERMS1)';
    phase1=theta1(theta_index,:)';
%     re=cos(2*pi*f_in1(n)*(time) + phase1);
    re=cos(2*pi*f_in1(n)*(time_m) + phase1);
    fading_re=c_in1 *sum(re);

    n=(1:NUM_TERMS2)';
    phase2=theta2(theta_index,:)';
%     im=cos(2*pi*f_in2(n)*(time) + phase2);
    im=cos(2*pi*f_in2(n)*(time_m) + phase2);
    fading_im=c_in2 *sum(im);
    jake_fading(m)=fading_re+sqrt(-1)*fading_im;
end

