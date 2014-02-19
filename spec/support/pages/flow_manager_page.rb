class FlowManagerPage < Page
  class CardFragment < PageFragment
    def title
      text
    end
  end

  class PaperSummary < PageFragment
    def title
      find('h4').text
    end

    def cards
      all('.card').map { |c| CardFragment.new c }
    end
  end

  class Column < PageFragment
    def papers
      all('.paper-profile').map { |p| PaperSummary.new p }
    end
  end

  def column title
    wait_for_turbolinks
    el = all('.column').detect { |c| c.find('h1').text == title }
    Column.new el if el
  end
end
