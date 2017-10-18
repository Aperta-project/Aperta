class AuthorContext < TemplateContext
  whitelist :first_name, :last_name, :email, :author_initial, :affiliation
end
