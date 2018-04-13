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

# This class represents a customized Task built with CardContent
class CustomCardTask < Task
  # This sets all custom cards to be snapshottable submission tasks. Another
  # mechanism for handling these class-level attributes on the custom card's
  # latest version instance will be needed as soon as we convert a legacy card
  # that is not both a submission task and snapshottable.
  include MetadataTask
  DEFAULT_TITLE = 'Custom Card'.freeze
  has_many :export_deliveries,
    foreign_key: 'task_id',
    class_name: "TahiStandardTasks::ExportDelivery",
    dependent: :destroy
  # unlike other answerables, a CustomCardTask class does not have
  # a concept of a latest card_version.  This is only determinable
  # from an instance of a CustomCardTask
  def default_card
    # noop
  end

  # Overrides Task
  def self.create_journal_task_type?
    false
  end
end
