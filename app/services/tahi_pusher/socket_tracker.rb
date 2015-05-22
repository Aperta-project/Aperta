module TahiPusher::SocketTracker
  extend ActiveSupport::Concern

  included do
    def set_pusher_socket
      RequestStore.store[:requester_pusher_socket_id] = request.headers["HTTP_PUSHER_SOCKET_ID"]
    end
  end
end
