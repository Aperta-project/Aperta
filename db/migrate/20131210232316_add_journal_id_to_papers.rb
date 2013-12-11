class AddJournalIdToPapers < ActiveRecord::Migration
  def change
    add_reference :papers, :journal, index: true

    reversible do |dir|
      dir.up do
        execute <<-SQL
          INSERT INTO "journals" ("name") VALUES ('PLOS Yeti');
          UPDATE "papers" SET "journal_id" = (SELECT "journals".id FROM "journals" ORDER BY "journals"."id" DESC LIMIT 1) WHERE "papers"."journal_id" IS NULL;
        SQL
      end

      dir.down do
        execute <<-SQL
          DELETE FROM "journals" WHERE "journals"."name" = 'PLOS Yeti';
        SQL
      end
    end
  end
end
