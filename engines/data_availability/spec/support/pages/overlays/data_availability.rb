class DataAvailabilityOverlay < CardOverlay
  class Question < PageFragment
    def checked?
      checkbox.checked?
    end

    def check
      checkbox.click
    end

    def dataset
      find('.dataset')
    end

    def fill_dataset_field(field, text)
      # field = dataset.find("input[name=#{field}]")
      fill_in field, with: text
    end

    private

    def checkbox
      find('input[type=checkbox]')
    end
  end

  def nth_check_question(n)
    question = all('li.item')[n]
    Question.new(question)
  end
end
