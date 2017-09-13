namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-10284: Add marketing copy to Preprint Posting card

      10284 is for creating an additional overlay that appears immediately after
      submitting a paper on a workflow that has preprints enabled. The Preprint
      Posting card is being updated to have an "if" condition to detect whether
      or not it is being displayed in the new overlay, and if so to add some
      additional bullet points above the radio button choice.
    DESC

    task aperta_10284_add_marketing_copy_to_preprint_posting_card: :environment do
      cards = Card.where(name: "Preprint Posting")
      raise Exception, "No Preprint Posting cards were found." if cards.empty?
      Card.transaction do
        before_count = cards.count
        cards.each do |card|
          card.xml =
            <<-XML.strip_heredoc
              <?xml version="1.0" encoding="UTF-8"?>
              <card required-for-submission="true" workflow-display-only="false">
                <content content-type="display-children">
                  <content content-type="if" condition="isOverlay">
                    <content content-type="display-children" child-tag="li" wrapper-tag="ol">
                      <content content-type="text">
                        <text>Benefit: Establish priority</text>
                      </content>
                      <content content-type="text">
                        <text>Benefit: Gather feedback</text>
                      </content>
                      <content content-type="text">
                        <text>Benefit: Cite for funding</text>
                      </content>
                    </content>
                    <content content-type="text">
                      <text>
                        <![CDATA[Establish priority: take credit for your research and discoveries, by posting a copy of your uncorrected proof online. If you do <b>NOT</b> consent to having an early version of your paper posted online, indicate your choice below.]]>
                      </text>
                    </content>
                  </content>
                  <content content-type="radio" value-type="text" default-answer-value="1" allow-annotations="false" required-field="false">
                    <possible-value label="Yes, I want to accelerate research by publishing a preprint ahead of peer review" value="1"/>
                    <possible-value label="No, I do not want my article to appear online ahead of the reviewed article" value="2"/>
                  </content>
                </content>
              </card>
            XML
          card.publish!('Add marketing copy for post-submit overlay')
        end
        after_count = Card.where(name: "Preprint Posting").select { |card| card.to_xml.match /isOverlay/ }.length
        if after_count != before_count
          raise Exception, "Not all cards were updated, rolling back."
        end
      end
    end
  end
end
