require_relative './support/card_seeder'
namespace 'card_seed' do
  task 'competing_interests_task': :environment do
    content = []
    content << {
      ident: "competing_interests--has_competing_interests",
      value_type: "boolean",
      text: "Do any authors of this manuscript have competing interests (as described in the <a target='_blank' href='http://journals.plos.org/plosbiology/s/competing-interests'>PLOS Policy on Declaration and Evaluation of Competing Interests</a>)?",
      children: [
        {
          ident: "competing_interests--statement",
          value_type: "text",
          text: "Please provide details about any and all competing interests in the box below. Your response should begin with this statement: \"I have read the journal's policy and the authors of this manuscript have the following competing interests.\""
        }
      ]
    }

    CardSeeder.seed_card('TahiStandardTasks::CompetingInterestsTask', content)
  end
end
