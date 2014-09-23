class ReindexTablesForSolr < ActiveRecord::Migration
  def up
    Rake::Task["sunspot:reindex"].invoke
  end
end
