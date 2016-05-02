from impala.dbapi import connect



print 'connect to server'
conn = connect(host='ast12.recerca.intranet.urv.es', port=8888,user='lab144', password='lab144')

print 'try to connect'

cur = conn.cursor()

print 'try to login'


# http://blog.cloudera.com/blog/2014/04/a-new-python-client-for-impala/
# pip install -U setuptools