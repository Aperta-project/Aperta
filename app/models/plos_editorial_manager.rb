class PlosEditorialManager < ActiveRecord::Base
  establish_connection "plos_editorial_manager_#{Rails.env}".to_sym
end
