class UnsavedChanges < Page
  def self.find_overlay(session)
    overlay = session.find('.overlay-container')
    new(overlay)
  end

  def initialize(element)
    super element
    synchronize_content! "You have unsaved changes"
  end

  def discard_changes
    find("a", text: "Discard Changes").click
  end
end
