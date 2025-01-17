%clear; close all; clc;
train_data = readtable('TrainData.csv');
j = 0;
for user = 1:40 %max number of users
    filename = strcat('User',int2str(user));
    try
        Z = readtable(char(strcat(filename,'.csv')));
        disp(strcat("Processing : ",filename,'.csv'));
    catch
        disp(strcat(filename,'.csv does not exist!'));
        if (user == 40)
            writetable(test_data,'TestData.csv','WriteVariableNames',false); 
        end    
        continue;
    end    
        if (j==0)
        	test_data = Z;
        	j = 1;
        else
            test_data = vertcat(test_data,Z);
                
        end
end 
j=0;

    dtree = fitctree(train_data,strcat('Var',int2str(size(train_data,2)))); %training the tree
    %before = findall(groot,'Type','figure'); % Find all figures
    %view(dtree,'mode','graph');    %uncomment to see the tree plot
    %after = findall(groot,'Type','figure');
    %h = setdiff(after,before); % Get the figure handle of the tree viewer
    %saveas(h,strcat(filename,'.png'));
     
    %Forming the confusion matrix and testing the test data on the tree
    %disp(train_data(:,:));
    %disp(predict(dtree,test_data(:,1:end-1)));
    [CFM,order] = confusionmat(table2array(test_data(:,end)),predict(dtree,test_data(:,1:end-1)));
    disp(CFM);
    classes = unique(table2array(test_data(:,end)));
    for i = 1:size(CFM,1)
        r(i)=CFM(i,i)/sum(CFM(i,:)); %finding recall for every class
        p(i)=CFM(i,i)/sum(CFM(:,i)); %finding precision for every class
        a(i)=trace(CFM)*100/(trace(CFM)-(2*CFM(i,i))+sum(CFM(i,:))+sum(CFM(:,i))); %finding accuracy for every class
        %removing NaN
        r(isnan(r))=0; 
        p(isnan(p))=0;
        %a(isnan(a))=[];
        f(i)=2*r(i)*p(i)/(p(i)+r(i));%finding f value for every class
        f(isnan(f))=1; %removing 
        if CFM(i,i) == 0
            if sum(CFM(i,:)) - CFM(i,i) == 0 && sum(CFM(:,i)) - CFM(i,i) == 0
                r(i) = 0;
                p(i) = 0;
                f(i) = 0;
            elseif sum(CFM(i,:)) - CFM(i,i) > 0 || sum(CFM(:,i)) - CFM(i,i) > 0
                r(i) = 1;
                p(i) = 1;
                f(i) = 1;  
            end
        end
        
        if (ismember(order(i),classes))
            arr = {order(i),p(i),r(i),f(i),strcat(int2str(a(i)),'%')}; %combining all accuracy metrics
            if (j==0)
                Z = arr;
                j = 1;
            else
                Z = vertcat(Z,arr); %combining all accuracy metrics
            end
        end    
     end
    Z = array2table(Z);
    Z.Properties.VariableNames = {'Class' 'Precision' 'Recall' 'F1' 'Accuracy'}
    writetable(Z,'decision_tree_metrics.csv');   %creates metrics file for every user

