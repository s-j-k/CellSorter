%% Performs the cell sorting

  % stack the waveforms and impute the data matrix
  dataTable=d_pre;
  % use the waveform with the highest spike height out of each channel
  channels = zeros(height(dataTable), 1);
  for ii = height(dataTable):-1:1
    % X(ii, :) = corelib.vectorise(dataTable.waveforms{ii});
    channels(ii) = max(max(dataTable(ii)));
    X(ii, :) = dataTable(ii);
  end

  % rescale within each time-series, to within the box [-1, 1]
  for ii = 1:size(X, 1)
    X(ii, :) = rescale(X(ii, :), -1, 1);
  end

  % add the firing rate as a feature
  % X = [X dataTable.firing_rate];

  %% Perform the cell sorting procedure

  % instantiate the CellSorter object
  cs = CellSorter;
  cs.algorithm = 'umap';

  %% Update the data table and visualize results
% need to find spike width and firing rate first



%%
  % perform dimensionality reduction and clustering
  labels_sw = cs.kcluster(dataTable.spike_width);
  labels_fr = cs.kcluster(dataTable.firing_rate);

  % diagram of classification

  %   firing_rate
  %       ^
  %       |
  %  FSI  |  FSI
  %       |
  % --------------->  spike_width
  %       |
  %  FSI  |  PYR
  %       |

  % if a cell has a low firing rate and a large spike width, it is pyramidal
  % check to see which label corresponds to large spike width
  if mean(dataTable.spike_width(labels_sw == 1)) > mean(dataTable.spike_width(labels_sw == 2))
    flag_sw = 1;
  else
    flag_sw = 2;
  end

  if mean(dataTable.firing_rate(labels_fr == 1)) > mean(dataTable.firing_rate(labels_fr == 2))
    flag_fr = 1;
  else
    flag_fr = 2;
  end

  dataTable.isPyramidal = labels_sw == flag_sw & labels_fr ~= flag_fr;

  % add the labels to the data table
  dataTable.labels_sw = labels_sw;
  dataTable.labels_fr = labels_fr;

  % save the results by overwriting the existing .mat file
  save('Holger-CellSorter-processed.mat', 'dataTable', 'r')
end

% plot the reduced data, colored by cluster
figure; hold on
scatter(dataTable.firing_rate(dataTable.isPyramidal), dataTable.spike_width(dataTable.isPyramidal));
scatter(dataTable.firing_rate(~dataTable.isPyramidal), dataTable.spike_width(~dataTable.isPyramidal));
title('Holger-CellSorter / k-means clustering')
xlabel('firing rate (Hz)')
ylabel('spike width (ms)')
legend({'pyr', 'fsi'}, 'Location', 'best')
figlib.pretty()

% plot the waveforms, grouped by cluster
figure;
time_points = (1/50) * 1:length(dataTable.waveforms{1}); % s

ax(1) = subplot(1, 2, 1); hold on;
indices = find(dataTable.isPyramidal);
for ii = 1:length(indices)
  plot(time_points, dataTable.waveforms{indices(ii)}(:, dataTable.channels(indices(ii))));
end
xlabel('time (s)')
ylabel('voltage deflection (a.u.)')
title(['pyramidal waveforms'])

ax(2) = subplot(1, 2, 2); hold on;
indices = find(~dataTable.isPyramidal);
for ii = 1:length(indices)
  plot(time_points, dataTable.waveforms{indices(ii)}(:, dataTable.channels(indices(ii))));
end
xlabel('time (s)')
ylabel('voltage deflection (a.u.)')
title(['fast-spiking interneuron waveforms'])

linkaxes(ax, 'xy')
figlib.pretty('LineWidth', 1, 'PlotBuffer', 0.1);


return
