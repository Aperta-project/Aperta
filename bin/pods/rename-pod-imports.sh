app_dir="../../client/app/"
test_dir="../../client/tests/"

pod_sed="s@'tahi/(adapter|controller|model|route|resource|serializer|service|transform|view)s/(.*)'@'tahi/pods/\2/\1'@"
component_sed="s@'tahi/components/(.*)'@'tahi/pods/components/\1/component'@"

case "$1" in
    "run")
        for d in $app_dir $test_dir
        do
            echo "********************Changing imports for $d"
            for c in $pod_sed $component_sed
            do
                ag -l -0 "from\s'tahi/" $d | xargs -0 sed -E -i '' -e ${c}
            done
        done
        ;;
    "test")
        for d in $app_dir $test_dir
        do
            echo "********************TEST Changing imports for $d"
            for c in $pod_sed $component_sed
            do
                ag -l -0 "from\s'tahi/" $d | xargs -0 sed -E -n -e ${c}p
            done
        done
        ;;
    *)
        echo "Usage: $0 {run|test}"
        exit 1
esac
