
# Sidekiq has "Delayed Extensions" which will background queue a single
# method call without creating a separate worker class. This is usually
# invoked as `MyClass.delay.some_class_method`. However, the call to
# `delay` actually returns a proxy object, making Rspec expectations a
# bit difficult to rely on.
#
# You can read more at github.com/mperham/sidekiq/wiki/Delayed-Extensions.
#
# This support method will return a double to allow normal mocking
# expectations to be performed without Sidekiq's extensions getting in
# the way.
#
def mock_delayed_class(delayed_class)
  mocked_delayed_class = double(:mocked_delayed_class)
  allow(delayed_class).to receive(:delay).and_return(mocked_delayed_class)
  mocked_delayed_class
end

