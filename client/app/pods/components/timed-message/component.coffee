`import Ember from 'ember'`

TimedMessageComponent = Ember.Component.extend
  duration: 5000

  messageDidChange: (->
    @$().html(@get('message'))

    Ember.run.later(@, ->
      this.set('message', '')
    , @get('duration'))
  ).observes('message')

 `export default TimedMessageComponent`
