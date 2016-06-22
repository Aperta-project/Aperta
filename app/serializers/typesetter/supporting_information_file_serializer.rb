module Typesetter
  # Serializes a supporting information file for the typesetter.
  # Expects a supporting information file as its object to serialize.
  class SupportingInformationFileSerializer < ActiveModel::Serializer
    attributes :title, :caption, :file_name, :label

    private

    def label
      "#{object.label} #{object.category}"
    end

    def file_name
      object.filename
    end
  end
end
