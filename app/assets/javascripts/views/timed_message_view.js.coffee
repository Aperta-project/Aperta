ETahi.TimedMessageView = Em.View.extend
  messageDidChange: (->
    @$().html @get('message')
    setTimeout(=>
      @set 'message', ''
    , 5000)
  ).observes('message')
