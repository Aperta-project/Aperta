class UserSettings < ActiveRecord::Base
  belongs_to :user
  has_many :flows

  after_create :add_flows

  def add_flows
    [
      {title:"Up for grabs", empty_text: "Right now, there are no papers for you to grab."},
      {title:"My tasks", empty_text: "You don't have any tasks right now."},
      {title:"My papers", empty_text: "You aren't on any papers right now."},
      {title:"Done", empty_text: "There is no recent activity to report."}
    ].each do |attrs|
      flows.create! attrs
    end
  end
end
