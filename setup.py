#!/bin/env python
# -*- coding: utf-8 -*-

from setuptools import setup, find_packages

setup(
   name             = 'COCOPLOT',
   version          = '0.1.0',
   description      = 'COlor COllapsed PLOTting quick-look and context image software',
   author           = 'A. Pietrow',
   author_email     = 'alex.pietrow@astro.su.se',
   classifiers      = [
       # How mature is this project? Common values are
       #   3 - Alpha
       #   4 - Beta
       #   5 - Production/Stable
       "Development Status :: 3 - Alpha",
       "Intended Audience :: Developers",
       "Topic :: Software Development :: Build Tools",
       "License :: OSI Approved :: BSD 3-Clause License",
       "Programming Language :: Python :: 3",
       "Programming Language :: Python :: 3.7",
       "Programming Language :: Python :: 3.8",
       "Programming Language :: Python :: 3.9",
       "Programming Language :: Python :: 3.10",
       "Programming Language :: Python :: 3 :: Only",
   ],
   url              = 'https://github.com/mdruett/COCOPLOT',
   package_dir      = {'': 'Python'},
   packages         = find_packages(where='Python', include=['cocopy']),
   python_requires  = '>=3.7, <4',
   install_requires = ['numpy', 'astropy', 'matplotlib', 'Pillow']
)
