class FlowManagerPage < Page
  path :root

  def add_column title
    find('.add-flow-column-button').click
    find('.overlay-x .flow-manager-button', text: title.upcase).click
  end

  def column title
    synchronize_content!(title)
    el = all('.column').detect { |c| c.find('h2').text == title }
    Column.new el if el
  end

  def columns title
    synchronize_content!(title)
    all('.column').select { |c| c.find('h2').text == title }
  end

  def has_column? title
    page.has_content?(title)
  end

  def has_no_column? title
    page.has_no_content?(title)
  end

  def has_available_column? title
    find('.add-flow-column-button').click
    within('.overlay-x') do
      page.has_content?(title.upcase)
    end
  end

  def available_column_count
    find('.add-flow-column-button').click
    within('.overlay-x') do
      all('.flow-manager-button').count
    end
  end

  class CardFragment < PageFragment
    def title
      text
    end

    def completed?
      has_css?('.card-completed-icon')
    end
  end

  class PaperProfile < PageFragment
    def title
      find('.paper-profile-title')
    end

    def view
      click_link title
      TaskManagerPage.new
    end

    def cards
      find_all('.card').map { |c| CardFragment.new c }
    end

    def card_by_title(card_title)
      cards.find { |card| card.title == card_title }
    end
  end

  class Column < PageFragment
    def paper_profiles
      find_all('.paper-profile').map { |p| PaperProfile.new p }
    end

    def paper_profiles_for title
      paper_profiles.select { |p| p.title == title }
    end

    def has_empty_text?
      all('.empty-text').present?
    end

    def remove
      find(".column-header").hover
      find('.remove-column').click
    end
  end
end
