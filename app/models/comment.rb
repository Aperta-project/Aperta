class Comment < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :task
  belongs_to :commenter, class_name: 'User', inverse_of: :comments
  has_many :comment_looks

  validates :task, :body, presence: true

  def self.create_with_comment_look(task, params)
    c = new params
    if task.class.method_defined?(:participants)
      task.participants.each do |participant|
        if params[:commenter_id]
          commenter_id = params[:commenter_id].to_i
        else
          commenter_id = params[:commenter].id
        end

        next if participant.id == commenter_id
        c.comment_looks.new user_id: participant.id, comment: c
      end
    end
    c.save!
    c
  end

  def meta_type
    self.class.name
  end

  def has_meta?
    true
  end

  def meta_id
    id
  end

  private

  def task_payload
    { task_id: task.id, paper_id: task.paper.id }
  end
end
