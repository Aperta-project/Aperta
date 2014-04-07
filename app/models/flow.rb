class Flow < ActiveRecord::Base
  attr_accessor :papers
  belongs_to :user_setting
end

