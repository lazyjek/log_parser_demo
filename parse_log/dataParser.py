#!/usr/bin/env python
#-*- coding:gbk -*-

import pdb
from UserDict import UserDict
import sys

class data_parser_t(UserDict):
    ''' schema '''
    key_idx = {
        'index':1,
        'show':2, 
        'click':3, 
        'charge':4, 
        'query':5, 
        'bidword':6, 
        'time':7, 
        'q':8, 
        'age':9, 
        'gender':10, 
        'city':11,
        'catagory':12,
    }
    alias = {
    }
    data = {}

    def __init__(self, line = None, safemode = True):
        UserDict.__init__(self)
        self.refresh(line, safemode)

    def refresh(self, line = None, safemode = False):
        try:
            self.cols = []
            self.data = {}
            if line:
                if safemode:
                    de_line = unicode(line, 'gbk')
                    dcols = de_line.split('\t')
                    _cols = [c.encode('gbk') for c in dcols]
                else:
                    _cols = line.split('\t')
                self.cols.extend(_cols)
            return 0
        except Exception:
            return -1

    def __setitem__(self, key, item):
        if key in self.alias:
            key = self.alias[key]
        self.data[key] = item
        return

    def __len__(self):
        return len(self.cols)

    def __getitem__(self, key):

        if key in self.alias:
            key = self.alias[key]

        if key in self.data:
            return self.data[key]
        
        if isinstance(key, int):
            keyidx = key
        else:
            if key not in self.key_idx:
                print key
                raise KeyError
            keyidx = self.key_idx[key]
        
        keyidx = keyidx - 1

        if keyidx >= len(self.cols):
            raise KeyError
        return self.cols[keyidx]

    def __getattr__(self, key):
        return self[key]

    def dump(self):
        ret = ''
        for i in self.cols:
            ret += i + ','
        print 'cols_len=%s, cols=[%s], data=%s'%(len(self.cols), ret, self.data )
