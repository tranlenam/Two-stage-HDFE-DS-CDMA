function [y, UnEquaChips]=CDMA_HDFE_UW_BitLevel_SoftDecision_LE(x,Code,Wf,b,mod,linear_coeff)
% x:        Received signal, unequalized signal
% Wf:       Feedforward filter coeffs
% b:        Feedback filter coeffs
% y:        Detected Data
global UNIQUE_WORD
Nb              =length(b);   % the number of feedback taps.
SF              =length(Code);
M               =length(x)/SF;

MaxIteration    =1;

% Detected Bit
y=zeros(M,1)+1i*zeros(M,1);
UnEquaChips=zeros(length(x),1)+1i*zeros(length(x),1);

% Feedbach Register 
reg=zeros(Nb+SF,1);

% Initialize the feedback register with the Unique word
reg(1:Nb)=UNIQUE_WORD(end:-1:(end-Nb+1));

% Frequency response of received signal
Xf=fft(x);


% % Transform to time domain signal
r=ifft(Wf.*Xf);

% The input of despreading process is soft decision
EstChip=zeros(SF,1)+1i*zeros(SF,1);


%*******************The LE is done first**********************************%
le_r=ifft(Xf.*linear_coeff);
% Despreading
le_despread=Despread(le_r,Code);

le_detected=zeros(M,1);
% Symbol detection
for k=1:M
    le_detected(k)=Detect(le_despread(k),mod);
end
% Respreding
le_r=Spread(le_detected,Code);

%*******************end of LE*********************************************%

%*******************H-DFE comes the second********************************%
for k=1:M
    
    ChipIteration=le_r((k-1)*SF+1:(k*SF));
    for n=1:SF
        % chip-by-chip equalization
        EstChip(n)     =r((k-1)*SF+n)-sum(b.*reg(1:Nb));
        % shift the register;
        reg         =circshift(reg,1);
        reg(1)  =ChipIteration(n);
    end
    
    % Despread and Detect Symbol
    EstData =Despread(EstChip,Code);
    
    y(k)    =Detect(EstData,mod);
    
    ChipIteration =Spread(y(k),Code);
    
    reg(1:SF)=ChipIteration(end:-1:1);
    
    UnEquaChips((k-1)*SF+1:k*SF)=EstChip;
end

%EOF