# A soft singleton class for globally tracking the last preprint doi
class PreprintDoiIncrementer < ActiveRecord::Base
  class DoiIncrementerSingletonError < StandardError; end
  def self.next_article_number!
    first_or_create!.send(:succ!).send(:to_doi)
  end

  def self.create
    raise DoiIncrementerSingletonError if first.present?
    super
  end

  private

  def succ!
    tap { update!(value: self.value += 1) }
  end

  def to_doi
    format("%0#{Paper::PREPRINT_DOI_ARTICLE_NUMBER_LENGTH}i", value)
  end
end
