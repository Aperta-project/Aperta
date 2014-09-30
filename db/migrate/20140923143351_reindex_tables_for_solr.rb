class ReindexTablesForSolr < ActiveRecord::Migration
  def up
    if Rails.env.development?
      Rake::Task["sunspot:solr:start"].invoke
      Rake::Task["sunspot:reindex"].invoke
    end
  end
end
