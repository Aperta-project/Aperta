class NestedQuestionAnswer < ActiveRecord::Base
  belongs_to :nested_question
  belongs_to :owner, polymorphic: true
end
