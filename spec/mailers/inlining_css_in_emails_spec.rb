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
      stub_template "fake_mailer/send_fake_email.erb" => "<div class='.mailer'>test</div>"
      mail(to: 'noone@example.com', subject: 'fake mail')
    end
  end

  describe 'premailer-rails' do
    let(:email) { FakeMailer.send_fake_email }

    before(:each) do
      # The assets pipeline is nil when Rails.application.assets.config
      # is set to false when Rails boots up. However, if we set it to false
      # now it doesn't do anything. To not affect the entire test environment
      # we will explicitly
      @rails_assets = Rails.application.assets
      @rails_asset_compile = Rails.application.config.assets.compile
      Rails.application.assets = nil
      Rails.application.config.assets.compile = false
    end

    after(:each) do
      # Restore original Rails settings
      Rails.application.config.assets.compile = @rails_asset_compile
      Rails.application.assets = @rails_assets
    end

    it 'inlines css' do
      delivered_email = email.deliver_now
      expect(delivered_email.body).to match(/<div class='.mailer' css='width: 600px;'>/)
    end
  end
end
