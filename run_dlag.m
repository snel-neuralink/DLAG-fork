function run_dlag(data1,data2, baseDir, runIdx, xDims_across, xDims_within1, xDims_within2, maxIters,numFolds, randomSeed)
    % add path to DLAG
    % addpath(genpath(funcpath))
    
    
    T = size(data1,2); % time points
    for t=1:size(data1,1) % trials
        seq(t).trialId = t;
        seq(t).T = T;
        seq(t).y = [transpose(squeeze(data1(t,:,:)));
            transpose(squeeze(data2(t,:,:)))];
    end
    
       
        % print the size of y for verification
        disp("Size of each trial: "+num2str(size(seq(1).y)))
        yDims = [size(data1, 3) size(data2,3)];          % Number of observed features (neurons) in each group (area)
        disp("Number of latents: "+num2str(yDims))
        % xDims_across = 0;         % This number of across-group latents matches the synthetic ground truth
        % xDims_within = {5, 5};    % These numbers match the within-group latents in the synthetic ground truth
        % xDims_across = 3;
        % xDims_within = num2cell(yDims-xDims_across);
        xDims_within = {xDims_within1, xDims_within2};
        disp("Number of across-group latents: "+num2str(xDims_across))
        disp("Number of within-group latents: "+num2str(cell2mat(xDims_within)))
        segLength = T;           % Largest trial segment length, in no. of time points
        % 0b) Set up parallelization
        % ===========================
    
        % If parallelize is true, all cross-validation folds and bootstrap samples
        % will be analyzed in parallel using Matlab's parfor construct. 
        % If you have access to multiple cores, this provides significant speedup.
        parallelize = true;
        numWorkers = 32;      % Adjust this to your computer's specs
    
        % 1a) Fitting a DLAG model
        % ========================
    
        % Let's explicitly define all of the optional arguments, for 
        % the sake of demonstration:
                       % Results will be saved in baseDir/mat_results/runXXX/,  
                               % where XXX is runIdx. Use a new runIdx for each dataset.
                % Base directory where results will be saved
        overwriteExisting = false; % Control whether existing results files are overwritten
        saveData = false;         % Set to true to save train and test data (not recommended)
        method = 'dlag';          % For now this is the only option, but that may change in the near future
        binWidth = 15;            % Sample period / spike count bin width, in units of time (e.g., ms)
        % numFolds = 0;             % Number of cross-validation folds (0 means no cross-validation)
        
        rGroups = [1 2];          % For performance evaluation, we can regress group 2's activity with group 1
        startTau = 2*binWidth;    % Initial timescale, in the same units of time as binWidth
        
        init_method = 'static';   % Initialize DLAG with fitted pCCA parameters
        learnDelays = true;       % Set to false if you want to fix delays at their initial value
        % maxIters = 1e3;           % Limit the number of EM iterations (not recommended for final fitting stage)
        freqLL = 10;              % Check for data log-likelihood convergence every freqLL EM iterations
        freqParam = 10;          % Store intermediate delay and timescale estimates every freqParam EM iterations
        minVarFrac = 0.001;        % Private noise variances will not be allowed to go below this value
        verbose = true;           % Toggle printed progress updates
        % randomSeed% = 0;           % Seed the random number generator, for reproducibility
        fitAll = true;
        saveDir = sprintf('%s/mat_results/run%03d', baseDir, runIdx);
       if ~isfolder(saveDir)
            mkdir(saveDir);
        end
        save(fullfile(saveDir,'seq_data.mat'), 'seq')
        fit_dlag(runIdx, seq, ...
                 'baseDir', baseDir, ...
                 'method', method, ...
                 'binWidth', binWidth, ...
                 'numFolds', numFolds, ...
                 'xDims_across', xDims_across, ...
                 'xDims_within', xDims_within, ...
                 'yDims', yDims, ...
                 'rGroups', rGroups,...
                 'startTau', startTau, ...
                 'segLength', segLength, ...
                 'init_method', init_method, ...
                 'learnDelays', learnDelays, ...
                 'maxIters', maxIters, ...
                 'freqLL', freqLL, ...
                 'freqParam', freqParam, ...
                 'minVarFrac', minVarFrac, ...
                 'parallelize', false, ... % Only relevant for cross-validation
                 'verbose', verbose, ...
                 'randomSeed', randomSeed, ...
                 'overwriteExisting', overwriteExisting, ...
                 'saveData', saveData, ...
                 'fitAll', fitAll);

xDims_within = [xDims_within1, xDims_within2];
res = getModel_dlag(runIdx, xDims_across, xDims_within, ...
'baseDir', baseDir);
saveDir = sprintf('%s/mat_results/run%03d/', baseDir, runIdx);
plotFittingProgress(res, ...
                    'freqLL', freqLL, ...
                    'freqParam', freqParam, ...
                    'units', 'ms', ...
                    'saveDir', saveDir);


    end