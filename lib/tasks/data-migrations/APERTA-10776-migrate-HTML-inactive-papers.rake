# APERTA-10776 Migrate HTML data for inactive papers

namespace :data do
  namespace :migrate do
    namespace :html_sanitization do
      desc 'Sanitize the HTML data for all inactive papers'
      task html_sanitize_inactive_papers: :environment do
        Rake::Task['data:migrate:html_sanitization:sanitize_inactive_database_columns'].invoke
        Rake::Task['data:migrate:html_sanitization:sanitize_inactive_tech_check_bodies'].invoke
        Rake::Task['data:migrate:html_sanitization:sanitize_inactive_answer_html'].invoke
      end

      def papers_to_migrate(active = ENV['ACTIVE'] == 'true')
        inactive_states = %w(rejected withdrawn accepted)
        query = Paper.select(:id)
        query = active ? query.where.not(publishing_state: inactive_states) : query.where(publishing_state: inactive_states)
        query.pluck(:id).map(&:to_i)
      end

      desc 'It goes through every HTML database column and sanitizes it'
      task sanitize_inactive_database_columns: :environment do
        paper    = -> (record) { record.id }
        direct   = -> (record) { record.paper_id }
        indirect = -> (record) { record.paper.id }
        reply    = -> (record) { record.discussion_topic.paper.id }

        list = [
          [Attachment,      direct,   true,  %i(title caption)],
          [Comment,         indirect, false, %i(body)],
          [Decision,        direct,   true,  %i(letter author_response)],
          [DiscussionReply, reply,    false, %i(body)],
          [Invitation,      indirect, true,  %i(body decline_reason reviewer_suggestions)],
          [Paper,           paper,    false, %i(abstract title)],
          [RelatedArticle,  indirect, false, %i(linked_title additional_info)]
        ]

        dry = ENV['DRY_RUN'] == 'true'

        current_papers = papers_to_migrate.to_set

        counters = Struct.new(:kinds, :records, :fields)
        processed_papers = Hash.new { |h, k| h[k] = counters.new(Set.new, 0, 0) }
        clean = -> (text) { text.to_s.gsub(/\s+/, ' ').strip }

        puts "*** Migrating database columns - dry=#{dry}"

        list.each do |(model, locator, newlines, fields)|
          records = model.all
          records.each do |record|
            # puts "Record #{record.class} #{record.id}"
            paper_id = locator[record].to_i
            # throw "Invalid paper id: #{paper_id} for #{model} [#{record.id}]" unless paper_id > 0
            next unless paper_id.in?(current_papers)

            counter = processed_papers[paper_id]
            counter.kinds << (record.try(:type) || model.name)
            fields.each do |field|
              before = record[field]
              next if before.blank?

              text = newlines ? before.gsub("\n", "<br>") : before
              after = HtmlScrubber.standalone_scrub!(text)
              next if before.strip == after.strip

              if dry
                header = "<br>PAPER #{paper_id} - #{model} #{field} [#{record.id}]"
                puts "#{header} BEFORE: #{clean[before]}"
                puts "#{header} AFTER: #{clean[after]}"
              else
                record[field] = after
                counter.fields += 1
              end
            end

            next if dry

            if record.changed?
              saved = record.save(validate: false)
              counter.records += 1 if saved
            end
          end
        end

        processed_papers.keys.sort.each do |paper_id|
          counter = processed_papers[paper_id]
          next if counter.fields.zero?
          counter.kinds.sort.each do |kind|
            puts "*** Migrate Paper [#{paper_id}] migrated #{counter.fields} HTML #{kind} field(s) in #{counter.records} record(s)"
          end
          puts "\n"
        end

        puts "*** Migrated database columns for papers [#{processed_papers.size}]"
      end

      desc 'It goes through every tech check body and converts newlines to break tags'
      task sanitize_inactive_tech_check_bodies: :environment do
        dry = ENV['DRY_RUN'] == 'true'
        body_keys = %w(initialTechCheckBody finalTechCheckBody revisedTechCheckBody)
        current_papers = papers_to_migrate
        tasks = Task.where(paper_id: current_papers).all
        tasks = tasks.select { |task| task.body.is_a? Hash }

        puts "*** Migrating tech check bodies - dry=#{dry}"
        count = 0
        tasks.each do |task|
          body = task.body
          next unless body

          body_keys.each do |key|
            text = body[key]
            next unless text

            newlines = text.count("\n")
            next if newlines.zero?

            count += 1
            body[key] = text.gsub("\n", "<br>")
            task.body = body

            if dry
              puts "*** Migrate Paper [#{task.paper_id}] Task [#{task.id}] #{task.type} #{key.titleize} Newlines [#{newlines}]"
            else
              task.save
            end
          end
        end

        puts "*** Migrated tech check bodies [#{count}]"
      end

      desc 'It goes through every answer that has HTML values in and sanitize it'
      task sanitize_inactive_answer_html: :environment do
        dry = ENV['DRY_RUN'] == 'true'
        Rake::Task['cards:load'].invoke

        puts "*** Migrating card content answers - dry=#{dry}"
        current_papers = papers_to_migrate.to_set
        clean = -> (text) { text.to_s.gsub(/\s+/, ' ').strip }

        field_counts = Hash.new { |h, k| h[k] = 0 }
        CardContent.where(value_type: 'html').includes(:answers).each do |cc|
          # puts "migrating card content answers #with #{cc.ident}"
          cc.answers.each do |answer|
            next unless answer.paper_id.in?(current_papers)

            before = answer.value
            next if before.blank?

            text = before.gsub("\n", "<br>")
            after = HtmlScrubber.standalone_scrub!(text)
            next if before.strip == after.strip

            field_counts[cc.ident] += 1
            if dry
              header = "CARD_CONTENT [#{answer.paper_id}] #{cc.ident}"
              puts "#{header} BEFORE: #{clean[before]}"
              puts "#{header} AFTER: #{clean[after]}"
            else
              answer.update!(value: after)
            end
          end
        end

        field_counts.keys.sort.each do |ident|
          puts "*** Migrate #{field_counts[ident]} HTML #{ident} field(s)"
        end

        puts "*** Migrated inactive answers [#{field_counts.size}]"
      end
    end
  end
end
