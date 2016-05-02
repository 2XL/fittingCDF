
from workload_generator.utils import translate_matlab_fitting_to_scipy

size_distribution_file = "filesize_{}".format('video')
output_distribution_file = "{}_{}".format(size_distribution_file, 'scipy')
output_stream = file(output_distribution_file, "w")
for fs_line in open(size_distribution_file, "r"):
    mimetype, fitting, parameters = fs_line.split(",")
    fitting, parameters = translate_matlab_fitting_to_scipy(fitting, parameters)
    print >> output_stream, "file size distribution" + "," + mimetype + "," + fitting + "," + parameters


