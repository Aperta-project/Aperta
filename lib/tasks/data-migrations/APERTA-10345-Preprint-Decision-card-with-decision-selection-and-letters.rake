# Migration to update letter templates for Preprint Decision Card

namespace :data do
  namespace :migrate do
    desc 'It updates liquid templates for accept and reject email letters'
    task update_preprint_decision_templates: :environment do
      ident = 'preprint-accept'
      LetterTemplate.where(ident: ident).first_or_initialize.tap do |lt|
        lt.ident = ident
        lt.scenario = 'Preprint Decision'
        lt.subject = 'Manuscript Accepted for ApertarXiv'
        lt.to = '{{manuscript.creator.email}}'
        lt.body = <<-TEXT.strip_heredoc
          <p>Dear Dr. {{manuscript.creator.last_name}},</p>
          <p>Your {{journal.name}} manuscript, '{{manuscript.title}}', has been approved for pre-print publication. Because you have opted in to this opportunity, your manuscript has been forwarded to ApertarXiv for posting. You will receive another message with publication details when the article has posted.</p>
          <p>Please note this decision is not related to the decision to publish your manuscript in {{journal.name}}. As your manuscript is evaluated for publication you will receive additional communications.</p>
          <p>Kind regards,</p>
          <p>Publication Team</p>
          <p>ApertarXiv</p>
        TEXT

        lt.save!
      end
      ident = 'preprint-reject'
      LetterTemplate.where(ident: ident).first_or_initialize.tap do |lt|
        lt.ident = ident
        lt.scenario = 'Preprint Decision'
        lt.subject = 'Manuscript Declined for ApertarXiv'
        lt.to = '{{manuscript.creator.email}}'
        lt.body = <<-TEXT.strip_heredoc
          <p>Dear Dr. {{manuscript.creator.last_name}},</p>
          <p>Your {{journal.name}} manuscript, '{{manuscript.title}}', has been declined for pre-print publication.</p>
          <p>Please note this decision is not related to the decision to publish your manuscript in {{journal.name}}. As your manuscript is evaluated for publication you will receive additional communications.</p>
          <p>Kind regards,</p>
          <p>Publication Team</p>
          <p>ApertarXiv</p>
        TEXT

        lt.save!
      end
    end
  end
end
