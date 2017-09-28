# coding: utf-8

namespace :seed do
  namespace :letter_templates do
    desc 'Adds default letter-templates for Register Decision to all journals.'
    task populate: :environment do
      Journal.all.each do |journal|
        JournalFactory.seed_letter_templates(journal)
      end
    end
  end
end
