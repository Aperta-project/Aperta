class OldRoleSerializer < ActiveModel::Serializer
  attributes :id,
             :kind,
             :name,
             :required?,
             :can_administer_journal,
             :can_view_assigned_manuscript_managers,
             :can_view_all_manuscript_managers

  has_one :journal, embed: :id
end
