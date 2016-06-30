require 'rails_helper'

describe Snapshot::SupportingInformationTaskSerializer do
  subject(:serializer) { described_class.new(task) }
  let!(:paper) { FactoryGirl.create(:paper) }
  let!(:task) { FactoryGirl.create(:supporting_information_task, paper: paper) }
  let!(:si_file_1) do
    FactoryGirl.create(
      :supporting_information_file,
      :with_resource_token,
      caption: 'supporting info 1 caption',
      owner: task,
      paper: paper,
      title: 'supporting info 1 title',
    ).tap do |si_file|
      si_file.update_column :file, 'yeti-1.jpg'
    end
  end
  let!(:si_file_2) do
    FactoryGirl.create(
      :supporting_information_file,
      :with_resource_token,
      caption: 'supporting info 2 caption',
      owner: task,
      paper: paper,
      title: 'supporting info 2 title',
    ).tap do |si_file|
      si_file.update_column :file, 'yeti-2.jpg'
    end
  end

  describe '#as_json' do
    let(:si_files_json) do
      serializer.as_json[:children].select do |child_json|
        child_json[:name] == 'supporting-information-file'
      end
    end

    it 'serializes to JSON' do
      expect(serializer.as_json).to include(
        name: 'supporting-information-task',
        type: 'properties'
      )
    end

    it "serializes the supporting information files for the task's paper" do
      expect(si_files_json.length).to be 2

      expect(si_files_json[0]).to match hash_including(
        name: 'supporting-information-file',
        type: 'properties'
      )

      expect(si_files_json[0][:children]).to include(
        { name: 'id', type: 'integer', value: si_file_1.id },
        { name: 'file', type: 'text', value: si_file_1.filename },
        { name: 'file_hash', type: 'text', value: si_file_1.file_hash },
        { name: 'title', type: 'text', value: si_file_1.title },
        { name: 'caption', type: 'text', value: si_file_1.caption },
        { name: 'publishable', type: 'boolean', value: si_file_1.publishable },
        { name: 'striking_image', type: 'boolean', value: si_file_1.striking_image },
        { name: 'url', type: 'url', value: si_file_1.non_expiring_proxy_url }
      )

      expect(si_files_json[1]).to match hash_including(
        name: 'supporting-information-file',
        type: 'properties'
      )
      expect(si_files_json[1][:children]).to include(
        { name: 'id', type: 'integer', value: si_file_2.id },
        { name: 'file', type: 'text', value: si_file_2.filename },
        { name: 'file_hash', type: 'text', value: si_file_2.file_hash },
        { name: 'title', type: 'text', value: si_file_2.title },
        { name: 'caption', type: 'text', value: si_file_2.caption },
        { name: 'publishable', type: 'boolean', value: si_file_2.publishable },
        { name: 'striking_image', type: 'boolean', value: si_file_2.striking_image },
        { name: 'url', type: 'url', value: si_file_2.non_expiring_proxy_url }
      )
    end

    context 'serializing related nested questions' do
      include_examples 'snapshot serializes related nested questions', resource: :task
    end
  end
end
