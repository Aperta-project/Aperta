class ChangePreprintShortDoiToPreprintDoiArticleNumberFromTableName < ActiveRecord::Migration
  def change
    rename_column :papers, :preprint_short_doi, :preprint_doi_article_number
  end
end
