
close all
clc

%{
USE::
1r load file_size.mat > double click
2n % change the mime=''    import each .dat file
3r % run plot
4r % rename the legend x,y,z..., REAL
legend ... REAL
%} 
figureCDF = figure;
% Create axes
axesCDF = axes('Parent',figureCDF);
hold on
mime = 'video'
title(mime)
for i = [1:1:2]
    filename = strcat('test_',mime,int2str(i),'.dat')
    sizes = importfile(filename);
    ecdf(sizes);
    disp(i)
end
ecdf(max)

set(axesCDF,'XMinorTick','on','XScale','log','YMinorTick','on','YScale','linear');
legend(axesCDF,'show');

%