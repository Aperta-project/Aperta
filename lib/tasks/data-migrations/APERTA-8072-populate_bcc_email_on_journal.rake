namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-8072: Sets default BCC email addresses

      For invitations, a setting is stored on the journal
      for a BCC address used to capture and chase down any
      outstanding invitations.
    DESC
    task populate_bcc_email_on_journal: :environment do
      if Rails.env.production?
        Journal.all.update_all(
          reviewer_email_bcc: 'apertachasing@plos.org',
          editor_email_bcc: 'apertachasing@plos.org'
        )
      elsif !Rails.env.development?
        Journal.all.update_all(
          reviewer_email_bcc: 'apertadevteam@plos.org',
          editor_email_bcc: 'apertadevteam@plos.org'
        )
      end
    end
  end
end
