class VoucherInvitationsSerializer < InvitationSerializer
  attributes :information, :journal_logo_url, :paper_title, :paper_abstract

  def journal_logo_url
    task.paper.journal.logo_url
  end

  def paper_title
    task.paper.title
  end

  def paper_abstract
    task.paper.abstract
  end
end
