%% 导入数据
clear, clc, close all
session = 'indy_20170124_01';
filename = sprintf('raw_data/%s.mat', session);
bin_size = 100;
min_rate = 2;
[X,R] = indy_data_load(filename, bin_size, min_rate, 'cursor');
X = X';
R = R';
[n_neuron, n_bin] = size(R);

%% Tunning curve
path_tunning_pos = 'result\tunning\pos\';
if ~exist(path_tunning_pos)
    mkdir(path_tunning_pos);
end
path_tunning_vel = 'result\tunning\vel\';
if ~exist(path_tunning_vel)
    mkdir(path_tunning_vel);
end
path_tunning_acc = 'result\tunning\acc\';
if ~exist(path_tunning_acc)
    mkdir(path_tunning_acc);
end

% 对位置的tuning
c = linspecer(3);
X(1, :) = X(1, :) - mean(X(1, :));
X(2, :) = X(2, :) - mean(X(2, :));

ticks = 0:1/4*pi:7/4*pi;
ticks_label = {'0', '1/4pi', '1/2pi', '3/4pi', 'pi', ...
        '5/4pi', '3/2pi', '7/4pi'};
for i_neuron = 1:2%n_neuron
    smooth_R = smooth(R(i_neuron,:),10)';
    [pd, r2] = plot_tuning_curve(smooth_R, X(1:2,:), c(1, :)); % 为什么有些方位角没有trial？
    xlim([-0.5,7/4*pi+0.5])
    xticks(ticks)
    xticklabels(ticks_label)
    name = sprintf('Tunning position, # %d neuron', i_neuron);
    xlabel('Direction of movement')
    ylabel('Spike count')
    title(name)
    set(gca,'FontSize',16);
    saveas(gcf,[path_tunning_pos, name,'.png']);
end
% 对速度的tuning
for i_neuron = 1:2%n_neuron
    smooth_R = smooth(R(i_neuron,:),10)';
    [pd, r2] = plot_tuning_curve(smooth_R, X(3:4,:), c(2, :));
    xlim([-0.5,7/4*pi+0.5])
    xticks(ticks)
    xticklabels(ticks_label)
    name = sprintf('Tunning velocity, # %d neuron', i_neuron);
    xlabel('Direction of movement')
    ylabel('Spike count')
    title(name)
    set(gca,'FontSize',16);
    saveas(gcf,[path_tunning_vel, name,'.png']);
end
% 对加速度的tuning
for i_neuron = 1:2%n_neuron
    smooth_R = smooth(R(i_neuron,:),10)';
    [pd, r2] = plot_tuning_curve(smooth_R, X(5:6,:), c(3, :));
    xlim([-0.5,7/4*pi+0.5])
    xticks(ticks)
    xticklabels(ticks_label)
    name = sprintf('Tunning acceleration, # %d neuron', i_neuron);
    xlabel('Direction of movement')
    ylabel('Spike count')
    title(name)
    set(gca,'FontSize',16);
    saveas(gcf,[path_tunning_acc, name,'.png']);
end


   
        






