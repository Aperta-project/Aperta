class ManuscriptManagerTemplatePage < Page
  text_assertions :paper_type, ".paper-type-name"

  def self.visit(journal)
    page.visit "/admin/journals/#{journal.to_param}/manuscript_manager_templates"
    new
  end

  def phases
    expect(page).to have_css('.column h2')
    all('.column h2').map(&:text)
  end

  def has_phase_names?(*phases)
    phases.each do |p_name|
      expect(page).to have_css('.column h2', text: p_name)
    end
  end

  def find_phase(phase_name)
    PhaseFragment.new(
      find('.column h2', text: phase_name).find(:xpath, '../../..'))
  end

  def add_new_template
    click_link "Add New Template"
  end

  def paper_type
    find(".paper-type-name")
  end

  def paper_type=(type)
    find(".paper-type-name").click
    find(".edit-paper-type-field").set(type)
  end

  def save
    find(".paper-type-save-button").click
  end
end
