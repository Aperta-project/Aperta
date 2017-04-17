# Migration for handling snapshot HTML sanitization for APERTA-8656
namespace :data do
  namespace :migrate do
    namespace :html_sanitization do
      desc 'It goes through every snapshot that has HTML values in '
      task sanitize_snapshot_html: :environment do
        set = []
        set.push([['adhoc-attachment',
                   'decision-attachment',
                   'invitation-attachment',
                   'manuscript-attachment',
                   'question-attachment',
                   'sourcefile-attachment',
                   'figure'], ['caption', 'title']])
        set.push([['decision'], ['letter']])
        set.push([['discussion-reply'], ['letter']])
        set.push([['invitation'], ['body', 'decline_reason', 'reviewer_suggestions']])
        set.push([['paper'], ['title', 'abstract']])
        set.push([['related-article'], ['linked_title']])
        set.push([['versioned-text'], ['text', 'original_text']])

        set.each do |m|
          SnapshotMigratorIterator.run!(m)
        end
      end
    end
  end
end
# Helper class for APERTA-8656 migration
class SnapshotMigratorIterator
  def self.run!(arr)
    arr[0].each do |model_name|
      sm = SnapshotMigrator.new(model_name, arr[1], HtmlSanitizationSnapshotConverter.new)
      sm.call!
    end
  end
end
