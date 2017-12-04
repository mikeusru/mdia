function [BETA,R,J]=MichaelisMentenFit(X, Y, Z)

%Beta=[EC50, Hill, a];

BETA0=[mean(X), 4, max(Y)];
[BETA,R,J] = NLINFIT(X,Y,@MichaelisMenten,BETA0);
[BETA1,R,J] = NLINFIT(X,Y,@MichaelisMenten_Fix,BETA0);
[BETA2,R,J] = NLINFIT(X,Y,@MichaelisMenten_Fix2,BETA0);
[BETA4,R,J] = NLINFIT(X,Y,@MichaelisMenten_Fix4,BETA0);
x1=[0:max(X)/25:max(X)];
figure;
hold on;
if nargin == 2
    plot(X, Y, 'o');
elseif nargin == 3
    errorbar(X, Y, Z, 'o');
    plot(X, Y, 'o', 'MarkerEdgeColor', 'Blue', 'MarkerFaceColor', 'Blue', 'MarkerSize',12);
end

plot(x1, MichaelisMenten(BETA, x1), 'color', 'blue', 'LineWidth', 3)
plot(x1, MichaelisMenten_Fix(BETA1, x1), '--', 'color', 'green', 'LineWidth', 2);
plot(x1, MichaelisMenten_Fix2(BETA2, x1), '--', 'color', 'red', 'LineWidth', 2);
plot(x1, MichaelisMenten_Fix4(BETA4, x1), 'color', 'black');
Xlim([0, max(X)]);
text(max(X)/10, max(Y)*9/10, ['Hill Coefficient = ', num2str(BETA(2)), '    EC50 = ', num2str(BETA(1))], 'Color', 'Blue');
text(max(X)/10, max(Y)*8/10, ['Hill Coefficient = 1', '    EC50=', num2str(BETA1(1))], 'Color', 'Green');
text(max(X)/10, max(Y)*7/10, ['Hill Coefficient = 2', '    EC50=', num2str(BETA2(1))], 'Color', 'Red');
text(max(X)/10, max(Y)*6/10, ['Hill Coefficient = 4', '    EC50=', num2str(BETA4(1))], 'Color', 'Black');

% function y=MichaelisMenten(beta, x)
% EC50 = beta(1);
% Hill    = beta(2);
% a = beta(3);
% y = a*x.^Hill./(x.^Hill+EC50^Hill);
