% Fixed effects transformation %

function r=tr(y,largeT,t)
warning off MATLAB:divideByZero;   
lt = length(y(:,1));

for j=1:lt
    if j<lt
    r1(j)=(((largeT(j)-t(j))/(largeT(j)-t(j)+1))^0.5)*(y(j)-(1/(largeT(j)-t(j)))*(sum(y((j+1):(j+largeT(j)-t(j))))));
end
end
r1=r1';

jj=1;
for j=1:lt
     if t(j)<largeT(j)
         r2(jj)=r1(j);
         jj=jj+1;
     end; 
end;
r=r2';
     