require "rails_helper"

describe TokenCoAuthorsController do
  let! (:setting_template) do
    FactoryGirl.create(:setting_template,
     key: "Journal",
     setting_name: "coauthor_confirmation_enabled",
     value_type: 'boolean',
     boolean_value: true)
  end

  context 'author' do
    let(:author) { FactoryGirl.create(:author) }

    context "and coauthor_confirmation is disabled" do
      subject(:do_request) { get :show, token: author.token }

      it "renders a 404" do
        author.paper.journal.setting("coauthor_confirmation_enabled").update!(value: false)
        do_request
        expect(response.status).to eq(404)
      end
    end

    context "and coauthor_confirmation is enabled" do
      describe 'GET /co_authors_token/:token' do
        subject(:do_request) { get :show, token: author.token }
        it "renders the show template" do
          do_request
          expect(response).to render_template("token_co_authors/show")
        end

        context "author previously confirmed" do
          let!(:author) { FactoryGirl.create(:author, co_author_state: 'confirmed') }
          it "renders :thank_you" do
            do_request
            expect(response).to render_template("token_co_authors/thank_you")
          end
        end
      end

      describe "PUT /co_authors_token/:token/confirm" do
        subject(:do_request) { put :confirm, token: author.token }
        it "confirms the author as a co author" do
          expect { do_request }.to change {
            author.reload
            author.co_author_confirmed?
          }
        end

        it "creates an activity feed item" do
          expect(Activity).to receive(:co_author_confirmed!).with(author, user: nil)
          do_request
        end

        it "renders :thank_you" do
          do_request
          expect(response).to render_template("token_co_authors/thank_you")
        end

        context "author previously confirmed" do
          let!(:author) { FactoryGirl.create(:author, co_author_state: 'confirmed') }
          it "renders :thank_you" do
            do_request
            expect(response).to render_template("token_co_authors/thank_you")
          end
        end
      end
    end
  end

  context 'group_author' do
    let(:group_author) { FactoryGirl.create(:group_author) }

    context "and coauthor_confirmation is disabled" do
      subject(:do_request) { get :show, token: group_author.token }

      it "renders a 404" do
        group_author.paper.journal.setting("coauthor_confirmation_enabled").update!(value: false)
        do_request
        expect(response.status).to eq(404)
      end
    end

    context "and coauthor_confirmation is enabled" do
      describe 'GET /co_authors_token/:token' do
        subject(:do_request) { get :show, token: group_author.token }
        it "renders the show template" do
          do_request
          expect(response).to render_template("token_co_authors/show")
        end

        context "author previously confirmed" do
          let!(:group_author) { FactoryGirl.create(:group_author, co_author_state: 'confirmed') }
          it "renders :thank_you" do
            do_request
            expect(response).to render_template("token_co_authors/thank_you")
          end
        end
      end

      describe "PUT /co_authors_token/:token/confirm" do
        subject(:do_request) { put :confirm, token: group_author.token }
        it "confirms the group_author as a co author" do
          expect { do_request }.to change {
            group_author.reload
            group_author.co_author_confirmed?
          }
        end

        it "creates an activity feed item" do
          expect(Activity).to receive(:co_author_confirmed!).with(group_author, user: nil)
          do_request
        end

        it "renders :thank_you" do
          do_request
          expect(response).to render_template("token_co_authors/thank_you")
        end

        context "group author previously confirmed" do
          let!(:group_author) { FactoryGirl.create(:author, co_author_state: 'confirmed') }
          it "renders :thank_you" do
            do_request
            expect(response).to render_template("token_co_authors/thank_you")
          end
        end
      end
    end
  end
end
