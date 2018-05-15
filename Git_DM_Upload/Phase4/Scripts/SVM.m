clear; close all; clc;
test_files = {'User2.csv','User3.csv','User4.csv','User6.csv','User7.csv','User8.csv','User9.csv','User10.csv','User12.csv','User13.csv','User14.csv','User15.csv','User17.csv','User18.csv','User21.csv','User23.csv','User25.csv','User26.csv','User27.csv','User29.csv','User30.csv','User31.csv','User32.csv','User33.csv','User34.csv','User35.csv','User37.csv'};
no_classes = 10;

train_data = table2array(readtable('TrainData.csv'));
train_set = train_data(:,1:size(train_data,2)-1);

% create metric files
for test_file = 1:length(test_files)
    f = fopen(char(strcat('testUserMetrics', test_files(test_file))), 'w');
    fprintf(f, 'Class,Precision,Recall,F1 Score,Accuracy\n');
    fclose(f);
end

% for every class run the model and predict the test data of all the users
for class = 1:no_classes
% initialize the gesture class as 1 and all the other classes as 0
    train_label = train_data(:,size(train_data,2));
    for row = 1:size(train_label, 1)
        if train_label(row) == class
            train_label(row) = 1;
        else
            train_label(row) = 0;
        end
    end
    model = fitcsvm(train_set, train_label,'Standardize',true,'KernelFunction','rbf','ClassNames',[0,1]);
    
% test the model for every test user    
    for test_file = 1:length(test_files)
        test_data = table2array(readtable(char(strcat('testData/', test_files(test_file)))));
        if size(test_data,1) == 0
            continue;
        end
        test_set = test_data(:,1:size(test_data,2)-1);
        test_label = test_data(:,size(test_data,2));
        if ~ismember(class, test_label)
            continue;
        end
    % initialize the gesture class as 1 and all the other classes as 0
        for row = 1:size(test_label, 1)
            if test_label(row) == class
                test_label(row) = 1;
            else
                test_label(row) = 0;
            end
        end

    % predict the classes
        predict_label = predict(model, test_set);
        
    % compute the accuracy metrics
        [c, cm, ind, per] = confusion(test_label', predict_label');
        precision = cm(1,1) / (cm(1,1) + cm(1,2));
        recall = cm(1,1) / (cm(1,1) + cm(2,1));
        f1score = 2 * recall * precision / (precision+recall);
        accuracy = (cm(1,1) + cm(2,2)) / (cm(1,1) + cm(2,2) + cm(1,2) + cm(2,1));
        if cm(1,1) == 0
            precision = 0;
            recall = 0;
            f1score = 0;
        end
        
    % write the metrics to output file
        f = fopen(char(strcat('testUserMetrics', test_files(test_file))), 'a');
        fprintf(f, '%d,', class);
        fprintf(f, '%.2f,' , precision);
        fprintf(f, '%.2f,' , recall);
        fprintf(f, '%.2f,' , f1score);
        fprintf(f, '%.2f%%\n', accuracy*100);
        fclose(f);
    end
end
