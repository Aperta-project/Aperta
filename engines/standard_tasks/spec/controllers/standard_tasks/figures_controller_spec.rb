require 'spec_helper'

module StandardTasks
  describe FiguresController do
    routes { StandardTasks::Engine.routes }
    let(:user) { create :user }
    let(:paper) do
      FactoryGirl.create(:paper, :with_tasks, user: user)
    end
    let(:task) do
      FactoryGirl.create(:task, phase: paper.phases.first, type: "StandardTasks::FigureTask")
      StandardTasks::FigureTask.first
    end

    before { sign_in user }

    describe "destroying the figure" do
      subject(:do_request) { delete :destroy, id: task.figures.last.id, task_id: task.id }
      before(:each) do
        task.figures.create! attachment: fixture_file_upload('yeti.tiff', 'image/tiff')
      end

      it "destroys the figure record" do
        expect {
          do_request
        }.to change{StandardTasks::Figure.count}.by -1
      end
    end

    describe "Unauthorized Request" do
      let(:paper) do
        FactoryGirl.create(:paper, :with_tasks)
      end

      subject(:do_request) do
        post :create, task_id: task.to_param, format: :json, figure: { attachment: fixture_file_upload('yeti.tiff', 'image/tiff') }
      end

      it "will not allow access" do
        do_request
        expect(response.status).to eq(403)
      end
    end

    describe "POST 'create'" do
      subject(:do_request) do
        post :create, task_id: task.to_param, format: :json, figure: { attachment: fixture_file_upload('yeti.tiff', "image/tiff") }
      end

      it_behaves_like "an unauthenticated json request"

      it "saves the attachment to this paper" do
        expect { do_request }.to change(StandardTasks::Figure, :count).by(1)
        expect(StandardTasks::Figure.last.task_id).to eq task.id
      end

      context "validating the filetype" do
        it "rejects bad filetypes" do
          expect {
            post :create, task_id: task.to_param, format: :json, figure: { attachment: fixture_file_upload('about_turtles.docx') }
          }.to change{StandardTasks::Figure.count}.by 0
        end
      end

      context "when the attachments are in an array" do
        subject(:do_request) do
          post :create, task_id: task.to_param, format: :json, figure: { attachment: [fixture_file_upload('yeti.tiff', 'image/tiff'), fixture_file_upload('yeti.jpg', 'image/jpg')] }
        end

        it "saves each attachment to this task" do
          expect { do_request }.to change(StandardTasks::Figure, :count).by(2)
          expect(StandardTasks::Figure.last.task_id).to eq task.id
        end
      end

      context "when it's an AJAX request" do
        subject(:do_request) do
          post :create, task_id: task.to_param, figure: { attachment: fixture_file_upload('yeti.tiff', 'image/tiff') }, format: :json
        end

        it "responds with a JSON array of figure data" do
          do_request
          figure = StandardTasks::Figure.last
          expect(JSON.parse(response.body)).to eq(
            {
              figures: [
                { id: figure.id,
                  filename: "yeti.tiff",
                  alt: "Yeti",
                  src: "/uploads/paper/1/standard_tasks/figure/attachment/1/yeti.tiff",
                  preview_src: "/uploads/paper/1/standard_tasks/figure/attachment/1/preview_yeti.png",
                  title: "Title: yeti.tiff",
                  caption: nil }
              ]
            }.with_indifferent_access
          )
        end
      end
    end

    describe "PUT 'update'" do
      subject(:do_request) { patch :update, id: task.figures.last.id, task_id: task.to_param, figure: {title: "new title", caption: "new caption"}, format: :json }
      before(:each) do
        task.figures.create! attachment: fixture_file_upload('yeti.tiff', 'image/tiff')
      end

      it "allows updates for title and caption" do
        do_request

        figure = task.figures.last
        expect(figure.caption).to eq("new caption")
        expect(figure.title).to eq("new title")
      end
    end
  end
end
