require 'rails_helper'
require 'generator_spec'
require 'generators/tahi/plugin/plugin_generator'

describe Tahi::PluginGenerator, type: :generator do
  root_dir = Pathname.new(__FILE__).join('..', '..', 'tmp')
  engine_dir = root_dir.join('engines', 'foo')

  destination root_dir.to_s

  [['tahi-foo'], ['tahi-foo', engine_dir.to_s]].each do |args|
    arguments args

    before(:all) do
      prepare_destination
      run_generator
    end

    it 'creates a client path' do
      expect(engine_dir.join('client').directory?).to be(true)
    end

    it 'creates a client/package.json' do
      package_path = engine_dir.join('client', 'package.json')
      package_json = JSON.parse(File.read(package_path))
      expect(package_path.exist?).to be(true)
      expect(package_json['name']).to eq('tahi-foo')
      expect(package_json['keywords']).to eq(['ember-addon'])
    end

    pending 'works with namespaced plugins' do
      expect(engine_dir.join('app', 'controllers', 'tahi', 'application.rb').exist?).to be(true)
    end
  end
end
