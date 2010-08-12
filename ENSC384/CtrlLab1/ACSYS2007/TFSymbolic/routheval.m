function routharray=routhsym(den);

% Symbolic Epsilon for substitution
eps = sym('eps');

order=length(den);                          %get number of coefficients
routharray=sym(zeros(order,ceil(order/2)));	%initialize symbolic Routh array 

for ii=1:order,
	routharray(2-rem(ii,2),ceil(ii/2))=den(ii); %1st and 2nd rows
end

steps=order-2;           %remaining rows

index=zeros(steps,1);	 %number of columns per row
for ii=1:steps,
	index(steps-ii+1)=ceil(ii/2);
end

for ii=3:order,
	if(all(routharray(ii-1,:)==0)),         %Zero Row
			disp(['Row of zeros found at row' num2str(ii-1) '. Auxiliary polynomial is used']);
			a=order-ii+2;                   %order of auxiliary equation
			b=ceil(a/2)-rem(a,2)+1;         %number of auxiliary coefficients
			routharray(ii-1,1:b)=routharray(ii-2,1:b).*[a:-2:0];	%derivative of auxiliary
	elseif(routharray(ii-1,1)==0),              %first element in row is zero
			disp(['First element of row' num2str(ii-1) ' is zero. Epsilon is used.']);
			routharray(ii-1,1)=eps;	%replace by epsilon
	end
				%compute the Routh array elements
	for jj=1:index(ii-2),
		routharray(ii,jj)=-det([routharray(ii-2,1) routharray(ii-2,jj+1);routharray(ii-1,1) routharray(ii-1,jj+1)])/routharray(ii-1,1);
	end
end

	
	