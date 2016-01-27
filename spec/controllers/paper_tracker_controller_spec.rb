require 'rails_helper'

describe PaperTrackerController do
  let(:user) { FactoryGirl.create :user, site_admin: true }
  let(:per_page) { Kaminari.config.default_per_page }

  before { sign_in user }

  describe 'let(per_page)' do
    it 'is available and useful' do
      expect(per_page).to be_truthy
      expect(per_page.instance_of?(Fixnum)).to eq(true)
    end
  end

  describe 'on GET #index' do
    it 'list the paper in journal that user belongs to' do
      paper = make_matchable_paper
      get :index, format: :json
      json = JSON.parse(response.body)
      expect(json['papers'].size).to eq 1
      expect(json['papers'][0]['title']).to eq paper.title
    end

    it 'do not list the paper if is not submitted' do
      paper = FactoryGirl.create(:paper)
      assign_journal_role(paper.journal, user, :admin)
      get :index, format: :json
      json = JSON.parse(response.body)
      expect(json['papers'].size).to eq 0
    end

    it 'do not list the paper where user do not have a old_role' do
      FactoryGirl.create(:paper, :submitted)
      get :index, format: :json
      json = JSON.parse(response.body)
      expect(json['papers'].size).to eq 0
    end

    context 'meta data' do
      it 'returns meta data about the results' do
        get :index, format: :json
        json = JSON.parse(response.body)
        expect(json['meta']).to be_truthy
        expect(json['meta']['page']).to be_truthy
        expect(json['meta']['totalCount']).to be_truthy
        expect(json['meta']['perPage']).to be_truthy
      end

      it 'meta[page] is 1 when not sent in params' do
        get :index, format: :json
        json = JSON.parse(response.body)
        expect(json['meta']['page']).to eq(1)
      end

      it 'meta[page] is eq to param[page]' do
        get :index, format: :json, page: 7
        json = JSON.parse(response.body)
        expect(json['meta']['page']).to eq(7)
      end

      it 'returns per_page info needed for client pagination' do
        get :index, format: :json
        json = JSON.parse(response.body)
        expect(json['meta']['perPage']).to eq(per_page)
        # note: param-based per page not yet implemented
        # so we use default kaminari config
      end

      context 'when num matching papers is less than default per page' do
        it 'paper numbers and totalPages are the same and correct ' do
          count = per_page - 1
          count.times { make_matchable_paper }
          get :index, format: :json
          json = JSON.parse(response.body)
          expect(json['papers'].count).to eq(count)
          expect(json['meta']['totalCount']).to eq(count)
        end
      end

      context 'when num matching papers is more than default per page' do
        it 'returns the per page num of papers, totalCount matches total' do
          count = per_page + 1
          count.times { make_matchable_paper }
          get :index, format: :json
          json = JSON.parse(response.body)
          expect(json['papers'].count).to eq(per_page)
          expect(json['meta']['totalCount']).to eq(count)
        end
      end
    end
  end

  def make_matchable_paper
    paper = FactoryGirl.create(:paper, :submitted)
    assign_journal_role(paper.journal, user, :admin)
    paper
  end
end
