class TokenInvitationSerializer < InvitationIndexSerializer
  self.root = :token_invitation

  attributes :token,
             :journal_staff_email

  def journal_staff_email
    object.paper.journal.staff_email
  end
end
