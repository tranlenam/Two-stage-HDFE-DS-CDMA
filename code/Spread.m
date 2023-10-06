function y=Spread(x,code)
codelen = length(code);
y=zeros(length(x)*codelen,1);
for k=1:length(x)
    y((k-1)*codelen+1:k*codelen) = x(k)*code;
end