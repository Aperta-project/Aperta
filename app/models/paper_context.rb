# Provides a template context for Papers
class PaperContext < TemplateContext
  whitelist :title

  def corresponding_author
    AuthorContext.new(@object.corresponding_authors.first)
  end
end
