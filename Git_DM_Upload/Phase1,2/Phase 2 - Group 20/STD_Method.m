% Clear workspace
clear; close all; clc;
% Declare all global variables
numberoftopfeatures = 5;
W = 0;
% Names of the files to be loaded
gestures = {'about.csv','and.csv','can.csv','cop.csv','deaf.csv','decide.csv','father.csv','find.csv','go out.csv','hearing.csv'};
% Names of the sensors' attributes
features = {'ALX','ALY','ALZ','ARX','ARY','ARZ','EMG0L','EMG1L','EMG2L','EMG3L','EMG4L','EMG5L','EMG6L','EMG7L','EMG0R','EMG1R','EMG2R','EMG3R','EMG4R','EMG5R','EMG6R','EMG7R','GLX','GLY','GLZ','GRX','GRY','GRZ','ORL','OPL','OYL','ORR','OPR','OYR'};

% Apply STD for the time series data of every sensor attributes 
for gesture = 1:length(gestures)
    Z = 0;
    % Read each file to extract the same attributes from each files
    rawData = readtable(char(gestures(gesture)));
    input = table2array(rawData(:,2:46)); 
    % Applying STD for the input data
	Y = std(input,0,2);
	for i = 1:length(Y)/length(features)
        X = transpose(Y(i:i+length(features)-1,:));
        if Z == 0
            Z = X;
        else
            Z = [Z;X];
        end
    end
	if W == 0
        W = trimmean(Z,0.5);
    else
        W = [W;trimmean(Z,0.5)];
	end
end
% Finding the best attributes by selecting five attributes who has high variance among all
[Z,I] = sort(var(W),'descend');
disp(features(I(:,1:numberoftopfeatures)));