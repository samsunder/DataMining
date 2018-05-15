% Clear workspace
clear; close all; clc;
% Create these directory if there isn't one
mkdir('featureMatrix')
mkdir('featurePlot')
% Names of all the gestures
gestures = {'about','and','can','cop','deaf','decide','father','find','go out','hearing'};
% Names of the sensors' attributes
features = {'ALX','ALY','ALZ','ARX','ARY','ARZ','EMG0L','EMG1L','EMG2L','EMG3L','EMG4L','EMG5L','EMG6L','EMG7L','EMG0R','EMG1R','EMG2R','EMG3R','EMG4R','EMG5R','EMG6R','EMG7R','GLX','GLY','GLZ','GRX','GRY','GRZ','ORL','OPL','OYL','ORR','OPR','OYR'};
% Selected attributes by FFT method
fft_features = ["EMG0R" "EMG4R" "ALY" "GLY" "GLZ"];
% Selected attributes by PSD method
psd_features = ["EMG4L" "EMG0L" "EMG1L" "EMG3R" "EMG5L"];
% Selected attributes by DWT method
dwt_features = ["EMG5L" "EMG0R" "EMG4R" "OYR" "EMG4L"];
% Selected attributes by RMS method
rms_features = ["GRX" "GRY" "GLZ" "GRZ" "ALX"];
% Selected attributes by STD method
std_features = ["EMG5L" "EMG6L" "EMG7L" "EMG4L" "EMG0R"];
% List of all new feature names
featureNames = ["FFT_EMG0R_P1";"FFT_EMG0R_P2";"FFT_EMG0R_P3";
                "FFT_EMG4R_P1";"FFT_EMG4R_P2";"FFT_EMG4R_P3";
                "FFT_ALY_P1";"FFT_ALY_P2";"FFT_ALY_P3";
                "FFT_GLY_P1";"FFT_GLY_P2";"FFT_GLY_P3";
                "FFT_GLZ_P1";"FFT_GLZ_P2";"FFT_GLZ_P3";
                "PSD_EMG4L_P1";"PSD_EMG4L_P2";"PSD_EMG4L_P3";
                "PSD_EMG0L_P1";"PSD_EMG0L_P2";"PSD_EMG0L_P3";
                "PSD_EMG1L_P1";"PSD_EMG1L_P2";"PSD_EMG1L_P3";
                "PSD_EMG3R_P1";"PSD_EMG3R_P2";"PSD_EMG3R_P3";
                "PSD_EMG5L_P1";"PSD_EMG5L_P2";"PSD_EMG5L_P3";
                "DWT_EMG5L_P1";"DWT_EMG5L_P2";"DWT_EMG5L_P3";
                "DWT_EMG0R_P1";"DWT_EMG0R_P2";"DWT_EMG0R_P3";
                "DWT_EMG4R_P1";"DWT_EMG4R_P2";"DWT_EMG4R_P3";
                "DWT_OYR_P1";"DWT_EMG4R_P2";"DWT_EMG4R_P3";
                "DWT_EMG4L_P1";"DWT_EMG4L_P2";"DWT_EMG4L_P3";
                "RMS_GRX";"RMS_GRY";"RMS_GLZ";"RMS_GRZ";"RMS_ALX";
                "STD_EMG5L";"STD_EMG6L";"STD_EMG7L";"STD_EMG4L";"STD_EMG0R"];
% All the features extracted by different methods
featureExtraction = [fft_features;psd_features;dwt_features;rms_features;std_features];

% Read the files based on each gesture names
for gesture = 1 :length(gestures)
   rawData = readtable(char(strcat(gestures(gesture),'.csv')));
   % Find total number of actions
   actions = height(rawData)/34;
   L = width(rawData) - 1;
   %data = ["FFT_EMG0R_P1" "FFT_EMG0R_P2" "FFT_EMG0R_P3" "FFT_EMG4R_P1" "FFT_EMG4R_P2" "FFT_EMG4R_P3" "FFT_ALY_P1" "FFT_ALY_P2" "FFT_ALY_P3" "FFT_GLY_P1" "FFT_GLY_P2" "FFT_GLY_P3" "FFT_GLZ_P1" "FFT_GLZ_P2" "FFT_GLZ_P3" "PSD_EMG4L_P1" "PSD_EMG4L_P2" "PSD_EMG4L_P3" "PSD_EMG0L_P1" "PSD_EMG0L_P2" "PSD_EMG0L_P3" "PSD_EMG1L_P1" "PSD_EMG1L_P2" "PSD_EMG1L_P3" "PSD_EMG3R_P1" "PSD_EMG3R_P2" "PSD_EMG3R_P3" "PSD_EMG5L_P1" "PSD_EMG5L_P2" "PSD_EMG5L_P3" "DWT_EMG5L_P1" "DWT_EMG5L_P2" "DWT_EMG5L_P3" "DWT_EMG0R_P1" "DWT_EMG0R_P2" "DWT_EMG0R_P3" "DWT_EMG4R_P1" "DWT_EMG4R_P2" "DWT_EMG4R_P3" "DWT_OYR_P1" "DWT_EMG4R_P2" "DWT_EMG4R_P3" "DWT_EMG4L_P1" "DWT_EMG4L_P2" "DWT_EMG4L_P3" "RMS_GRX" "RMS_GRY" "RMS_GLZ" "RMS_GRZ" "RMS_ALX" "STD_EMG5L" "STD_EMG6L" "STD_EMG7L" "STD_EMG4L" "STD_EMG0R"];
   % Feature names will be the header for the output csv files
   data = [transpose(featureNames)];
   % Perform the feature extraction for every actions
   for i = 1:actions
        temp = [];
        % Read individual csv files
        input = table2array(rawData(1:34,2:end));
        % Perform all the 5 feature extraction methods
        for extraction = 1:length(featureExtraction)
            % Each feature extraction methods are performed for their
            % corresponding selected sensors' attributes
            feature_index = featureIndex(featureExtraction(extraction,:),features);
            switch extraction
                case 1
                    % Calling function to perform FFT
                    for instance = 1:length(feature_index)
                        % The function returns only the top three peak values after performing FFT
                        fftFeatureValues = fftFeatures(input(feature_index(instance),:), L);
                        temp = horzcat(temp,fftFeatureValues);
                    end
                case 2
                    % Calling function to perform PSD
                    for instance = 1:length(feature_index)
                        % The function returns only the top three peak values after performing PSD
                        psdFeatureValues = psdFeatures(input(feature_index(instance),:));
                        temp = horzcat(temp,psdFeatureValues);
                    end
                case 3
                    % Calling function to perform DWT
                    for instance = 1:length(feature_index)
                        % The function returns only the top three peak values after performing DWT
                        dwtFeatureValues = dwtFeatures(input(feature_index(instance),:));
                        temp = horzcat(temp,dwtFeatureValues);
                    end
                case 4
                    % Calling function to perform RMS
                    for instance = 1:length(feature_index)
                        % The function returns only the RMS value for the selected attributes
                        rmsFeatureValues = rmsFeatures(input(feature_index(instance),:));
                        temp = horzcat(temp,rmsFeatureValues);
                    end
                case 5
                    % Calling function to perform STD
                    for instance = 1:length(feature_index)
                        % The function returns only the STD value for the selected attributes
                        stdFeatureValues = stdFeatures(input(feature_index(instance),:));
                        temp = horzcat(temp,stdFeatureValues);
                    end            
            end
        end
        % Removing rows which has any non-numerical values.
        if temp ~= -Inf
            data = vertcat(data,temp);
        end
        rawData(1:34,:) = [];
   end
   % Labeling the spider plots with F1 to F55 
   fig = figure('name',char(gestures(gesture)));
   [m n] = size(data);
   P_labels = cell(n, 1);
   for ii = 1:n
       P_labels{ii} = sprintf('F %i', ii);
   end
   % Spider plots for each gestures
   spider_plot(str2double(data(2:end,:)), P_labels, 2, 1,...
   'Marker', 'o',...
   'LineStyle', '-',...
   'LineWidth', 2,...
   'MarkerSize', 5);
   cd('featurePlot')
   saveas(fig,strcat(char(gestures(gesture)),'_Features.jpg'));
   cd ..
   cd('featureMatrix')
   writetable(array2table(data),char(strcat(gestures(gesture),'Features.csv')),'WriteVariableNames',false);
   cd ..
end

% function which extracts and returns the index for particular attributes
function feature_index = featureIndex(listofFeatures,features)
feature_index = [];
for k = 1 : length(listofFeatures) 
    feature_index(end+1) = find(strcmp(features,listofFeatures(k)));
end
end

% function which performs FFT and returns the top 3 peak values.
function fftFeatureValues = fftFeatures(x,L)
Y = fft(x);
P2 = abs(Y/L);
P1 = P2(1:(L/2+1));
P1(2:end-1) = 2*P1(2:end-1);
[Data,I] = sort(P1,'descend'); 
% Returns only the top 3 peak values
fftFeatureValues = P1(I(:,1:3));
end

% function which performs PSD and returns the top 3 peak values.
function psdFeatureValues = psdFeatures(x)
Fs = 15;
Y = pspectrum(x,1024);
hpsd = dspdata.psd(Y,'Fs',Fs);
hpsdData = transpose(pow2db(hpsd.Data));
[Data,I] = sort(hpsdData,'descend'); 
% Returns only the top 3 peak values
psdFeatureValues = hpsdData(I(:,1:3));
end

% function which performs DWT and returns the top 3 peak values.
function dwtFeatureValues = dwtFeatures(x)
[A,D] = dwt(x,'sym4');
[Data,I] = sort(A,'descend');
% Returns only the top 3 peak values
dwtFeatureValues = A(I(:,1:3));
end

% function which performs RMS and returns the rms value.
function rmsFeatureValues = rmsFeatures(x)
rmsFeatureValues = rms(x);
end

% function which performs STD and returns the rms value.
function stdFeatureValues = stdFeatures(x)
stdFeatureValues = std(x);
end
