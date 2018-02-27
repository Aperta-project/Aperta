# This is used to serialize letter templates which are used to draft emails
# 'name' is used by select-2 dropdowns later
class LetterTemplateSerializer < AuthzSerializer
  attributes :id, :name, :category, :to, :subject, :body, :journal_id, :merge_fields, :scenario, :cc, :bcc

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
