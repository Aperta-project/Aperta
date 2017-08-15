# The CardType class is a lightweight stopgap for creating a table.
# Once we actually need some metadata we'll transition over to the database, but for
# now having to create the table and ensure properly seeded data is overkill
class CardType
  attr_accessor :display_name, :task_klass
  def initialize(display_name, task_klass)
    @display_name = display_name
    @task_klass = task_klass
  end

  # Card types are really just a mapping between a name and a constant for now.
  # If you update this list you **must** update cardTypeMap in
  # client/app/pods/paper/workflow/controller.js
  def self.all
    [
      new('Custom Card', CustomCardTask),
      new('Upload Manuscript', TahiStandardTasks::UploadManuscriptTask)
    ]
  end

  def self.class_for_name(name)
    all.find { |card_type| card_type.display_name == name }
  end

  # An array of card type names, mostly for consumption on the client side
  def self.display_names
    all.map(&:display_name)
  end
end
