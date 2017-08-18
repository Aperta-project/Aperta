require 'rails_helper'

describe Readyable do
  let(:create_fake_readyables_table) do
    silence_stream($stdout) do
      ActiveRecord::Schema.define do
        create_table :fake_readyables, force: true do |t|
          t.string :value
        end
      end
    end
  end

  let(:klass) do
    create_fake_readyables_table
    Class.new(ApplicationRecord) do
      include Readyable
      self.table_name = 'fake_readyables'
    end
  end

  let(:ready_obj) do
    klass.new
  end

  describe 'an including class' do
    it "doesn't have ready and ready_issues properties by default" do
      expect(ready_obj.ready).to be_falsey
      expect(ready_obj.ready_issues).to be_falsey
    end

    it "can be initialized for ready properties" do
      ready_obj.ready_init
      expect(ready_obj.ready).to be_truthy
      expect(ready_obj.ready_issues).to be_truthy
    end
  end
end
