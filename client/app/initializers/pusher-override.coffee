`import Ember from 'ember'`
`import ENV from 'tahi/config/environment'`

PusherInitializer =
  name: 'pusher-override'
  before: 'pusher'
  initialize: (container, application) ->

    # TODO: force pusher to use unencrypted websocket connection
    # [pivotal #95086450]
    #
    window.Pusher.prototype.isEncrypted = -> true

    ENV['APP']['PUSHER_OPTS'] =
      key: window.eventStreamConfig.key
      connection:
        wsHost: window.eventStreamConfig.host
        wsPort: window.eventStreamConfig.port
        authEndpoint: window.eventStreamConfig.auth_endpoint_path
        disableStats: true
        enabledTransports: ['ws']

`export default PusherInitializer`
