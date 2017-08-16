namespace :data do
  namespace :migrate do
    namespace :html_sanitization do
      desc 'It converts style attributes to styling tags in titles, abstracts, and short titles'
      task sanitize_styles: :environment do
        Content = Struct.new(:record, :field, :paper)
        Statistics = Struct.new(:kind, :total, :processed, :changed, :updated)
        Styles = Set.new(%w(font-style font-weight))
        Dry = ENV['DRY_RUN'] == 'true'

        def rules(text)
          text.split(';').map(&:strip).inject(Set.new) do |props, rule|
            row = rule.split(':').map(&:strip)
            props << row.first
          end
        end

        def replace_styles(statistics, models)
          styler = Loofah::Scrubber.new do |node|
            style = node.attributes['style']
            next Loofah::Scrubber::CONTINUE if style.blank?

            statistics.processed += 1
            styling = rules(style.text)
            matches = Styles & styling
            tags = matches.map do |match|
              case match
              when 'font-style'  then 'i'
              when 'font-weight' then 'b'
              end
            end.compact.uniq

            node.attributes['style'].remove
            next Loofah::Scrubber::CONTINUE if tags.empty?

            statistics.changed += 1
            case tags.size
            when 1
              node.inner_html = "<#{tags.first}>#{node.to_html}</#{tags.first}>"
            when 2
              node.inner_html = "<#{tags.first}><#{tags.last}>#{node.to_html}</#{tags.last}></#{tags.first}>"
            end

            Loofah::Scrubber::CONTINUE
          end

          models.each do |model|
            text = model.record[model.field]
            next if text.blank?

            before = HtmlScrubber.style_scrub!(text.strip)
            after = Loofah.fragment(before).scrub!(styler).to_html.strip
            after = HtmlScrubber.standalone_scrub!(after)
            next if before == after

            statistics.updated += 1
            if Dry
              before = before.tr("\n", ' ')
              after = after.tr("\n", ' ')
              puts "<u>Paper [#{model.paper}] #{statistics.kind}</u><br>\n1. #{before}<br>\n2. #{after}<br>\n<br>\n"
            else
              model.record[model.field] = after
              model.record.save
            end
          end
        end

        def migrate(kind)
          list = yield
          statistics = Statistics.new(kind, list.size, 0, 0, 0)
          replace_styles(statistics, list)
          statistics
        end

        results = []
        papers = Paper.order(:id).all
        short_title = CardContent.where("ident like '%short%'").first

        results << migrate('Paper Title')    { papers.map { |paper| Content.new(paper, :title, paper.id) } }
        results << migrate('Short Title')    { short_title.answers.order(:id).map { |answer| Content.new(answer, :value, answer.paper_id) } }
        results << migrate('Paper Abstract') { papers.map { |paper| Content.new(paper, :abstract, paper.id) } }

        puts
        puts results
      end
    end
  end
end
