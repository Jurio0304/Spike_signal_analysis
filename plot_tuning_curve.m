function [pd, r2] = plot_tuning_curve(neural_data, kin_data, c)
% neural_data: 1 neuron x n_bin
% kin_data: 2 dim x n_bin
n_sample=100;
ratio = 0.7;
tunig_samp = [];
for i = 1:n_sample % 重复采样
    len_samp = randsample(size(neural_data,2),round(size(neural_data,2)*ratio)); %
    [tuning8_fr] = calc_tuning_curve(neural_data(1,len_samp), kin_data(:,len_samp));
    tuning_samp(i,:) = tuning8_fr;
end

tuning_mean  = mean(tuning_samp,1);
tuning_std = std(tuning_samp,1);

x = 0:pi/4:7/4*pi;

% tuning_mean = [tuning_mean tuning_mean(1)];
% tuning_std = [tuning_std tuning_std(1)];
figure()
errorbar(x,tuning_mean,tuning_std,'*','linewidth', 1,'Color',c);
hold on;
[pd, fit_func, solve, xrange, r2] = calc_pd(tuning8_fr);
xrange = 0:0.1:2*pi;
fr_fit = fit_func(solve, xrange);
plot(xrange, fr_fit, linewidth=2, Color=c);
xlim([0,2*pi-pi/4]);
% hold on
% plot([pd/180*pi, pd/180*pi],[min(fr_fit), max(fr_fit)])
end


