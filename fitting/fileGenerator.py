
from workload_generator.utils import get_random_value_from_fitting

class FileGenerator(object):

    def __init__(self):
        self.file_size_fitting = dict()
        self.file_size_max = 1000
        self.file_size_min = 1
    '''Get the size based on type statistical fittings'''
    # the type can be => [audio application chemical image message text video]
    def get_file_size(self, mime):
        (function, kv_params) = self.file_size_fitting[mime]
        file_size = get_random_value_from_fitting(function, kv_params)
        '''Avoid extremely large or small waiting times due to statistical functions'''
        if file_size > self.file_size_max:
            file_size = self.file_size_max
        if file_size < self.file_size_min:
            file_size = self.file_size_min
        return file_size

    def add_interarrival_transition_fitting(self, size, function, params):
        #If there is no entry for this transition, create one
        if size not in self.file_size_fitting:
            self.file_size_fitting[size] = dict()
        self.file_size_fitting[size] = (function, params)

    '''Get the file_size information from stereotype recipe'''
    def initialize_from_recipe(self, stereotype_recipe):
        for l in open(stereotype_recipe, "r"):
            model_attribute = l.split(',')[0]
            if 'chain' in model_attribute:
                size, transitions, fitting = l[:-1].split(',')[1:5]
                kw_params = eval(l[l.index('{'):])
                self.add_interarrival_transition_fitting(size, fitting, kw_params)
