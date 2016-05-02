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
%multitype = {'image', 'text','application','audio'};
%multitype = {'message', 'video','chemical',};

profile = {'backup', 'sync', 'download'};
request = {'get','make','move','put','unlink'};
file_prefix='cdf_file_type_request_';
file_extension='.csv';
%for prof = profile    
for req = request
 disp(req);
 file_name = strcat(file_prefix,req,file_extension);
 filename= file_name{1};
 [multitypeSorted,hitSorted] = importfileMultitypeHit(filename);
 [D PD] = allfitdist(hitSorted);
 % D of fitted distributions and parameters
 % PD representing the fitted distributions
  
 % outfilemin = strcat(prof,'_file_type_fit','.mat');
 outfilemin = strcat(req,'_file_type_fit','.mat');
  
 filenamemin = outfilemin{1}; 
 save(filenamemin, 'D', 'PD', 'multitypeSorted', 'hitSorted' ); % fitxers mes petits...
 disp ('Saved')
end





%


%


