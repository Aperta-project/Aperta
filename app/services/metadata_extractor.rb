class MetadataExtractor
  attr_accessor :paper

  def self.call(paper: paper)
    MetadataExtractor.new(paper: paper).call
  end

  def initialize(paper: paper)
    @paper = paper
  end

  def call
    paper.tasks.where(type: Task.metadata_types.to_a).each do |task|
      dump_json_data(task)
    end
  end

  def dump_json_data(task)
    # put this into a file
    task_serializer(task).to_json
  end

  def task_serializer(task)
    "#{task.class.to_s}Serializer".constantize.new(task)
  rescue NameError => e
    TaskSerializer.new(task)
  end
end
