##
# A service class for automatically adding figures at the appropriate locations
# in manuscript texts
class FigureInserter
  def initialize(raw_text, figures, direct_img_links: false)
    @raw_text = raw_text
    @figures = figures
    @html_tree = Nokogiri::HTML::DocumentFragment.parse raw_text
    @direct_img_links = direct_img_links
  end

  def call
    return @raw_text unless @figures.present?
    sorted_figures.each { |figure| insert_figure figure }
    @html_tree.to_html
  end

  private

  def sorted_figures
    @figures.sort_by { |fig| fig.rank || 0 }
  end

  def insert_figure(figure)
    node = find_caption_node figure.rank
    if node
      node.add_previous_sibling node_for_figure(figure)
    else
      @html_tree.add_child node_for_not_found_figure(figure)
    end
  end

  def node_for_figure(figure)
    <<-HTML
      <img class="paper-body-figure"
           data-figure-id="#{figure.id}"
           data-figure-rank="#{figure.rank}"
           src="#{figure_url(figure)}">
    HTML
  end

  def node_for_not_found_figure(figure)
    node_for_figure(figure) + <<-HTML
      <p class="paper-body-figure-caption">#{figure.title}.</p>
    HTML
  end

  def figure_url(figure)
    if @direct_img_links
      figure.proxyable_url(version: :detail)
    else
      figure.detail_src(cache_buster: true)
    end
  end

  ##
  # Finds a caption label node.
  #
  # Caption nodes are <p> tags starting with a sentence labelling the figure
  # number. For example "<p>Fig. 1.</p>" is a caption node. They are also
  # considered to be whatever <p> tag surrounds a node containing that sentence.
  # For instance in "<p><em>Fig. 1.<em></p>" the <p> node will be returned by
  # this function

  def find_caption_node(figure_id)
    return unless figure_id.is_a? Numeric
    possible_matches = [
      "Figure #{figure_id}.",
      "Figure #{figure_id}:",
      "Figure #{figure_id}-", # hyphen
      "Figure #{figure_id}—", # n-dash
      "Figure #{figure_id}–", # m-dash
      "Fig #{figure_id}.",
      "Fig. #{figure_id}."
    ]
    selectors = possible_matches.flat_map do |match_test|
      ["p[text()^='#{match_test}']",
       "p [text()^='#{match_test}']"]
    end

    node = @html_tree.at_css(*selectors)
    node.at_xpath('./ancestor-or-self::p') if node
  end
end
