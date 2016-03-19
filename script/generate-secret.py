#!env python

import random
import string
import file

secret = ''.join([random.SystemRandom().choice("{}{}{}".format(
              string.ascii_letters, string.digits, string.punctuation)) for i in range(50)])
f = file('/run/app/django_secret', 'w')
f.write(secret)
f.close()


