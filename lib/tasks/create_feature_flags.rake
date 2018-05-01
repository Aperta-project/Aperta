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

task 'create_feature_flags': :environment do
  # To create a new feature flag, simply add it to the list and run `rake create_feature_flags`. By
  # convention, feature flags are in ALL_CAPS_SNAKE_CASE.
  #
  # To eliminate a flag, just remove it from this list. Beware,
  # though! You must remove ALL REFERENCES to the flag BEFORE you
  # remove it from this list!
  #
  # See the FeatureFlag model for more usage information.
  #
  FeatureFlag.contain_exactly! [
    "CARD_CONFIGURATION",
    "KEEP_APEX_HTML",
    "PREPRINT",
    "JIRA_INTEGRATION",
    "DISABLE_SUBMISSIONS"
  ]
end
