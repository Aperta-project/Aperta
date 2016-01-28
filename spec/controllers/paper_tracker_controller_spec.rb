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

    context 'when search query (simple) is sent in params' do
      it 'properly detects when its meant as a title,
          returns nothing when no match' do
        make_matchable_paper title: 'no can find'
        get :index, format: :json, query: 'please find'
        json = JSON.parse(response.body)
        expect(Paper.count).to eq 1
        expect(json['papers'].count).to eq 0
      end

      it 'properly detects when its meant as a title,
          returns good match' do
        make_matchable_paper title: 'tin roof blues'
        get :index, format: :json, query: 'tin roof blues' # not fuzzy
        json = JSON.parse(response.body)
        expect(Paper.count).to eq 1
        expect(json['papers'].count).to eq 1
        expect(json['papers'].first['title']).to eq 'tin roof blues'
      end

      it 'allows title text to be fuzzy' do
        make_matchable_paper title: 'making friends'
        get :index, format: :json, query: 'friend make' # fuzzy
        json = JSON.parse(response.body)
        expect(Paper.count).to eq 1
        expect(json['papers'].count).to eq 1
        expect(json['papers'].first['title']).to eq 'making friends'
      end

      it 'properly detects when its meant as a DOI,
          returns nothing when no match' do
        make_matchable_paper(title: 'title 123', doi: '456')
        get :index, format: :json, query: '123'
        json = JSON.parse(response.body)
        expect(Paper.count).to eq 1
        expect(json['papers'].count).to eq 0
      end

      it 'properly detects when its meant as a DOI, results are good' do
        make_matchable_paper(title: 'title 123', doi: '456')
        get :index, format: :json, query: '456'
        json = JSON.parse(response.body)
        expect(Paper.count).to eq 1
        expect(json['papers'].count).to eq 1
        expect(json['papers'].first['manuscript_id']).to eq '456'
      end

      it 'respects pagination when there are more matches than per_page' do
        (per_page + 1).times { make_matchable_paper(title: 'foo') }
        get :index, format: :json, query: 'foo'
        json = JSON.parse(response.body)
        expect(Paper.count).to eq(per_page + 1)
        expect(json['papers'].count).to eq per_page
      end
    end

    context 'when order param is sent with request' do
      it 'orders the results via orderBy' do
        make_matchable_paper(title: 'aaa foo')
        make_matchable_paper(title: 'bbb foo')
        make_matchable_paper(title: 'aaa foo')
        get :index, format: :json, query: 'foo', orderBy: :title
        json = JSON.parse(response.body)
        expect(Paper.count).to eq(3)
        expect(json['papers'][0]['title']).to eq('aaa foo')
        expect(json['papers'][1]['title']).to eq('aaa foo')
        expect(json['papers'][2]['title']).to eq('bbb foo')
      end

      it 'orders the results by orderDir when sent' do
        make_matchable_paper(title: 'aaa foo')
        make_matchable_paper(title: 'bbb foo')
        make_matchable_paper(title: 'aaa foo')
        get :index,
            format: :json,
            query: 'foo',
            orderBy: :title,
            orderDir: :desc
        json = JSON.parse(response.body)
        expect(Paper.count).to eq(3)
        expect(json['papers'][0]['title']).to eq('bbb foo')
        expect(json['papers'][1]['title']).to eq('aaa foo')
        expect(json['papers'][2]['title']).to eq('aaa foo')
      end
    end
  end

  def make_matchable_paper(attrs={})
    paper = FactoryGirl.create(:paper, :submitted, attrs)
    assign_journal_role(paper.journal, user, :admin)
    paper
  end
end
