% Clear workspace
clear; close all; clc;
% Create this directory if there isn't one
mkdir('FFT_Plot')
% Declare all global variables 
Fs = 15;                 
T = 1/Fs;
corr_coeff = [];
% Names of the files to be loaded
gestures = {'about.csv','and.csv','can.csv','cop.csv','deaf.csv','decide.csv','father.csv','find.csv','go out.csv','hearing.csv'};
% Names of the sensors' attributes
features = {'ALX','ALY','ALZ','ARX','ARY','ARZ','EMG0L','EMG1L','EMG2L','EMG3L','EMG4L','EMG5L','EMG6L','EMG7L','EMG0R','EMG1R','EMG2R','EMG3R','EMG4R','EMG5R','EMG6R','EMG7R','GLX','GLY','GLZ','GRX','GRY','GRZ','ORL','OPL','OYL','ORR','OPR','OYR'};

% Apply FFT for the time series data of every sensor attributes 
for feature = 1:length(features)
    FFT = {};
    % Apply FFT for each attributes
    fig = figure('name',char(features(feature)));
    for gesture = 1:length(gestures)
        % Read each file to extract the same attributes from each files
        rawData = readtable(char(gestures(gesture)));
        L = width(rawData) - 1;
        t = (0:L-1)*T;        
        f = Fs*(0:L/2)/L;
        Y = 0;
        for i = 0:((height(rawData)/34) - 1)
            % Apply FFT for all data of the same attributes
            input = table2array(rawData(i*34+feature,2:end));
            % Sum up the FFT output
            Y = Y + fft(input);
        end
        % Converting into single side power spectrum
        P2 = abs(Y/L)/(i+1);
        P1 = P2(1:(L/2+1));
        P1(2:end-1) = 2*P1(2:end-1);
        FFT = [FFT;P1];
        % Plot the FFT output of all the 10 gestures for a single attribute 
        subplot(2,5,gesture) 
        plot(f,P1)
        xlabel('Frequency (Hz)')
        ylabel('Power')
        title(gestures(gesture));
    end
    coeff = 0;
    % Find the correlation coefficient between each gestures of the same
    % attributes
    for a = 1:length(gestures)
        for b = (a+1):length(gestures)
            % Correlation coefficient can be found only between two signals
            % but we have 10 gestures for each attributes, hence we find correlation
            % coefficient for all possibile combinations and sum it up.
            signal1 = FFT{a};
            signal2 = FFT{b};
            % Appending zeros
            sx = size(signal1);
            sy = size(signal2);
            if sx(2) ~= sy(2)
                m = max(sx(2), sy(2));
                if sx(2) ~= m
                    signal1 = [signal1 zeros(abs([0 m]-sx))];
                else
                    signal2 = [signal2 zeros(abs([0 m]-sy))];
                end
            end
            R = corrcoef(signal1,signal2);
            % Summing up all the correlation coefficient
            coeff = coeff + R(2);
        end
    end
    corr_coeff = horzcat(corr_coeff,coeff);
    cd('FFT_Plot')
    % Saving all the plots in the folder FFT_Graph
    saveas(fig,strcat('FFT_',char(features(feature)),'.jpg'));
    cd ..
end
% Finding the best attributes by selecting five attributes whose
% correlation coefficient are the least among all
[coeffValue,featureIndex] = sort(corr_coeff,'ascend');
disp(features(featureIndex(1:5)))
