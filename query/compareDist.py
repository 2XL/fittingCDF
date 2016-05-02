'''
Created on 30/6/2015
@author: Raul
'''

from workload_generator import utils
from scipy.stats import stats
from scipy.stats.distributions import lognorm, genpareto
import math

'''
file_types_sizes,\
{
    'Pics': ('norm' ,{'loc':102400, 'scale':10}),               image
    'Code':('norm' ,{'loc':51200,'scale':1}),                   text
    -- 'Docs': ('norm' ,{'loc':51200,'scale':5}),
    'Media': ('norm',{'loc':2048000,'scale':200}),              video
    'Applications': ('norm' ,{'loc':153600,'scale':15}),        application
    -- 'Compressed': ('norm' ,{'loc':122880,'scale':12})
    --                                                          audio
    --                                                          chemical

}

-- tendre que volver a hacer-lo con otro metodo de agrupar los extensiones

# 	multipart	none_multipart	hit

0	audio	    mpeg	        1534823
1	audio	    ogg	            258727
2	audio	    x-wav	        217257
3	audio	    basic	        174314
4	audio	    midi	        64838

5	text	    html	        4455410
6	text	    plain	        2989341
7	text	    x-chdr	        1771552
8	text	    x-csrc	        1459302
9	text	    x-java	        1308872

10	application	x-httpd-php	    4189084
11	application	pdf	            3354467
12	application	javascript	    2937699
13	application	java-vm	        2707452
14	application	xml	            2606380

15	message	    rfc822	        95169

16	image	    jpeg	        12245298
17	image	    png	            9708042
18	image	    gif	            2417041
19	image	    tiff	        537779
20	image	    svg+xml	        491711

21	chemical	x-pdb	        144778
22	chemical	x-cache	        111359
23	chemical	x-cdx	        56122
24	chemical	x-cif	        45760
25	chemical	x-mdl-rdfile	14608

26	video	    mp4	            98280
27	video	    x-msvideo	    43262
28	video	    quicktime	    23977
29	video	    3gpp	        17738
30	video	    x-flv	        16143




'''

if __name__ == '__main__':


    '''

        MATLAB
        1r preparar array dataset
        2n [D, PD]alldistfit(dataset)
        3r save2json('',D)
        4r copy paset json to json file

        IDEA
        5t testFileSizeDistribution.py > json into csv file
        6t translateMatlabToScipy.py > cast matlab object .csv into python scipy fitting parameters
        7t compareDistribution.py > generate #(random values) by fitting parameters >> file_type_XXXX#.dat (# priority)







        '''