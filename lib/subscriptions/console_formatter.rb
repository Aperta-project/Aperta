module Subscriptions

  # Print subscription detail as a nicely formatted table
  #
  class ConsoleFormatter

    def initialize(registry)
      @registry = registry
    end

    # TODO: clean this up
    def format
      out = StringIO.new
      ws = widths
      out.puts ['Event Name'.ljust(ws[0]), 'Subscribers'.ljust(ws[1])].join(' ')
      @registry.sort.map do |event, info|
        out.puts [event.ljust(ws[0]), info.map(&:subscribers).join(', ').ljust(ws[1])].join(' ')
      end
      out.string
    end

    def widths
      [
        @registry.keys.map(&:length).max || 0,
        @registry.values.map { |info| info.map(&:subscribers).join(', ').length }.max || 0,
      ]
    end
  end

end
