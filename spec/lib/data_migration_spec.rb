require 'rails_helper'
require 'data_migration'

describe DataMigration, rake: true do
  let(:klass) { Class.new(DataMigration) }

  it 'should fail on down' do
    expect { klass.new.down }.to raise_exception(ActiveRecord::IrreversibleMigration)
  end

  context 'when `RAKE_TASK` is not defined' do
    it 'should fail on up' do
      expect { klass.new.up }.to raise_exception(/did not define RAKE_TASK/)
    end
  end

  context 'when `RAKE_TASK` is defined' do
    let(:klass) { Class.new(DataMigration) }

    before do
      klass::RAKE_TASK = 'my-rake-task'
    end

    context 'but the task does not exist' do
      it 'should return nil' do
        expect(klass.new.up).to be(nil)
      end
    end

    context 'and the task exists' do
      let(:underlying_code) { double }
      before do
        Rake::Task.define_task('my-rake-task') do
          underlying_code.call
        end
      end

      it 'should be called' do
        expect(underlying_code).to receive(:call)
        klass.new.up
      end
    end
  end
end
