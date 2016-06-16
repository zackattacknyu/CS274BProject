    
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

maxN = 20;

figure
hold on

expValuesSafe = zeros(1,maxN);
for N = 1:maxN
    expValuesSafe(N) = N*r1;
end
plot(expValuesSafe, 'r-');

colors = {'g-','k-','b-'};
ii = 1;
for percentage = [5 10 20]
    
    if(percentage == 5)
        % 5 percent one
        p = 0.05;
        d = 15;
        r2 = 100-d;
    elseif(percentage == 10)
        %10 percent one
        p = 0.1;
        d = 10;
        r2 = 50-d;
    else
        %20 percent one
        p = 0.2;
        d = 5;
        r2 = 40-d;
    end

    expValuesRisk = zeros(1,maxN);
    for N = 1:maxN
        expValuesRisk(N) = N*p*r2 + N^2*r1 + (p*d-r1)*N*(N+1)/2;
    end

    plot(expValuesRisk,colors{ii});
    ii = ii+1;
    
end

legend('Safe Route','Risky, 5%','Risky: 10%','Risky: 20%');
hold off

