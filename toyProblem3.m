    
%{
The 5% one: 
Starts at 100, increases by 15

The 10% one:
starts at 50?, increases by 10

The 20% one:
starts at 40, increases by 5
%}

%probability that number of shots required is less than N
Nmax = 10;
p1 = 0.2;
p2 = 0.1;
p3 = 0.05;
pN1 = zeros(1,Nmax);
pN2 = zeros(1,Nmax);
pN3 = zeros(1,Nmax);
for n=1:Nmax
   pN1(n) = 1 - (1-p1)^n; 
   pN2(n) = 1 - (1-p2)^n; 
   pN3(n) = 1 - (1-p3)^n; 
end
figure
hold on
plot(pN1)
plot(pN2)
plot(pN3)
grid on
hold off
legend('p=20%','p=10%','p=5%');
xlabel('Number of Shots Available');
ylabel('Probability that at least one will make it');


