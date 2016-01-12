require 'rails_helper'

describe CurrentUserSerializer do
  subject(:serializer){ described_class.new(user) }
  let(:user) { FactoryGirl.build(:user) }

  describe '#permissions' do
    it 'sideloads permissions for the current user' do
      permissions_table = [{
        object: { id: 1, type: 'User'},
        permissions:{
          view_profile:{
            states: ['*']
          }
        }
      }]

      allow(user).to receive(:filter_authorized)
        .with(:view_profile, user)
        .and_return(permissions_table)

      expect(serializer.as_json[:permissions]).to eq([{
        id: 1,
        table: permissions_table
      }].as_json)
    end
  end
end
