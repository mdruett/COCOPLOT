cd Python/docs/
make clean
rm -rf source/cocopy*.rst 
sphinx-apidoc -o source ../cocopy
make html
touch build/html/.nojekyll
