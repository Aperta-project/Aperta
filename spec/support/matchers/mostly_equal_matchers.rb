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

RSpec::Matchers.define :mostly_eq do |expected|
  diffable

  match do |actual|
    actual = actual.respond_to?(:to_a) ? actual.to_a : [actual]
    actual.map! { |member| member.attributes.except(*@ignore) }
    expected = expected.respond_to?(:to_a) ? expected.to_a : [expected]
    expected.map! { |member| member.attributes.except(*@ignore) }

    # set instance variables for nice-looking diff
    @actual = actual
    @expected_as_array = [expected]

    values_match? expected, actual
  end

  chain :except do |*ignore|
    @ignore = ignore
  end
end
