# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

module Subscriptions

  # Holds subscription details in a single list. Tracks which events and
  # subscribers are added. It also tracks where those subscriptions were made,
  # so tracking down the source of a subscriber is a simple affair.
  #
  class Registry
    extend Forwardable
    include Enumerable

    def_delegators :@events, :each, :keys, :values

    EventInfo = Struct.new(:event, :subscribers, :added_from)

    def initialize
      @events = {}
      @subscribers = []
    end

    def add(event_name, *subscribers)
      added_from = caller_locations(1, 1)[0] # path/to/subscriber.rb:99
      event_info = EventInfo.new(event_name, subscribers, added_from)

      duplicated_handler_check!(event_info)

      @events[event_name] ||= []
      @events[event_name] << event_info
      @subscribers.concat Subscriber.subscribe(event_name, subscribers)
    end

    def subscribers_for(event)
      matching_events = @events.select do |event_name, _|
        /#{event}/ =~ event_name
      end

      matching_events.map do |_, event_infos|
        event_infos.map(&:subscribers)
      end.flatten
    end

    def pretty_print(io=$stdout)
      headers = ["Event Name", "Subscribers"]
      rows = @events.sort.map do |event, info|
        [event, info.map(&:subscribers).flatten.map(&:to_s).sort.join(', ')]
      end
      io.puts Subscriptions::ConsoleFormatter.new(headers, rows).to_s
    end

    def unsubscribe_all
      Subscriber.unsubscribe(@subscribers)
      @subscribers.clear
      @events.clear
    end

    private

    def duplicated_handler_check!(new_info)
      previously_registered = @events[new_info.event]
      return if previously_registered.nil?

      new_info.subscribers.each do |new_handler|
        duplicate_info = previously_registered.detect { |info| info.subscribers.include?(new_handler) }

        if duplicate_info
          raise DuplicateSubscribersRegistrationError.new("#{new_handler} can only be registered once per event, but was registered twice for event `#{new_info.event}` at both: \n\t1. #{duplicate_info.added_from} \n\t2. #{new_info.added_from}\n")
        end
      end
    end

  end

end
