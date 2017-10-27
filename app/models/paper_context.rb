class PaperContext < TemplateContext
  include UrlBuilder

  whitelist :title, :abstract, :paper_type
  context :user,   as: :academic_editors, many: true
  context :user,   as: :handling_editors, many: true
  context :author, as: :authors, many: true
  context :author, as: :corresponding_authors, many: true
  context :user,   as: :editor

  def editor
    return if @object.handling_editors.empty?
    UserContext.new(@object.handling_editors.first)
  end

  def url
    url_for(:paper, id: @object.id).sub("api/", "")
  end
end
