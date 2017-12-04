function y = yphys_mini_fitting (beta0, x)

tau1 = beta0(1);
tau2 = beta0(2);
scale = beta0(3);
offset = beta0(4);
shift = beta0(5);
deltat = 0.2;
%shift = 0;
template = yphys_mini_makeTemplate(tau1,tau2, shift, deltat);
x = 1:length(template);

y = offset + template * scale;