require 'rails_helper'

describe TahiStandardTasks::DataAvailabilityTask do
  describe '.restore_defaults' do
    include_examples '<Task class>.restore_defaults update title to the default'
    include_examples '<Task class>.restore_defaults update old_role to the default'
  end
end
