class VoucherInvitationsSerializer < InvitationSerializer
  attributes :journal_logo_url, :journal_name, :journal_staff_email, :paper_title, :paper_abstract, :token

  def journal_logo_url
    task.paper.journal.logo_url
  end

  def journal_name
    task.paper.journal.name
  end

  def journal_staff_email
    task.paper.journal.staff_email
  end

  def paper_title
    task.paper.title
  end

  def paper_abstract
    task.paper.abstract
  end
end
