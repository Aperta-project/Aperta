# Provides a template context for Users
class UserContext < TemplateContext
  def self.merge_fields
    [{ name: :first_name },
     { name: :last_name },
     { name: :email },
     { name: :title }]
  end

  whitelist :first_name, :last_name, :email

  def title
    affiliations.first.try(:title)
  end

  private

  def affiliations
    @object.affiliations
  end
end
