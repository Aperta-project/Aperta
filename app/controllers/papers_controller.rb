class PapersController < ApplicationController
  before_filter :authenticate_user!

  def show

    respond_to do |format|
      format.html do
        @paper = PaperPolicy.new(params[:id], current_user).paper
        raise ActiveRecord::RecordNotFound unless @paper
        redirect_to edit_paper_path(@paper) unless @paper.submitted?
        @tasks = TaskPolicy.new(@paper, current_user).tasks
      end

      format.json do
        # @paper = PaperPolicy.new(params[:id], current_user).paper
        # raise ActiveRecord::RecordNotFound unless @paper
        #
        # render json: @paper
         render json: {
   "phases" =>  [
     {
       "id" =>  1,
       "name" =>  "Submission Data",
       "position" =>  0,
       "paper_id" =>  1,
       "tasks" =>  [
         {id:  4, type:  'declaration_task'},
         {id:  2, type:  'AuthorsTask'},
         {id:  3, type:  'FigureTask'},
         {id:  1, type:  'UploadManuscriptTask'},
       ]
     },
     {
       "id" =>  2,
       "name" =>  "Assign Editor",
       "position" =>  1,
       "paper_id" =>  1,
       "tasks" =>  [
         {id: 7, type: 'PaperEditorTask'},
         {id: 5, type: 'PaperAdminTask'},
         {id: 6, type: 'TechCheckTask'}
       ]
     },
     {
       "id" =>  3,
       "name" =>  "Assign Reviewers",
       "position" =>  2,
       "paper_id" =>  1,
       "tasks" =>  [
         {id: 12, type: 'MessageTask'},
         {id: 11, type: 'MessageTask'},
         {id: 8, type: 'PaperReviewerTask'}
       ]
     },
     {
       "id" =>  4,
       "name" =>  "Get Reviews",
       "position" =>  4,
       "paper_id" =>  1,
       "tasks" =>  [
         {id: 10, type: 'ReviewerReportTask'}
       ]
     },
     {
       "id" =>  5,
       "name" =>  "Make Decision",
       "position" =>  5,
       "paper_id" =>  1,
       "tasks" =>  [
         {id: 9, type: 'RegisterDecisionTask'}
       ]
     }
   ],
   "tasks" =>  [
     {
       "id" =>  4,
       "title" =>  "Enter Declarations",
       "type" =>  "DeclarationTask",
       "completed" =>  false,
       "message_subject" =>  nil,
       "declarations" =>  "These are my declarations",
       "phase_id" =>  1,
       "assignee_ids" =>  [
         
       ],
       "assignee_id" =>  1
     },
     {
       "id" =>  2,
       "title" =>  "Add Authors",
       "type" =>  "AuthorsTask",
       "completed" =>  false,
       "message_subject" =>  nil,
       "phase_id" =>  1,
       "assignee_ids" =>  [
         
       ],
       "assignee_id" =>  1,
       "author_ids" =>  [
         
       ]
     },
     {
       "id" =>  3,
       "title" =>  "Upload Figures",
       "type" =>  "FigureTask",
       "completed" =>  true,
       "message_subject" =>  nil,
       "figures" =>  "These are my figures",
       "phase_id" =>  1,
       "assignee_ids" =>  [
         
       ],
       "assignee_id" =>  1
     },
     {
       "id" =>  1,
       "title" =>  "Upload Manuscript",
       "type" =>  "UploadManuscriptTask",
       "completed" =>  true,
       "message_subject" =>  nil,
       "phase_id" =>  1,
       "assignee_ids" =>  [
         
       ],
       "assignee_id" =>  1
     },
     {
       "id" =>  7,
       "title" =>  "Assign Editor",
       "type" =>  "PaperEditorTask",
       "completed" =>  false,
       "message_subject" =>  nil,
       "phase_id" =>  2,
       "assignee_ids" =>  [
         1
       ],
       "assignee_id" =>  1,
       "editor_ids" =>  [
         3
       ],
       "editor_id" =>  3
     },
     {
       "id" =>  5,
       "title" =>  "Assign Admin",
       "type" =>  "PaperAdminTask",
       "completed" =>  false,
       "message_subject" =>  nil,
       "admins" =>  [
         {
           "id" =>  1,
           "first_name" =>  "Mike",
           "last_name" =>  "Mazur",
           "affiliation" =>  "Neo",
           "email" =>  "mike@neo.com",
           "created_at" =>  "2014-02-17T18 => 22 => 00.307Z",
           "updated_at" =>  "2014-03-14T22 => 33 => 03.548Z",
           "username" =>  "mike",
           "admin" =>  true
         }
       ],
       "admin" =>  {
         "id" =>  1,
         "first_name" =>  "Mike",
         "last_name" =>  "Mazur",
         "affiliation" =>  "Neo",
         "email" =>  "mike@neo.com",
         "created_at" =>  "2014-02-17T18 => 22 => 00.307Z",
         "updated_at" =>  "2014-03-14T22 => 33 => 03.548Z",
         "username" =>  "mike",
         "admin" =>  true
       },
       "phase_id" =>  2,
       "assignee_ids" =>  [
         1
       ],
       "assignee_id" =>  1
     },
     {
       "id" =>  6,
       "title" =>  "Tech Check",
       "type" =>  "TechCheckTask",
       "completed" =>  true,
       "message_subject" =>  nil,
       "phase_id" =>  2,
       "assignee_ids" =>  [
         1
       ],
       "assignee_id" =>  1
     },
     {
       "id" =>  12,
       "title" =>  "Foo",
       "type" =>  "MessageTask",
       "completed" =>  false,
       "message_subject" =>  "Foo",
       "phase_id" =>  3,
       "assignee_ids" =>  [
         1
       ],
       "assignee_id" =>  nil
     },
     {
       "id" =>  11,
       "title" =>  "Subj",
       "type" =>  "MessageTask",
       "completed" =>  false,
       "message_subject" =>  "Subj",
       "phase_id" =>  3,
       "assignee_ids" =>  [
         1
       ],
       "assignee_id" =>  nil
     },
     {
       "id" =>  8,
       "title" =>  "Assign Reviewers",
       "type" =>  "PaperReviewerTask",
       "completed" =>  false,
       "message_subject" =>  nil,
       "phase_id" =>  3,
       "assignee_ids" =>  [
         3
       ],
       "assignee_id" =>  1,
       "reviewer_ids" =>  [
         2
       ]
     },
     {
       "id" =>  10,
       "title" =>  "Reviewer Report",
       "type" =>  "ReviewerReportTask",
       "completed" =>  false,
       "message_subject" =>  nil,
       "phase_id" =>  4,
       "assignee_ids" =>  [
         1
       ],
       "assignee_id" =>  2
     },
     {
       "id" =>  9,
       "title" =>  "Register Decision",
       "type" =>  "RegisterDecisionTask",
       "completed" =>  false,
       "message_subject" =>  nil,
       "phase_id" =>  5,
       "assignee_ids" =>  [
         3
       ],
       "assignee_id" =>  3
     }
   ],
   "users" =>  [
     {
       "id" =>  1,
       "full_name" =>  "Mike Mazur",
       "image_url" =>  "\/images\/profile-no-image.jpg"
     },
     {
       "id" =>  3,
       "full_name" =>  "Edi Tor",
       "image_url" =>  "\/images\/profile-no-image.jpg"
     },
     {
       "id" =>  2,
       "full_name" =>  "Rev Iewer",
       "image_url" =>  "\/images\/profile-no-image.jpg"
     }
   ],
   "paper" =>  {
     "id" =>  1,
     "short_title" =>  "Tasks",
     "title" =>  "Technical Writing Information Sheets",
     "phase_ids" =>  [
       1,
       2,
       3,
       4,
       5
     ]
   }
 }
      end
    end
  end

  def new
    @paper = Paper.new
  end

  def create
    @paper = current_user.papers.new(paper_params)

    if @paper.save
      redirect_to edit_paper_path @paper
    else
      render :new
    end
  end

  def edit
    @paper = PaperPolicy.new(params[:id], current_user).paper
    redirect_to paper_path(@paper) if @paper.submitted?
    @tasks = TaskPolicy.new(@paper, current_user).tasks
  end

  def update
    @paper = Paper.find(params[:id])
    params[:paper][:authors] = JSON.parse params[:paper][:authors] if params[:paper].has_key? :authors

    if @paper.update paper_params
      respond_to do |f|
        f.html { redirect_to root_path }
        f.json { head :no_content }
      end
    end
  end

  def upload
    @paper = Paper.find(params[:id])

    manuscript_data = DocumentParser.parse(params[:upload_file].path)
    @paper.update manuscript_data
    redirect_to edit_paper_path(@paper)
  end

  private

  def paper_params
    params.require(:paper).permit(:short_title, :title, :abstract, :body, :paper_type, :submitted, :journal_id, declarations_attributes: [:id, :answer], authors: [:first_name, :last_name, :affiliation, :email])
  end
end
