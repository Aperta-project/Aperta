module FinancialDisclosure
  class FunderSerializer < ActiveModel::Serializer
    attributes :id, :name, :grant_number, :website,
               :funder_had_influence, :funder_influence_description

    has_one :task, embed: :ids, include: false
    has_many :authors, embed: :ids, include: true
  end
end
