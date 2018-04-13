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

class StripAuthorWhitespace < ActiveRecord::Migration
  # This uses the same underlying method that runs in the author's
  # before_validation callback. That method will remove
  # leading and trailing whitespace from email, first_name, last_name, and
  # middle_initial.  We can't run the normal `save` method with validations because
  # some existing authors have other data problems outside the scope of this migration that
  # will fail validation
  # rubocop:disable Rails/Output
  def up
    puts "Before migration: #{email_count} authors with whitespace in their emails out of #{Author.count} total"
    Author.find_each do |author|
      author.strip_whitespace
      author.save(validate: false)
    end

    new_count = email_count
    puts "After migration: #{new_count}"
    raise ActiveRecord::Rollback, "The migration left #{new_count} emails unstripped" if new_count != 0
    puts "Whitespace removed"
  end
  # rubocop:enable Rails/Output

  def email_count
    Author.where('email like ? OR authors.email like ?', ' %', '% ').count
  end
end
