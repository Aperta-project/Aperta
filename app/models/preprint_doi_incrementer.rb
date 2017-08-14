# A soft singleton class for globally tracking the last preprint doi
class PreprintDoiIncrementer < ActiveRecord::Base
  class DoiIncrementerSingletonError < StandardError; end;
  DOI_LENGTH = 7

  def self.get_next_doi!
    first.succ!.to_doi
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
    pad_string = ""
    pad_length = DOI_LENGTH - value.to_s.length
    pad_length.times { |n| pad_string[n] = "0" }
    pad_string + value.to_s
  end
end
