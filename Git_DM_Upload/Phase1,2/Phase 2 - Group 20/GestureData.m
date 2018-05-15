% Clear workspace
clear; close all; clc;
% Names of all the gestures
gestures = {'about','and','can','cop','deaf','decide','father','find','go out','hearing'};
% Names of the sensors' attributes
features = {'ALX','ALY','ALZ','ARX','ARY','ARZ','EMG0L','EMG1L','EMG2L','EMG3L','EMG4L','EMG5L','EMG6L','EMG7L','EMG0R','EMG1R','EMG2R','EMG3R','EMG4R','EMG5R','EMG6R','EMG7R','GLX','GLY','GLZ','GRX','GRY','GRZ','ORL','OPL','OYL','ORR','OPR','OYR'};
% Names of all the subFolders from which the files are read.
for i = 1:37
  subFolders{i} = strcat('DM',num2str(i,'%02i'));
end

% Read the files based on each gesture names
for gesture = 1:length(gestures)
    actionCount = 1;
    gestureData = {};
    % Look for any files with *gesture* name
    gesRegex = strcat('*',char(gestures(gesture)),'*');
    gesFilename = strcat(char(gestures(gesture)),'.csv');
    % Read all files of the same gesture from all the subfolders
    for k = 1:length(subFolders) 
        cd(subFolders{k});
        % Getting all the files in that subfolder
        files = dir(gesRegex);
        for file = 1:length(files)
            disp(files(file).name)
            % Read individual files
            rawData = readtable(files(file).name);
            disp(height(rawData))
            % Check if the number of rows are between 40 and 45, if not,
            % discard that file
            if (height(rawData) >= 40) && (height(rawData) <= 45)
                % Consider only the first 34 attributes
                rawData = rawData(:,(1:34));
                featureName = strcat('Action',num2str(actionCount,'%i'),features);
                rawData = table2array(rawData);
                % Transposing the data and append all action vertically
                Data = transpose([featureName;num2cell(rawData)]);
                if isempty(gestureData)
                    gestureData = [gestureData;Data];
                else
                    % Appending zeros
                    sx = size(gestureData);
                    sy = size(Data);
                    if sx(2) ~= sy(2)
                        a = max(sx(2), sy(2)); 
                        gestureData = [[gestureData num2cell(zeros(abs([0 a]-sx)))]; [Data num2cell(zeros(abs([0 a]-sy)))]];
                    else
                        gestureData =  [gestureData;Data];
                    end

                end
                actionCount = actionCount + 1;
            end
        end
        cd ..
        disp(subFolders{k})
    end
% Write the final data into a new csv file with the corresponding gesture
% name as it's file name.
writetable(cell2table(gestureData),gesFilename,'WriteVariableNames',false);
end