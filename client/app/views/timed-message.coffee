`import Ember from 'ember'`

TimedMessageView = Ember.View.extend
  messageDidChange: (->
    @$().html @get('message')
    setTimeout(=>
      @set 'message', ''
    , 5000)
  ).observes('message')

 `export default TimedMessageView`
