module TahiPusher
  class Channel
    attr_reader :channel_name

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
        return true unless parsed_channel.active_record_backed?
        authorized_users.include?(user)
      end
    rescue ActiveRecord::RecordNotFound
      return false
    end


    private

    def authorized_users
      Accessibility.new(parsed_channel.target).users
    end

    def parsed_channel
      @parsed_channel ||= ChannelName.parse(channel_name)
    end

    def with_logging(message)
      Pusher.logger.info("** [Pusher] #{message}") if TahiPusher::Config.verbose_logging?
      yield
    rescue Pusher::HTTPError => e
      Pusher.logger.error("** [Pusher] #{e.message}")
      raise e
    end
  end
end
