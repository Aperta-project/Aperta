class InvitationIndexSerializer < ActiveModel::Serializer
  self.root = :invitation

  attributes :id,
             :state,
             :title,
             :abstract,
             :email,
             :invitee_role,
             :created_at,
             :updated_at,
             :invitee_id,
             :information,
             :paper_type,
             :paper_short_doi,
             :journal_name,
             :journal_staff_email

  has_one :task, embed: :id, polymorphic: true

  def title
    object.paper.title
  end

  def abstract
    object.paper.abstract
  end

  def paper_type
    object.paper.paper_type
  end

  def paper_short_doi
    object.paper.short_doi
  end

  def journal_name
    object.paper.journal.name
  end

  def journal_staff_email
    object.paper.journal.staff_email
  end
end
