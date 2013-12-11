class PaperAdminTask < Task
  after_initialize :initialize_defaults

  private

  def initialize_defaults
    self.title = 'Paper Shepherd' if title.blank?
  end
end
