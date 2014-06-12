module DataAvailability
  class Task < ::Task
    title "Data Availability"
    role "author"

    has_many :questions, inverse_of: :task
  end
end
