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
  end
end
