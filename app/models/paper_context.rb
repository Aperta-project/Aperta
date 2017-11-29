class PaperContext < TemplateContext
  include UrlBuilder

  whitelist :title, :abstract, :paper_type
  subcontexts :academic_editors,      type: :user
  subcontexts :handling_editors,      type: :user
  subcontexts :authors,               type: :author
  subcontexts :corresponding_authors, type: :author
  subcontext  :editor,                type: :user
  subcontext  :creator, type: :user

  def editor
    return if object.handling_editors.empty?
    UserContext.new(object.handling_editors.first)
  end

  def url
    url_for(:paper, id: object.id).sub("api/", "")
  end
end
