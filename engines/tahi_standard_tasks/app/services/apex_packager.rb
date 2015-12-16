# This class creates a temporary ZIP file for FTP to Apex
class ApexPackager
  attr_reader :zip_file

  class ApexPackagerError < StandardError
  end

  def self.create(paper)
    packager = new(paper)
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
    extension = @paper.latest_version.source.path.split('.').last
    package.put_next_entry("#{@paper.manuscript_id}.#{extension}")
    package.write(open(@paper.latest_version.source_url, &:read))
  end

  def add_striking_image(package)
    return unless @paper.striking_image

    package.put_next_entry(figure_apex_filename(@paper.striking_image))
    package.write(@paper.striking_image.attachment.read)
  end

  def add_figures(package)
    @paper.figures.each do |figure|
      fail ApexPackagerError, 'Figures do not comply' unless figures_comply?
      next if @paper.striking_image == figure
      package.put_next_entry(figure_apex_filename(figure))
      package.write(figure.attachment.read)
    end
  end

  def figure_apex_filename(figure)
    return figure.filename unless figure == @paper.striking_image

    extension = figure.filename.split('.').last
    "Strikingimage.#{extension}"
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
    return unless figures_comply_answer
    figures_comply_answer.value
  end

  def figures_task
    @figures_task ||= @paper.tasks.find_by_type(
      'TahiStandardTasks::FigureTask')
  end

  def figures_comply_answer
    return unless figures_task
    @figures_comply_answer ||= figures_task.answer_for('figures--complies')
  end
end
