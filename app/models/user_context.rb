class UserContext < TemplateContext
  whitelist :first_name, :last_name, :email, :full_name

  def title
    affiliations.first.try(:title)
  end

  def name_or_email
    object.try(:full_name) || object.try(:email)
  end

  private

  def affiliations
    object.affiliations
  end
end
