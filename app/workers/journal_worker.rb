class JournalWorker
  include Sidekiq::Worker

  def perform(journal_id)
    journal = Journal.find(journal_id)
    CustomCard::FileLoader.load(journal) if journal
  end
end
