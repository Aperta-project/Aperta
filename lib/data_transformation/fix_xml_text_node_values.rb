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

module DataTransformation
  # Makes sure HTML with the XML of custom cards are valid
  # This does two things:
  # 1. Fixes non-breaking '<br>'s by making them self-closing
  # 2. Fixes
  class FixXmlTextNodeValues < Base
    counter :br_elements_closed
    counter :cdata_nodes_removed

    def transform
      remove_cdata_nodes
      fix_unclosed_brs
      fix_unclosed_ols
    end

    def remove_cdata_nodes
      card_contents = CardContent.all
      card_contents.each do |content|
        next if content.text.blank?
        previous_text = content.text
        replaced = content.text.gsub(/<!\[CDATA\[|\]\]>/, '')
        next unless replaced
        log("Updating CardContent with removed CDATA nodes: #{content.id}")
        log("old: #{previous_text}")
        log("new: #{content.text}")
        content.update!(text: replaced)
      end
    end

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
      card_contents = CardContent.joins(:entity_attributes).where(ident: 'competing_interests--has_competing_interests')
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
