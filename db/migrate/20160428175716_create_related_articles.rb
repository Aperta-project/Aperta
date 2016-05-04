##
# A related article represents a linkt to another manuscript, which
# may or may not already be published. Sometimes, two articles should
# be published together, so one needs to be held to wait for the
# other. Other times, they are related, but not simultaneously
# published. Those relationships are one-way.
class CreateRelatedArticles < ActiveRecord::Migration
  def change
    create_table :related_articles do |t|
      t.references :paper, index: true
      t.string :linked_doi
      t.string :linked_title
      t.string :additional_info
      t.boolean :send_manuscripts_together
      t.text :send_link_to_apex

      t.timestamps
    end
  end
end
