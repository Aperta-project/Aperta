class ReindexTablesForSolr < ActiveRecord::Migration
  def up
    Rake::Task["sunspot:reindex"].invoke if Rails.env.development?
  end
end
