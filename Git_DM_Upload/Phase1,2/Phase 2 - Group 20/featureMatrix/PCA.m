% Clear the workspace
clear; close all; clc;
% Create these directory if there isn't one
mkdir('PCA_Plot')
mkdir('PCA_Matrix')
% List of all gesture names
gestureNames = {'about','and','can','cop','deaf','decide','father','find','go out','hearing'};
% Names of all csv Files
gestures = {'aboutFeatures.csv','andFeatures.csv','canFeatures.csv','copFeatures.csv','deafFeatures.csv','decideFeatures.csv','fatherFeatures.csv','findFeatures.csv','go outFeatures.csv','hearingFeatures.csv'};
% Names of the sensors' attributes
features = {'ALX','ALY','ALZ','ARX','ARY','ARZ','EMG0L','EMG1L','EMG2L','EMG3L','EMG4L','EMG5L','EMG6L','EMG7L','EMG0R','EMG1R','EMG2R','EMG3R','EMG4R','EMG5R','EMG6R','EMG7R','GLX','GLY','GLZ','GRX','GRY','GRZ','ORL','OPL','OYL','ORR','OPR','OYR'};
% Declare all the global variable 
gesture_index = int16.empty(length(gestures) + 1, 0);
gesture_index(1) = 1;
dataset = 0;
NumComponents = 0;
variance_sum = 0;

% read the feature martices, and append vertically
for gesture = 1:length(gestures)
    % Read the data from each csv files
    rawData = table2array(readtable(char(gestures(gesture))));
    if size(dataset, 1) == 1
        dataset = rawData;
    else
        % Append all the data vertically
        dataset = vertcat(dataset, rawData);
    end
    % Store the index whenever you append a new file
    gesture_index(gesture + 1) = size(dataset, 1);
end

% Perform PCA on the dataset
[coeff,score,latent] = pca(dataset);
total_variance = sum(latent);

% Get the least number of components contributing more than (90%) variance
for i = 1:size(latent, 1)
    variance_sum = variance_sum + latent(i,1);
    NumComponents = NumComponents + 1;
    if variance_sum / total_variance >= 0.9
        break;
    end
end

% Labeling the spider plots with F1 to F55
P_labels = cell(NumComponents, 1); 
for ii = 1:NumComponents
P_labels{ii} = sprintf('F %i', ii); 
end 

% Plotting the eigen vectors using biplot
fig = figure('name','PCA Eigen Vectors Analysis');
for i = 1:(NumComponents-1)
    % We have 8 principle components and we are plotting eigen vectors of
    % every two consecutive principle components.
    subplot(floor(NumComponents/2),2,i);
    biplot(coeff(:,i:i+1),'Scores',score(:,i:i+1));%'VarLabels',P_labels);
    title(['Component' num2str(i) ' v/s Componnet' num2str(i+1)]);
    xlabel(strcat('Component',num2str(i)));
    ylabel(strcat('Componnet',num2str(i+1)));
end
saveas(fig,strcat('PCA Eigen Vectors Analysis','.jpg'));

% Extract the new feature matrix by multiplying the input feature matrix
% and eigen vectors of first 8 principle components
new_feature_matrix = dataset * coeff(:,1:NumComponents);


% Splitting the new feature matrix for each gesture
for gesture = 1:length(gestures)
    gestureRows = new_feature_matrix(gesture_index(gesture):gesture_index(gesture + 1), :);
    cd('PCA_Matrix')
    % Write the data into separate csv files.
    writetable(array2table(gestureRows), strcat("PCA", gestures(gesture)),'WriteVariableNames',false);
    cd ..
    % Spider plot the new feature matrix for each gesture
    fig = figure('name',char(gestures(gesture)));
    spider_plot(gestureRows(:,1:8), P_labels, 2, 1,... 
    'Marker', 'o',... 
    'LineStyle', '-',... 
    'LineWidth', 2,... 
    'MarkerSize', 5);
    title(strcat('PCA ',char(gestures(gesture))));
    cd('PCA_Plot')
    saveas(fig,strcat('PCA',char(gestureNames(gesture)),'.jpg'));
    cd ..
end