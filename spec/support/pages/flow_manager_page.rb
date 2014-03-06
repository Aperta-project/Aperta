class FlowManagerPage < Page
  class CardFragment < PageFragment
    def title
      text
    end
  end

  class PaperProfile < PageFragment
    def title
      find('h4').text
    end

    def view
      click_link title
      TaskManagerPage.new
    end

    def cards
      all('.card').map { |c| CardFragment.new c }
    end
  end

  class Column < PageFragment
    def paper_profiles
      all('.paper-profile').map { |p| PaperProfile.new p }
    end

    def paper_profiles_for title
      paper_profiles.select { |p| p.title == title }
    end

    def has_empty_text?
      all('.empty-text').present?
    end

    def remove
      find('.remove-column').click
    end
  end

  def add_column title
    find('a', text: "ADD NEW COLUMN").click
    all('a').detect { |button| button.text == title }.click
  end

  def column title
    wait_for_turbolinks
    el = all('.column').detect { |c| c.find('h2').text == title }
    Column.new el if el
  end

  def columns title
    wait_for_turbolinks
    el = all('.column').select { |c| c.find('h2').text == title }
  end

  def has_column? title
    !!column(title)
  end

  path :flow_manager
end
