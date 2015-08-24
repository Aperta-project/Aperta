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

      def paper_to_billing_hash
        #TODO: find out what to send
        {
          'RecordTypeId'               => nil,
          'Exclude_from_EM__c'         => nil,
          'Journal_Department__c'      => nil,
          'Subject'                    => nil,
          'Description'                => nil,
          'Origin'                     => nil,
          'SuppliedEmail'              => nil,
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
    end
  end

end
