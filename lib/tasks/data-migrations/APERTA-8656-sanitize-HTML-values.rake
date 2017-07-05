# Migration for handling snapshot HTML sanitization for APERTA-8656

namespace :data do
  namespace :migrate do
    namespace :html_sanitization do
      desc 'It goes through every HTML database column and sanitizes it'
      task sanitize_database_html: :environment do
        paper    = -> (record) { record.id }
        direct   = -> (record) { record.paper_id }
        indirect = -> (record) { record.paper.id }
        reply    = -> (record) { record.discussion_topic.paper.id }

        list = [
          [Attachment,      direct,   false, %i(title caption)],
          [Comment,         indirect, false, %i(body)],
          [Decision,        direct,   true,  %i(letter author_response)],
          [DiscussionReply, reply,    false, %i(body)],
          [Invitation,      indirect, true,  %i(body decline_reason reviewer_suggestions)],
          [Paper,           paper,    false, %i(abstract title)],
          [RelatedArticle,  indirect, false, %i(linked_title additional_info)]
        ]

        dry = ENV['DRY_RUN'] == 'true'
        inactive_states = %w(rejected withdrawn accepted)
        current_papers = Paper.select(:id).where.not(publishing_state: inactive_states).pluck(:id).map(&:to_i).to_set
        counters = Struct.new(:kinds, :records, :fields)
        processed_papers = Hash.new { |h, k| h[k] = counters.new(Set.new, 0, 0) }
        clean = -> (text) { text.to_s.gsub(/\s+/, ' ').strip }

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

              before = before.gsub("\n", "<br>") if newlines
              after = HtmlScrubber.standalone_scrub!(before)
              next if before.strip == after.strip && (!translate)

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
            puts "Paper [#{paper_id}] migrated #{counter.fields} HTML #{kind} field(s) in #{counter.records} record(s)"
          end
          puts "\n"
        end
      end

      desc 'It goes through every answer that has HTML values in and sanitize it'
      task sanitize_answer_html: :environment do
        dry = ENV['DRY_RUN'] == 'true'
        inactive_states = %w(rejected withdrawn accepted)
        current_papers = Paper.select(:id).where.not(publishing_state: inactive_states).pluck(:id).to_set
        clean = -> (text) { text.to_s.gsub(/\s+/, ' ').strip }

        idents = [
          'cover_letter--text',
          'data_availability--data_location',
          'front_matter_reviewer_report--suitable--comment',
          'production_metadata--production_notes',
          'publishing_related_questions--short_title',
          'reviewer_report--comments_for_author'
        ]

        break_fields = Set.new(['cover_letter--text'])

        field_counts = Hash.new { |h, k| h[k] = 0 }
        CardContent.where(ident: idents).includes(:answers).each do |cc|
          # puts "migrating card content answers #with #{cc.ident}"
          cc.answers.each do |answer|
            next unless answer.paper_id.in?(current_papers)

            before = answer.value
            next if before.blank?

            translate = cc.ident.in?(break_fields)
            before = before.gsub("\n", "<br>") if translate
            after = HtmlScrubber.standalone_scrub!(before)
            next if before.strip == after.strip && (!translate)

            if dry
              header = "CARD_CONTENT [#{answer.paper_id}] #{cc.ident}"
              puts "#{header} BEFORE: #{clean[before]}"
              puts "#{header} AFTER: #{clean[after]}"
            else
              answer.update!(value: after)
              field_counts[cc.ident] += 1
            end
          end
        end

        field_counts.keys.sort.each do |ident|
          puts "Migrated #{field_counts[ident]} HTML #{ident} field(s)"
        end
      end
    end
  end
end
