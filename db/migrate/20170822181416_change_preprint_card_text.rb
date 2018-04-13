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

class ChangePreprintCardText < ActiveRecord::Migration
  OLD_TEXT = "Establish priority: take credit for your research and discoveries, by posting a copy of your uncorrected proof online. If you do <b>NOT</b> consent to having an early version of your paper posted online, uncheck the box below.".freeze
  NEW_TEXT = "Establish priority: take credit for your research and discoveries, by posting a copy of your uncorrected proof online. If you do <b>NOT</b> consent to having an early version of your paper posted online, indicate your choice below.".freeze

  # Just to be extra safe, scope content edits to the existing Preprint Posting card
  def custom_preprint_content
    CardContent.joins(:card_version, :card).where(cards: { name: "Preprint Posting" })
  end

  def swap_text(previous_text, new_text)
    custom_preprint_content.where(text: previous_text).find_each do |content|
      content.update!(text: new_text)
    end
    raise "Update failed, previous text still exists" if custom_preprint_content.where(text: previous_text).exists?
  end

  def up
    swap_text OLD_TEXT, NEW_TEXT
  end

  def down
    swap_text NEW_TEXT, OLD_TEXT
  end
end
