class PotentialFlowSerializer < ActiveModel::Serializer
  attributes :id, :journal_name, :journal_logo, :title

  private

  def journal_name
    object.journal.try(:name)
  end

  def journal_logo
    object.journal.try(:logo_url)
  end
end
