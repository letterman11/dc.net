old_path=
new_path=
old_path_2=
new_path_2=

find ~/pyUp/py3x/marksPWAPage -iname "*.py" -or -iname "*.js"  -or -iname "*.html" -type f | xargs sed -i 's#pyWebMarks#ex2WebMarks#g'
find ~/pyUp/py3x/marksPWAPage  -iname "*.html"  -type f | xargs sed -i 's#/css/#/ex2/css/#g'
find ~/pyUp/py3x/marksPWAPage  -iname "*.html"  -type f | xargs sed -i 's#/js/#/ex2/js/#g'
