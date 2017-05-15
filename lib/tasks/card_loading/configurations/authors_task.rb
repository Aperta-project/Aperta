# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class AuthorsTask
    def self.name
      "TahiStandardTasks::AuthorsTask"
    end

    def self.title
      "Authors Task"
    end

    def self.content
      [
        {
          ident: 'authors--persons_agreed_to_be_named',
          value_type: 'boolean',
          text: 'Any persons named in the Acknowledgements section of the manuscript, or referred to as the source of a personal communication, have agreed to being so named.'
        },

        {
          ident: 'authors--authors_confirm_icmje_criteria',
          value_type: 'boolean',
          text: 'All authors have read, and confirm, that they meet, <a href="http://www.icmje.org/recommendations/browse/roles-and-responsibilities/defining-the-role-of-authors-and-contributors.html" target="_blank">ICMJE</a> criteria for authorship.'
        },

        {
          ident: 'authors--authors_agree_to_submission',
          value_type: 'boolean',
          text: 'All contributing authors are aware of and agree to the submission of this manuscript.'
        }
      ]
    end
  end
end
