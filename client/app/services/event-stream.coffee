`import Ember from 'ember'`
`import Utils from 'tahi/services/utils'`

interval = 500
EventStream = Ember.Object.extend
  eventSource: null
  channels: null
  messageQueue: null
  wait: false
  init: ->
    @set('messageQueue', [])
    @resetChannels()
    @processMessages()

  addEventListener: (eventName) ->
    @get('eventSource').addEventListener eventName, @msgEnqueue.bind(@)

  msgEnqueue: (msg) ->
    @get('messageQueue').unshiftObject(msg)

  processMessages: ->
    unless @get('wait')
      if msg = @messageQueue.popObject()
        msg.parsedData = JSON.parse(msg.data)
        if @shouldProcessMessage(msg)
          description = "Event Stream (#{msg.type}): #{msg.parsedData.subscription_name}"
          Utils.debug(description, msg)
          @msgResponse(msg.parsedData)
    Ember.run.later(@, 'processMessages', [], interval)

  shouldProcessMessage: (msg) ->
    @get('channels').contains(msg.type) or msg.parsedData.action == 'destroyed'

  pause: ->
    @set('wait', true)

  play: ->
    @set('wait', false)

  stop: ->
    @get('eventSource').close() if @get('eventSource')

  resetChannels: ->
    @pause()
    @stop()
    params =
      url: '/event_stream'
      method: 'GET'
      success: (data) =>
        return if data.enabled == 'false'
        @set('eventSource', new EventSource(data.url))
        Ember.$(window).unload => @stop()
        @set('channels', data.channels)
        Utils.debug("Event Stream: updated channels", data.channels)
        data.channels.forEach (eventName) =>
          @addEventListener(eventName)
        @play()
    Ember.$.ajax(params)

  msgResponse: (esData) ->
    if esData.event # minimal code to work
      @store.pushPayload('event', { event: esData })
      Ember.run =>
        event = @store.getById("event", esData.id)
        @emitEvent(event)
    else # legacy event sever
      action = esData.action
      delete esData.action
      delete esData.subscription_name
      (@eventStreamActions[action] || -> null).call(this, esData)

  emitEvent: (event, queueName="actions") ->
    Ember.run.schedule queueName, @, =>
      try
        action = event.get('event')
        @router.send(action, event)
      catch e
        unhandled = e.message.match(/Nothing handled the action/)
        throw e unless unhandled

  applicationSerializer: (->
    @store.container.lookup("serializer:application")
  ).property()

  eventStreamActions:
    created: (esData) ->
      Ember.run => @store.pushPayload(esData)

    updated: (esData)->
      Ember.run => @store.pushPayload(esData)

    destroyed: (esData)->
      type = @get('applicationSerializer').typeForRoot(esData.type)
      esData.ids.forEach (id) =>
        if type == "task"
          record = @store.findTask(id)
        else
          record = @store.getById(type, id)
        if record
          record.unloadRecord()

`export default EventStream`
