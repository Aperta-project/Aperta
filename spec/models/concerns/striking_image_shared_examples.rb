require 'rails_helper'

RSpec.shared_examples 'a striking image' do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:instance) { described_class.new }
  let(:another_instance) { described_class.new }
  before(:each) do
    instance.owner = paper
    instance.save
  end

  describe '#striking_image' do
    it "returns false if the instance is not the paper's striking image" do
      expect(instance.striking_image).to be(false)
    end

    it "returns true if the instance is the paper's striking image" do
      paper.striking_image = instance
      expect(instance.striking_image).to be(true)
    end
  end

  describe '#striking_image=' do
    it "sets the paper's striking image if it receives true" do
      instance.striking_image = true
      expect(paper.striking_image).to be(instance)
    end

    it "unsests the paper's striking image if it receives false\
       *and* the instance is the current striking image." do
      paper.striking_image = instance
      instance.striking_image = false
      expect(paper.striking_image).to be(nil)
    end

    it "doesn't change the paper's striking image if it receives false\
       and the instance is *not* the current striking image." do
      paper.striking_image = another_instance
      instance.striking_image = false
      expect(paper.striking_image).to be(another_instance)
    end
  end
end
