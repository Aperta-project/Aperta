class AddUsesResearchArticleReviewerReportToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :uses_research_article_reviewer_report, :boolean, default: false

    reversible do |dir|
      dir.up do
        # All existing Papers used research article reviewer reports
        execute <<-SQL;
          UPDATE papers
          SET uses_research_article_reviewer_report='t';
        SQL
      end
    end
  end
end
