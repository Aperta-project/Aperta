require 'rails_helper'

describe TahiStandardTasks::PublishingRelatedQuestionsTask do
  it_behaves_like 'is a metadata task'

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
    it_behaves_like '<Task class>.restore_defaults update old_role to the default'
  end
end
