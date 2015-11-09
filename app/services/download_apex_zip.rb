require 'open-uri'

class DownloadApexZip
  def initialize(paper)
    @paper = paper
  end

  def export
    buffer = Zip::OutputStream.write_buffer do |package|
      @package = package
      add_manuscript
      add_striking_image
      add_figures
      add_supporting_information
      add_metadata
    end

    buffer.string
    #File.open("temp.zip", "w") {|f| f.write(buffer.string)}
  end

  def add_manuscript
    #package.put_next_entry(filename)
  end

  def add_striking_image
    return unless @paper.striking_image
    @package.put_next_entry(@paper.striking_image.filename)
    @package.write(@paper.striking_image.file.read)
  end

  def add_figures
    return unless figures_comply?
    @paper.figures.each do |figure|
      next if @paper.striking_image == figure
      @package.put_next_entry(figure.filename)
      @package.write(figure.attachment.file.read)
    end
  end

  def figures_comply?
    return find_answer("TahiStandardTasks::FigureTask", "figures_comply")
  end

  def add_supporting_information
    @paper.supporting_information_files.each do |file|
      return unless file.publishable?
      @package.put_next_entry(file.filename)
      @package.write(file.attachment.file.read)
    end
  end

  def add_metadata
  end

  def find_answer task_type, ident
    t = @paper.tasks.find_by_type(task_type)
    return unless t

    return t.answer_for(ident).value
  end
end
