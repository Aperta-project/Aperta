module Invitable
  extend ActiveSupport::Concern

  included do
    has_many :invitations, inverse_of: :task, foreign_key: :task_id
  end

  def invitation_invited(_invitation)
    raise NotImplementedError, "the method 'invitation_invited' must be defined in the subclass"
  end

  def invitation_accepted(_invitation)
    raise NotImplementedError, "the method 'invitation_accepted' must be defined in the subclass"
  end

  def accept_allowed?(_invitation)
    true
  end
end
