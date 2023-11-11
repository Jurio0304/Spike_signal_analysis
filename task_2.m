clear, clc, close all
session = ["indy_20161206_02","indy_20170124_01"];
n_session = length(session);
bin_size = 100;
min_rate = 2;
kin_obj = 'cursor'; % ['finger', 'cursor']

path_fitting = 'result\fitting\';
if ~exist(path_fitting)
    mkdir(path_fitting);
end

r_square = cell(1, n_session);
r_square_0 = cell(1, n_session);

max_r = 0;
for i_session = 1:n_session
    filename = sprintf('raw_data/%s.mat', session(i_session));
    [X,R] = indy_data_load(filename, bin_size, min_rate, kin_obj);
    X = X';
    R = R';

    % smooth the data
    [n_neuron, n_bin] = size(R);
    smooth_R = zeros(n_neuron, n_bin);
    for i_neuron = 1:n_neuron
        smooth_R(i_neuron,:) = smoothdata(R(i_neuron,:),"gaussian",10);
    end

    % 速度模型
    [r2,m_depth] = calc_r_square(smooth_R, X(3:4,:));
    r_square{1, i_session} = r2;
    max_r = max(max_r, max(r2)); % max r across all sessions

    r2(r2<0) = 0; %将小于0的数值替换为0
    r_square_0{1, i_session} = r2;

    
    % 保存结果。用于任务三
    bin_data.fr = R;
    bin_data.kin = X;
    bin_data.r2 = r2; %或许只考虑更高R2的神经元能提高解码性能？
    
    path_bin_data = 'bin_data\';
    if ~exist(path_bin_data)
        mkdir(path_bin_data);
    end
    
    name = sprintf('%s%s_binsize_%d_minrate_%d_kintype_%s.mat', ...
        path_bin_data,session(i_session), bin_size, min_rate,kin_obj);
    
    save(name, 'bin_data');
end

space = 0.02;
edges = 0:space:ceil(max_r/space)*space;
H = zeros(length(edges)-1,n_session);
for i_session = 1:n_session
    figure()
    h = histogram(r_square_0{i_session}, edges,'Normalization','probability');
    H(:, i_session) = h.Values;
end
figure()
c = linspecer(n_session);
bar_plot = bar(H);

for i = 1 : length(edges)-1
    for j = 1 : n_session
        bar_plot(1, j).FaceColor = 'flat';
        bar_plot(1, j).CData(i,:) = c(j,:);
        bar_plot(1, j).EdgeColor = 'flat';
    end
end

xlabel('R^2')
ylabel('Percentage of neurons')
yticks(0:0.1:0.8)
yticklabels(0:10:80)
ticks = 0:length(edges);
ticks = ticks - 0.5;
xticks(ticks)
xticklabels(edges)
name = 'Fitting for velocity';
title(name)
set(gca, 'FontSize',16)
legend(bar_plot,'20161206','20170124'); % 这里写死了，之后可以再改
saveas(gcf,[path_fitting, name,'.png']);