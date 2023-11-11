function [pd, fit_func, solve, xrange, r2] = calc_pd(average_fr)
% Calculate preferred direction for a single neuron
% Input:
%     average_fr:
%         1 x n_bin 
% Output:
%     r_square:
%         1 x n_neuron. Adjusted R2 of these neurons
%     m_depth:
%         1 x n_neuron. 模型深度？
xrange = [0:pi/4:2*pi-pi/4]; % 8 angles, 以该角度范围的最小值作为x
y = average_fr;


yu = max(y);
yl = min(y);
yr = (yu-yl);                               % Range of ‘y’
yz = y-yu+(yr/2); %未使用
% zx = x(yz(:) .* circshift(yz(:),[1 0]) <= 0);     % Find zero-crossings
% per = 2*mean(diff(zx));                     % Estimate period
ym = mean(y);                               % Estimate of
fit_func = @(b,x)  b(1).*(sin(x + 2*pi/b(2))) + b(3);    % Function to fit
fcn = @(b) sum((fit_func(b,xrange) - y).^2);                              % Least-Squares cost function
%s = fminsearch(fcn, [yr;  per;  -1;  ym]);
solve = fminsearch(fcn, [yr;  -1;  ym]);                  % Minimise Least-Squares
xp = linspace(min(xrange),max(xrange));


pd_rad = pi/2-2*pi/solve(2);
pd = mod(rad2deg(pd_rad),360);

y_pred = fit_func(solve,xrange);
r2 = 1-(sum((y_pred-y).^2)/sum((y-mean(y)).^2));

% solve(1): sine wave amplitude (in units of y)
% s(-): period (in units of x) ** QY:fixed to 2*pi
% s(2): phase (phase is s(-)/(2*s(2)) in units of x)
% s(3): offset (in units of y)
% https://ww2.mathworks.cn/matlabcentral/answers/121579-curve-fitting-to-a-sinusoidal-function

% figure(1)
% plot(x,y,'b',  xp,fit(s,xp), 'r')
% grid

end