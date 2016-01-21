Authorizations.configure do |config|
  config.assignment_to(
    Paper,
    authorizes: Task,
    via: :tasks
  )
end
