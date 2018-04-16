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

class RemovePBrFromPaperTitles < ActiveRecord::Migration
  def change
    # This query should be comprehensive. All titles with closing tags also contain
    # a corresponding starting tag.
    Paper.where("title ~ '<br\s*/?>' OR title ~ '<p>' OR title ~ '<div>' OR title ~ '\\n'").each do |p|
      title = p.title
      [/^<p>/, %r{</p>$}].each { |tag| title.gsub!(tag, '') }
      ["\n", '<p>', '</p>', %r{<br\s*/?>}, '<div>', '</div>'].each { |tag| title.gsub!(tag, ' ') }
      # rubocop:disable Rails/SkipsModelValidations:
      p.update_column(:title, title)
    end
  end
end
