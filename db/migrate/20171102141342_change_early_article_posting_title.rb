class ChangeEarlyArticlePostingTitle < ActiveRecord::Migration
  # rubocop:disable Rails/SkipsModelValidations

  # The existing custom card migrator doesn't change Task and TaskTemplate titles as part
  # of the migration process.  APERTA-10455 renamed the Early Article Posting card to Early Version,
  # and now need to update the existing data.  This issue doesn't affect adding new Early Version tasks
  # directly to the workflow
  def change
    old_title =  'Early Article Posting'
    new_title =  'Early Version'
    Task.where(title: old_title).update_all(title: new_title)
    TaskTemplate.where(title: old_title).update_all(title: new_title)
  end
  # rubocop:enable Rails/SkipsModelValidations
end
