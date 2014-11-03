ETahi.ShowIfParentComponent = Ember.Component.extend
  showContent: Em.computed.oneWay 'initialShowState'

  initialShowState: (->
    prop = @get('propName')
    @get(prop)
  ).property('parentView')

  prop: ""

  propName: ( ->
    "parentView.#{@get('prop')}"
  ).property('prop')

  showPropDidChange: (sender, key) ->
    @set('showContent', sender.get(key))
  
  setupObserver: ( ->
    @addObserver(@get('propName'), this, @showPropDidChange)
  ).on('didInsertElement')

  removeObserver: ( ->
    Ember.removeObserver(this, @get('propName'), this, @showPropDidChange)
  ).on('willDestroyElement')
