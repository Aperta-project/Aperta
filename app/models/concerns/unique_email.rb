# UniqueEmail checks the author tables for existing email addresses and
# validates that the new or changed email is not a duplicate.
module UniqueEmail
  extend ActiveSupport::Concern

  included do
    validate :check_duplicate_email

    def check_duplicate_email
      paper = Paper.find(paper_id)
      emails = (paper.authors.pluck(:email) + paper.group_authors.pluck(:email)).uniq
      emails.delete(email) unless new_record? || email_changed?
      errors.add(:email, 'Duplicate email address for this manuscript') if email.in?(emails)
    end
  end
end
