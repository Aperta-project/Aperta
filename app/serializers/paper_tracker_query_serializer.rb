# For the jsonification of paper tracker queries, used as "Saved
# Searches" on the paper tracker page.
class PaperTrackerQuerySerializer < AuthzSerializer
  attributes :title, :query, :order_by, :order_dir, :id

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
