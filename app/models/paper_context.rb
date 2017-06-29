# Provides a template context for Papers
class PaperContext < TemplateContext
  include UrlBuilder

  whitelist :title, :abstract, :paper_type

  def academic_editors
    @object.academic_editors.map { |ae| UserContext.new(ae) }
  end

  def authors
    @object.authors.map { |a| AuthorContext.new(a) }
  end

  def corresponding_authors
    @object.corresponding_authors.map { |ca| AuthorContext.new(ca) }
  end

  def editor
    return if @object.academic_editors.empty?
    UserContext.new(@object.academic_editors.first)
  end

  def url
    url_for(:paper, id: @object.id).sub("api/", "")
  end
end
