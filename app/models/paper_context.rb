class PaperContext < TemplateContext
  include UrlBuilder

  whitelist :title, :abstract, :paper_type
  contexts :academic_editors,      type: :user
  contexts :handling_editors,      type: :user
  contexts :authors,               type: :author
  contexts :corresponding_authors, type: :author
  context  :editor,                type: :user

  def editor
    return if object.handling_editors.empty?
    UserContext.new(object.handling_editors.first)
  end

  def url
    url_for(:paper, id: object.id).sub("api/", "")
  end
end
