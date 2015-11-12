module Typesetter
  # Serializes editor for the typesetter.
  # Expects an editor as its object to serialize.
  class EditorSerializer < ActiveModel::Serializer
    attributes :first_name, :last_name, :email, :department, :title

    private

    def affiliation
      object.affiliations.first
    end

    def department
      affiliation.department
    end

    def title
      affiliation.title
    end
  end
end
