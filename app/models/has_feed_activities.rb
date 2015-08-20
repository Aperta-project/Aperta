##
#  HasFeedActivities makes some happy methods for listing which events
#  should be saved for the activity feed for any model that extends it.
#
###### EXAMPLE
#
#  class FooBar
#    extend HasFeedActivities
#
#    feed_activities subject: :paper, feed_names: ['manuscript'] do
#      activity :created, "FooBar created."
#      activity(:activated) { "#{user.full_name}'s foobar active. Watch out!" }
#    end
#
#  foo_bar = FooBar.create
#  foo_bar.created_activity! current_user
#  foo_bar.activated_activity! current_user
#
######
#
# - :subject is a method name (or a Proc) that returns the paper (or other
#   object) of concern.
#
# - :feed_names is either an Array of feed names, or else a method
#   name (or a Proc) that returns a list of feed names.
#
# - activity then takes a name and a string message (or a block that
#   returns a string message)
#

module HasFeedActivities

  def feed_activities defaults = {}
    @defaults = defaults
    yield
  end

  private

  def activity activity_name, message = nil, options = {}, &block
    options = @defaults.merge(options)

    # Evaluate the key here so that 'name' is the root name of
    # polymorphic classes such as Task.
    key = "#{name.downcase}.#{activity_name.to_s}"

    define_method activity_name.to_s + "_activity!" do |acting_user|
      message = message || instance_eval(&block)

      feed_names = options[:feed_names]
      if !(feed_names.is_a? Array)
        feed_names = instance_eval(&feed_names)
      end

      feed_names.map do |feed_name|
        Activity.create(
          feed_name: feed_name,
          activity_key: key,
          subject: instance_eval(&(options[:subject])),
          user: acting_user,
          message: message
        )
      end
    end
  end
end
