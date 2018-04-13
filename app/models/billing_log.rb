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

# This table stores the information that can be exported to csv for processing
require 'csv'

class BillingLog < ActiveRecord::Base
  include ViewableModel
  belongs_to :paper, class_name: 'Paper', foreign_key: 'documentid'
  validates :paper, presence: true

  mount_uploader :csv_file, BillingLogUploader

  def populate_attributes
    return self if update_attributes(billing_json)
  end

  def create_csv
    csv = CSV.new ""
    csv << billing_json.keys
    csv << billing_json.values
    csv
  end

  def save_and_send_to_s3!
    tmp_file = Tempfile.new('')
    tmp_file.write(create_csv.string)
    update!(csv_file: tmp_file)
  end

  def filename
    @filename ||=
    "billing-log(#{id})-paper(#{paper.id})-#{current_time}.csv"
  end

  private

  def current_time
    Time.current.strftime("%Y-%m-%d")
  end

  def billing_json
    @billing_json ||=
      JSON.parse(
        Typesetter::BillingLogSerializer.new(paper).to_json)['billing_log']
  end
end
