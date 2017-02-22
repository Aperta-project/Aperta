#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import os
from random import shuffle
import re
import subprocess

modulelist = []
err_list = []

dir_ = '/'.join([os.getcwd(), 'frontend'])
for file_ in os.listdir(dir_):
  if re.search('^test_.*.py', file_):
    module_name = file.split('.')[0]
    modulelist.append('.'.join(['frontend', module_name]))
shuffle(modulelist)
print(modulelist)
for module in modulelist:
  cmd = 'python -m {0}'.format(module)
  try:
    status = subprocess.check_call(cmd.split(), stderr=subprocess.STDOUT)
  except:
    err_list.append(status)
    continue

print(err_list)

