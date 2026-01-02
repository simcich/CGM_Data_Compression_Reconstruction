%% RunMain.m
% -------------------------------------------------------------------------
% Script to evaluate landmark-based encoding methods for 
% Continuous Glucose Monitoring (CGM) profiles
%
% Aim:
% This script supports the article:
%   "Peak-Nadir Encoding for Efficient CGM Data Compression 
%    and High-Fidelity Reconstruction"
%
% The script loads CGM profiles, applies different compression methods
% (Peaks & Nadirs (PN), PN + Support points (PN+), and Uniform Downsampling),
% reconstructs the signals, and evaluates performance.
%
% Requirements:
%   - MATLAB R2020a or later
%   - Input CGM dataset in CSV format (288 samples per row, 24h @ 5min resolution)
%   - Supplementary functions:
%       * compress_Calc.m  (applies compression and reconstruction)
%       * compress_Eval.m  (evaluates performance metrics)
%
% Output:
%   - Reconstructed CGM signals
%   - Compression performance metrics (R², MAE, compression ratio, glycemic metrics)
%   - Figures showing landmark selection and reconstructed signals (if enabled)
%
% Author: Simon Cichosz
% 
% -------------------------------------------------------------------------

%% Housekeeping
clc; clear;

%% USER SETTINGS (adjust as needed)
plotON = 1;              % (1 = plot CGM profiles with landmarks and reconstruction; 0 = no plots)
MinPeakProminence = 15;  % Peak detection threshold [mg/dL]; higher = fewer detected peaks
ds = 14;                 % Downsampling rate (uniform selection every ds samples)
n = 22;                  % Total landmark points for PN / PN+ encoding (including peaks, nadirs, support)

%% LOAD DATA
% Input: CSV file containing CGM profiles
% Each row = one 24h profile with 288 samples (5-min resolution)
% Example path below – adjust to your local dataset
cgms = csvread('C:\Users\Basis User\Desktop\compressCGM\SyntheticCGM\db.csv');

% Preallocate storage for results
allMetrics      = table();  % Summary metrics
allMetricsRec1  = table();  % PN results
allMetricsRec2  = table();  % PN+ results
allMetricsRec3  = table();  % Downsampling results
outMea          = [];       % Per-profile error values
points          = [];       % Landmark points

%% LOOP THROUGH CGM PROFILES
% Define time axis (24h @ 5 min resolution)
tim = datetime('00:00', 'Format', 'HH:mm') + minutes(0:5:1435);

% Example: process only profile #10008
% Change loop range to process multiple profiles
for k = 10000+8 : 10000+8
    glucose = cgms(k, 2:289);  % Extract one CGM profile (skip ID column)
    t = 1:288;                 % Sample indices
    
    % Apply compression methods and reconstruct
    % compress_Calc.m handles:
    %   - PN method
    %   - PN+ method
    %   - Uniform downsampling
    %   - Interpolation-based reconstruction
    %   - Calculation of CGM metrics
    compress_Calc
    
    % Increment counter
    i = i + 1;
end

%% EVALUATION
% Run evaluation of reconstructed signals
% compress_Eval.m computes:
%   - Mean Absolute Error (MAE)
%   - R² (coefficient of determination)
%   - Preservation of CGM-derived clinical metrics (e.g., TIR, MAGE)
compress_Eval
