require 'rails_helper'

shared_examples 'a synchronous paper converter' do
  subject { converter }
  it { is_expected.to be_a_kind_of PaperConverters::SynchronousPaperConverter }

  describe '#output_filename' do
    subject { converter.output_filename }
    it { is_expected.to be_present }
  end

  describe "#output_filetype" do
    subject { converter.output_filetype }
    it { is_expected.to be_present }
  end
end
