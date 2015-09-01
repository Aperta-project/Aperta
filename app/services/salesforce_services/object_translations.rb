module SalesforceServices
  module ObjectTranslations

    class ManuscriptTranslator
      def initialize(user_id:, paper:)
        @user_id = user_id
        @paper = paper
      end

      def paper_to_manuscript_hash
        {
          "RecordTypeId" => "012U0000000E4ASIA0", # TODO: make this dynamic
          "OwnerId" => @user_id,
          "Editorial_Process_Close__c" => false,
          "Display_Technical_Notes__c" => false,
          "CreatedByDeltaMigration__c" => false,
          "Editorial_Status_Date__c" => Time.now,
          "Revision__c" => "0.0" # TODO: pull from paper
        }
      end
    end

    class BillingTranslator
      def initialize(paper:)
        @paper = paper
      end

      def paper_to_billing_hash # (pfa)
        #TODO: find out what to send
        {
          'SuppliedEmail'              => @paper.creator.email, # ?
          #'RecordTypeId'               => nil, # default, set by SF
          'Exclude_from_EM__c'         => true,
          'Journal_Department__c'      => @paper.journal.name,
          'Subject'                    => manuscript_id, # subject of email
          'Description'                => "#{@paper.creator.full_name} has applied for PFA with submission #{manuscript_id}",
          'Origin'                     => "PFA Request", # dropdown in SF
          'PFA_Funding_Statement__c'   => nil,
          'PFA_Question_2__c'          => nil,
          'PFA_Question_2a__c'         => nil,
          'PFA_Question_2b__c'         => nil,
          'PFA_Question_1__c'          => nil,
          'PFA_Question_1a__c'         => nil,
          'PFA_Question_1b__c'         => nil,
          'PFA_Question_3__c'          => nil,
          'PFA_Question_3a__c'         => nil,
          'PFA_Question_4__c'          => nil,
          'PFA_Question_4a__c'         => nil,
          #no existe
          #'PFA_Amount_to_Pay__c'       => nil,
          'PFA_Able_to_Pay_R__c'       => nil,
          'PFA_Supporting_Docs__c'     => nil,
          'PFA_Additional_Comments__c' => nil,
        }
      end
      
      def manuscript_id
        # will be the doi, and there is a story for that "DOIs should be assigned to all Papers in Aperta"
        # manuscript ID = PONE-D-14-18244
        "prefix-#{@paper.id}"
        # PLOS ONE                         - PONE
        # PLOS Yeti                        - 
        # PLOS Pathogens                   - PPAT
        # PLOS Genetics                    - PGEN
        # PLOS Biology                     - PBIO
        # PLOS Medicine                    - PMED
        # PLOS Computational Biology       - PCBI
        # PLOS Neglected Tropical Diseases - PNTD
      end
    end

  end

end
