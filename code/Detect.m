function y=Detect(x,mod);
re=real(x);
im=imag(x);
if mod=='bpsk'
    if re>0
        y=1;
    else 
        y=-1;
    end
elseif mod=='qpsk'
    if im<0;
        im=-1/sqrt(2);
    else
        im=1/sqrt(2);
    end
    if re<0;
        re=-1/sqrt(2);
    else
        re=1/sqrt(2);
    end
    y=re+j*im;
end
