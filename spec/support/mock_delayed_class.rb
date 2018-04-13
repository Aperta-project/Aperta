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


# Sidekiq has "Delayed Extensions" which will background queue a single
# method call without creating a separate worker class. This is usually
# invoked as `MyClass.delay.some_class_method`. However, the call to
# `delay` actually returns a proxy object, making Rspec expectations a
# bit difficult to rely on.
#
# You can read more at github.com/mperham/sidekiq/wiki/Delayed-Extensions.
#
# This support method will return a double to allow normal mocking
# expectations to be performed without Sidekiq's extensions getting in
# the way.
#
def mock_delayed_class(delayed_class)
  mocked_delayed_class = double(:mocked_delayed_class)
  allow(delayed_class).to receive(:delay).and_return(mocked_delayed_class)
  mocked_delayed_class
end
