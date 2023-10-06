function Wn=walsh(N,option);
%WALSH	Returns walsh codes of length N
%	Wn=walsh(N)
%	This returns a matrix of all the walsh codes of length N
%	N must be greater then 1 and a power of 2, e.g. 2,4,8,16,32..
%	If N isn't a power of 2 then it is rounded up to the next power
%	of two. e.g. walsh(5) gives the same result as walsh(8);
% 
%	Example walsh codes. 
%	For N = 2
%	W2 = [ 1 1 
%	       1 0 ];
%
%	For N = 4
%	W4 = [ 1 1 1 1
%	       1 0 1 0 
%	       1 1 0 0 
%	       1 0 0 1 ];
%
%	Wn=walsh(N,'+-') returns the result as +- 1 e.g.
%	N = 2
%	W2 = [1  1 
%	      1 -1];
%	Copyright (c) Eric Lawrey July 1997

%	Modified:
%	9/7/97	Started coding the function. This function is finished
%		and tested to work.

M = ceil(log(N)/log(2));	%find the power of 2 to match N, e.g. M=5 for N=32
if (nargin ~= 2),
	option = '++';		%Set default to ones and zeros
end
	
if (option=='+-'),
	if 2^M == 1,
		Wn = [1];
	elseif 2^M == 2,
		Wn = [1 1; 1 -1];
	else
		Wn =  [1 1 1 1; 1 -1 1 -1; 1 1 -1 -1; 1 -1 -1 1];
		for k = 1:M-2,
			Wn = [Wn Wn; Wn (-Wn)];
		end
	end
else
	if 2^M == 1,
		Wn = [1];
	elseif 2^M == 2,
		Wn = [1 1; 1 0];
	else
		Wn =  [1 1 1 1; 1 0 1 0; 1 1 0 0; 1 0 0 1];
		for k = 1:M-2,
			Wn = [Wn Wn; Wn ~Wn];
		end
	end
end