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

class CreateBillingLogs < ActiveRecord::Migration
  def change
    create_table :billing_logs do |t|
      t.string     :guid, index: true
      t.integer    :documentid, index: true, null: false
      t.string     :title
      t.string     :firstname
      t.string     :middlename
      t.string     :lastname
      t.string     :institute
      t.string     :department
      t.string     :address1
      t.string     :address2
      t.string     :address3
      t.string     :city
      t.string     :state
      t.integer    :zip
      t.string     :country
      t.string     :phone1
      t.string     :phone2
      t.integer    :fax
      t.string     :email
      t.references :journal, index: true, null: false
      t.string     :pubdnumber
      t.string     :doi
      t.string     :dtitle
      t.string     :fundRef
      t.string     :collectionID
      t.string     :collection
      t.date       :original_submission_start_date
      t.string     :direct_bill_response
      t.date       :date_first_entered_production
      t.string     :gpi_response
      t.date       :final_dispo_accept
      t.string     :category
      t.date       :import_date
      t.string     :csv_file
      t.timestamps
    end
  end
end
