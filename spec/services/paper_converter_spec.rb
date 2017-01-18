# TODO: Create a valid PaperConverter test. The export method has been removed,
# which was used for creating a doc file from an HTML extract of a prior upload,
# which isn't a valid use case.
#
# require 'rails_helper'
#
# describe PaperConverter do
#   let(:paper) { FactoryGirl.create(:paper, :with_creator) }
#   let(:user) { FactoryGirl.create(:user) }
#
#   describe ".export" do
#     it "returns job_id" do
#       VCR.use_cassette('convert_to_docx', record: :once) do
#         response = described_class.export(paper, 'docx', user)
#         expect(response.job_id).to eq 'd5ee706f-a473-46ed-9777-3b7cd2905d08'
#       end
#     end
#   end
# end
