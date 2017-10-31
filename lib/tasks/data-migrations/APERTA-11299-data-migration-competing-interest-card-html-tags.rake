# rubocop:disable Metrics/BlockLength
namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-11299: Competing Interests custom card html tag migration fix

      The current Competing Interests card has html tag errors in the <text> element tags of the parsed XML. This
      patches that in the CardContent records that were created.
    DESC

    task aperta_11299_data_migration_competing_interest_card_html_tags: :environment do
      card_contents = CardContent.joins(:content_attributes)
                          .where('content_attributes.name': 'text')
                          .where('content_attributes.string_value = ?', "Please provide details about any and all competing interests in the box below. Your response should begin with this statement: \"I have read the journal's policy and the authors of this manuscript have the following competing interests.\"<br><br>Please note that if your manuscript is accepted, this statement will be published.")
      if card_contents.empty?
        raise Exception, 'No matching cards were found - has Competing Interests been migrated to a custom card yet?'
      end
      CardContent.transaction do
        card_contents.each do |content|
          content.update!(text: "Please provide details about any and all competing interests in the box below. Your response should begin with this statement: \"I have read the journal's policy and the authors of this manuscript have the following competing interests.\"<br/><br/>Please note that if your manuscript is accepted, this statement will be published.")
        end
      end

      card_contents = CardContent.joins(:content_attributes)
                          .where('content_attributes.name': 'text')
                          .where('content_attributes.string_value = ?', '<ol class="question-list"><li class="question"><div class="question-text"><p>You are responsible for recognizing and disclosing on behalf of all authors any competing interest that could be perceived to bias their work, acknowledging all financial support and any other relevant financial or non-financial competing interests.</p>Do any authors of this manuscript have competing interests (as described in the <a target="_blank" href="http://journals.plos.org/plosbiology/s/competing-interests">PLOS Policy on Declaration and Evaluation of Competing Interests</a>)?</div></li>')
      if card_contents.empty?
        raise Exception, 'No matching cards were found - has Competing Interests been migrated to a custom card yet?'
      end
      CardContent.transaction do
        card_contents.each do |content|
          content.update!(text: '<ol class="question-list"><li class="question"><div class="question-text"><p>You are responsible for recognizing and disclosing on behalf of all authors any competing interest that could be perceived to bias their work, acknowledging all financial support and any other relevant financial or non-financial competing interests.</p>Do any authors of this manuscript have competing interests (as described in the <a target="_blank" href="http://journals.plos.org/plosbiology/s/competing-interests">PLOS Policy on Declaration and Evaluation of Competing Interests</a>)?</div></li></ol>')
        end
      end
    end
  end
end
