clc;
format long 
% load training data
WholeData = load('DataQuerylevelnorm.txt');

% Devide data into three parts to get training,vilidation and test data
[rows,columns] = size(WholeData);
TrainingData = WholeData;
TrainingData(ceil(rows*0.4)+1:rows,:)=[];
ValidationData = WholeData;
ValidationData([1:ceil(rows*0.4) ceil(rows*0.5)+2:rows],:) = [];
TestData = WholeData;
TestData(1:ceil(rows*0.5)+1,:) =[];

% Some parameters setting,you can change here to adjust different
% parameters to avoid overfitting
M = 5;
Log_Lamada = -100;
Log_Lamada_End = 20;
Lamada_Space =20;
Lamada_index = 0;
M_Axis = 1:M;
Log_Lamada_Axis = Log_Lamada : Lamada_Space :Log_Lamada_End;
Figure_Index = 0;

% matrix for ERMS
Gausian_Training_RMS = zeros(M,abs(Log_Lamada-Log_Lamada_End)/Lamada_Space+1);
Gausian_Validation_RMS = zeros(M,abs(Log_Lamada-Log_Lamada_End)/Lamada_Space+1);
Gausian_Test_RMS = zeros(M,abs(Log_Lamada-Log_Lamada_End)/Lamada_Space+1);
Sig_Training_RMS = zeros(M,abs(Log_Lamada-Log_Lamada_End)/Lamada_Space+1);
Sig_Validation_RMS = zeros(M,abs(Log_Lamada-Log_Lamada_End)/Lamada_Space+1);
Sig_Test_RMS = zeros(M,abs(Log_Lamada-Log_Lamada_End)/Lamada_Space+1);
Gausain_Gap_Train_Test = zeros(M,abs(Log_Lamada-Log_Lamada_End)/Lamada_Space+1);
Sig_Gap_Train_Test = zeros(M,abs(Log_Lamada-Log_Lamada_End)/Lamada_Space+1);


for m = 1:M
    m
    Lamada_index = 0;
    for log_lamada = Log_Lamada : Lamada_Space :Log_Lamada_End
    Lamada_index = Lamada_index+1;
    % get training model 
    [rms_gausian_train,rms_sig_train,w_gausian,w_sig,miu,std] = training(TrainingData,m,log_lamada);
    Gausian_Training_RMS(m,Lamada_index)= rms_gausian_train;
    Sig_Training_RMS(m,Lamada_index) = rms_sig_train;
    % validation 
    [rms_gausian_val,rms_sig_val] = predict(ValidationData,miu,std,m,w_gausian,w_sig);
    Gausian_Validation_RMS(m,Lamada_index)= rms_gausian_val;
    Sig_Validation_RMS(m,Lamada_index) = rms_sig_val;
    % test
    [rms_gausian_test,rms_sig_test] = predict(TestData,miu,std,m,w_gausian,w_sig);
    Gausian_Test_RMS(m,Lamada_index)= rms_gausian_test;
    Sig_Test_RMS(m,Lamada_index) = rms_sig_test;
    end
end
Gausian_Test_RMS
Sig_Test_RMS
Gausain_Gap_Train_Test = (Gausian_Test_RMS-Gausian_Training_RMS)./Gausian_Training_RMS
Sig_Gap_Train_Test = (Sig_Test_RMS-Sig_Training_RMS)./Sig_Training_RMS

% draw ERMS graph for different M
for m =1:M
    Figure_Index = Figure_Index +1;
    figure(Figure_Index);
    plot(Log_Lamada_Axis,Gausian_Training_RMS(m,:),'-m','LineWidth',1.5);hold on;
    plot(Log_Lamada_Axis,Gausian_Validation_RMS(m,:),'-b','LineWidth',1.5);hold on;
    plot(Log_Lamada_Axis,Gausian_Test_RMS(m,:),'-r','LineWidth',1.5);hold on;
    plot(Log_Lamada_Axis,Gausain_Gap_Train_Test(m,:),'-.r','LineWidth',1.5);hold on;
    xlabel(['ln(¦Ë) (when M=',num2str(m),')']);
    
    ylabel('E_{RMS}');
    legend('GauTrain','GauVal','GauTest','GausianGap');
    Figure_Index = Figure_Index +1;
    figure(Figure_Index);
    plot(Log_Lamada_Axis,Sig_Training_RMS(m,:),'-g','LineWidth',1.5);hold on;
    plot(Log_Lamada_Axis,Sig_Validation_RMS(m,:),'-y','LineWidth',1.5);hold on;
    plot(Log_Lamada_Axis,Sig_Test_RMS(m,:),'-k','LineWidth',1.5);hold on;
    plot(Log_Lamada_Axis,Sig_Gap_Train_Test(m,:),'-.k','LineWidth',1.5);hold on;
    xlabel(['ln(¦Ë) (when M=',num2str(m),')']);
    ylabel('E_{RMS}');
    legend('SigTrain','SigVal','SigTest','SigGap');
end
% draw ERMS graph for different  Lamada
Lamada_index = 0;
for log_lamada = Log_Lamada : Lamada_Space :Log_Lamada_End
    Figure_Index = Figure_Index +1;
    figure(Figure_Index);
    Lamada_index = Lamada_index+1;
    plot(M_Axis,Gausian_Training_RMS(:,Lamada_index),'-m','LineWidth',1.5);hold on;
    plot(M_Axis,Gausian_Validation_RMS(:,Lamada_index),'-b','LineWidth',1.5);hold on;
    plot(M_Axis,Gausian_Test_RMS(:,Lamada_index),'-r','LineWidth',1.5);hold on;
    plot(M_Axis,Gausain_Gap_Train_Test(:,Lamada_index),'-.r','LineWidth',1.5);hold on;
%     xlabel for no fixing overfitting
%     xlabel('M');
    xlabel(['M (when ln(¦Ë)=',num2str(log_lamada),')']); 
    ylabel('E_{RMS}');
    legend('GauTrain','GauVal','GauTest','GausianGap');
    Figure_Index = Figure_Index +1;
    figure(Figure_Index);
    plot(M_Axis,Sig_Training_RMS(:,Lamada_index),'-g','LineWidth',1.5);hold on;
    plot(M_Axis,Sig_Validation_RMS(:,Lamada_index),'-y','LineWidth',1.5);hold on;
    plot(M_Axis,Sig_Test_RMS(:,Lamada_index),'-k','LineWidth',1.5);hold on;
    plot(M_Axis,Sig_Gap_Train_Test(:,Lamada_index),'-.k','LineWidth',1.5);hold on;
%     xlabel for no fixing overfitting
%     xlabel('M');
    xlabel(['M (when ln(¦Ë)=',num2str(log_lamada),')']); 
    ylabel('E_{RMS}');
    legend('SigTrain','SigVal','SigTest','SigGap');
%     legend('GauTrain','GauVal','GauTest','SigTrain','SigVal','SigTest','GausianGap','SigGap');
%     xlabel(['M (when ln(¦Ë)=',num2str(log_lamada),')']);   
%     ylabel('E_{RMS}');
%     legend('GauTrain','GauVal','GauTest','SigTrain','SigVal','SigTest','GausianGap','SigGap');
end
