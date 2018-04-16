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

# CardTaskType contains metadata about the type of Task that should
# be instantiated for a given card when a task is created by the TaskFactory.
# Users can assign a CardType to a Card when creating a new Card in the
# admin screen.
class CardTaskType < ActiveRecord::Base
  include ViewableModel
  validates :display_name, presence: true
  validates :task_class, presence: true

  # maps display_name to task_class
  DEFAULT_NAMES = {
    'CustomCardTask' => 'Custom Card',
    'TahiStandardTasks::UploadManuscriptTask' => 'Upload Manuscript'
  }.freeze

  def user_can_view?(_check_user)
    true
  end

  def self.default_attributes(klass)
    { display_name: DEFAULT_NAMES.fetch(klass), task_class: klass }
  end

  def self.find_or_create_default(klass = 'CustomCardTask')
    find_by(task_class: klass) || create!(default_attributes(klass))
  end

  def self.named(name)
    where(display_name: name).first
  end

  def self.custom_card
    where(task_class: 'CustomCardTask').first
  end

  def self.seed_defaults
    [
      default_attributes('CustomCardTask'),
      default_attributes('TahiStandardTasks::UploadManuscriptTask')
    ].each do |hash|
      CardTaskType.find_or_create_by!(hash)
    end
  end
end
