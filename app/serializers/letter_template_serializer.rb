# This is used to serialize letter templates which are used to draft emails
# 'text' is used by select-2 dropdowns later
class LetterTemplateSerializer < ActiveModel::Serializer
  attributes :id, :text, :template_decision, :to, :letter, :journal_id
end
