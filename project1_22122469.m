%project1
clc
clear all
close all

% load the data
startdate = '01/01/1995';
enddate = '01/01/2022';
f = fred
JPY = fetch(f,'JPNRGDPEXP',startdate,enddate)
OY = fetch(f,'CLVMNACSCAB1GQFR',startdate,enddate)


% (伊国)CLVMNACSCAB1GQIT

jpy = log(JPY.Data(:,2));
oy = log(OY.Data(:,2));
q = JPY.Data(:,1);



T = size(jpy,1);

% Hodrick-Prescott filter
lam = 1600;
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

JP_GDP = A\jpy;
Other_GDP = A\oy;

% detrended GDP
jpytilde = jpy-JP_GDP;
oytilde = oy - Other_GDP;

% plot detrended GDP
dates = 1990:1/4:2022.1/4; zerovec = zeros(size(jpy));
figure
title('Detrended log(real GDP) 1994Q1-2022Q1'); hold on
plot(q, jpytilde,'r')
plot(q, oytilde,'b')
datetick('x', 'yyyy-qq')
legend({'jp','未定'},'Location','southwest')

%compute sd(y), sd(c), rho(y), rho(c), corr(y,c)(from detrended series)
jpysd = std(jpytilde)*100;
oysd = std(oytilde)*100;
jpyrho = corrcoef(jpytilde(2:T),jpytilde(1:T-1)); jpyrho = jpyrho(1,2);
oyrho = corrcoef(oytilde(2:T),oytilde(1:T-1)); oyrho = oyrho(1,2);
corryc = corrcoef(jpytilde(1:T),oytilde(1:T)); corryc = corryc(1,2);

disp(['Percent standard deviation of detrended log real GDP of Japan: ', num2str(jpysd),'.']); disp(' ')
disp(['Percent standard deviation of detrended log real GDP of NAN: ', num2str(oysd),'.']); disp(' ')
disp(['Serial correlation of detrended log real GDP of Japan: ', num2str(jpyrho),'.']); disp(' ')
disp(['Serial correlation of detrended log real GDP of NAN: ', num2str(oyrho),'.']); disp(' ')
disp(['Contemporaneous correlation between detrended log real Japan GDP and NAN GDP: ', num2str(corryc),'.']);



