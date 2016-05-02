clc

%% fitting de file size



%% todo
%{
cargar array,

[mult, hit] = importfileMultitypeHit('filename.csv')

llamar a la funcion de fitting
[md, d] = allfitdist(hit)

exportar en json los parametros de fitting

chemical	445983
message     95169
audio       2370868
image       26024888
text        16695481
video       248956
application	25722320
%}
multitype = {'audio', 'application','chemical','image','message', 'text','video'};
%multitype = {'message'};
file_prefix='cdf_file_size_';
file_extension='.csv';
for mult = multitype
 
 disp(mult);
 file_name = strcat(file_prefix,mult,file_extension);
 filename= file_name{1};
 [min, max] = importfile(filename);
 [D PD] = allfitdist(max);
 % D of fitted distributions and parameters
 % PD representing the fitted distributions
 
 outfile = strcat(mult,'_file_size','.mat');
 outfilemin = strcat(mult,'_file_size_min','.mat');
 
 filename = outfile{1};
 filenamemin = outfilemin{1};
 % save(filename, 'max', 'D', 'PD');
 save(filename, 'D', 'PD'); % fitxers mes petits...
 
 disp ('Saved')
end





%


%


