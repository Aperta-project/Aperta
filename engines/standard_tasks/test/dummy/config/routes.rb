Rails.application.routes.draw do

  mount StandardTasks::Engine => "/standard_tasks"
end
