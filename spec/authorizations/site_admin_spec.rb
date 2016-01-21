require 'rails_helper'

describe 'For the time being, site admins should have ALL permissions.' do
  include AuthorizationSpecHelper

  let!(:admin) { FactoryGirl.create(:user, site_admin: true) }

  let!(:paper) { Authorizations::FakePaper.create! }
  let!(:paper2) { Authorizations::FakePaper.create! }
  let!(:paper3) { Authorizations::FakePaper.create! }
  let!(:paper4) { Authorizations::FakePaper.create! }

  before(:all) do
    Authorizations.reset_configuration
    AuthorizationModelsSpecHelper.create_db_tables
  end

  context 'if the user is a site admin' do
    describe 'they can?' do
      it 'do anything' do
        expect(admin.can?(:view, paper)).to eq(true)
      end
    end

    describe 'filter_authorized' do
      it 'should return its inputs for a single instance' do
        expect(admin.filter_authorized(:view, paper).objects).to include(paper)
      end

      it 'should return all instances when a class is passed in' do
        expect(admin.filter_authorized(:view, Authorizations::FakePaper)
                .objects).to eq(Authorizations::FakePaper.all)
      end

      it 'should return the same instances when a relation is passed in' do
        expect(admin.filter_authorized(:view, Authorizations::FakePaper.all)
                .objects).to eq(Authorizations::FakePaper.all)
        expect(
          admin.filter_authorized(
            :view, Authorizations::FakePaper.where(id: [paper2.id, paper3.id]))
                .objects).to match([paper2, paper3])
      end
    end
  end
end
