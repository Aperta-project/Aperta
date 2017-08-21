# For the jsonification of paper tracker queries, used as "Saved
# Searches" on the paper tracker page.
class PaperTrackerQuerySerializer < ActiveModel::Serializer
  attributes :title, :query, :order_by, :order_dir, :id
end
