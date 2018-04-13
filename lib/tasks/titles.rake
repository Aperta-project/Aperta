# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# rubocop:disable Style/Semicolon
# rubocop:disable Layout/CaseIndentation
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

  task identify: :environment do
    Content = Struct.new(:id, :text)
    Styles = Set.new(%w(font-style font-weight))

    def rules(text)
      text.split(';').map(&:strip).inject(Set.new) do |props, rule|
        row = rule.split(':').map(&:strip)
        props << row.first
      end
    end

    def analyze(kind, list)
      tags = []
      styler = Loofah::Scrubber.new do |node|
        style = node.attributes['style']
        next Loofah::Scrubber::CONTINUE if style.blank?

        styling = rules(style.text)
        matches = Styles & styling

        tags = matches.map do |match|
          case match
            when 'font-style'  then 'i'
            when 'font-weight' then 'b'
          end
        end.compact
      end

      count = 0
      list.each do |item|
        text = HtmlScrubber.style_scrub!(item.text)
        tags = []
        Loofah.fragment(text).scrub!(styler)
        next if tags.empty?

        count += 1
        text = text.gsub("\n", ' ')
        puts "#{kind} #{item.id.to_s.rjust(4)}: #{tags.join(', ').rjust(4)} -- [#{text.size.to_s.rjust(4)}] #{text}"
      end

      count
    end

    def collect(kind)
      list = yield
      count = analyze(kind, yield)
      "#{kind}: #{count} of #{list.size}"
    end

    results = []
    papers = Paper.order(:id).all
    results << collect('Paper Title')    {papers.map {|paper| Content.new(paper.id, paper.title)}}
    results << collect('Paper Abstract') {papers.map {|paper| Content.new(paper.id, paper.abstract)}}

    short_title = CardContent.where("ident like '%short%'").first
    results << collect('Short Title')  {short_title.answers.order(:id).map {|answer| Content.new(answer.id, answer.value)}}

    puts
    puts results
  end
end
