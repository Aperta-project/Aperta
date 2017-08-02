# This is used to serialize letter templates which are used to draft emails
# 'name' is used by select-2 dropdowns later
class LetterTemplateSerializer < ActiveModel::Serializer
  attributes :id, :name, :category, :to, :subject, :body, :journal_id
end
