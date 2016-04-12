require 'rails_helper'
require 'erb'

describe 'Inlining CSS into emails', type: :mailer do
  class FakeMailer < ActionMailer::Base
    default from: Rails.configuration.from_email
    layout 'mailer'

    # stub_template is a useful method available in views, but not mailers.
    def stub_template(hsh)
      view_paths.unshift(ActionView::FixtureResolver.new(hsh))
    end

    def send_fake_email
      stub_template 'fake_mailer/send_fake_email.erb' => '<div class=".mailer">test</div>'
      mail(to: 'noone@example.com', subject: 'fake mail')
    end
  end

  describe 'premailer-rails' do
    let(:email) { FakeMailer.send_fake_email }

    # temporary storage for precompiling assets in this test
    let(:test_assets_path) { Rails.root.join('tmp/test-assets') }

    before(:each) do
      # The assets pipeline is nil when Rails.application.assets.config
      # is set to false when Rails boots up. However, if we set it to false
      # now it doesn't do anything. To not affect the entire test environment
      # we will explicitly
      @rails_assets = Rails.application.assets
      @rails_asset_compile = Rails.application.config.assets.compile
      @rails_asset_digest = Rails.application.config.assets.digest
      @rails_asset_js_compressor = Rails.application.config.assets.js_compressor

      Rails.application.assets = nil
      Rails.application.config.assets.compile = false
      Rails.application.config.assets.digest = true
      Rails.application.config.assets.paths << test_assets_path

      precompile_mailer_css
    end

    after(:each) do
      # Restore original Rails settings
      Rails.application.config.assets.digest = @rails_asset_digest
      Rails.application.config.assets.compile = @rails_asset_compile
      Rails.application.assets = @rails_assets

      # Clean up our files
      FileUtils.rm_rf(test_assets_path)
    end

    def precompile_mailer_css
      environment = Sprockets::Environment.new
      environment.append_path(Rails.root.join('app/assets/stylesheets'))

      manifest = Sprockets::Manifest.new(environment.index, test_assets_path)
      manifest.compile("#{DEFAULT_MAILER_STYLESHEET}.css")
    end

    it 'inlines css' do
      delivered_email = email.deliver_now
      body = Nokogiri::HTML(delivered_email.html_part.body.to_s)
      element = body.search('.mailer[style*="width: 600px"]')
      expect(element).to be
    end
  end
end
