%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GMM_LINEAR

% Computes the GMM estimator of a linear model

% Format
% [beta,se,jstat] = gmm_linear(y,z,x);

% Inputs
% y	nx1	dependent variable
% z	nxk	rhs variables
% x	nxl	instruments variables (should include constant and exogenous parts of z), l>=k

% Outputs
% beta	kx1	Regression slope estimates
% se	kx1	standard errors
% jstat	1x1	J Statistic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [beta,se,jstat]=gmm_linear(y,z,x)
pihat=regress(z,x);
xz=x'*z;
xy=x'*y;
beta=((pihat'*xy)'/(pihat'*xz)')';
e=y-z*beta;
xe=x.*(e*ones(1,length(x(1,:))));
g=inv(xe'*xe);
v=inv(xz'*g*xz);
beta=v*(xz'*g*xy);
se=sqrt(diag(v));
m=x'*(y-z*beta);
jstat=m'*g*m;