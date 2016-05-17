module Typesetter
  # Serializes a funder for the typesetter.
  # Expects a funder as its object to serialize.
  class FunderSerializer < Typesetter::TaskAnswerSerializer
    attributes :additional_comments, :name, :grant_number, :website, :influence,
               :influence_description
  end
end
