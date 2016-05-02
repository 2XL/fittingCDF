

from workload_generator.utils import translate_matlab_fitting_to_scipy
from scipy.stats import genpareto
import math
import json
import numpy
from pylab import *
from matplotlib import *


from fileGenerator import FileGenerator
print 'hello'

file_generator = FileGenerator()





from pprint import pprint

# file type =>
# multitype = ['audio']  # , 'application', 'chemical', 'image', 'message', 'text', 'video']

request = ['get', 'put', 'make', 'unlink', 'move']
fitting = dict()
index = 0
for req in request:
    with open('type/{}_file_type_fit.json'.format(req)) as data_file:
        data = json.load(data_file)
        for d in data:
            dist = d['DistName']
            # print mult, dist
            # print data[DistName]
            params = d['Params']
            paramNames = d['ParamNames']
            idx = 0
            parameters = ""
            for item in paramNames:
                if idx > 0:
                    parameters += " "
                try:
                    parameters += str(item)+"="+str(params[idx])
                except TypeError:
                    parameters += str(item)+"="+str(params)

                idx += 1
            # print parameters
            line = "{},{},{} ".format(req, dist, parameters)
            print line
            index += 1
            fitting["{}{}".format(req, index)] = line
            # generalized extreme value,k=1.87110387302981 sigma=0.38096890778117 mu=0.199634595057584
            # generalized pareto,k=5.59532304512292 sigma=0.430467922602313 theta=0.00499999988823778
            # print params[1]
            # fitting = # genpareto(params[0], scale=params[1], threshold=params[2])
            # fitting = translate_matlab_fitting_to_scipy(dist, kv_params)
            #print fitting
print "end of file"


print fitting
# generalized pareto continuous random variable
# http://docs.scipy.org/doc/scipy-0.15.1/reference/generated/scipy.stats.genpareto.html









