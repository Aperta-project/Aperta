`import Ember from 'ember'`
`import ENV from 'tahi/config/environment'`

PusherInitializer =
  name: 'pusher-override'
  before: 'pusher'
  initialize: (container, application) ->
    ENV['APP']['PUSHER_OPTS'] =
      key: window.eventStreamConfig.key
      connection:
        authEndpoint: window.eventStreamConfig.auth_endpoint_path
        # NOTE: pusher config is confusing
        #   when https, encrypted is ALWAYS true
        #   when http, it uses this config (false)
        encrypted: false
        disableStats: true
        enabledTransports: ['ws']
    if window.eventStreamConfig.host
      ENV['APP']['PUSHER_OPTS']['connection'] =
        Ember.merge(ENV['APP']['PUSHER_OPTS']['connection'],
          wsHost: window.eventStreamConfig.host
          wsPort: window.eventStreamConfig.port
          wssPort: window.eventStreamConfig.port)

`export default PusherInitializer`
