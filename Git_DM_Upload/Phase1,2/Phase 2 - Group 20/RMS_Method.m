% Clear workspace
clear; close all; clc;
% Declare all global variables 
Fs = 15;
ZPArray = 0;
W=0;
numberoftopfeatures = 5;
% Names of the files to be loaded
gestures = {'about.csv','and.csv','can.csv','cop.csv','deaf.csv','decide.csv','father.csv','find.csv','go out.csv','hearing.csv'};
% Names of the sensors' attributes
features = {'ALX','ALY','ALZ','ARX','ARY','ARZ','EMG0L','EMG1L','EMG2L','EMG3L','EMG4L','EMG5L','EMG6L','EMG7L','EMG0R','EMG1R','EMG2R','EMG3R','EMG4R','EMG5R','EMG6R','EMG7R','GLX','GLY','GLZ','GRX','GRY','GRZ','ORL','OPL','OYL','ORR','OPR','OYR'};

% Apply RMS for the time series data of every sensor attributes 
for gesture = 1:length(gestures)
    Data = 0;
    % Read each file to extract the same attributes from each files
    rawData = readtable(char(gestures(gesture)));
    input = table2array(rawData(1:1:end,2:46));
    input = cos(2*pi*15*input);
    % Applying RMS for the input data
    Y = rms(input,2);
    for p=1 : length(features) 
        Data2 = transpose(Y(p:p+length(features)-1,:));
        if (Data == 0)
            Data = Data2;
        else
            Data = [Data2;Data];
        end    
    end
    if W == 0
        W = trimmean(Data,0.5);
    else
        W = [W;trimmean(Data,0.5)];   
    end
end
% Finding the best attributes by selecting five attributes who has high variance among all
[Data,I] = sort(var(W),'descend'); 
disp(features(I(:,1:numberoftopfeatures)));