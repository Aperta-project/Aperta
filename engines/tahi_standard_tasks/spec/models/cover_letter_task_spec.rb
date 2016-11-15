require 'rails_helper'

describe TahiStandardTasks::CoverLetterTask do
  it_behaves_like 'is snapshottable'

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
  end
end
