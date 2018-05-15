clear; close all; clc;
for user = 1:40 %max number of users
    filename = strcat('User',int2str(user));
    try
        PCAData = readtable(char(strcat(filename,'.csv')));
        disp(strcat("Reading : ",filename,'.csv'));
    catch
        disp(strcat(filename,'.csv does not exist!'));
        continue;
    end
    PCAData = PCAData(randperm(size(PCAData,1)),:); %randomizing the rows
    PCAData_train = PCAData(1:round(size(PCAData,1)*0.6),:); %storing the train data (60%)
    dtree = fitctree(PCAData_train,strcat('Var',int2str(size(PCAData,2)))); %training the tree
    before = findall(groot,'Type','figure'); % Find all figures
    
    %view(dtree,'mode','graph');    %uncomment to see the tree plot
    %after = findall(groot,'Type','figure');
    %h = setdiff(after,before); % Get the figure handle of the tree viewer
    %saveas(h,strcat(filename,'.png'));
     
    %Forming the confusion matrix and testing the test data on the tree
    [CFM,order] = confusionmat(table2array(PCAData(round(size(PCAData,1)*0.6)+1:end,end)),predict(dtree,PCAData(round(size(PCAData,1)*0.6)+1:end,1:end-1)));
    %disp(CFM);
    j = 0;
    for i = 1:size(CFM,1)
        r(i)=CFM(i,i)/sum(CFM(i,:)); %finding recall for every class
        p(i)=CFM(i,i)/sum(CFM(:,i)); %finding precision for every class
        a(i)=trace(CFM)*100/(trace(CFM)-(2*CFM(i,i))+sum(CFM(i,:))+sum(CFM(:,i))); %finding accuracy for every class
        %removing NaN
        r(isnan(r))=[]; 
        p(isnan(p))=[];
        a(isnan(a))=[];
        f(i)=2*r(i)*p(i)/(p(i)+r(i));%finding f value for every class
        f(isnan(f))=[]; %removing NaN
        arr = {i,p(i),r(i),f(i),strcat(int2str(a(i)),'%')}; %combining all accuracy metrics
        if (j==0)
                Z = arr;
                j = 1;
        else
               Z = vertcat(Z,arr); %combining all accuracy metrics
        end
    end
    Z = array2table(Z);
    Z.Properties.VariableNames = {'Class' 'Precision' 'Recall' 'F1' 'Accuracy'}
    writetable(Z,strcat('decision_tree_metrics_',filename,'.csv'));   %creates metrics file for every user
end
