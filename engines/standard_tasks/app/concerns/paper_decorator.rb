require 'active_support/concern'

module PaperDecorator

  extend ActiveSupport::Concern

  included do
    klass = self.to_s
    Paper.class_eval do
      has_many :figures, dependent: :destroy, class_name: klass
    end
  end

end
