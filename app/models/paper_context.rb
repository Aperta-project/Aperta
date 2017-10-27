class PaperContext < TemplateContext
  include UrlBuilder

  whitelist :title, :abstract, :paper_type
  context :user,   many: :academic_editors
  context :user,   many: :handling_editors
  context :author, many: :authors
  context :author, many: :corresponding_authors
  context :user,   as:   :editor

  def editor
    return if object.handling_editors.empty?
    UserContext.new(object.handling_editors.first)
  end

  def url
    url_for(:paper, id: object.id).sub("api/", "")
  end
end
