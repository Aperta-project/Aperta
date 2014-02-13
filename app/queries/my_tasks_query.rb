class MyTasksQuery
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def paper_profiles
    tasks.inject(Hash.new { Array.new }) do |acc, task|
      acc[task.paper] <<= task
      acc
    end
  end

  private

  def tasks
    Task.where(assignee: user)
  end
end
