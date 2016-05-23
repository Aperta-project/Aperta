# This table stores the information that can be exported to csv for processing
require 'csv'

class BillingLog < ActiveRecord::Base
  belongs_to :paper, class_name: 'Paper', foreign_key: 'documentid'
  belongs_to :journal
  validates :paper, :journal, presence: true

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
