module TahiPusher::SocketTracker
  extend ActiveSupport::Concern

  included do
    def set_pusher_socket
      RequestStore.store[:requester_pusher_socket_id] = \
          request.headers["Pusher-Socket-ID"]
    end
  end
end
