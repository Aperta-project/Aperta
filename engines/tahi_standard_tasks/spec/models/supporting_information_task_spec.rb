require 'rails_helper'

module TahiStandardTasks
  describe SupportingInformationTask do
    it_behaves_like 'is a metadata task'

    describe '.restore_defaults' do
      it_behaves_like '<Task class>.restore_defaults update title to the default'
    end

    describe "#file_access_details" do
      let(:paper) { FactoryGirl.create(:paper, :with_tasks) }

      before :each do
        files = [double(:file, access_details: :hello)]
        paper = double(:paper, files: files)
        allow(supporting_information_task).to receive(:paper).and_return(paper)
      end

      let(:supporting_information_task) do
        ::TahiStandardTasks::SupportingInformationTask.create!(
          completed: true,
          paper: paper,
          phase: paper.phases.first,
          title_html: "Supporting Info"
        )
      end

      it "returns a JSON object of access details from figures" do
        expect(supporting_information_task.file_access_details).to eq [:hello]
      end
    end
  end
end
