require 'tahi_plugin'
require 'ember_addons_installer'

module Rails; end

describe EmberAddonsInstaller do
  describe "#add_addons_from_gems" do

    context "when the package.json file is empty" do
      let(:package_file_path) { File.expand_path '../../fixtures/client/package_empty.json', __FILE__ }
      let!(:before_file_contents) { JSON.load File.open(package_file_path) }

      it "write gems that start with 'tahi-' to package.json" do

        allow(Rails).to receive(:root).and_return(File.expand_path('../../fixtures/', __FILE__))
        EmberAddonsInstaller.new(package_path: package_file_path).add_addons_from_gems

        after_file_contents = JSON.load File.open(package_file_path)

        expect(after_file_contents['ember-addon']['paths'].to_s).to match("engines/plos_billing/client")
        expect(after_file_contents['ember-addon']['paths'].to_s).to match("plos_bio/client")
      end

      after(:each) do
        File.open package_file_path, 'w' do |file|
          file << JSON.pretty_generate(before_file_contents)
        end
      end
    end

    context "when the package.json file is not empty" do
      let(:package_file_path) { File.expand_path '../../fixtures/client/package_with_tahi_gems.json', __FILE__ }
      let!(:before_file_contents) { JSON.load File.open(package_file_path) }

      it "removes all ember-addons that start with 'tahi-' before adding and keeps regular addons" do
        allow(Rails).to receive(:root).and_return(File.expand_path('../../fixtures/', __FILE__))

        # pretend that regular-ember-addon exists
        orig_directory = File.method(:directory?)
        allow(File).to receive(:directory?) do |dir|
          if dir.match(/regular-ember-addon/)
            true
          else
            orig_directory.call(dir)
          end
        end
        EmberAddonsInstaller.new(package_path: package_file_path).add_addons_from_gems

        after_file_contents = JSON.load File.open(package_file_path)

        expect(after_file_contents['ember-addon']['paths']).to include '../regular-ember-addon'
        expect(after_file_contents['ember-addon']['paths']).to_not include '../legacy-delete-me/tahi-plos-billing/client'
        expect(after_file_contents['ember-addon']['paths']).to_not include '../legacy-delete-me/tahi_upload_manuscript/client'
      end

      after(:each) do
        File.open package_file_path, 'w' do |file|
          file << JSON.pretty_generate(before_file_contents)
        end
      end
    end
  end
end
