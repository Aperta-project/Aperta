class PaperEditorTask < Task
  after_initialize :initialize_defaults

  private

  def initialize_defaults
    self.title = 'Assign Editor' if title.blank?
  end
end
