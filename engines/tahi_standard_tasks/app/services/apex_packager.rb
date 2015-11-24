# This class creates an in memory ZIP file for FTP to Apex
class ApexPackager
  attr_reader :zip_file

  def self.create(paper)
    packager = ApexPackager.new(paper)
    packager.zip
    packager
  end

  def initialize(paper)
    @paper = paper
    @zip_file = Tempfile.new('zip')
  end

  def zip
    Zip::OutputStream.open(@zip_file) do |package|
      add_figures(package)
      add_striking_image(package)
      add_supporting_information(package)
      add_metadata(package)
      add_manuscript(package)
    end
  end

  private

  def add_manuscript(package)
    package.put_next_entry("#{@paper.manuscript_id}.docx")
    package.write(open(@paper.latest_version.source_url).read)
  end

  def add_striking_image(package)
    return unless @paper.striking_image

    package.put_next_entry(@paper.striking_image.apex_filename)
    package.write(@paper.striking_image.attachment.read)
  end

  def add_figures(package)
    return unless figures_comply?
    @paper.figures.each do |figure|
      next if figure.striking_image
      package.put_next_entry(figure.apex_filename)
      package.write(figure.attachment.read)
    end
  end

  def add_supporting_information(package)
    @paper.supporting_information_files.each do |file|
      next unless file.publishable?
      package.put_next_entry(file.filename)
      package.write(file.attachment.read)
    end
  end

  def add_metadata(package)
    metadata = Typesetter::MetadataSerializer.new(@paper).to_json
    temp_file = Tempfile.new('metadata')
    temp_file.write(metadata)
    temp_file.rewind
    package.put_next_entry('metadata.json')
    package.write(temp_file.read)
    temp_file.close
  end

  def figures_comply?
    find_answer('TahiStandardTasks::FigureTask', 'figure_complies')
  end

  def find_answer(task_type, ident)
    t = @paper.tasks.find_by_type(task_type)
    return unless t
    return unless t.answer_for(ident)

    t.answer_for(ident).value
  end
end
