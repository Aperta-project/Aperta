# rubocop:disable Metrics/BlockLength
namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-11101: Convert fields to use inline-editor

      This data migration strips line feeds, and HTML paragraph and br tags
      from existing answers. Fields using these idents in questions have been
      changed to use the new "inline" TinyMCE option, which will disallow those
      tags in new questions.
    DESC

    task aperta_11101_remove_html_markup_from_inline_idents: :environment do
      idents = %w[publishing_related_questions--short_title competing_interests--statement data_availability--data_location]

      CardContent.transaction do
        idents.each do |ident|
          card_content = CardContent.find_by(ident: ident)
          answers = Answer.where(card_content: card_content)
          strip_html(answers, ident)
        end
        strip_html(RelatedArticle.all, 'Related Articles', 'linked_title')
      end
    end

    def selector
      %r{</?p>|<br>|\n}
    end

    def strip_html(rows, name, column = 'value')
      begin_count = rows.select { |r| r[column].match selector }.count

      if begin_count > 0
        # rubocop:disable Rails/SkipsModelValidations:
        # These aren't the validations you're looking for, Rubocop. Move along.
        rows.update_all("#{column} = regexp_replace(#{column}, '</?p>|<br>|\n', '', 'g')")
        # rubocop:enable Rails/SkipsModelValidations:
        rows.reload
        remaining = rows.select { |r| r[column].match selector }.count
        raise Exception, 'Not all affected markup was removed, rolling back' if remaining > 0
        p "Cleaned #{begin_count} rows for #{name}"
      else
        p "#{name} had no answers with affected markup"
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
