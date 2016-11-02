module TahiPusher
  class Channel
    attr_reader :channel_name

    def self.push(channel_name:, **args)
      new(channel_name: channel_name).push(**args)
    end

    def initialize(channel_name:)
      @channel_name = channel_name
    end

    def authenticate(socket_id:)
      message = "Authenticating channel_name=#{channel_name}, socket=#{socket_id}"
      with_logging(message) do
        Pusher[channel_name].authenticate(socket_id)
      end
    end

    def push(event_name:, payload:, excluded_socket_id: nil)
      message = "Pushing event_name=#{event_name}, channel=#{channel_name}, payload=#{payload}, excluded_socket_id=#{excluded_socket_id}"
      with_logging(message) do
        excluded_socket = {}
        excluded_socket.merge!( { socket_id: excluded_socket_id }) if excluded_socket_id.present?
        Pusher.trigger(channel_name, event_name, payload, excluded_socket)
      end
    end

    def authorized?(user:)
      message = "Checking authorization on channel_name=#{channel_name} for user_id=#{user.id}"
      with_logging(message) do
        if system_channel?
          true
        else
          user.can?(:view, parsed_channel.target)
        end
      end
    rescue TahiPusher::ChannelResourceNotFound
      false
    end

    private

    def parsed_channel
      @parsed_channel ||= ChannelName.parse(channel_name)
    end

    def system_channel?
      !parsed_channel.active_record_backed?
    end

    def with_logging(message)
      if Rails.application.config.x.pusher_verbose_logging
        Pusher.logger.info("** [Pusher] #{message}")
      end
      yield
    rescue Pusher::HTTPError => e
      Pusher.logger.error("** [Pusher] #{e.message}")
      raise e
    end
  end
end
