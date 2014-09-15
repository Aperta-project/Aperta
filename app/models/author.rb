class Author < ActiveRecord::Base
  actable

  belongs_to :author_group, inverse_of: :authors
  acts_as_list scope: :author_group

  validates :author_group, presence: true

  def formatted_errors
    self.errors.to_h.merge(id: self.id)
  end

  # TODO: make this a global override
  # Because .specific returns nil if there isn't a specific one
  def specific_with_derive
    specific_without_derive.presence || self
  end
  alias_method_chain :specific, :derive
end
