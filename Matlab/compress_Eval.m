%% Compression 
points = struct2table(points);


compress1 =  1/median(points.rec1./points.original)
compress2= 1/median(points.rec2./points.original)
compress3= 1/median(points.rec3./points.original)

%% assesments
% Define the list of variable names
variableNames = {'Mean', 'CV', 'Std','TIR','TITR','TBR','TBR1','TBR2','TAR','TAR1','TAR2','MAGE'}; %  variable names

% Initialize an empty table for storing results
metrics_results = table();

% Loop over each variable and compute the metrics
for i = 1:length(variableNames)
    varName = variableNames{i};
    
    % Extract corresponding columns from tables
    y = allMetrics.(varName);
    y_rec1 = allMetricsRec1.(varName);
    y_rec2 = allMetricsRec2.(varName);
    y_rec3 = allMetricsRec3.(varName);
    
    % Remove NaN values by keeping only valid indices
    validIdx1 = ~isnan(y) & ~isnan(y_rec1);
    validIdx2 = ~isnan(y) & ~isnan(y_rec2);
    validIdx3 = ~isnan(y) & ~isnan(y_rec3);
    
    % Compute metrics for Rec1 if sufficient valid data exists
    if sum(validIdx1) > 1
        y_valid1 = y(validIdx1);
        y_rec1_valid = y_rec1(validIdx1);
        

        % Pearson correlation coefficient
        r_rec1 = corr(y_valid1, y_rec1_valid);

        R2_rec1 = r_rec1^2;
        
        % Mean Absolute Error (MAE)
        MAE_rec1 = mean(abs(y_valid1 - y_rec1_valid));

        % % MARD 
        % MAE_rec1 = mean(abs(y_valid1 - y_rec1_valid) ./ (y_valid1+0.000000000001)) * 100;
    else
        R2_rec1 = NaN;
        r_rec1 = NaN;
        MAE_rec1 = NaN;
    end
    
    % Compute metrics for Rec2 if sufficient valid data exists
    if sum(validIdx2) > 1
        y_valid2 = y(validIdx2);
        y_rec2_valid = y_rec2(validIdx2);
        
        
        % Pearson correlation coefficient
        r_rec2 = corr(y_valid2, y_rec2_valid);

        R2_rec2 = r_rec2^2;
        
        % Mean Absolute Error (MAE)
        MAE_rec2 = mean(abs(y_valid2 - y_rec2_valid));

    else
        R2_rec2 = NaN;
        r_rec2 = NaN;
        MAE_rec2 = NaN;
    end

    % Compute metrics for Rec3 if sufficient valid data exists
    if sum(validIdx3) > 1
        y_valid3 = y(validIdx3);
        y_rec3_valid = y_rec3(validIdx3);
        
        
        % Pearson correlation coefficient
        r_rec3 = corr(y_valid3, y_rec3_valid);

        R2_rec3 = r_rec3^2;
        
        % Mean Absolute Error (MAE)
        MAE_rec3 = mean(abs(y_valid3 - y_rec3_valid));


    else
        R2_rec3 = NaN;
        r_rec3 = NaN;
        MAE_rec3 = NaN;
    end
    
    % Round the values to 2 decimal places
    R2_rec1 = round(R2_rec1, 2);
    r_rec1 = round(r_rec1, 2);
    MAE_rec1 = round(MAE_rec1, 2);
    R2_rec2 = round(R2_rec2, 2);
    r_rec2 = round(r_rec2, 2);
    MAE_rec2 = round(MAE_rec2, 2);
    R2_rec3 = round(R2_rec3, 2);
    r_rec3 = round(r_rec3, 2);
    MAE_rec3 = round(MAE_rec3, 2);
    
    
    % Append results to table
    newRow = table({varName}, R2_rec1, r_rec1, MAE_rec1, R2_rec2, r_rec2, MAE_rec2, R2_rec3, r_rec3, MAE_rec3,...
                   'VariableNames', {'Variable', 'R2_Rec1', 'r_Rec1', 'MAE_Rec1', 'R2_Rec2', 'r_Rec2', 'MAE_Rec2', 'R2_Rec3', 'r_Rec3', 'MAE_Rec3'});
    
    metrics_results = [metrics_results; newRow];
end

% Display the results
disp(metrics_results);

R2_rec1 = mean(metrics_results.R2_Rec1)
R2_rec2 = mean(metrics_results.R2_Rec2)
R2_rec3 = mean(metrics_results.R2_Rec3)

r_rec1 = mean(metrics_results.r_Rec1)
r_rec2 = mean(metrics_results.r_Rec2)
r_rec3 = mean(metrics_results.r_Rec3)

MAE_rec1 = mean(metrics_results.MAE_Rec1)
MAE_rec2 = mean(metrics_results.MAE_Rec2)
MAE_rec3 = mean(metrics_results.MAE_Rec3)