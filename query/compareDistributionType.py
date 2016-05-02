

from scipy.stats import stats
import numpy
import math
from scipy.stats import lognorm,genpareto
import json
from workload_generator.utils import get_random_value_from_fitting

# leer del backup sample y representar la grafica.

filename = "filetype_scipy"


index_line = 0
last_op = ""
curr_op = ""
for fs_line in open(filename, 'r'):
 print fs_line
 items = fs_line.split(',')
 line = items
 index_line+=1
 #print line
 title = line[0]
 oper = line[1]
 dist = line[2]
 args = ','.join(line[3:])
 print args
 ob = eval(args)

'''
 outfile = "test_{}{}.dat".format(mime, index_line)
 test = open(outfile, "w")
 print outfile
 for i in range(2000):
  value = get_random_value_from_fitting(dist,ob)
  print >> test, value
 test.close()
'''

"""
 test = open("test.dat", "w") # generar un archio dat
 for i in range(1000):
  value = get_random_value_from_fitting('genpareto',{'shape':3.776394061,'scale':67176.96527,'threshold':-2.220446049e-15})
  print >> test, value
  # print stats.genpareto(2.9948, scale=2.4671, loc=0.0250).rvs()
  #c=[0.7180, 0.9328, 1.2021]
  #print stats.fisk.rvs(0.5201, 0.4190)
 test.close()
"""





# plot fs_line => file size distribution
'''
v = numpy.random.gumbel(loc=1.20212649309532, scale=0.932804666751013, size=10000)

fitting = stats.genextreme(0.718044067607244, loc=1.20212649309532, scale=0.932804666751013)
fitting = stats.genextreme(-0.698811055279666, scale=942.089026948802, loc=1200.79721156363)

fitting = lognorm(1.38272913665692, scale=math.exp(8.222))
print math.exp(8.222)

fitting = stats.invgauss(5.3146e+06, scale=927.7)
fitting = stats.fatiguelife(20.6005318028672, scale=559477.198848146) #(1.4064e+006, scale=34.0631)
fitting = stats.cauchy(1488.0640353570552, 596.42456464706072)
fitting = stats.fisk(0.4190, shape=0.5201)
mu=9.31524829249769
sigma=41.5219061720147

fitting = lognorm(2.8638, scale=math.exp(7.003))
print math.exp(7.003)

fitting = lognorm(2.0881, scale=math.exp(8.8915))
print math.exp(8.8915)



fitting = stats.genextreme(-0.4408, scale=624.2910, loc=860.450)

print stats.genpareto.fit(rvs)
fitting = genpareto(1.9149, scale=9.5497e-004, threshold=4.7847e-005)
lognorm,{'shape':1.38272913665692,'scale':3721.93882124}
shape=0.853515926272757 scale=1.39900305679406 threshold=-2.22044604925031e-015
fitting = stats.genpareto()


'''




