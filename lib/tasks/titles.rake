# rubocop:disable Style/Semicolon
# rubocop:disable Style/CaseIndentation
# rubocop:disable Performance/StringReplacement

namespace :titles do
  task and_abstracts: :environment do
    regex = /<.*style\s*=/
    current_papers = Paper.all
    puts current_papers.size
    titles = current_papers.map(&:title).map { |title| HtmlScrubber.standalone_scrub!(title) }.grep(regex)
    puts titles.take(2)
    puts
    abstracts = current_papers.map(&:abstract).map { |abstract| HtmlScrubber.standalone_scrub!(abstract) }.grep(regex)
    puts abstracts.take(2)
  end

  task short: :environment do
    regex = /<.*style\s*=/
    card_id = CardContent.where("ident like '%short%'").first.id
    answers = Answer.where(card_content_id: card_id)
    puts answers.size
    styles = answers.map(&:value).grep(regex)
    puts styles.size
    styles = answers.map(&:value).map { |value| HtmlScrubber.standalone_scrub!(value) }.grep(regex)
    puts styles.size
  end

  task parse: :environment do
    def rules(text)
      text.split(';').map(&:strip).inject(Set.new) do |props, rule|
        row = rule.split(':').map(&:strip)
        props << row.first
      end
    end

    styles = Set.new(%w(font-style font-weight))
    card_id = CardContent.where("ident like '%short%'").first.id
    answers = Answer.where(card_content_id: card_id)
    puts answers.size

    values = answers.map(&:value).map { |value| HtmlScrubber.style_scrub!(value) }
    output = ''

    styler = Loofah::Scrubber.new do |node|
      style = node.attributes['style']
      (output << node.to_s; next Loofah::Scrubber::CONTINUE) if style.blank?

      styling = rules(style.text)
      matches = styles & styling
      node.remove_attribute('style')
      (output << node.to_s; next Loofah::Scrubber::CONTINUE) if matches.empty?

      contents = node.to_s
      matches.each do |match|
        tag = case match
          when 'font-style'  then 'i'
          when 'font-weight' then 'b'
        end
        contents = "<#{tag}>#{contents}</#{tag}>" if tag
      end

      output << contents
      Loofah::Scrubber::STOP
    end

    values.each do |text|
      output = ''
      Loofah.fragment(text).scrub!(styler)
      next if text == output
      puts "1. #{text.gsub("\n", ' ')}\n2. #{output.gsub("\n", ' ')}\n\n"
    end
  end
end
