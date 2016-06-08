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
    remove_figures
    process_all_figures
    @html_tree.to_html
  end

  private

  def figures_by_label
    @figures.select(&:attachment?)
      .each_with_object({}) do |fig, accum|
        accum[fig.rank] = fig
      end
  end

  def process_all_figures
    captions = captions_by_label

    figures_by_label.each do |label, figure|
      if captions[label]
        insert_figure(figure, captions[label])
      else
        append_figure(figure)
      end
    end
  end

  def captions_by_label
    find_possible_caption_nodes
      .each_with_object({}) do |node, accum|
        figure_regex.match(node_text(node)) do |match|
          matched_label = match["label"].to_i
          accum[matched_label] ||= node
        end
      end
  end

  def insert_figure(figure, caption_node)
    caption_node.add_previous_sibling node_for_figure(figure)
  end

  def append_figure(figure)
    @html_tree.add_child node_for_not_found_figure(figure)
  end

  def find_possible_caption_nodes
    match_test = "Fig"
    # match paragraph tags that contain the text
    # or whose children contain the text
    selectors = ["p[text()^='#{match_test}']", "p *[text()^='#{match_test}']"]

    @html_tree.css(*selectors).map do |node|
      node.at_xpath('./ancestor-or-self::p')
    end
  end

  # matches Fig. 1, Figure 25, etc.
  # returns the label digits as 'label' in its MatchData
  def figure_regex
    /^Fig(ure|\.)?\s+(?<label>\d+)/
  end

  def node_text(node)
    node.inner_text.rstrip.lstrip.gsub(/[[:space:]]+/, ' ')
  end

  def remove_figures
    @html_tree.search('.//img').remove
  end

  def node_for_figure(figure)
    <<-HTML
      <img class="paper-body-figure pdf-image pdf-image-with-caption"
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
end
