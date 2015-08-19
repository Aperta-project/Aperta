module HasFeedActivities
  def feed_activities defaults = {}
    @defaults = defaults
    yield
  end

  private

  def activity activity_name, message = nil, options = {}, &block
    options = @defaults.merge(options)
    key = "#{name.downcase}.#{activity_name.to_s}"

    define_method activity_name.to_s + "_activity!" do |user|
      message = message || instance_eval(&block)

      feed_names = options[:feed_names]
      if !feed_names.is_a? Array
        feed_names = instance_eval(&feed_names)
      end

      feed_names.map do |feed_name|
        Activity.create(
          feed_name: feed_name,
          activity_key: key,
          subject: instance_eval(&(options[:subject])),
          user: user,
          message: message
        )
      end
    end
  end
end
