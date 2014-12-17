% Get trainning model:input training data,m and lamada;output:Root mean
% suqare,w ,mean and std 
function [rms_gausian,rms_sig,w_gausian,w_sig,miu,std] = training(TrainingData,m,Lamada)
[rows,columns] = size(TrainingData);
% get feature matrix
X = TrainingData;
X(:,1) = [];
% get relevance value vector
T = TrainingData;
T(:,2:columns) = [];
% get s and miu
% try diffrent s
% std = std2(TrainingData)*100;
std = std2(TrainingData);
miu = zeros(1, m-1);
for miuindex= 1:m-1
    temp = TrainingData;
%     different miu
    temp((floor(rows/m*miuindex)):rows,:)= [];
%     temp(1:(ceil(rows/m*miuindex)),:)= [];
    miu(1,miuindex) = mean2(temp);
end
% lamada I
LamadaI = exp(Lamada)*eye((columns-1)*(m-1)+1);
% get desigh matrix by row
Design_Gausian = zeros(rows,(columns-1)*(m-1)+1);
Design_Sig = zeros(rows,(columns-1)*(m-1)+1);
for row_index = 1 : rows
    %for each row to get fai
    for m_index = 0: m-1
        if m_index ==0
            Design_Gausian(row_index,1) = 1; %the first column of the design matrix is 1 vector
            Design_Sig(row_index,1) = 1;
            continue;
        end
        for n = 1: (columns-1)
             Design_Gausian(row_index,((m_index-1)*(columns-1)+n+1)) = exp(-(TrainingData(row_index,(columns-1))-miu(m_index))^2/(2*std^2));
             Design_Sig(row_index,((m_index-1)*(columns-1)+n+1)) =1/(1+exp((miu(m_index)-TrainingData(row_index,(columns-1)))/std));
        end    
    end
end

% get w with lamada matrix to avoid overfitiing
 w_gausian = pinv(Design_Gausian'*Design_Gausian+LamadaI)*Design_Gausian'*T;
 w_sig = pinv(Design_Sig'*Design_Sig+LamadaI)*Design_Sig'*T;
%  get w without fixing oevrfitting
%  w_gausian = pinv(Design_Gausian'*Design_Gausian)*Design_Gausian'*T;
%  w_sig = pinv(Design_Sig'*Design_Sig)*Design_Sig'*T;
% get y
y_gausian = Design_Gausian*w_gausian;
y_sig =  Design_Sig*w_sig;
% get RMS
rms_gausian = sqrt((y_gausian-T)'*(y_gausian-T)/rows);
rms_sig = sqrt((y_sig-T)'*(y_sig-T)/rows);
end  %function ends

