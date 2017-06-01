# Migration for handling snapshot HTML sanitization for APERTA-8656

require 'differ'

namespace :data do
  namespace :migrate do
    namespace :html_sanitization do
      desc 'It goes through every snapshot that has HTML values in it sanitizes it'
      task sanitize_snapshot_html: :environment do
        # list = [
        #   [['adhoc-attachment',      'decision-attachment',
        #     'invitation-attachment', 'manuscript-attachment',
        #     'question-attachment',   'sourcefile-attachment', 'figure'
        #    ],
        #    ['caption', 'title']
        #   ],
        #   [['decision'], ['letter']],
        #   [['discussion-reply'], ['letter']],
        #   [['invitation'], ['body', 'decline_reason', 'reviewer_suggestions']],
        #   [['paper'], ['title', 'abstract']],
        #   [['related-article'], ['linked_title']],
        # ]

        # APERTA-8566: Snapshots will not be migrated
        # dry = ENV['DRY_RUN'] == 'true'
        # list.each do |m|
        #   SnapshotMigratorIterator.run!(m, dry_run: dry)
        # end
      end

      desc 'It goes through every HTML database column and sanitizes it'
      task sanitize_database_html: :environment do
        paper    = -> (record) { record.id }
        direct   = -> (record) { record.paper_id }
        indirect = -> (record) { record.paper.id }
        # reply    = -> (record) { record.discussion_topic.paper.id }

        list = [
          [Attachment,      direct,   %i(title caption)],
          # [Comment,         indirect, %i(body)],
          [Decision,        direct,   %i(letter author_response)],
          # [DiscussionReply, reply,    %i(body)],
          [Invitation,      indirect, %i(body decline_reason reviewer_suggestions)],
          [Paper,           paper,    %i(abstract title)],
          [RelatedArticle,  indirect, %i(linked_title additional_info)]
        ]

        dry = ENV['DRY_RUN'] == 'true'
        inactive_states = %w(rejected withdrawn accepted)
        current_papers = Paper.select(:id).where.not(publishing_state: inactive_states).pluck(:id).to_set

        list.each do |(model, locator, fields)|
          records = model.all
          records.each do |record|
            # puts "Record #{record.class} #{record.id}"
            paper_id = locator[record]
            next unless paper_id.in?(current_papers)

            fields.each do |field|
              before = record[field]
              next if before.blank?
              after = HtmlScrubber.standalone_scrub!(before)
              next if before.strip == after.strip
              if dry
                diffs = Differ.diff_by_word(after, before).to_s.gsub(/\s/, ' ')
                puts "PAPER #{paper_id} - COLUMN #{model} #{field} [#{record.id}]: #{diffs}"
              else
                record[field] = after
              end
            end
            next if dry
            record.save! if record.changed?
          end
        end
      end

      desc 'It goes through every answer that has HTML values in and sanitize it'
      task sanitize_answer_html: :environment do
        dry = ENV['DRY_RUN'] == 'true'
        inactive_states = %w(rejected withdrawn accepted)
        current_papers = Paper.select(:id).where.not(publishing_state: inactive_states).pluck(:id).to_set

        idents = [
          'cover_letter--text',
          'data_availability--data_location',
          'front_matter_reviewer_report--suitable--comment',
          'production_metadata--production_notes',
          'publishing_related_questions--short_title',
          'reviewer_report--comments_for_author'
        ]

        CardContent.where(ident: idents).includes(:answers).each do |cc|
          # puts "migrating card content answers #with #{cc.ident}"
          cc.answers.each do |answer|
            next unless answer.paper_id.in?(current_papers)
            before = answer.value
            after = HtmlScrubber.standalone_scrub!(before)
            next if before.strip == after.strip
            if dry
              diffs = Differ.diff_by_word(after, before).to_s.gsub(/\s/, ' ')
              puts "CARD_CONTENT [#{answer.paper_id}] #{cc.ident}: #{diffs}"
            else
              answer.update!(value: after)
            end
          end
        end
      end
    end
  end
end

# Helper class for APERTA-8656 snapshot migration
class SnapshotMigratorIterator
  def self.run!(arr, dry_run: false)
    arr[0].each do |model_name|
      sm = SnapshotMigrator.new(model_name, arr[1], HtmlSanitizationSnapshotConverter.new, dry_run: dry_run)
      sm.call!
    end
  end
end
