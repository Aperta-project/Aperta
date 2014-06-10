require 'spec_helper'

describe DownloadAvatar do
  let(:user) { FactoryGirl.create(:user) }
  let(:url) { "https://tahi-development.s3.amazonaws.com/temp/500px-Jack_black.jpg" }

  it "downloads the attachment" do
    VCR.use_cassette('avatar') do
      DownloadAvatar.call(user, url)
      expect(user.avatar.file.filename).to eq("500px-Jack_black.jpg")
    end
  end
end
