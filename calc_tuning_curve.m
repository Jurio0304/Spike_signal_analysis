function [tuning8_fr] = calc_tuning_curve(spike_data, velocity_data)
% Calculates tuning curve for neurons. 
% 
%   Inputs:
%       spike_data: n_neuron x n_time (double)
%           smoothed spike.
%       velocity_data: 2 x n_time (double)
%           2-dim velocity data
%   Output:
%       tuning8_fr: n_neuron x 8: 8-angel average fire rate
% 
bin_idx = [];
tuning8_fr = [];
for i = 1:size(velocity_data,2)
    deg = rad2deg(atan2(velocity_data(2,i),velocity_data(1,i))); % 得到该时刻速度的方向
    if deg <0
       deg = deg + 360;            
    end  
%     if(velocity_data(1,i)>0 && velocity_data(2,i)<0)
%         deg = deg + 360;
%     elseif(velocity_data(1,i)<0 && velocity_data(2,i)<0)
%         deg = deg +180;
%     elseif(velocity_data(1,i)<0 && velocity_data(2,i)>0)
%         deg = deg +180;
%     end
    bin_idx(i) = ceil(deg/45); % 将0-360度方向分为八类
end
for bin_i = 1:8
    spike_i = spike_data(:,find(bin_idx==bin_i)); % 属于该方向的时刻的发放数
    tuning8_fr(:,bin_i) = sum(spike_i,2)/size(spike_i,2)*5; % 因为bin时间为20ms
end

end