module StandardTasks
  class AwesomeTask < Task
    title "Awesome Task"
    role "author"

    has_many :awesome_authors
    accepts_nested_attributes_for :awesome_authors

    def active_model_serializer
      TaskSerializer
    end

    def valid?(context=nil)
      super(context)
      valid_authors = true
      awesome_authors.each do |a|
        if a.invalid?
          self.errors.add(:awesome_authors, a.formatted_errors)
          valid_authors = false
        end
      end
      self.errors.add(:completed, "Please check the errors above.") unless valid_authors
      self.errors.empty?
    end


  end
end
