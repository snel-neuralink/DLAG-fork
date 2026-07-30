function [best_across_dim] = getBestDimension(baseDir)

    ll = [];
    across_dims = [];
    sweepFiles = dir(fullfile(baseDir,'mat_results'));
    sweepFiles = sweepFiles([sweepFiles.isdir]);
    sweepFiles = sweepFiles(~ismember({sweepFiles.name}, {'.', '..'}));
    run_idx = 0;
    for i=1:length(sweepFiles)
        run_idx = strsplit(sweepFiles(i).name,'run');
        run_idx = str2num(run_idx{1,2});
        % [cvResults, ~] = getCrossValResults_dlag(run_idx, 'baseDir', baseDir);
        % if isempty(cvResults)
        %     continue;
        % end
        % ll = [ll cvResults.sumLL.joint];
        % across_dims = [across_dims run_idx];
    end
    % get the dimensions for the best model
    % [max_ll, max_idx] = max(ll);
    % best_run_idx = max_idx-1;
    % best_across_dim = across_dims(max_idx);
    best_across_dim = run_idx;
    fprintf('Best across-group latent dimension: %d\n', best_across_dim);
end