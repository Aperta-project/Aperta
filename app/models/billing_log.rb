# This table stores the information that can be exported to csv for processing
class BillingLog < ActiveRecord::Base
  belongs_to :paper, class_name: 'Paper', foreign_key: 'documentid'
  belongs_to :journal
  validates :paper, :journal, presence: true

  def populate_attributes
    return self if update_attributes(billing_json)
  end

  def to_csv
    csv = CSV.new ""
    csv << billing_json.keys
    csv << billing_json.values
    csv
  end

  def save_and_send_to_s3
    s3 = CloudServices::S3Service.new.connection

    directory = s3.directories.new(
      key:    Rails.application.config.s3_bucket,
      public: false
    )

    s3_file = directory.files.create(
      key:    "billing/#{filename}",
      body:   to_csv.string,
      public: true
    )
    # returns true if !errors
    s3_file.save && save && update_column(:s3_url, s3_file.url(1.week.from_now))
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
