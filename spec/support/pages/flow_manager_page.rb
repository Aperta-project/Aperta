class FlowManagerPage < Page
  path :flow_manager

  def add_column title
    find('.add-flow-column-button').click
    find('.overlay a', text: title).click
  end

  def column title
    el = all('.column').detect { |c| c.find('h2').text == title }
    Column.new el if el
  end

  def columns title
    el = all('.column').select { |c| c.find('h2').text == title }
  end

  def has_column? title
    !!column(title)
  end

  class CardFragment < PageFragment
    def title
      text
    end

    def completed?
      has_class_name?('card-completed')
    end
  end

  class PaperProfile < PageFragment
    def title
      find('.paper-profile-title').text
    end

    def view
      click_link title
      TaskManagerPage.new
    end

    def cards
      all('.card').map { |c| CardFragment.new c }
    end

    def card_by_title(card_title)
      cards.find { |card| card.title == card_title }
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
      hover
      find('.remove-column').click
    end
  end
end
