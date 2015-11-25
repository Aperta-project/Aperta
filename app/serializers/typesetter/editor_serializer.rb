module Typesetter
  # Serializes editor for the typesetter.
  # Expects an editor as its object to serialize.
  class EditorSerializer < ActiveModel::Serializer
    attributes :first_name, :last_name, :email, :department, :title,
               :organization

    private

    def affiliation
      object.affiliations.first
    end

    def department
      return unless affiliation
      affiliation.department
    end

    def title
      return unless affiliation
      affiliation.title
    end

    def organization
      return unless affiliation
      affiliation.name
    end
  end
end
