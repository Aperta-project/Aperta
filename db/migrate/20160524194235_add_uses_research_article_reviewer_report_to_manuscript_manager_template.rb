class AddUsesResearchArticleReviewerReportToManuscriptManagerTemplate < ActiveRecord::Migration
  def change
    add_column :manuscript_manager_templates, :uses_research_article_reviewer_report, :boolean, default: false

    reversible do |dir|
      dir.up do
        # All existing MMTs used research article reviewer reports
        execute <<-SQL
          UPDATE manuscript_manager_templates
          SET uses_research_article_reviewer_report='t';
        SQL
      end
    end
  end
end
