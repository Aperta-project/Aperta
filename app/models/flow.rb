class Flow < ActiveRecord::Base
  attr_accessor :papers
  belongs_to :user, inverse_of: :flows
  belongs_to :role, inverse_of: :flows

  def self.templates
    {
      "up for grabs" =>
        {title:"Up for grabs", empty_text: "Right now, there are no papers for you to grab."},
      "my tasks" =>
        {title:"My tasks", empty_text: "You don't have any tasks right now."},
      "my papers" =>
        {title:"My papers", empty_text: "You aren't on any papers right now."},
      "done" =>
        {title:"Done", empty_text: "There is no recent activity to report."}
    }
  end
end

