# For the jsonification of paper tracker queries, used as "Saved
# Searches" on the paper tracker page.
class PaperTrackerQuerySerializer < ActiveModel::Serializer
  attributes :title, :query, :id
end
