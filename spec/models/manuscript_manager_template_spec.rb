require 'rails_helper'

describe ManuscriptManagerTemplate do

  describe "validations" do
    it 'must have a paper type' do
      new_template = ManuscriptManagerTemplate.new paper_type: nil
      expect(new_template).to_not be_valid
      expect(new_template).to have(1).errors_on(:paper_type)
    end

  end

end
