ETahi.ErrorMessageComponent = Ember.Component.extend
  classNames: ['error-message']
  classNameBindings: ['visible']
  layoutName: 'error-message'

  visible: (->
    if @get('message') then '' else 'error-message--hidden'
  ).property('message')
