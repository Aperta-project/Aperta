class TaskManagerPage < Page
  class PaperShepherdOverlay < CardOverlay
  end

  class AssignEditorOverlay < CardOverlay
    def paper_editor=(name)
      select name, from: 'Editor'
    end

    def paper_editor
      selected_option = all('#task_paper_role_attributes_user_id option[selected]').first
      selected_option.try :text
    end
  end

  class PhaseFragment < PageFragment
    def view_card card_name, &block
      click_on card_name
      overlay = "TaskManagerPage::#{card_name.gsub ' ', ''}Overlay".constantize.new session.find('#overlay')
      block.call overlay
      overlay.dismiss
    end
  end

  path :manage_paper

  def phases
    all('.phase h2').map(&:text)
  end

  def phase phase_name
    phase = all('.phase').detect do |p|
      p.find('h2').text == phase_name
    end
    PhaseFragment.new phase
  end

  def navigate_to_edit_paper
    within('#control-bar') do
      click_link "Article"
    end
    EditSubmissionPage.new
  end
end
