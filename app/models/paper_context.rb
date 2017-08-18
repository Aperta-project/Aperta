# Provides a template context for Papers
class PaperContext < TemplateContext
  include UrlBuilder

  def self.merge_fields
    [
      { name: :title },
      { name: :abstract },
      { name: :paper_type },
      { name: :url },
      { name: :editor, context: UserContext },
      { name: :academic_editors, context: UserContext, many: true },
      { name: :handling_editors, context: UserContext, many: true },
      { name: :authors, context: AuthorContext, many: true },
      { name: :corresponding_authors, context: UserContext, many: true }
    ]
  end

  whitelist :title, :abstract, :paper_type

  def academic_editors
    @object.academic_editors.map { |ae| UserContext.new(ae) }
  end

  def handling_editors
    @object.handling_editors.map { |he| UserContext.new(he) }
  end

  def authors
    @object.authors.map { |a| AuthorContext.new(a) }
  end

  def corresponding_authors
    @object.corresponding_authors.map { |ca| AuthorContext.new(ca) }
  end

  def editor
    return if @object.handling_editors.empty?
    UserContext.new(@object.handling_editors.first)
  end

  def url
    url_for(:paper, id: @object.id).sub("api/", "")
  end
end
