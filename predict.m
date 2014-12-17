% Adjust papameter and predict target values£¬ input:validation or test
% data,miu,std,m, w_gausian,w_sig, output:rms_gausian,rms_sig
function [rms_gausian,rms_sig] = predict(validation_data,miu,std,m,w_gausian,w_sig)
[rows,columns] = size(validation_data);
% get feature matrix
X = validation_data;
X(:,1) = [];
% get relevance value vector
T = validation_data;
T(:,2:columns) = [];
T = double(T);
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
             Design_Gausian(row_index,((m_index-1)*(columns-1)+n+1)) = exp(-(validation_data(row_index,(columns-1))-miu(m_index))^2/(2*std^2));
             Design_Sig(row_index,((m_index-1)*(columns-1)+n+1)) =1/(1+exp((miu(m_index)-validation_data(row_index,(columns-1)))/std));
        end    
    end
end

% get y
y_gausian = Design_Gausian*w_gausian;
y_sig =  Design_Sig*w_sig;
figure(100);
plot(y_gausian);hold on;
figure(101);
plot(y_sig);hold on;
% get RMS
rms_gausian = sqrt((y_gausian-T)'*(y_gausian-T)/rows);
rms_sig = sqrt((y_sig-T)'*(y_sig-T)/rows);
end

