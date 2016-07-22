require 'rails_helper'

RSpec.shared_examples 'a thing with major and minor versions' do |name|
  let(:paper) { FactoryGirl.create(:paper) }

  before do
    @things = name.to_s.pluralize.to_sym
  end

  let!(:version_0_0) do
    FactoryGirl.create(
      name.to_sym,
      paper: paper,
      major_version: 0,
      minor_version: 0)
  end

  let!(:version_0_1) do
    FactoryGirl.create(
      name.to_sym,
      paper: paper,
      major_version: 0,
      minor_version: 1)
  end

  let!(:version_0_2) do
    FactoryGirl.create(
      name.to_sym,
      paper: paper,
      major_version: 0,
      minor_version: 2)
  end

  let!(:version_1_0) do
    FactoryGirl.create(
      name.to_sym,
      paper: paper,
      major_version: 1,
      minor_version: 0)
  end

  let!(:draft) do
    paper.send(@things).drafts.first || FactoryGirl.create(
      name.to_sym,
      paper: paper,
      minor_version: nil,
      major_version: nil)
  end

  let(:versions) { paper.send(@things) }

  describe '#version_desc' do
    it 'should return the versioned things in descending version order' do
      expect(versions.completed.version_desc.to_a)
        .to eq([version_1_0, version_0_2, version_0_1, version_0_0])
    end

    it 'should return an unversioned thing first' do
      expect(versions.version_desc.first.major_version).to be(nil)
      expect(versions.version_desc.first.minor_version).to be(nil)
    end
  end

  describe '#version_asc' do
    it 'should return the versioned things in ascending version order' do
      expect(versions.completed.version_asc.to_a)
        .to eq([version_0_0, version_0_1, version_0_2, version_1_0])
    end

    it 'should return an unversioned thing last' do
      expect(versions.version_asc.last.major_version).to be(nil)
      expect(versions.version_asc.last.minor_version).to be(nil)
    end
  end

  describe 'creating a draft' do
    let(:first_version) { versions.first }

    it 'fails if a draft already exists' do
      expect(versions.drafts.count).to eq 1
      expect(first_version).to be_present
      expect { versions.create! }
        .to raise_exception(ActiveRecord::RecordInvalid)
    end
  end
end
