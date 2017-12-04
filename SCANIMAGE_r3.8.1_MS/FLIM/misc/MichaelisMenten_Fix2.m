function y=MichaelisMenten_Fix(beta, x)

EC50 = beta(1);
Hill  = 2;
%Hill = 2;
a = beta(3);

y = a*x.^Hill./(x.^Hill+EC50^Hill);
