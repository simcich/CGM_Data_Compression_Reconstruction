

%ds = downsample rate for "dumb" method
if ~exist('ds', 'var')
    ds = 12;  % Replace with the actual default value you want
end

% Find peaks (meal-related glucose spikes)
[peaks, peak_locs] = findpeaks(glucose, t, 'MinPeakProminence', MinPeakProminence); %10  MinPeakProminence

% Find nadirs (glucose dips)
inverted_glucose = -glucose; % Invert signal to find valleys
[nadirs, nadir_locs] = findpeaks(inverted_glucose, t, 'MinPeakProminence', MinPeakProminence);
nadirs = -nadirs; % Convert back to normal scale

% Ensure all values are row vectors
peak_locs = peak_locs(:).';
nadir_locs = nadir_locs(:).';
peaks = peaks(:).';
nadirs = nadirs(:).';

% Include first and last measurement
first_time = t(1);
first_value = glucose(1);
last_time = t(end);
last_value = glucose(end);

% Combine all key points (first, last, peaks, nadirs)
key_times = [first_time, peak_locs, nadir_locs, last_time];
key_values = [first_value, peaks, nadirs, last_value];

% Sort everything by time
[key_times, sort_idx] = sort(key_times);
key_values = key_values(sort_idx);

% Store in a single matrix (time, value)
compressed_data = [key_times; key_values]';


%% Greedy add additional keypoints
% Ensure key_times and key_values are column vectors
key_times2 = key_times(:);
key_values2 = key_values(:);

% Get indices of existing key_times in t
[~, key_indices] = ismember(key_times2, t);
key_indices = unique(key_indices);

% Check how many more points to add
points_to_add = n - numel(key_indices);
if points_to_add <= 0
    warning('Already have >= n key points.');
    glucose_reconstructed = interp1(key_times2, key_values2, t, 'pchip');
    
else

% Begin greedy point selection
for ii = 1:points_to_add
    best_err = inf;
    best_idx = -1;

    for j = 1:length(t)
        if ismember(j, key_indices)
            continue;
        end

        % Add candidate
        temp_indices = sort([key_indices; j]);
        temp_times = t(temp_indices);
        temp_values = glucose(temp_indices);

        % Interpolate and calculate error
        reconstructed = interp1(temp_times, temp_values, t, 'pchip');
        err = nanmean(abs(glucose - reconstructed));  % L2 norm

        if err < best_err
            best_err = err;
            best_idx = j;
        end
    end

    % Update with the best new point
    key_indices = sort([key_indices; best_idx]);
end

end

% Final reconstruction
key_times2 = t(key_indices);
key_values2 = glucose(key_indices);


%% Downsample approach
key_times3 = t(1:ds:end);
key_values3 = glucose(1:ds:end);
if t(end)~=key_times3(end)
    key_times3 = [key_times3 t(end)];
    key_values3 = [key_values3 glucose(end)];
end


%% reconstruct signal

% Reconstruct signal using cubic spline interpolation
glucose_reconstructed = interp1(key_times, key_values, t, 'pchip');
glucose_reconstructed2 = interp1(key_times2, key_values2, t, 'pchip');

glucose_reconstructed3 = interp1(key_times3, key_values3, t, 'linear');



%% calc out measurments

samling_f = 5;                 % Sampling frequency in minutes.
sampling_variation = 0.05;      % Threshold for sampling variation in minutes.
morning_start_h = 8;            % Hour at which the morning period starts, marking the end of night.
convertToMgdL = 0;              % Conversion flag for CGM measurements (1=convert mmol/L to mg/dL).
ploton = 0;                     % plotting flag (0= not plots)
handleMissing = 'remove';  % 'interpolate' or 'remove' to handle missing data.

% Original signal
cgm = table( glucose', tim', 'VariableNames', {'cgmval', 'time'});
% Compute the CGM metrics using the QoCGM function.
metrics = QoCGM(cgm, samling_f, sampling_variation, morning_start_h, convertToMgdL, ploton, handleMissing);
metrics = struct2table(metrics, 'AsArray', true);
allMetrics = [allMetrics; metrics]; 

% Reconstruct1
cgm = table( glucose_reconstructed', tim', 'VariableNames', {'cgmval', 'time'});
% Compute the CGM metrics using the QoCGM function.
metrics = QoCGM(cgm, samling_f, sampling_variation, morning_start_h, convertToMgdL, ploton, handleMissing);
metrics = struct2table(metrics, 'AsArray', true);
allMetricsRec1 = [allMetricsRec1; metrics]; 

% Reconstruct2
cgm = table( glucose_reconstructed2', tim', 'VariableNames', {'cgmval', 'time'});
% Compute the CGM metrics using the QoCGM function.
metrics = QoCGM(cgm, samling_f, sampling_variation, morning_start_h, convertToMgdL, ploton, handleMissing);
metrics = struct2table(metrics, 'AsArray', true);
allMetricsRec2 = [allMetricsRec2; metrics]; 


% Reconstruct3
cgm = table( glucose_reconstructed3', tim', 'VariableNames', {'cgmval', 'time'});
% Compute the CGM metrics using the QoCGM function.
metrics = QoCGM(cgm, samling_f, sampling_variation, morning_start_h, convertToMgdL, ploton, handleMissing);
metrics = struct2table(metrics, 'AsArray', true);
allMetricsRec3 = [allMetricsRec3; metrics]; 




points(i).rec1 = size(key_values,2);
points(i).rec2 = size(key_values2,2);
points(i).rec3 = size(key_values3,2);
points(i).original = size(glucose,2);




%% Plot profiles, encoding and reconstruction

if plotON==1

    %% Plot
    % Create a figure
    fig = figure;
    hold on;



    set(gca,'fontname','robot')
    get(gca,'fontname')
    sg = sgtitle('Encoding / decoding','FontWeight', 'bold')
    sg.HorizontalAlignment = 'left'; % Align title to the left
    sg.FontSize = 12; % Set font size for the sgtitle

    % Set the size of the figure
    fig.Position = [10, 10, 700, 700]; % [left, bottom, width, height]

    kv2 = key_values2;
    kt2 = key_times2;
    % Find indices in kt2 that are NOT in key_times
    mask = ~ismember(kt2, key_times);
    
    % Keep only values not in key_times
    kt2 = kt2(mask);
    kv2 = kv2(mask);

    subplot(2,1,1)
    % Plot detected peaks, nadirs, and first/last points
    plot(t, glucose,'color', [128, 128, 128] / 255, 'LineWidth', 1.5); hold on;
    plot(kt2, kv2, 'o', 'color',  [255, 121, 120] / 255, 'MarkerFaceColor', [255, 121, 120] / 255, 'MarkerSize', 5);
    plot(peak_locs, peaks, '^','color',  'k', 'MarkerFaceColor',  'k', 'MarkerSize', 5.2);
    plot(nadir_locs, nadirs, 'v', 'color',  'k', 'MarkerFaceColor',  'k', 'MarkerSize', 5.2);
    plot([first_time, last_time], [first_value, last_value], 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 5);
    xlabel('Time (hours)');
    ylabel('Glucose (mg/dL)');
    legend('Original Signal','Support',  'Peaks', 'Nadirs', 'First & Last','Location', 'northwest');
    xticks([0 6 12 18 24]*12); % Adjust tick marks based on hours
    xtick_labels = {'0', '6', '12', '18', '24'};
    xticklabels(xtick_labels);
    grid on;
    %title('A');


    % Plot original vs. reconstructed signal
    subplot(2,1,2)
    plot(t, glucose,'color', [128, 128, 128] / 255, 'LineWidth', 1.5); hold on;
    curve1= plot(t, glucose_reconstructed, '--', 'color', [128, 128, 128] / 255, 'LineWidth', 1.5);
    curve2= plot(t, glucose_reconstructed2, '-', 'color',  [255, 121, 120] / 255,'LineWidth', 1.5);

    plot(kt2, kv2, 'o', 'color',  [255, 121, 120] / 255, 'MarkerFaceColor', [255, 121, 120] / 255, 'MarkerSize', 5);
    plot(peak_locs, peaks, '^','color',  'k', 'MarkerFaceColor',  'k', 'MarkerSize', 5.2);
    plot(nadir_locs, nadirs, 'v', 'color',  'k', 'MarkerFaceColor',  'k', 'MarkerSize', 5.2);
    plot([first_time, last_time], [first_value, last_value], 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 5);

    xlabel('Time (hours)');
    ylabel('Glucose (mg/dL)');
    lgd = legend([curve1, curve2], {'Decoded PN', 'Decoded PN+'}, 'Location', 'northwest');

    xticks([0 6 12 18 24]*12); % Adjust tick marks based on hours
    xtick_labels = {'0', '6', '12', '18', '24'};
    xticklabels(xtick_labels);
    grid on;
    %title('B');

    % Save the figure as a PNG with the specified size
    exportgraphics(fig, 'Figure.png', 'Resolution', 600); % High resolution



end