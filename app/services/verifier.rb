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

class MessageExpired < StandardError; end
class InvalidPayload < StandardError; end

class Verifier
  attr_accessor :data

  EXPIRATION_DATE_KEY = "_verifier_expiration_date"

  def initialize(data={})
    @data = data.dup
  end

  def encrypt(expiration_date:nil)
    add_expiration_date(expiration_date) if expiration_date.present?
    verifier.generate(data)
  end

  def decrypt
    decrypted.tap do
      validate_expiration! if expiration_date
    end
  end

  def expiration_date
    @expiration_date ||= decrypted.delete(EXPIRATION_DATE_KEY)
  end

  private

  def verifier
    @verifier ||= Rails.application.message_verifier(:ihat_verifier)
  end

  def decrypted
    @decrypted ||= verifier.verify(data)
  end

  def expired?
    expiration_date && Time.now > expiration_date
  end

  def add_expiration_date(expiration_date)
    data[EXPIRATION_DATE_KEY] = expiration_date
  rescue IndexError
    raise InvalidPayload.new("Data to be encrypted with expiration date must be a hash")
  end

  def validate_expiration!
    raise MessageExpired if expired?
  end
end
