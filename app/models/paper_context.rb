# Provides a template context for Papers
class PaperContext < TemplateContext
  include UrlBuilder

  whitelist :title, :academic_editors

  def corresponding_authors
    @object.corresponding_authors.map { |ca| AuthorContext.new(ca) }
  end

  def editor
    UserContext.new(academic_editors.first) unless academic_editors.empty?
  end

  def url
    url_for(:paper, id: @object.id).sub("api/", "")
  end
end
