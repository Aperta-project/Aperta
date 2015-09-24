class PaperConversionsPolicy < PapersPolicy
  def export?
    can_view_paper? paper
  end

  def status?
    can_view_paper? paper
  end
end
