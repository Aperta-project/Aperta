class EditSubmissionPage < Page
  path :edit_paper

  def visit_dashboard
    click_link 'Dashboard'
    DashboardPage.new
  end

  def short_title=(val)
    fill_in "Short title", with: val
  end

  def title=(val)
    fill_in "Title", with: val
  end

  def abstract=(val)
    fill_in "Abstract", with: val
  end

  def body=(val)
    fill_in "Body", with: val
  end

  def title
    find_field("Title").value
  end

  def abstract
    find_field("Abstract").value
  end

  def body
    find_field("Body").value
  end

  def save
    click_on 'Save'
    DashboardPage.new
  end

  def upload_word_doc
    click_on "Upload Manuscript"
    attach_file 'Upload Word Document', Rails.root.join('spec/fixtures/about_turtles.docx')
    click_on "Upload File"
    self
  end
end
