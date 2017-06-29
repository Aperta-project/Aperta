# UniqueEmail checks the author tables for existing email addresses and
# validates that the new or changed email is not a duplicate of an existing one
module UniqueEmail
  extend ActiveSupport::Concern

  included do
    validate :email, :check_duplicate_email

    def check_duplicate_email
      paper = Paper.find(paper_id)
      emails = all_author_emails(paper)
      unless new_record?
        emails.delete(email) unless email_changed?
      end
      return unless email.in?(emails)
      errors.add(:email, 'Duplicate email address for this manuscript')
    end

  private

    def all_author_emails(paper)
      fields = [[paper.authors, :email], [paper.group_authors, :contact_email]]
      Set.new.tap { |set| fields.each { |assoc, field| set.merge(assoc.pluck(field)) } }
    end
  end
end
