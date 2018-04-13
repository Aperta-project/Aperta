# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
