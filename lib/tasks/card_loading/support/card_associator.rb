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

require_relative "./card_factory"

# This class is responsible associating any ActiveRecord class (that
# has the answerable mixin) with a CardVersion.
#
# It is assumed this will be leveraged to associate any existing record
# (such as Tasks, GroupAuthors, etc.) with a Card.
#
class CardAssociator
  attr_accessor :model_klass, :answerables

  def initialize(model_klass)
    @model_klass = model_klass
    raise "#{model_klass} is not an answerable model" unless model_klass.try(:answerable?)
  end

  def process
    card = Card.find_by_class_name!(model_klass)
    card.transaction do
      answerables.update_all(card_version_id: card.latest_published_card_version.id)
      CardVersion.where(card: card, published_at: nil).update_all(published_at: DateTime.current)
    end
  end

  def assert_all_associated!
    if answerables.reload.any?
      raise "Not all #{model_klass} have an associated CardVersion"
    end
  end

  private

  def answerables
    @answerables ||= model_klass.where(card_version_id: nil)
  end
end
