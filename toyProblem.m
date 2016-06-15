    
p = 0.05;
r2 = 50;
d = 15;
%N = 2;
r1 = 10;

%sumR = 0;
%for i = 1:N
%   Ri = p*(r2+d*i) + (N-i)*r1;
%   sumR = sumR + Ri;
%end

maxN = 5;
expValuesRisk = zeros(1,maxN);
expValuesSafe = zeros(1,maxN);
for N = 1:maxN
    expValuesRisk(N) = N*p*r2 + N^2*r1 + (p*d-r1)*N*(N+1)/2;
    expValuesSafe(N) = N*r1;
end

figure
hold on
plot(expValuesRisk, 'r-');
plot(expValuesSafe, 'g-');
legend('Riskier Route','Safe Route');
hold off
