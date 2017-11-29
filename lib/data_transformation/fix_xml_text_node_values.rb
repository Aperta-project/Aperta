module DataTransformation
  # Makes sure HTML with the XML of custom cards are valid
  # This does two things:
  # 1. Fixes non-breaking '<br>'s by making them self-closing
  # 2. Fixes
  class FixXmlTextNodeValues < Base
    counter :br_elements_closed

    def transform
      fix_unclosed_brs
      fix_unclosed_ols
    end

    private

    def fix_unclosed_brs
      card_contents = CardContent.all
      card_contents.each do |content|
        next if content.text.blank?
        previous_text = content.text
        replaced = content.text.gsub!(/<br>/, '<br/>')
        next unless replaced
        increment_counter(:br_elements_closed)
        log("Updating CardContent with self closing <brs/>: #{content.id}")
        log("old: #{previous_text}")
        log("new: #{content.text}")
        content.update!(text: replaced)
      end
    end

    def fix_unclosed_ols
      card_contents = CardContent.joins(:content_attributes).where(ident: 'competing_interests--has_competing_interests')
      assert(
        card_contents.present?,
        'expected at least one card content to be present - was the card content deleted?'
      )
      CardContent.transaction do
        card_contents.each do |content|
          content.update!(text: '<ol class="question-list"><li class="question"><div class="question-text"><p>You are responsible for recognizing and disclosing on behalf of all authors any competing interest that could be perceived to bias their work, acknowledging all financial support and any other relevant financial or non-financial competing interests.</p>Do any authors of this manuscript have competing interests (as described in the <a target="_blank" href="http://journals.plos.org/plosbiology/s/competing-interests">PLOS Policy on Declaration and Evaluation of Competing Interests</a>)?</div></li></ol>')
        end
      end
    end
  end
end
