%clear wirksopace
clear; close all; clc;

% declare and initialise global variable
gestures = {'about','and','can','cop','deaf','decide','father','find','go out','hearing'};
features = {'ALX','ALY','ALZ','ARX','ARY','ARZ','EMG0L','EMG1L','EMG2L','EMG3L','EMG4L','EMG5L','EMG6L','EMG7L','EMG0R','EMG1R','EMG2R','EMG3R','EMG4R','EMG5R','EMG6R','EMG7R','GLX','GLY','GLZ','GRX','GRY','GRZ','ORL','OPL','OYL','ORR','OPR','OYR'};
for i = 1:37
  subFolders{i} = strcat('DM',num2str(i,'%02i'));
end
numActions = zeros(length(gestures),length(subFolders));
for gesture = 1:length(gestures)
    actionCount = 1;
    gestureData = {};
    gesRegex = strcat('*',char(gestures(gesture)),'*');
    gesFilename = strcat(char(gestures(gesture)),'.csv');
    for k = 1:length(subFolders) 
        cd(subFolders{k});
        files = dir(gesRegex);
        for file = 1:length(files)
            disp(files(fi le).name)
            rawData = readtable(files(file).name);
            disp(height(rawData))
            if (height(rawData) >= 40) && (height(rawData) <= 45)
                disp('True')
                rawData = rawData(:,(1:34));
                featureName = strcat('Action',num2str(actionCount,'%i'),features);
                rawData = table2array(rawData);
                Data = transpose([featureName;num2cell(rawData)]);
                if isempty(gestureData)
                    gestureData = [gestureData;Data];
                else
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
        numActions(gesture,k) = actionCount - 1;
    end

writetable(cell2table(gestureData),gesFilename,'WriteVariableNames',false);
end