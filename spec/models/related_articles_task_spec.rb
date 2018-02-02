require 'rails_helper'

describe RelatedArticlesTask do
  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
  end
end
