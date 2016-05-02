clc
clear all;
close all;
 


 
 

disp('CDF plot: file size by multitype') 

multitype = {'audio', 'application','chemical','image','message', 'text','video'};
% load file

file_prefix = 'cdf_file_size_';
file_extension = '.csv';

disp('----print csv files-----')
% Create figure
figureCDF = figure;
% Create axes
axesCDF = axes('Parent',figureCDF);
title('CDF of file size distribution by multitype')
% Set the remaining axes properties
set(axesCDF,'XMinorTick','on','XScale','log','YMinorTick','on','YScale','linear');
hold(axesCDF,'on');

for mult = multitype

file_name = strcat(file_prefix,mult,file_extension);


% locate the file
% test = csvread(file_name{1}, 1, 1, );

% filename = 'G:\trazas.csv\cdf [unicos] ficheros por formato y [perfil]\u1file_type_prob_freq_backup.csv';
filename = file_name{1};

[min, max] = importfile(filename);
%% Allocate imported array to column variable names
 

% sort the index
% [hitSorted, sortedIndex] = sort(hit);
% multipartSorted = multipart(sortedIndex);



%% Clear temporary variables
% clearvars filename delimiter startRow formatSpec fileID dataArray ans;
 
ecdf(max) 

end

xlabel('size');
% Create ylabel
ylabel('files');

legend(multitype);

legend(axesCDF,'show');
box(axesCDF,'on');
disp '------bundle keys-------'

disp 'save as: '

output_file = 'cdf_file_size.png'
saveas(figureCDF, output_file );



















