`import Ember from 'ember'`
`import RESTless from 'tahi/services/rest-less'`

HeartbeatService = Ember.Object.extend
  interval: 90 * 1000
  intervalId: null
  resource: null

  init: ->
    resource = @get('resource')
    throw new Error("need to specify resource") unless resource

  start: ->
    @heartbeat() # immediate heartbeat
    heartbeatWrapper = => @heartbeat()
    @set('intervalId', setInterval(heartbeatWrapper, @get('interval')))

  stop: ->
    intervalId = @get('intervalId')
    if intervalId
      clearInterval(intervalId)
      @set('intervalId', null)

  heartbeat: ->
    RESTless.putModel(@get('resource'), "/heartbeat")

`export default HeartbeatService`
