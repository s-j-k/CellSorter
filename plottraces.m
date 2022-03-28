figure; hold on;
nTraces=size(d_pre,1);
offset=5;
% for i = 1:nTraces
for i = 1:nTraces
    plot(1:size(d_pre,2),d_pre(i,:)+i*offset - offset)
end
ylim([-5 200])
%% now sort
figure;hold on;
[maxF,ind] = max(d_pre, [], 2);
[~, index] = sort(ind);
cc = d_pre(index, :);

for i = 1:nTraces
    plot(1:size(d_pre,2),cc(i,1:size(d_pre,2))+i*offset - offset)
end
ylim([-5 200])
%%
% now normalize the traces ? 


%%
figure; hold on;
imagesc(cc)
