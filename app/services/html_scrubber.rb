# A Scrubber that scrubs out bad HTML and text we don't want
# https://github.com/rails/rails-html-sanitizer for more details
class HtmlScrubber < Rails::Html::PermitScrubber
  def initialize
    super
    self.tags = %w(form i sub sup b a div p)
    self.attributes = %w(href class id)
  end

  def skip_node?(node)
    # this is a crappy hack to get around Microsoft deciding that adding
    # comments within style tags is a good idea
    node.children.remove if node.name == 'style'

    node.text?
  end
end
