# Authors and group authors are listed by the manuscript's creator --
# but what if they're attempting to gain credibility by adding
# important coauthors who were not actually involved in the work? This
# module extends author-like models to track when and how authors
# confirm (or refute) their contributions to a manuscript.
module CoAuthorConfirmable
  extend ActiveSupport::Concern

  included do
    validates :co_author_state,
      inclusion: { in: %w[confirmed unconfirmed refuted],
                   message: "must be confirmed, unconfirmed or refuted" },
      allow_nil: true
  end

  def co_author_confirmed?
    co_author_state == 'confirmed'
  end

  def co_author_refuted?
    co_author_state == 'refuted'
  end

  def co_author_confirmed!
    # not every author has an associated user, so this is a crappy workaround
    update_coauthor_state('confirmed', nil)
  end

  def update_coauthor_state(status, user_id)
    update_attributes!(
      co_author_state: status,
      co_author_state_modified_by_id: user_id,
      co_author_state_modified_at: Time.now.utc
    )
  end
end
