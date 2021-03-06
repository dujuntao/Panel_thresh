%%%%%%%%%IVTAR_Panel.M%%%%%%%%%

%%%%%%%%%%%
% Panel Threshold Estimation with Endogeneous Variable %
%%%%%%%%%%%

% Stephanie Kremer, Alex Bick, Dieter Nautz

% Based on a MATLAB proccedure IVTAR.M written by Bruce E. Hansen

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Data %
%function ivtarpanel;
% load Develop_transformed_data.txt;
% z=Develop_transformed_data;
% load Develop_instrumentsall.txt;
% p=Develop_instrumentsall;

load Develop_transformed_data.txt;
z=Develop_transformed_data;
load Develop_instrumentsall.txt;
p=Develop_instrumentsall;



grgdp      = z(:,1);    % average_growthrate_gdp         
inflat     = z(:,2);    % average_inflationrate         
population = z(:,3);    % average_growthrate_pop      
invest     = z(:,4);    % average_investmentshare        
tot        = z(:,5);    % average_terms of trate rate   
sdtot      = z(:,6);    % standarddeviation_terms of trate 
openess    = z(:,7);    % average_log_openess           
sdopen     = z(:,8);    % log_standarddeviation_openess  
initial    = z(:,9);
country    = z(:,10);
KK         = z(:,11);
t          = z(:,12);
largeT     = z(:,13);
instr1     = p(:,1);    % instruments
instr2     = p(:,2);
instr3     = p(:,3);
instr4     = p(:,4);
instr5     = p(:,5);
instr6     = p(:,6);
instr7     = p(:,7);

y=grgdp;
q=inflat;
c=inflat; %exogeneous variable; regime-dependent
z1=initial; %endogeneous; regime-independent
z2=[invest,population,tot,sdtot,openess,sdopen]; %exogeneous regime-independent
x=[instr1 instr2 instr3 instr4 instr5 instr6 instr7]

%%%%%%Fixed Effects Transformation***********



yt = tr(y,largeT,t);
ct = tr(c,largeT,t);
zt1= tr(z1,largeT,t);

k=length(z2(1,:));
zt2=zeros(length(yt(:,1)),k);
i=1;
while i<=k
    zt2(:,i)=tr(z2(:,i),largeT,t);
    i=i+1;
end;

ii=1;
for i=1:length(q(:,1))
     if t(i)<largeT(i)
         qt(ii)=q(i);
         ii=ii+1;
     end; 
end;
qt=qt';

%%%%%%%%Define Parameters****************

conf_=0.90;
conf1_=0.80;
conf2_=1;
reduced=0;

%%%%%%%%2SLS*************************

xx=[x,zt2];
z1hat=xx*regress(zt1,xx);

zhat=[z1hat,zt2];

%%%%%%%%%%%%%%%%%%
n=length(yt(:,1));
xx=[zhat,tr(c,largeT,t)];
k=length(xx(1,:));
e=yt-xx*regress(yt,xx);
s0=det(e'*e);
n1=round(.05*n)+k;
n2=round(.95*n)-k;
qs=sortrows(q,1);
qs=qs(n1:n2);
qs=unique(qs);
qn=length(qs(:,1));
sn=zeros(qn,1);
r=1;
while r<=qn
    d=(q<=qs(r));
    xxx=[xx,tr(c.*d,largeT,t),tr(d,largeT,t)]; %regime-specific constant inserted here%
    xxx=xxx-xx*regress(xxx,xx);
    ex=e-xxx*regress(e,xxx);
    sn(r)=det(ex'*ex);
    r=r+1;
end;
[temp,r]=min(sn);
smin=sn(r);
qhat=qs(r);
d=(q<=qhat);
xxx=[zhat,tr(c.*d,largeT,t),tr(d,largeT,t)]; %regime-specific constant inserted here%
dd=1-d;
xxx=[xxx,tr(c.*dd,largeT,t)]; 
beta=regress(yt,xxx);
yhat=xxx*beta;
e=yt-yhat;
lr=n*(sn/smin-1);
sig2=smin/n;

i=length(zhat(1,:));
beta1=beta(i+1);
beta2=beta(i+3); %add 3 because of the regime-specific constant%

if length(yt(1,:))>1
    eta1=1;
    eta2=1;
else
    r1=(ct*(beta1-beta2)).^2;
    r2=r1.*(e.^2);
    qx=[qt.^0,qt.^1,qt.^2];
    qh=[qhat.^0,qhat.^1,qhat.^2];
    m1=(r1'/qx')';
    m2=(r2'/qx')';
    g1=qh*m1;
    g2=qh*m2;
    eta1=((g2'/g1')/sig2')';
    sigq=sqrt(mean((qt-mean(qt)').^2)');
    hband=2.344*sigq/(n^(.2));
    u=(qhat-qt)/hband;
    u2=u.^2;
    f=mean((1-u2).*(u2<=1))'*(.75/hband);
    df=-mean(-u.*(u2<=1))'*(1.5/(hband^2));
    eps=r1-qx*m1;
    sige=(eps'*eps)/(n-3);
    hband=sige/(4*f*((m1(3)+(m1(2)+2*m1(3)*qhat)*df/f)^2));
    u2=((qhat-qt)/hband).^2;
    kh=((1-u2)*.75/hband).*(u2<=1);
    g1=mean(kh.*r1)';
    g2=mean(kh.*r2)';
    eta2=((g2'/g1')/sig2')';
end;
c1=-2*log(1-sqrt(conf_));
lr0=(lr>=c1);
lr1=(lr>=(c1*eta1));
lr2=(lr>=(c1*eta2));
if max(lr0)==1
    [temp,indtemp1]=min(lr0);
    revlr0=lr0(1);
    for ii=2:length(lr0)
        revlr0=[lr0(ii);revlr0];
    end;
    [temp,indtemp2]=min(revlr0);
    qcf0=[qs(indtemp1),qs(qn+1-indtemp2)];
else
    qcf0=[qs(1),qs(qn)];
end;
if max(lr1)==1
    [temp,indtemp1]=min(lr0);
    revlr1=lr1(1);
    for ii=2:length(lr1)
        revlr1=[lr1(ii);revlr1];
    end;
    [temp,indtemp2]=min(revlr1);
    qcf1=[qs(indtemp1),qs(qn+1-(indtemp2))];
else
    qcf1=[qs(1),qs(qn)];
end;
if max(lr2)==1
    [temp,indtemp1]=min(lr2);
    revlr2=lr2(1);
    for ii=2:length(lr2)
        revlr2=[lr2(ii);revlr2];
    end;
    [temp,indtemp2]=min(revlr2);
    qcf2=[qs(indtemp1),qs(qn+1-indtemp2)];
else
    qcf2=[qs(1),qs(qn)];
end;

% figure;
% clr = ones(qn,1)*c1;
% plot(qs,lr,qs,clr,qs,clr*eta1,qs,clr*eta2);
% grid on;
% title('Confidence Interval Construction for Threshold');
% xlabel('Threshold Variable');
% ylabel('Likelihood Ratio Sequence in Gama');
% legend('LR_n(Gama)','95% Critical','Hetero Corrected-1','Hetero Corrected-2');


%%%%%%%%%%%%
z=[zt1,zt2];
da=(q<=qhat);
db=1-da;

zi=[zt1,zt2,tr(c.*da,largeT,t),tr(da,largeT,t),tr(c.*db,largeT,t)]; %regime-specific constant inserted here%
xi=[x,zt2,tr(c.*da,largeT,t),tr(da,largeT,t),tr(c.*db,largeT,t)]; %regime-specific constant inserted here%
yi=yt;

[beta,se,jstat] = gmm_linear(yi,zi,xi);

betal=beta-se*1.96;
betau=beta+se*1.96;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n=length(yt(:,1));
xx=[zhat,tr(c,largeT,t)];
k=length(xx(1,:));
e=yt-xx*regress(yt,xx);
s0=det(e'*e);
n1=round(.05*n)+k;
n2=round(.95*n)-k;
qs=sortrows(q,1);
qs=qs(n1:n2);
qs=unique(qs);
qn=length(qs(:,1));
sn=zeros(qn,1);
r=1;
while r<=qn
    d=(q<=qs(r));
    xxx=[xx,tr(c.*d,largeT,t),tr(d,largeT,t)]; %regime-specific constant inserted here%
    xxx=xxx-xx*regress(xxx,xx);
    ex=e-xxx*regress(e,xxx);
    sn(r)=det(ex'*ex);
    r=r+1;
end;
[temp,r]=min(sn);
smin=sn(r);
qhat=qs(r);
d=(q<=qhat);
xxx=[zhat,tr(c.*d,largeT,t),tr(d,largeT,t)]; %regime-specific constant inserted here%
dd=1-d;
xxx=[xxx,tr(c.*dd,largeT,t)];
betaf=regress(yt,xxx); 
yhat=xxx*betaf; 
e=yt-yhat;
lr=n*(sn/smin-1);
sig2=smin/n;

i=length(x(1,:));
betaf1=betaf(i+1);
betaf2=beta(i+3); 

if length(yt(1,:))>1
    eta1=1;
    eta2=1;
else
    r1=(ct*(betaf1-betaf2)).^2;
    r2=r1.*(e.^2);
    qx=[qt.^0,qt.^1,qt.^2];
    qh=[qhat.^0,qhat.^1,qhat.^2];
    m1=(r1'/qx')';
    m2=(r2'/qx')';
    g1=qh*m1;
    g2=qh*m2;
    eta1=((g2'/g1')/sig2')';
    sigq=sqrt(mean((qt-mean(qt)').^2)');
    hband=2.344*sigq/(n^(.2));
    u=(qhat-qt)/hband;
    u2=u.^2;
    f=mean((1-u2).*(u2<=1))'*(.75/hband);
    df=-mean(-u.*(u2<=1))'*(1.5/(hband^2));
    eps=r1-qx*m1;
    sige=(eps'*eps)/(n-3);
    hband=sige/(4*f*((m1(3)+(m1(2)+2*m1(3)*qhat)*df/f)^2));
    u2=((qhat-qt)/hband).^2;
    kh=((1-u2)*.75/hband).*(u2<=1);
    g1=mean(kh.*r1)';
    g2=mean(kh.*r2)';
    eta2=((g2'/g1')/sig2')';
end;
c1=-2*log(1-sqrt(conf1_));
lr0=(lr>=c1);
lr1=(lr>=(c1*eta1));
lr2=(lr>=(c1*eta2));
if max(lr0)==1
    [temp,indtemp1]=min(lr0);
    revlr0=lr0(1);
    for ii=2:length(lr0)
        revlr0=[lr0(ii);revlr0];
    end;
    [temp,indtemp2]=min(revlr0);
    qcf0i=[qs(indtemp1),qs(qn+1-indtemp2)];
else
    qcf0i=[qs(1),qs(qn)];
end;
if max(lr1)==1
    [temp,indtemp1]=min(lr0);
    revlr1=lr1(1);
    for ii=2:length(lr1)
        revlr1=[lr1(ii);revlr1];
    end;
    [temp,indtemp2]=min(revlr1);
    qcf1i=[qs(indtemp1),qs(qn+1-(indtemp2))];
else
    qcf1i=[qs(1),qs(qn)];
end;
if max(lr2)==1
    [temp,indtemp1]=min(lr2);
    revlr2=lr2(1);
    for ii=2:length(lr2)
        revlr2=[lr2(ii);revlr2];
    end;
    [temp,indtemp2]=min(revlr2);
    qcf2i=[qs(indtemp1),qs(qn+1-indtemp2)];
else
    qcf2i=[qs(1),qs(qn)];
end;

%%%%%%%%%%%%%%%%%%

if conf2_==0
    qcf=qcf0i;
elseif conf2_==1
    qcf=qcf1i;
elseif conf2_==2
    qcf=qcf2i;
end;
qq=unique(q);
qqcf2=(qq<=qcf(2));
ind=0;
for i=1:length(qqcf2)
    if qqcf2(i)==1
        if ind==0
            temp=qq(i);
            ind=1;
        else
            temp=[temp;qq(i)];
        end;
    end;
end;
qq=temp;
qqcf1=(qq>=qcf(1)); 
ind=0;
for i=1:length(qqcf1)
    if qqcf1(i)==1
        if ind==0
            temp=qq(i);
            ind=1;
        else
            temp=[temp;qq(i)];
        end;
    end;
end;
qq=temp;
clear qqcf1;
clear qqcf2;
ind=0;
i=1;
while i<=length(qq(:,1));
    qi=qq(i);
    dai=(q<=qi);
    dbi=1-dai;
    yi=yt;
    zi=[zt1,zt2,tr(c.*dai,largeT,t),tr(dai,largeT,t),tr(c.*dbi,largeT,t)]; %regime-specific constant inserted here%
    xi=[x,zt2,tr(c.*dai,largeT,t),tr(dai,largeT,t),tr(c.*dbi,largeT,t)]; %regime-specific constant inserted here%

    [betafi,sei,jstati] = gmm_linear(yi,zi,xi);
    betafil=min([(betafi-sei*1.96),betal]')';
    betafiu=max([(betafi+sei*1.96),betau]')';
    
    %GMM/IV; Use alternatively: 
    %[betai,sei,jstati] = gmm_linear(yi,zi,xi);
    %betail=min([(betai-sei*1.96),betal]')';
    %betaiu=max([(betai+sei*1.96),betau]')'; 
    %And insert the alternative in Output
     
    
    i=i+1;
    
end;
z=length(zhat(1,:));

% eqhat=exp(qhat);
% eqcf0=exp(qcf0)
% eqcf1=exp(qcf1)
% eqcf2=exp(qcf2)


disp(' ');
disp(' ');
fprintf('Threshold Estimate (in levels):           %f\n',exp(qhat));
fprintf('Confidence Interval - Uncorrected:        %f  %f\n',exp(qcf0(1)),exp(qcf0(2)));
fprintf('Confidence Interval - Het Corrected Quad: %f  %f\n',exp(qcf1(1)),exp(qcf1(2)));
fprintf('Confidence Interval - Het Corrected NP:   %f  %f\n',exp(qcf2(1)),exp(qcf2(2)));
disp(' ');
disp(' ');
fprintf('Regime-independent regressors: %f\n');
disp(' ');
disp('Estimates        S.E.         Lower       Upper');
for i=1:z
    fprintf('%f    %f     %f    %f\n',betaf(i),se(i),betafil(i),betafiu(i));
end;
disp(' ');
fprintf('Regime-dependent regressors: %f\n');
disp(' ');
fprintf('Regime 1 : Threshold variable less than %f\n',exp(qhat));
fprintf('Number of observations:                   %f\n',sum(da));
disp(' ');
disp('Estimates       S.E.        Lower        Upper');
for i=z+1:z+2
    fprintf('%f    %f     %f    %f\n',betaf(i),se(i),betafil(i),betafiu(i));
end;
disp(' ');
fprintf('Regime 2 : Threshold variable greater than %f\n',exp(qhat));
fprintf('Number of observations:                   %f\n',sum(db));
disp(' ');
disp('Estimates      S.E.         Lower        Upper');
for i=z+3:z+3
    fprintf('%f    %f     %f    %f\n',betaf(i),se(i),betafil(i),betafiu(i));
end;
disp(' ');

