ETahi.FlashMessageComponent = Ember.Component.extend
  classNames: ['flash-message']
  classNameBindings: ['type']
  layoutName: 'flash-message'

  type: (->
    "flash-message--#{@get('message.type')}"
  ).property('message.type')

  fadeIn: (->
    @$().hide().fadeIn(250)
  ).on('didInsertElement')

  actions:
    remove: () ->
      @$().fadeOut =>
        @sendAction 'remove', @get('message')
