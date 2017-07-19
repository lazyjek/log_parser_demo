#!/user/bin/env python
#-*- coding:gbk -*-
import sys
from dataParser import data_parser_t
p = data_parser_t()

for line in sys.stdin:
    if not p.refresh(line.strip()):
        print '\t'.join([p.show,p.click,p.price])
