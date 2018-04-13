# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'

describe UserSerializer, serializer_test: true do
  subject(:serializer) { described_class.new(user, scope: user, scope_name: :current_user) }
  let(:user) do
    FactoryGirl.build_stubbed(
      :user,
      id: 99,
      affiliations: [affiliation],
      first_name: "Kyoto",
      last_name: "Rainstorm",
      orcid_account: orcid_account,
      username: "kyoto.rainstorm"
    )
  end
  let(:affiliation) { FactoryGirl.build_stubbed(:affiliation) }
  let(:orcid_account) { FactoryGirl.build_stubbed(:orcid_account) }

  describe '#as_json' do
    around do |example|
      ClimateControl.modify(ORCID_CONNECT_ENABLED: 'true') do
        example.run
      end
    end
    let(:json) { serializer.as_json[:user] }

    it 'serializes to JSON' do
      expect(json).to match hash_including(
        id: user.id,
        affiliation_ids: [affiliation.id],
        avatar_url: user.avatar_url,
        first_name: user.first_name,
        full_name: user.full_name,
        last_name: user.last_name,
        orcid_account_id: orcid_account.id,
        username: user.username
      )
    end

    it 'sideloads the orcid account' do
      expect(serializer.as_json[:orcid_accounts][0][:id]).to eq(orcid_account.id)
    end

    context 'and ORCID_CONNECT_ENABLED is false' do
      around do |example|
        ClimateControl.modify(ORCID_CONNECT_ENABLED: 'false') do
          example.run
        end
      end

      it 'does not include #orcid_account_id' do
        expect(json).to_not have_key(:orcid_account_id)
      end
    end
  end
end
