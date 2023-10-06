function y=Despread(x,Code);
SF=length(Code);
M=length(x)/length(Code);
y=zeros(M,1);
for k=1:M
    y(k)=(Code')*x(((k-1)*SF+1):(k*SF));
    y(k)=y(k)/length(Code);
end
