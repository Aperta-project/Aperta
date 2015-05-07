module TahiPusher::SocketTracker
  extend ActiveSupport::Concern

  included do
    def set_pusher_socket
      # TODO: determine how ember will send this param in
      RequestStore.store[:requester_pusher_socket_id] = params[:socket_id]
    end
  end
end
