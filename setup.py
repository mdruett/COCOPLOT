#!/bin/env python
# -*- coding: utf-8 -*-

from setuptools import setup, find_packages

with open("README.md", "r") as fh:
    long_description = fh.read()

setup(
<<<<<<< Updated upstream
   name             = 'COCOPLOT',
   version          = '0.1.0',
=======
   name             = 'COCOPLOTS',
   version          = '1.0.8',
>>>>>>> Stashed changes
   description      = 'COlor COllapsed PLOTting quick-look and context image software',
   long_description=long_description,
   long_description_content_type="text/markdown",
   author           = 'A.G.M. Pietrow, G.J.M. Vissers, C. Robustini, M.K. Druett',
   author_email     = 'alex.pietrow@astro.su.se',
   classifiers      = [
       # How mature is this project? Common values are
       #   3 - Alpha
       #   4 - Beta
       #   5 - Production/Stable
       "Development Status :: 3 - Alpha",
       "Intended Audience :: Developers",
       "Topic :: Software Development :: Build Tools",
       "License :: OSI Approved :: BSD License",
       "Programming Language :: Python :: 3",
       "Programming Language :: Python :: 3.7",
       "Programming Language :: Python :: 3.8",
       "Programming Language :: Python :: 3.9",
       "Programming Language :: Python :: 3.10",
       "Programming Language :: Python :: 3 :: Only",
       "Operating System :: OS Independent",
   ],
   url              = 'https://github.com/mdruett/COCOPLOT/tree/master/Python',
   package_dir      = {'': 'Python'},
   packages         = find_packages(where='Python', include=['cocopy']),
   python_requires  = '>=3.7, <4',
   install_requires = ['numpy', 'astropy', 'matplotlib', 'Pillow']
)
