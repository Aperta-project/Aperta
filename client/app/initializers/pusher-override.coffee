`import Ember from 'ember'`
`import ENV from 'tahi/config/environment'`

PusherInitializer =
  name: 'pusher-override'
  before: 'pusher'
  initialize: (container, application) ->
    ENV['APP']['PUSHER_OPTS'] =
      key: window.eventStreamConfig.key
      connection:
        wsHost: window.eventStreamConfig.host
        wsPort: window.eventStreamConfig.port
        wssPort: window.eventStreamConfig.port
        authEndpoint: window.eventStreamConfig.auth_endpoint_path
        # NOTE: pusher config is confusing
        #   when https, encrypted is ALWAYS true
        #   when http, it uses this config (false)
        encrypted: false
        disableStats: true
        enabledTransports: ['ws']

`export default PusherInitializer`
