function calculateLatents(data1, data2, baseDir, runIdx)
    T = size(data1,2); % time points
    for t=1:size(data1,1) % trials
        seq(t).trialId = t;
        seq(t).T = T;
        seq(t).y = [transpose(squeeze(data1(t,:,:)));
            transpose(squeeze(data2(t,:,:)))];
    end

    modelFile = dir(fullfile(baseDir,'mat_results',sprintf('run%03d',runIdx)));
    modelFile = modelFile(contains({modelFile.name}, 'dlag') & ~contains({modelFile.name}, 'cv'));
    if ~isempty(modelFile)
        filename = strsplit(modelFile(1).name,'_');
        best_within_dim_1 = str2double(filename{1,5});
        best_within_dim_2 = strsplit(filename{1,6},'.');
        best_within_dim_2 = str2double(best_within_dim_2{1,1});
        best_across_dim = runIdx;
        res = getModel_dlag(runIdx, best_across_dim, [best_within_dim_1, best_within_dim_2], ...
                        'baseDir', baseDir);
    else
        error('No DLAG model found for the specified run index.');
    end
    yDims = res.yDims;
    numGroups = length(yDims);
    sidx = [1, yDims(1)+1];
    eidx = [yDims(1), yDims(1) + yDims(2)];
    ySeq = [seq.y];
    xDim_total = res.xDim_within + res.xDim_across;
    % add the required fields to seq
    seq = exactInferenceWithLL_dlag(seq, res.estParams, 'getLL', false);
    groupSeq = partitionObs(seq,res.xDim_across+res.xDim_within,'datafield','xsm');
   
    seqAcross_all = cell(1,numGroups);
    seqWithin_all = cell(1,numGroups);
    for groupIdx = 1:numGroups
    
        % Partition latents into across- and within-group components
        [seqAcross, seqWithin] = partitionLatents_meanOnly(groupSeq{groupIdx}, ...
            res.estParams.xDim_across, res.estParams.xDim_within(groupIdx));
        seqAcross_all{groupIdx} = seqAcross;
        seqWithin_all{groupIdx} = seqWithin;
    end
    % save the results
    save(fullfile(modelFile(1).folder,'seq_latents.mat'),'seqAcross_all','seqWithin_all');

end