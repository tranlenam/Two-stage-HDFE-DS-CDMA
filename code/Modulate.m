function y=Modulate(x,mod)
y=1-2*x; % bpsk
if mod=='qpsk'
    y=y(1:2:end)+1i*y(2:2:end);
    y=1/(sqrt(2))*y;
end    