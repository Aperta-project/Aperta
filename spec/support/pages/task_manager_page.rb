class TaskManagerPage < Page
  class CardOverlay
    def initialize element
      @element = element
    end

    def dismiss
      @element.all('.close-overlay').first.click
    end

    def assignee
      selected_option = @element.all('#task_assignee_id option[selected]').first
      selected_option.try :text
    end

    def assignee=(name)
      @element.select name, from: 'Assignee'
    end

    def mark_as_complete
      @element.find('footer input[type="checkbox"]').click
    end

    def completed?
      @element.find('footer input[type="checkbox"]').checked?
    end
  end

  class PaperShepherdOverlay < CardOverlay
  end

  class AssignEditorOverlay < CardOverlay
    def paper_editor=(name)
      @element.select name, from: 'Editor'
    end

    def paper_editor
      selected_option = @element.all('#task_paper_role_attributes_user_id option[selected]').first
      selected_option.try :text
    end
  end

  class PhaseFragment
    def initialize element
      @element = element
    end

    def view_card card_name, &block
      @element.click_on card_name
      overlay = "TaskManagerPage::#{card_name.gsub ' ', ''}Overlay".constantize.new @element.session.find('#overlay')
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
