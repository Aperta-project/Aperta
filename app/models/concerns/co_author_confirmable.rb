module CoAuthorConfirmable
  extend ActiveSupport::Concern

  included do
    validates :co_author_state, inclusion: { in: %w(confirmed refuted), message: "must be confirmed or refuted" }, allow_nil: true
  end

  def co_author_confirmed?
    co_author_state == 'confirmed'
  end

  def co_author_confirmed!
    update_attributes!(
      co_author_state: 'confirmed',
      co_author_state_modified_at: Time.now.utc
    )
  end

  def co_author_refuted!
    update_attributes!(
      co_author_state: 'refuted',
      co_author_state_modified_at: Time.now.utc
    )
  end
end
