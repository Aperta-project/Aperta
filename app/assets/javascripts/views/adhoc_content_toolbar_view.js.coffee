ETahi.AdhocContentToolbarView = Em.View.extend
  templateName: 'adhoc_content_toolbar'
  classNames: ['adhoc-content-toolbar']
  classNameBindings: ['active:_active', 'animationDirection']

  active: false,
  animationDirection: '_animate-forward'

  actions:
    toggleAdhocContentToolbar: ->
      @set( 'animationDirection', (if @get('active') then '_animate-backward' else '_animate-forward') )
      @toggleProperty 'active'
