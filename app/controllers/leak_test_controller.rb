class LeakTestController < ApplicationController

  def plaintext
    render text: Time.zone.now.to_s
  end

  def boringhtml
  end

  def dbcount
    render text: "There are #{Paper.count} records."
  end

  def basicquery
    user = User.last
    render text: "I found this user named #{user.first_name}"
  end

  def paper
    paper = Paper.last
    render json: PaperSerializer.new(paper).to_json
  end

end
