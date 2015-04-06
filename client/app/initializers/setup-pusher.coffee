SetupPusher =
  name: 'setupPusher'
  before: 'pusher'

  initialize: (container, application) ->
    hostOptions = Tahi.PUSHER_OPTS.hostOptions
    window.Pusher.host = hostOptions.PUSHER_HOST
    window.Pusher.ws_port = hostOptions.PUSHER_WS_PORT
    window.Pusher.protocol = hostOptions.PUSHER_PROTOCOL

`export default SetupPusher`
