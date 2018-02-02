require 'rails_helper'

describe TaxonTask do
  it_behaves_like 'is a metadata task'

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
  end
end
