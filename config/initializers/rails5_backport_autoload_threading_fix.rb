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

# Backported fix from Rails 5 to remove autoload threading issue.
#
# Related to issue: https://github.com/rails/rails/issues/13142
# Fix pulled from: https://github.com/rails/rails/commit/a71350cae0082193ad8c66d65ab62e8bb0b7853b
#
# This will disable autoloading when eager_loading=true and cache_classes=true
# (typical in test and production environments) in the Rails.application.config.
# This causes constants that are not loaded to fail.
#
Rails.application.config.after_initialize do
  config = Rails.application.config
  if config.eager_load && config.cache_classes
    ActiveSupport::Dependencies.unhook!
  end
end
