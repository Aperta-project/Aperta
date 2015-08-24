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
        Paper.all.each do |paper|
          if paper.versioned_texts.empty?
            paper.versioned_texts.create(major_version: 0, minor_version: 0, text: '')
          end
        end
      end
    end
  end
end
