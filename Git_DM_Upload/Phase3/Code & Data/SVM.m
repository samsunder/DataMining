clear; close all; clc;
user_files = {'User1.csv','User5.csv','User11.csv','User16.csv','User19.csv','User20.csv','User22.csv','User24.csv','User28.csv','User36.csv'};
gestures = {'about','and','can','cop','deaf','decide','father','find','go out','hearing'};
no_classes = 10;

% for every user, use 60% as training set and 40% as test set, and
% calculate the accuracy metrics precision, recall and f1 score
for i = 1:length(user_files)
    fprintf('%s\n----------------------------\n', user_files{i}(1:length(user_files{i})-4));
    fprintf('Class\tAccuracy\tPrecision\tRecall\tF1 Score\n');
    x = table2array(readtable(char(user_files(i))));
    sz1 = size(x,1); sz2 = size(x,2);
%     shuffle the datamatrix
    x = x(randperm(sz1),:);
%     split into training and test set
    split = int32((sz1)*0.6);
    train_set = x(1:split,1:sz2-1); train_label = x(1:split,sz2); test_set = x(split+1:sz1,1:sz2-1); test_label = x(split+1:sz1,sz2);
    
%     train one model for every gesture keeping it as positive class and
%     all the other gestures as negative class
    for class = 1:no_classes
        local_train_label = train_label;
        local_test_label = test_label;
        recall = 0; precision = 0; f1score = 0; correct_predictions = 0; tp = 0; fp = 0; fn = 0;
%         initialize the gesture class as 1 and all the other classes as 0
        for row = 1:size(local_train_label, 1)
            if local_train_label(row) == class
                local_train_label(row) = 1;
            else
                local_train_label(row) = 0;
            end
        end
        for row = 1:size(test_label, 1)
            if local_test_label(row) == class
                local_test_label(row) = 1;
            else
                local_test_label(row) = 0;
            end
        end
%         train and predict
        model = fitcsvm(train_set, local_train_label);
        predict_label = predict(model, test_set);
%         calculate fp, tp and fn
        for row = 1:size(local_test_label, 1)
            if predict_label(row) ~= local_test_label(row)
                if predict_label(row) == 1
                    fp = fp + 1;
                else
                    fn = fn + 1;
                end
            else
                correct_predictions = correct_predictions + 1;
                if predict_label(row) == 1
                    tp = tp + 1;
                end
            end
        end
%         calculate precision, recall and f1 score
        if tp == 0 && fp == 0
            precision = 1;
        else
            precision = tp/(tp+fp);
        end
        if tp == 0 && fn == 0
            recall = 1;
        else
            recall = (tp/(tp+fn));
        end
        f1score = (2*tp)/(2*tp+fp+fn);
        fprintf("%d\t%.2f%%\t\t%.2f\t\t%.2f\t%.2f\n", class, 100*correct_predictions/size(test_set, 1), precision, recall, f1score);
    end
    fprintf('----------------------------\n');
end

