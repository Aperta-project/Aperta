require 'rails_helper'

describe SerializeIdsWithPolymorphism do
  describe ".call" do
    let(:task) { [double(type: task_type, class: double(name: task_type), id: "234")] }
    let(:result) { SerializeIdsWithPolymorphism.call task }

    context "when there is no prefix" do
      let(:task_type) { "UploadManuscriptTask" }

      it "returns the task name" do
        expect(result).to eq [{ id: task[0].id, type: task_type }]
      end
    end

    context "when the prefix is a task bundle" do
      let(:task_type) { "TahiStandardTasks::FigureTask" }

      it "returns the last part of the task type" do
        expect(result).to eq([{ id: task[0].id, type: "FigureTask" }])
      end
    end

    context "when the task type is not qualified" do
      let(:task_type) { "Funky::Crazy::blah" }

      it "raises if task type is not qualified" do
        expect{ result }.to raise_error
      end
    end
  end
end
