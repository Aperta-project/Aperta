# A Scrubber that scrubs out bad HTML and text we don't want
# https://github.com/rails/rails-html-sanitizer for more details
class HtmlScrubber < Rails::Html::PermitScrubber
  EXPANDED_TAGS = [:i,
                   :sub,
                   :sup,
                   :b,
                   :code,
                   :table,
                   :tr,
                   :td,
                   :th,
                   :thead,
                   :tfoot,
                   :div,
                   :p,
                   :h1,
                   :h2,
                   :h3,
                   :h4,
                   :h5,
                   :h6,
                   :ul,
                   :li,
                   :oi].freeze

  def initialize(tags: %w(i sub sup b code))
    super()
    self.tags = tags
    self.attributes = %w(href class id)
  end

  def skip_node?(node)
    # this is a crappy hack to get around Microsoft deciding that adding
    # HTML style comments within style tags is a good idea
    node.children.remove if node.name == 'style'

    node.text?
  end

  def self.standalone_scrub!(value, html_value_type = 'html')
    scrubber = html_value_type == "html" ? new : new(tags: EXPANDED_TAGS)
    fragment = Loofah.fragment(value)
    fragment.scrub!(scrubber)
    fragment.to_html
  end
end
