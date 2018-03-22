# Serializer for authors that aren't individuals; they live in the
# same list as normal authors
class GroupAuthorSerializer < AuthzSerializer
  include CardContentShim

  attributes :initial,
             :contact_first_name,
             :contact_middle_name,
             :contact_last_name,
             :contact_email,
             :co_author_state,
             :co_author_state_modified_at,
             :co_author_state_modified_by_id,
             :position,
             :paper_id,
             :name,
             :id

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
