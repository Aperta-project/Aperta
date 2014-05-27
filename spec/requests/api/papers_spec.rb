require 'spec_helper'

describe Api::PapersController do
  let!(:paper1) { FactoryGirl.create(:paper, :with_tasks,
                                     short_title: "paper-2",
                                     title: "First paper") }
  let(:author_group) { paper1.author_groups.first }
  let!(:author) { FactoryGirl.create(:author, author_group: author_group) }

  describe "GET 'index'" do
    let!(:paper2) { FactoryGirl.create(:paper, :with_tasks,
                                       short_title: "paper-1",
                                       title: "Second paper") }

    it "user can get a list of papers" do
      get api_papers_path
      expect(JSON.parse(response.body)).to eq(
        {"authors"=>
         [
           {"id"=> author.id,
           "first_name"=> author.first_name,
           "middle_initial"=> author.middle_initial,
           "last_name"=> author.last_name,
           "email"=> author.email,
           "affiliation"=>author.affiliation,
           "secondary_affiliation"=>author.secondary_affiliation,
           "title"=>author.title,
           "corresponding"=>author.corresponding,
           "deceased"=>author.deceased,
           "department"=>author.department,
           "author_group_id"=>author_group.id}
         ],
         "author_groups" =>
         [
           {"id"=>1, "name"=>"First Author", "author_ids"=>[1], "paper_id"=>1},
           {"id"=>2, "name"=>"Second Author", "author_ids"=>[], "paper_id"=>1},
           {"id"=>3, "name"=>"Third Author", "author_ids"=>[], "paper_id"=>1},
           {"id"=>4, "name"=>"First Author", "author_ids"=>[], "paper_id"=>2},
           {"id"=>5, "name"=>"Second Author", "author_ids"=>[], "paper_id"=>2},
           {"id"=>6, "name"=>"Third Author", "author_ids"=>[], "paper_id"=>2}
         ],
         "papers"=>
           [{"id"=>paper1.id,
             "title"=>paper1.title,
             "paper_type"=>paper1.paper_type,
             "epub"=>"http://www.example.com/api/papers/#{paper1.id}.epub",
             "author_group_ids"=>paper1.author_groups.pluck(:id)},
           {"id"=>paper2.id,
             "title"=>paper2.title,
             "paper_type"=>paper2.paper_type,
             "epub"=>"http://www.example.com/api/papers/#{paper2.id}.epub",
             "author_group_ids"=>paper2.author_groups.pluck(:id)}]
        })
    end

    context "when the published parameter is false" do
      it "user can get a list of non-published papers" do
        paper1.update_attribute('published_at', 2.days.ago)
        get api_papers_path(published: false)

        expect(JSON.parse(response.body)).to eq(
          {"authors"=>[],
           "author_groups" =>
           [
             {"id"=>4, "name"=>"First Author", "author_ids"=>[], "paper_id"=>2},
             {"id"=>5, "name"=>"Second Author", "author_ids"=>[], "paper_id"=>2},
             {"id"=>6, "name"=>"Third Author", "author_ids"=>[], "paper_id"=>2}
           ],
           "papers"=>
           [{"id"=>paper2.id,
             "title"=>paper2.title,
             "paper_type"=>paper2.paper_type,
             "epub"=>"http://www.example.com/api/papers/#{paper2.id}.epub",
             "author_group_ids"=>paper2.author_groups.pluck(:id)}]
          })
      end
    end

    context "when the published parameter is true" do
      it "user can get a list of non-published papers" do
        paper1.update_attribute('published_at', 2.days.ago)
        get api_papers_path(published: true)

        expect(JSON.parse(response.body)).to eq(
        {"authors"=>
         [
           {"id"=> author.id,
           "first_name"=> author.first_name,
           "middle_initial"=> author.middle_initial,
           "last_name"=> author.last_name,
           "email"=> author.email,
           "affiliation"=>author.affiliation,
           "secondary_affiliation"=>author.secondary_affiliation,
           "title"=>author.title,
           "corresponding"=>author.corresponding,
           "deceased"=>author.deceased,
           "department"=>author.department,
           "author_group_id"=>author_group.id}
         ],
         "author_groups" =>
         [
           {"id"=>1, "name"=>"First Author", "author_ids"=>[1], "paper_id"=>1},
           {"id"=>2, "name"=>"Second Author", "author_ids"=>[], "paper_id"=>1},
           {"id"=>3, "name"=>"Third Author", "author_ids"=>[], "paper_id"=>1}
         ],
         "papers"=>
           [{"id"=>paper1.id,
             "title"=>paper1.title,
             "paper_type"=>paper1.paper_type,
             "epub"=>"http://www.example.com/api/papers/#{paper1.id}.epub",
             "author_group_ids"=>paper1.author_groups.pluck(:id)},
           ]
        })
      end
    end
  end

  describe "GET 'show'" do
    it "user can get a single paper" do
      get api_paper_path(paper1.id)

      data = JSON.parse response.body
      expect(data['papers'].length).to eq 1
      expect(data).to eq(
        {"authors"=>
         [
           {"id"=> author.id,
           "first_name"=> author.first_name,
           "middle_initial"=> author.middle_initial,
           "last_name"=> author.last_name,
           "email"=> author.email,
           "affiliation"=>author.affiliation,
           "secondary_affiliation"=>author.secondary_affiliation,
           "title"=>author.title,
           "corresponding"=>author.corresponding,
           "deceased"=>author.deceased,
           "department"=>author.department,
           "author_group_id"=>author_group.id}
         ],
         "author_groups" =>
         [
           {"id"=>1, "name"=>"First Author", "author_ids"=>[1], "paper_id"=>1},
           {"id"=>2, "name"=>"Second Author", "author_ids"=>[], "paper_id"=>1},
           {"id"=>3, "name"=>"Third Author", "author_ids"=>[], "paper_id"=>1}
         ],
         "papers"=>
           [{"id"=>paper1.id,
             "title"=>paper1.title,
             "paper_type"=>paper1.paper_type,
             "epub"=>"http://www.example.com/api/papers/#{paper1.id}.epub",
             "author_group_ids"=>paper1.author_groups.pluck(:id)},
           ]
        })
    end
  end

  describe "PATCH 'published_at'" do
    context "whitelisted attribute" do
      it "updates the published_at attribute for a paper" do
        patch_params = %Q{[{ "op": "replace", "path": "/papers/0/publishedAt", "value": "2014-03-21" }]}
        patch api_paper_path(paper1.id), patch_params, { 'CONTENT_TYPE' => "application/json-patch+json",
                                                         'ACCEPT' => "application/vnd.api+json" }

        expect(response.body).to_not be_nil
        expect(response.status).to eq 204
        expect(paper1.reload.published_at).to eq("2014-03-21")
      end
    end

    context "non-whitelisted attribute" do
      it "does not update when attribute is not whitelisted for a paper" do
        patch_params = %Q{[{ "op": "replace", "path": "/papers/0/createdAt", "value": "2014-03-21" }]}
        patch api_paper_path(paper1.id), patch_params, { 'CONTENT_TYPE' => "application/json-patch+json",
                                                         'ACCEPT' => "application/vnd.api+json" }

        expect(response.status).to eq 401
        expect(paper1.reload.created_at).to_not eq "2014-03-21"
      end
    end
  end
end
