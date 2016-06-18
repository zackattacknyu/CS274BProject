    
%N = 2;
r1 = 10;

%{
The 5% one: 
Starts at 100, increases by 15

The 10% one:
starts at 50?, increases by 10

The 20% one:
starts at 40, increases by 5
%}

percentage = 5;

maxN = 5;

figure
hold on

kVals = 0:maxN;
expValuesSafe = (kVals+1).*10;
plot(expValuesSafe, 'r-');

colors = {'g-','k-','b-'};
pVals = [0.05 0.1 0.2];
dVals = [15 10 5];
rVals = [300 50 40];
ii = 1;
for jj = 1:3
    
    p = pVals(jj);
    d = dVals(jj);
    r2 = rVals(jj);

    expValues = p.*(r2 + d.*kVals);

    plot(expValues,colors{ii});
    ii = ii+1;
    
end

legend('Safe Route','Risky, 5%','Risky: 10%','Risky: 20%');
hold off



