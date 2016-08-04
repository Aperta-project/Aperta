require 'rails_helper'

describe Snapshot::FigureTaskSerializer do
  subject(:serializer) { described_class.new(task) }
  let(:task) { FactoryGirl.create(:figure_task, paper: paper) }
  let(:figure_1) do
    FactoryGirl.create(
      :figure,
      :with_resource_token,
      title: 'figure 1 title',
      caption: 'figure 1 caption',
    )
  end
  let(:figure_2) do
    FactoryGirl.create(
      :figure,
      :with_resource_token,
      title: 'figure 2 title',
      caption: 'figure 2 caption'
    )
  end

  let(:paper) { FactoryGirl.create(:paper, figures: [figure_1, figure_2]) }

  describe '#as_json' do
    let(:figures_json) do
      serializer.as_json[:children].select do |child_json|
        child_json[:name] == 'figure'
      end
    end

    it 'serializes to JSON' do
      expect(serializer.as_json).to include(
        name: 'figure-task',
        type: 'properties'
      )
    end

    it "serializes the figures for the task's paper" do
      expect(figures_json.length).to be 2

      expect(figures_json[0]).to match hash_including(
        name: 'figure',
        type: 'properties'
      )
      expect(figures_json[0][:children]).to include(
        { name: 'id', type: 'integer', value: figure_1.id },
        { name: 'file', type: 'text', value: figure_1.filename },
        { name: 'file_hash', type: 'text', value: figure_1.file_hash },
        { name: 'title', type: 'text', value: figure_1.title },
        { name: 'striking_image', type: 'boolean', value: figure_1.striking_image },
        { name: 'url', type: 'url', value: figure_1.non_expiring_proxy_url }
      )

      expect(figures_json[1]).to match hash_including(
        name: 'figure',
        type: 'properties'
      )
      expect(figures_json[1][:children]).to include(
        { name: 'id', type: 'integer', value: figure_2.id },
        { name: 'file', type: 'text', value: figure_2.filename },
        { name: 'file_hash', type: 'text', value: figure_2.file_hash },
        { name: 'title', type: 'text', value: figure_2.title },
        { name: 'striking_image', type: 'boolean', value: figure_2.striking_image },
        { name: 'url', type: 'url', value: figure_2.non_expiring_proxy_url }
      )
    end

    context 'serializing related nested questions' do
      it_behaves_like 'snapshot serializes related nested questions', resource: :task
    end
  end
end
