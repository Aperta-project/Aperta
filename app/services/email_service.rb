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

# This service handles various email validation and
# normalizationtasks throughout our app
class EmailService
  AT_SYMBOL = /.+@.+/
  ANGLE_ADDR = /
                (?:.+<)     # name and open angle bracket
                ([^>]+)     # the actual email address (addr-spec)
                (?:>)       # closing bracket
               /x
  def initialize(email:)
    @email = email
  end

  # This normalizes emails to addr-spec
  #
  # we currently receive emails that take the form of an
  #   * addr-spec (what we want)
  #   * angle-addr = [CFWS] "<" addr-spec ">" [CFWS] / obs-angle-addr
  # this setter will normalize angle-addr to addr-spec
  # https://tools.ietf.org/html/rfc2822 for more info
  def normalized
    @email = ANGLE_ADDR =~ @email ? Regexp.last_match(1) : @email
    @email.strip
  end

  def valid_email_or_nil
    @email = AT_SYMBOL =~ @email ? Regexp.last_match.to_s : nil
  end
end
