# This backfills short DOIs for papers.
class AddShortDoiToPapers < DataMigration
  RAKE_TASK_UP = 'data:migrate:papers:add_short_doi_to_papers'
end
