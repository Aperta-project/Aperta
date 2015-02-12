module Invitable
  extend ActiveSupport::Concern

  included do
    has_many :invitations, inverse_of: :task, foreign_key: :task_id
  end

  def invitation_accepted
    raise NotImplementedError, "the method 'invitation_accepted' must be defined in the subclass"
  end
end
