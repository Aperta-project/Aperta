# rubocop:disable Rails/SkipsModelValidations
namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-10955 move Title And Abstract card to the right picker column (authors, not editors)
    DESC
    task move_title_and_abstract: :environment do
      JournalTaskType.transaction do
        jtt = JournalTaskType.where(title: 'Title And Abstract', role_hint: 'editor')
        pre_count = jtt.count
        count = jtt.update_all(role_hint: 'author')
        raise "Found #{pre_count} cards to move, but only moved #{count} cards. Rolling back." unless count == pre_count
      end
    end

    task move_title_and_abstract_back: :environment do
      JournalTaskType.transaction do
        jtt = JournalTaskType.where(title: 'Title And Abstract', role_hint: 'author')
        pre_count = jtt.count
        count = jtt.update_all(role_hint: 'editor')
        raise "Found #{pre_count} cards to move, but only moved #{count} cards. Rolling back." unless count == pre_count
      end
    end
  end
end
