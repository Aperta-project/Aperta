class RequireFieldsOnVersionedText < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        # delete orphan versioned_texts
        execute "DELETE FROM versioned_texts where paper_id IS NULL;"
      end
    end

    change_column_null :versioned_texts, :paper_id, false
    change_column_null :versioned_texts, :minor_version, false
    change_column_default :versioned_texts, :minor_version, nil
    change_column_null :versioned_texts, :major_version, false
    change_column_default :versioned_texts, :major_version, nil

    reversible do |dir|
      dir.up do
        # ensure all papers have a latest_version
        execute("SELECT id FROM papers WHERE id NOT IN (SELECT paper_id FROM versioned_texts WHERE paper_id IS NOT NULL);").each do |row|
          execute("INSERT INTO versioned_texts (major_version, minor_version, text, paper_id) VALUES (0, 0, '', #{row['id']});")
        end
      end
    end
  end
end
