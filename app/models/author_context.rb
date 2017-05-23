# Provides a template context for Authors
class AuthorContext < TemplateContext
  whitelist :first_name, :last_name, :author_initial,
            :affiliation, :email
end
