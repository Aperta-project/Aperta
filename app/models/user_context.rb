# Provides a template context for Users
class UserContext < TemplateContext
  whitelist :first_name, :last_name, :email

  def title
    affiliations.first.try(:title)
  end

  private

  def affiliations
    @object.affiliations
  end
end
