# This table stores the information that can be exported to csv for processing
class BillingLog < ActiveRecord::Base
  belongs_to :paper, class_name: 'Paper', foreign_key: 'documentid'
  belongs_to :journal
end
