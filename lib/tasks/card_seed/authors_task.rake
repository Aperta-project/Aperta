require_relative './support/card_seeder'
namespace 'card_seed' do
  task 'authors_task': :environment do
    content = []
    content << {
      ident: 'authors--persons_agreed_to_be_named',
      value_type: 'boolean',
      text: 'Any persons named in the Acknowledgements section of the manuscript, or referred to as the source of a personal communication, have agreed to being so named.'
    }

    content << {
      ident: 'authors--authors_confirm_icmje_criteria',
      value_type: 'boolean',
      text: 'All authors have read, and confirm, that they meet, <a href="http://www.icmje.org/recommendations/browse/roles-and-responsibilities/defining-the-role-of-authors-and-contributors.html" target="_blank">ICMJE</a> criteria for authorship.'
    }

    content << {
      ident: 'authors--authors_agree_to_submission',
      value_type: 'boolean',
      text: 'All contributing authors are aware of and agree to the submission of this manuscript.'
    }

    CardSeeder.seed_card('TahiStandardTasks::AuthorsTask', content)
  end
end
