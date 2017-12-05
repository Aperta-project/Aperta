module Typesetter
  # Serializes a Funder for the typesetter.
  # Expects a Funder as its object to serialize.
  # Funder is no longer an ActiveRecord model, but it supports serializtion via the normal mechanism
  class FunderSerializer < ActiveModel::Serializer
    attributes :name, :grant_number, :website, :additional_comments, :influence, :influence_description, :funding_statement
  end
end
