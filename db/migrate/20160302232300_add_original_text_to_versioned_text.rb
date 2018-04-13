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

##
# Creates a property to VersionedText to represent the original HTML returned
# by IHAT.
#
# The text property will now have further modifications, namely it will
# have figures inserted near their corresponding captions
class AddOriginalTextToVersionedText < ActiveRecord::Migration
  ##
  # Redundant definition to make this migration work in a future which possibly
  # doesn't include the definition of VersionedText
  class VersionedText < ActiveRecord::Base
    belongs_to :paper
    has_many :figures, through: :paper

    def insert_figures
      imageful_text = FigureInserter.new(original_text, figures).call
      self.text = imageful_text
    end
  end

  def up
    add_column :versioned_texts, :original_text, :text
    VersionedText.reset_column_information
    VersionedText.find_each do |v_text|
      v_text.original_text = v_text.text
      v_text.insert_figures
      v_text.save!
    end
  end

  def down
    VersionedText.reset_column_information
    VersionedText.find_each do |v_text|
      v_text.update!(text: v_text.original_text)
    end
    remove_column :versioned_texts, :original_text
  end
end
