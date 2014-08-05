ETahi.AddStuffView = Em.View.extend
  templateName: 'add_stuff'
  classNames: ['add-stuff']
  classNameBindings: ['active:_active', 'animationDirection']

  active: false,
  animationDirection: '_animate-forward'

  actions:
    toggleAddStuffMenu: ->
      @set( 'animationDirection', (if @get('active') then '_animate-backward' else '_animate-forward') )
      @toggleProperty 'active'
