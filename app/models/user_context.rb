class UserContext < TemplateContext
  whitelist :first_name, :last_name, :email, :full_name

  def title
    affiliations.first.try(:title)
  end

  private

  def affiliations
    @object.affiliations
  end
end
