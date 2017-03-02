require 'rails_helper'

shared_examples 'a redirecting paper converter' do
  subject { converter }
  it { is_expected.to be_a_kind_of PaperConverters::RedirectingPaperConverter }

  describe '#download_url' do
    subject { converter.download_url }
    it { is_expected.to be_a_valid_url }
  end
end
