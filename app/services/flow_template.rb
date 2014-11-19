module FlowTemplate
  def self.templates
    {
      "up for grabs" =>
        { title: "Up for grabs" },
      "my tasks" =>
        { title: "My tasks" },
      "my papers" =>
        { title: "My papers" },
      "done" =>
        { title: "Done" }
    }
  end

  def self.template(title)
    templates.fetch(title.downcase, invalid_template)
  end

  def self.valid_titles
    templates.values.map { |template| template[:title] }
  end

  private

  def invalid_template
    { title: "Invalid" }
  end
end
