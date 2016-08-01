require 'rails_helper'

describe Snapshottable do
  let(:create_fake_snapshottables_table) do
    silence_stream($stdout) do
      ActiveRecord::Schema.define do
        create_table :fake_snapshottables, force: true do |t|
          t.string :name
        end
      end
    end
  end

  let(:klass) do
    create_fake_snapshottables_table
    Class.new(ActiveRecord::Base) do
      include Snapshottable
      self.table_name = 'fake_snapshottables'
    end
  end

  describe 'an including class' do
    it 'is not snapshottable by default' do
      expect(klass.snapshottable).to be(false)
    end

    it 'can be snapshottable affecting its instances relying on defaults' do
      instance_relying_on_defaults = klass.new
      instance_with_its_own_opinion = klass.new
      instance_with_its_own_opinion.snapshottable = true

      klass.snapshottable = true
      expect(instance_relying_on_defaults.snapshottable).to be(true)
      expect(instance_with_its_own_opinion.snapshottable).to be(true)

      klass.snapshottable = false
      expect(instance_relying_on_defaults.snapshottable).to be(false)
      expect(instance_with_its_own_opinion.snapshottable).to be(true)
    end
  end

  describe 'an instance' do
    let(:instance){ klass.new }

    it 'is not snapshottable by default' do
      expect(instance.snapshottable).to be(false)
    end

    it 'can be made snapshottable without affecting the class-level snapshotability' do
      instance.snapshottable = true
      expect(instance.snapshottable).to be(true)
      expect(klass.snapshottable).to be(false)
    end
  end
end
