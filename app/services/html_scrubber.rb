# A Scrubber that scrubs out bad HTML and text we don't want
# https://github.com/rails/rails-html-sanitizer for more details
class HtmlScrubber < Rails::Html::PermitScrubber
  def initialize
    super
    self.tags = %w(i sub sup span b a div p h1 h2 h3 h4 h5 h6 ul li oi)
    self.attributes = %w(href class id)
  end

  def skip_node?(node)
    # this is a crappy hack to get around Microsoft deciding that adding
    # HTML style comments within style tags is a good idea
    node.children.remove if node.name == 'style'

    node.text?
  end

  def self.standalone_scrub!(value)
    scrubber = self.new
    fragment = Loofah.fragment(value)
    fragment.scrub!(scrubber)
    fragment.to_html
  end
end
