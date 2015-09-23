RSpec::Matchers.define :have_path do |path|
  def parse(str)
    if str.is_a? Nokogiri::HTML::Document
      str
    else
      Nokogiri::HTML(str)
    end
  end

  match do |str|
    !parse(str).at(path).nil?
  end

  failure_message do |str|
    "Expected path #{path} to match in:\n#{parse(str).to_html(indent: 2)}"
  end

  failure_message_when_negated do |str|
    "Expected path #{path} not to match in:\n#{parse(str).to_html(indent: 2)}"
  end
end
