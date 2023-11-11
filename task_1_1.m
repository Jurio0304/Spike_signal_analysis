%% 导入数据
clear, clc, close all
session = 'indy_20170124_01';
filename = sprintf('raw_data/%s.mat', session);

load(filename);
[n_chan, max_unit] = size(spikes);
max_unit = max_unit - 1; % 第一列是unsorted neurons，后四列是sorted neurons
n_time = size(t, 1); 
fs = 250;
bin_len = 20; % bin大小设为20ms
bin_size = bin_len*fs/1000; %每5个点

% 得到矩阵形式的spike。这里是之前的版本，后面的任务都用了binSpikeCount函数
spike_array = false(n_chan * max_unit, n_time); % logical matrix
n_neuron = 1;
for i_chan = 1:n_chan
    for i_unit = 1:max_unit
        if ~isempty(spikes{i_chan, i_unit}) % 该通道的该神经元有发放
            t_idx = round((spikes{i_chan, i_unit} - t(1)) * fs + 1); % 发放时间转换为索引值
            t_idx = t_idx(t_idx > 0 & t_idx <= n_time); % 不考虑运动记录时间范围前后的发放
            spike_array(n_neuron, t_idx) = 1;
            n_neuron = n_neuron+1;
        end
    end
end

fr_threshold = 2; %发放率阈值
spike_array = spike_array(sum(spike_array, 2) >= fr_threshold * (t(end) - t(1)), :);
n_neuron = size(spike_array, 1);

%% 划分不同的trial
new_target_pos = [target_pos(1, :)];
new_target_t = 1;
for i_time = 2:n_time
    if target_pos(i_time, 1) ~= target_pos(i_time-1, 1) || target_pos(i_time, 2) ~= target_pos(i_time-1, 2)
        new_target_pos = [new_target_pos; target_pos(i_time, :)];
        new_target_t = [new_target_t; i_time];
    end
end

n_trial = size(new_target_t, 1) - 1; % 出现487次新目标，但是只考虑486个trial
trial_info = cell(1, n_trial);
n_angle = 8; %按照运动方向分为八类
for i_trial = 1:n_trial
    trial_info{i_trial}.time_start = new_target_t(i_trial+1);
    if i_trial < n_trial
        trial_info{i_trial}.time_end = new_target_t(i_trial+2)-1;
    else 
        trial_info{i_trial}.time_end = n_time;
    end
    trial_info{i_trial}.time_diff = trial_info{i_trial}.time_end - ...
        trial_info{i_trial}.time_start+1;% end_time属于该trial
    trial_info{i_trial}.origin_pos = new_target_pos(i_trial,:);
    trial_info{i_trial}.target_pos = new_target_pos(i_trial+1,:);
    trial_info{i_trial}.pos_diff = trial_info{i_trial}.target_pos - ...
        trial_info{i_trial}.origin_pos;
    angle = rad2deg(atan2(trial_info{i_trial}.pos_diff(2), trial_info{i_trial}.pos_diff(1))); 
    if angle <0
       angle = angle + 360;            
    end  
    trial_info{i_trial}.angle = angle;
    trial_info{i_trial}.angle_idx = ceil(angle/45); % 将0-360度方向分为八类
end

angle_of_trial = cellfun(@(x) x.angle_idx, trial_info);
duration_of_trial = cellfun(@(x) x.time_diff, trial_info);

%% 为不同的神经元，不同的angle绘制raster和PSTH
path_raster = 'result\raster\';
path_psth = 'result\psth\';
if ~exist(path_raster)
    mkdir(path_raster);
end
if ~exist(path_psth)
    mkdir(path_psth);
end

point_before = 50; %还包括前4*50=200ms
set(0,'DefaultFigureVisible', 'off')
for i_neuron = 1:2%n_neuron
    for i_angle = 1:n_angle
        idx_trial = find(angle_of_trial==i_angle);
        max_time_len = max(duration_of_trial(idx_trial))+point_before; 
        data = false(length(idx_trial), max_time_len);
        for j_trial = 1:length(idx_trial)
            data(j_trial,1:duration_of_trial(idx_trial(j_trial))+point_before) = ...
                spike_array(i_neuron, trial_info{idx_trial(j_trial)}.time_start-point_before: ...
                trial_info{idx_trial(j_trial)}.time_end);
        end

        % Raster
        figure('Position', [100, 100, 600, 300])
        box on
        LineFormat.LineWidth = 1;
        plotSpikeRaster(data,'PlotType','vertline','LineFormat',LineFormat,'AutoLabel',true);
        % xlim([-50,400])
        x_right = 100*floor(max_time_len / 100);
        xlim([0,x_right])
        ticks = 0:50:x_right;
        xticks(ticks)
        xticklabels(4*ticks - 200)
        name = sprintf('# %d neuron, # %d condition', i_neuron, i_angle);
        title(name)
        set(gca,'FontSize',16);
        saveas(gcf,[path_raster,name,'.png']);

        % PSTH: 针对分箱后数据
        data_sum = sum(data, 1);
        n_bin = floor(size(data_sum, 2)/bin_size);
        psth = zeros(n_bin,1);
        for i_bin =1:n_bin
            psth(i_bin) = sum(data_sum((i_bin-1)*bin_size+1:i_bin*bin_size));
        end
        figure('Position', [100, 100, 600, 300])
        box on
        bar(psth);
        % xlim([-10,80])
        xx_right = 20*floor(max_time_len / 100);
        xlim([0,xx_right])
        ticks = 0:10:xx_right;
        xticks(ticks)
        xticklabels(4*5*ticks - 200)
        name = sprintf('# %d neuron, # %d condition', i_neuron, i_angle);
        title(name)
        set(gca,'FontSize',16);
        saveas(gcf,[path_psth, name,'.png']);

    end
end

%% 想要实现类似center out的效果
% color = ['r','g','b','c','m','y','k','w'];
N = 8;
C = linspecer(N);

figure();
for i_angle = 1:n_angle
    idx_trial = find(angle_of_trial==i_angle);
    for j_trial = 1:30%length(idx_trial)
        trajectory = cursor_pos(trial_info{idx_trial(j_trial)}.time_start:...
            trial_info{idx_trial(j_trial)}.time_end, :);
        trajectory_center = trajectory - trajectory(1,:);
        plot(trajectory_center(:,1),trajectory_center(:,2), ...
            Color=C(i_angle,:), linewidth=1);hold on
    end
    xlim([-115,115]) 
    ylim([-115,115])
    set(gca,'xtick',[],'xticklabel',[],'ytick',[],'yticklabel',[])
end
print(gcf,'result\center_out','-dpng','-r300')


