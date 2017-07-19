# A Scrubber that scrubs out bad HTML and text we don't want
# https://github.com/rails/rails-html-sanitizer for more details
class HtmlScrubber < Rails::Html::PermitScrubber
  BASIC_TAGS    = 'p,br,strong,b,em,i,u,sub,sup,pre'.freeze
  EXTRA_TAGS    = ',a,div,span,code,ol,ul,li,h1,h2,h3,h4,table,thead,tbody,tfoot,tr,th,td'.freeze
  STANDARD_TAGS = Set.new((BASIC_TAGS + EXTRA_TAGS).split(',')).freeze
  TAG_ATTRS     = Set.new(%w(href rel target title)).freeze

  def initialize(attrs = [])
    super()
    self.tags = STANDARD_TAGS
    self.attributes = TAG_ATTRS + attrs
  end

  def skip_node?(node)
    # this is a crappy hack to get around Microsoft deciding that adding
    # HTML style comments within style tags is a good idea
    node.children.remove if node.name == 'style'

    node.text?
  end

  def self.standalone_scrub!(value)
    scrubber = new
    fragment = Loofah.fragment(value)
    fragment.scrub!(scrubber)
    fragment.to_html
  end

  def self.style_scrub!(value)
    scrubber = new(['style'])
    fragment = Loofah.fragment(value)
    fragment.scrub!(scrubber)
    fragment.to_html
  end
end
