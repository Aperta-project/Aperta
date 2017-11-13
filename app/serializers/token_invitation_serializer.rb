class TokenInvitationSerializer < InvitationIndexSerializer
  self.root = :token_invitation

  attributes :id,
             :journal_staff_email

  def id
    object.token
  end

  def journal_staff_email
    object.paper.journal.staff_email
  end
end
