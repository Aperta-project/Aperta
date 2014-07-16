class ManuscriptManagerTemplatePage < Page

  def self.visit(journal)
    page.visit "/admin/journals/#{journal.to_param}/manuscript_manager_templates"
    new
  end

  def phases
    expect(page).to have_css('.column h2')
    all('.column h2').map(&:text)
  end

  def find_phase phase_name
    expect(page).to have_content(phase_name) # use have_content/css/stuff assertion to avoid sleeps.
    PhaseFragment.new(all('.column').detect {|p| p.find('h2').text == phase_name })
  end

  def add_new_template
    click_link "Add New Template"
  end

  def paper_type
    find(".template-edit-paper-type input").value
  end

  def paper_type=(type)
    find(".template-edit-paper-type input").set(type)
  end

  def save
    find(".template-save-button").click
  end
end
