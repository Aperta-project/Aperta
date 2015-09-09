require 'rails_helper'

describe ManuscriptManagerTemplate do

  describe "validations" do

    it 'must have a paper type' do
      template = ManuscriptManagerTemplate.new paper_type: nil
      expect(template.valid?).to eq false
      expect(template.errors[:paper_type]).to eq(["can't be blank"])
    end

    it 'paper type must be unique per journal' do
      mmt = FactoryGirl.create(:manuscript_manager_template, paper_type: "TEST")

      template = ManuscriptManagerTemplate.create(paper_type: "test",
                                                  journal: mmt.journal)
      expect(template.valid?).to eq false
      expect(template.errors[:paper_type]).to eq(["has already been taken"])
    end
  end
end
