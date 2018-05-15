% Clear workspace
clear; close all; clc
% Create this directory if there isn't one
mkdir('DWT_Plot')
% Declare all global variables 
Fs = 15;
corr_coeff = [];
% Names of the files to be loaded
gestures = {'about.csv','and.csv','can.csv','cop.csv','deaf.csv','decide.csv','father.csv','find.csv','go out.csv','hearing.csv'};
% Names of the sensors' attributes
features = {'ALX','ALY','ALZ','ARX','ARY','ARZ','EMG0L','EMG1L','EMG2L','EMG3L','EMG4L','EMG5L','EMG6L','EMG7L','EMG0R','EMG1R','EMG2R','EMG3R','EMG4R','EMG5R','EMG6R','EMG7R','GLX','GLY','GLZ','GRX','GRY','GRZ','ORL','OPL','OYL','ORR','OPR','OYR'};

% Apply DWT for the time series data of every sensor attributes 
for feature = 1:length(features)
    dwtData = {};
    % Apply DWT for each attributes
    fig = figure('name',char(features(feature)));
    for gesture = 1:length(gestures)
        % Read each file to extract the same attributes from each files
        rawData = readtable(char(gestures(gesture)));
        L = height(rawData)/34;
        Y = 0;
        for i = 0:(L - 1)
            % Apply DWT for all data of the same attributes
            input = table2array(rawData(i*34+feature,2:end));
            [A,D] = dwt(input,'sym4');
            % Sum up the DWT output
            Y = Y + A;
        end
        Y = Y/L;
        dwtData = [dwtData;Y];
        % Plot the DWT output of all the 10 gestures for a single attribute 
        subplot(2,5,gesture) 
        plot(Y)
        xlabel('Time');
        ylabel('Coefficient Value');
        title(gestures(gesture));
    end
    coeff = 0;
    % Find the correlation coefficient between each gestures of the same
    % attributes
    for a = 1:length(gestures)
        for b = (a+1):length(gestures)
            signal1 = dwtData{a};
            signal2 = dwtData{b};
            R = corrcoef(signal1,signal2);
            coeff = coeff + R(2);
        end
    end
    corr_coeff = horzcat(corr_coeff,coeff); 
    cd('DWT_Plot')
    % Saving all the plots in the folder DWT_Graph
    saveas(fig,strcat('DWT_',char(features(feature)),'.jpg'));
    cd ..
end
% Finding the best attributes by selecting five attributes whose
% correlation coefficient are the least among all
[coeffValue,featureIndex] = sort(corr_coeff,'ascend'); 
disp(features(featureIndex(1:5)))