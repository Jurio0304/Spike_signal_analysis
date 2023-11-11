function [r_square,m_depth] = calc_r_square(trainNeuroData, trainKinData)
% Fits linear model and calculates tuning curve for neurons
% Input:
%     trainNeuroData:
%         n_neuron x n_bin 
%     trainKinData:
%         n_kin_dim x n_bin
% Output:
%     r_square:
%         1 x n_neuron. Adjusted R2 of these neurons
%     m_depth:
%         1 x n_neuron. 模型深度？
  


num_of_neuron = size(trainNeuroData,1);
r_square = zeros(1,num_of_neuron);
m_depth = zeros(1,num_of_neuron);
for i = 1:num_of_neuron 
    y = trainKinData';
    x = trainNeuroData(i,:)';
    mdl = fitlm(y,x); % 将y作为自变量估计x
    r_square(i) = mdl.Rsquared.Adjusted; 
    coe = table2array(mdl.Coefficients); % (n+1)*4 的矩阵，第一列存储系数，分别是[1 x1 x2 ... xn]对应的系数
    m_depth(i) = sqrt(coe(2,1).^2+coe(3,1).^2); % 有啥意义？
end

end