require 'rails_helper'

describe TahiStandardTasks::UploadManuscriptTask do
  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
    it_behaves_like '<Task class>.restore_defaults update old_role to the default'
  end
end
