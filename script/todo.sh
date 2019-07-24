filters=(TODO FIXME)

for filter in ${filters[*]}
do
    grep ${filter}: . -r --include=\*.{elm,js} --exclude-dir={node_modules,elm-stuff,assets}
    if [ "$?" -ne 1 ]
    then
        echo "FAILED - found ${filter}: in source files"
        exit 1
    fi
done
