require 'rails_helper'
require 'data_migration'

describe DataMigration, rake: true do
  let(:klass) { Class.new(DataMigration) }

  context 'when `RAKE_TASK_UP` is not defined' do
    it 'fails on up' do
      expect { klass.new.up }.to raise_exception(/did not define RAKE_TASK_UP/)
    end
  end

  context 'when `RAKE_TASK_DOWN` is not defined' do
    it 'noops' do
      expect(klass.new.down).to be(nil)
    end
  end

  context 'when `RAKE_TASK_UP` is defined' do
    let(:klass) { Class.new(DataMigration) }
    let(:task_name) { SecureRandom.hex(10) }

    before do
      klass::RAKE_TASK_UP = task_name
    end

    context 'but the task does not exist' do
      it 'noops' do
        expect(klass.new.up).to be(nil)
      end
    end

    context 'and the task exists' do
      let(:underlying_code) { double }
      before do
        Rake::Task.define_task(task_name) do
          underlying_code.call
        end
      end

      it 'should be called' do
        expect(underlying_code).to receive(:call)
        klass.new.up
      end
    end
  end

  context 'when `RAKE_TASK_DOWN` is defined' do
    let(:klass) { Class.new(DataMigration) }
    let(:task_name) { SecureRandom.hex(10) }

    before do
      klass::RAKE_TASK_DOWN = task_name
    end

    context 'but the task does not exist' do
      it 'noops' do
        expect(klass.new.down).to be(nil)
      end
    end

    context 'and the task exists' do
      let(:underlying_code) { double }
      before do
        Rake::Task.define_task(task_name) do
          underlying_code.call
        end
      end

      it 'should be called' do
        expect(underlying_code).to receive(:call)
        klass.new.down
      end
    end
  end
end
