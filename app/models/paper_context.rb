class PaperContext < TemplateContext
  include UrlBuilder

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

  def creator
    UserContext.new(@object.creator)
  end

  def preprint_opted_in
    FeatureFlag[:PREPRINT] && !@object.preprint_opt_out?
  end

  def preprint_opted_out
    FeatureFlag[:PREPRINT] && @object.preprint_opt_out?
  end
end
