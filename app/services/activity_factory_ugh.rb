class ActivityFactoryUgh
  class << self
    def createActivity(action, subject, user, source)
      send(action, subject, user, source)
    end

    def paper_created(subject, user, paper)
      Activity.create(
        feed_name: 'manuscript',
        activity_key: 'paper.created',
        subject: subject,
        user: user,
        message: "Manuscript was created"
      )
    end
  end
end
