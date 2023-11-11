function [X,R] = indy_data_load(filename, bin_size, min_rate, kin_obj)
if nargin == 3
    kin_obj = 'finger'; %默认使用finger pos
end
%% 参数设置
load(filename)
params.algorithm = 'rEFH';
params.datafile = filename;
params.mods = {'M1S1'};
params.Nmsperbin = bin_size;
params.trainingtime = 320;
% 320 seconds; also can choose 'half'.
params.fraction = 1;
params.hidsensoryratio = 4;
params.Fs = 250;
% dynamical params
params.typeUnits = {{'Poisson'},{'Bernoulli'}};
clc

%% 加载数据
T = 'sequencelength';
trainingtime = params.trainingtime;
mods = params.mods;
datafile = params.datafile;
Fs = params.Fs;
Nmsperbin = params.Nmsperbin; % 每个bin为100ms
Nmspers = 1000; % fact， 每s为1000ms
sperbin = (Nmsperbin/Nmspers); % 每个bin为0.1s
Nsamplesperbin = round(Fs*sperbin); % 每个bin的样本点数


% load neural data
Norder = 3;
% load
% X = cursor_pos;
% finger_pos
if strcmp(kin_obj, 'finger')
    X = finger_pos(:,2:3);
elseif strcmp(kin_obj, 'cursor')
    X = cursor_pos;
end

Ndims = size(X,2);
spikedata = spikes;
% just one "trial"---may be different for other data, e.g. HHS
St(1).X = X;
for iOrder = 2:Norder
    X = diff(X)*Fs;
    X = [X; X(end,:)];
    St(1).X = [St(1).X,X];  % 差分计算速度加速度
end
St(1).t = t;


minRate = min_rate;                              % Hz.  Somewhat arbitrary
% useful params
BinParams.m = Nsamplesperbin;
BinParams.dt = 1/Fs;
BinParams.Ndims = Ndims;
BinParams.Nstates = size(St(1).X,2);
BinParams.BINMETHOD = 'void';

% assemble usable "neurons"
UnitSpikesT = cell2struct(spikedata(:), 't', 2); %

% transform kinematic data and spike times into useful data
[R,X,~] = binSpikeCounts(St,UnitSpikesT,BinParams);

% reject slow, missing, or "extra" neurons
slow_neurons = mean(R)/sperbin <= minRate;
dead_neurons = arrayfun(@(ii)(isempty(spikedata{ii})),1:numel(spikedata));
bad_neurons = slow_neurons | dead_neurons;
R(:,bad_neurons) = [];
if isfield(params,'fraction')
    R = R(:,1:(floor(end*params.fraction)));
end

R = R / 0.1;
end