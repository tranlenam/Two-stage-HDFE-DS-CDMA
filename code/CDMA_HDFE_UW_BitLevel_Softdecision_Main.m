clear 
clc;
rng(1)
% global variables
global NUM_TERMS1 NUM_TERMS2 theta1 theta2 SAMPLING_INTERVAL
global f_m TAP_DELAY TAP_DELAY_POWER
global NUM_TAP
global FFT_SIZE

% for Unique Word transmission 
global UNIQUE_WORD

NUM_TERMS1=25;
NUM_TERMS2=24;

% Channel Parameters
VELOCITY        =120;       %km/h
f_m =(VELOCITY*1000/3600)*(2017*(10^6)/(3*10^8));	

CHP_RATE        =3686.4;       %Mbps
CHIP_INTERVAL=(10^6)/CHP_RATE;
OVER_SAMPLING   =1;
SAMPLING_INTERVAL=CHIP_INTERVAL/OVER_SAMPLING;
NUM_TAP=6;

%channel B
% TIME_TAP_DELAY  =[0 300 8900 12900 17100 20000]';  %us
% TAP_MEAN_POWER  =[-2.5 0 -12.8 -10 -25.2 -16.0]';
%channel A
% TIME_TAP_DELAY=[0 310 710 1090  1730 2510]';
% TAP_MEAN_POWER=[0 -1.0 -9.0 -10.0 -15.0 -20.0]';
%channel C
TIME_TAP_DELAY=[0 542 813 2168  7046 10027]';
TAP_MEAN_POWER=[0 -2.1 -12.4 -4.1 -11.1 -19.7]';


chip_delay=round(TIME_TAP_DELAY/CHIP_INTERVAL);
TIME_TAP_DELAY=chip_delay*CHIP_INTERVAL;

TAP_DELAY       =floor(TIME_TAP_DELAY/SAMPLING_INTERVAL);
TAP_DELAY_POWER=10.^(TAP_MEAN_POWER./10);
% Normalization
TAP_DELAY_POWER=TAP_DELAY_POWER/sum(TAP_DELAY_POWER);
theta1=zeros(8,25);
theta2=zeros(8,24);
for m=1:8
    theta1(m,:)=2*pi*rand(1,25);
    theta2(m,:)=2*pi*rand(1,24);
end

% System Parameters
FFT_SIZE=   1024;           % FFT size
SF=         16;             % spreading factor
M=          FFT_SIZE/SF;    % length of block data 
time=1;
% Simulation Parameters
EsNo=       [4,8,12,16,20];
EcNo=       EsNo-10*log10(SF);
No=         1./(10.^(EcNo./10));
noivar=     No;             % noise variance (noise power)
threserr=   100;            % the error threshold
thresiter=  50000;          % the iteration thershold
FER=        zeros(length(noivar),1);        % Bit error rate
BER=        zeros(length(noivar),1); 
ISILen=     ceil(TAP_DELAY(NUM_TAP)/SF);

% Modulation Type
mod=        'qpsk'; % only 'bpsk' or 'qpsk' is supported
% Walsh Code
Code=walsh(SF,'+-');
Code=1/sqrt(2)*(Code(:,4)+1i*Code(:,4));%the fourth code is chosen

UW_length=96;
load ../data/pn10;
UNIQUE_WORD=1-2*pn(1:UW_length);

UNIQUE_WORD=(UNIQUE_WORD+1i*UNIQUE_WORD)/sqrt(2);
DataLen=(FFT_SIZE-UW_length)/16*2;


for l=1:length(EsNo)
    err=0;
    ferr=0;
    cer=0;
    % The first PN code is send before actuall transmission
    [RecdData, Chan_coeff]=channel_time_varying(UNIQUE_WORD,noivar(l),time);
    previous_ISI=RecdData(end-TAP_DELAY(NUM_TAP)+1:end);
    time=time+(length(UNIQUE_WORD))*SAMPLING_INTERVAL*10^(-9);
    
    for iter=1:100*EsNo(l) % 200*EsNo(l) is for illutration purpose only, 
        % increase 500*EsNo(l) or higher for more accurate BER
        
        %  Generate Binary Data
        BinData=GenerateBinData(DataLen);
        
        %  Modualate Data
        ModData=Modulate(BinData,mod);
        
        %  Spread Data
        SpreadData=[Spread(ModData,Code);UNIQUE_WORD];
        
        % Generate channel coefficients and transmit the signal 
        [RecdData, Chan_coeff]=channel_time_varying(SpreadData,noivar(l),time);
        
        % Add the ISI and update ISI
        RecdData(1:TAP_DELAY(NUM_TAP))=RecdData(1:TAP_DELAY(NUM_TAP))+previous_ISI;
        previous_ISI=RecdData(end-TAP_DELAY(NUM_TAP)+1:end);
        % Only conider first received symbols 
        RecdData=RecdData(1:FFT_SIZE);
        

        % Increase simulation time
        time=time+(FFT_SIZE)*SAMPLING_INTERVAL*10^(-9);


        % get the feedforward and feedback filter coefficients
        [feedforward_coeff, feedback_coeff]=get_HDFE_coeff(Chan_coeff,noivar(l));
        
        % Combine with LE
        linear_coeff=get_LE_coeff(Chan_coeff,noivar(l));
        % Detect and feedback.        
        EquaData=CDMA_HDFE_UW_BitLevel_SoftDecision_LE(RecdData,Code,feedforward_coeff,feedback_coeff,mod,linear_coeff);
        
        % Demodulate the equalized data
        DemodData=Demodulate(EquaData,mod);
        
        % Calculate BER and FER performance
        frame_err=sum(BinData~=DemodData(1:length(BinData)));
        if (frame_err>0)
            ferr=ferr+1;
        end
        err=err+frame_err;
    end
    FER(l)=ferr/iter;
    BER(l)=err/(length(BinData)*iter);
end
semilogy(EsNo,BER)
xlabel('EbNo')
ylabel('BER')
saveas(gcf,'../results/BER.png')