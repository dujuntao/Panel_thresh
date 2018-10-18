%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REGRESS

% Computes a linear regression. Uses generalized inverse if X'X is singular

% Format
% beta = regress(y,x);

% Inputs
% y	nxm	dependent variable(s)
% x	nxk	independent variables (should include constant)

% Output
% beta	kxm	Regression slope estimates

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function beta=regress(y,x)
warning off;
mw=' ';
beta=(y'/x')';
[mw,idw] = lastwarn;
lastwarn(' ');
warning on;
if (1-(mw==' '))
    beta=pinv(x'*x)*(x'*y);
end;