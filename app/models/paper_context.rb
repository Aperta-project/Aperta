class PaperContext < TemplateContext
  include UrlBuilder

  whitelist :title, :abstract, :paper_type
  context :academic_editors,      type: :user,   many: true
  context :handling_editors,      type: :user,   many: true
  context :authors,               type: :author, many: true
  context :corresponding_authors, type: :author, many: true
  context :editor,                type: :user

  def editor
    return if object.handling_editors.empty?
    UserContext.new(object.handling_editors.first)
  end

  def url
    url_for(:paper, id: object.id).sub("api/", "")
  end
end
