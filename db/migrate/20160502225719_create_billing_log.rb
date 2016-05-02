# Adds BillingLogs table, used to track billing information for papers
class CreateBillingLog < ActiveRecord::Migration
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
      t.integer    :phone1
      t.integer    :phone2
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
      t.string     :s3_url
      t.timestamps
    end
  end
end
