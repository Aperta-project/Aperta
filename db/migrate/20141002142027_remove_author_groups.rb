class RemoveAuthorGroups < ActiveRecord::Migration
  def up
    add_column :authors, :paper_id, :integer

    Paper.all.each do |paper|
      index_offset = 0

      paper.author_groups.each do |ag|
        ag.authors.each do |a|
          a.update_attributes position: a.position+index_offset,
                              paper_id: paper.id
        end
        index_offset += ag.authors.length
      end
    end

    remove_column :authors, :author_group_id
    drop_table    :author_groups
    create_table  :author_paper
  end

  def down
    # irreversible
    raise ActiveRecord::IrreversibleMigration, "Can't recover author groups information."
  end
end

module RemoveAuthorGroup
  class ::AuthorGroup < ActiveRecord::Base
    belongs_to :paper
    has_many :authors, inverse_of: :author_group, dependent: :destroy
  end

  class ::Paper < ActiveRecord::Base
    has_many :author_groups, -> { order("id ASC") }, inverse_of: :paper, dependent: :destroy
  end

  class ::Author < ActiveRecord::Base
    belongs_to :author_group, inverse_of: :authors
  end
end

RemoveAuthorGroups.send :include, RemoveAuthorGroup
