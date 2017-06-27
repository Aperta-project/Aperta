# Provides a template context for Users
class UserContext < TemplateContext
  whitelist :first_name, :last_name, :email
end
