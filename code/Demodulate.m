function y=Demodulate(x,mod)
if mod=='bpsk'
    y=(1-x)/2;
elseif mod=='qpsk'
    y=sqrt(2)*x;
    y=(1+1i-y)/2;
    im=imag(y);
    re=real(y);
    y(1:2:2*length(x))=re;
    y(2:2:2*length(x))=im;
end
