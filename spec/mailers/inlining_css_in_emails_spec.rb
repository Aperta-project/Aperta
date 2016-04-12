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

    it 'inlines css' do
      expect(email.body).to match(/<div class='.mailer' css='width: 600px;'>/)
    end
  end
end
