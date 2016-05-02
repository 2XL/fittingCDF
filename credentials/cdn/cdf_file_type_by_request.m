clc;
clear all;
close all;

%%

disp('CDF plot: file type by profile') 

operation = {'get', 'make','move', 'put' , 'unlink'};
% load file

file_prefix = 'cdf_file_type_request_';
file_extension = '.csv';

disp('----print csv files-----')
% Create figure
figureCDF = figure;
% Create axes
axesCDF = axes('Parent',figureCDF);
title('CDF of file type distribution by request')
% Set the remaining axes properties
set(axesCDF,'XMinorTick','on','XScale','log','YMinorTick','on','YScale','linear');
hold(axesCDF,'on');

for oper = operation

file_name = strcat(file_prefix,oper,file_extension);


% locate the file
% test = csvread(file_name{1}, 1, 1, );

% filename = 'G:\trazas.csv\cdf [unicos] ficheros por formato y [perfil]\u1file_type_prob_freq_backup.csv';
filename = file_name{1};

[multitype, hit] = importfileMultitypeHit(filename);
%% Allocate imported array to column variable names
 

% sort the index
% [hitSorted, sortedIndex] = sort(hit);
% multipartSorted = multipart(sortedIndex);



%% Clear temporary variables
% clearvars filename delimiter startRow formatSpec fileID dataArray ans;
 
ecdf(hit) 

end

xlabel('count');
% Create ylabel
ylabel('files');

legend(operation);

legend(axesCDF,'show');
box(axesCDF,'on');
disp '------bundle keys-------'

disp 'save as: '

output_file = 'cdf_file_type_by_request.png'
saveas(figureCDF, output_file );



















