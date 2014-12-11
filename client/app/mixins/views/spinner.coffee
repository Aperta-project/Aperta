`import Ember from 'ember'`

SpinnerMixin = Ember.Mixin.create
  createSpinner: (dependentKey, selector, opts) ->
    return unless @$()
    Em.run =>
      if @get(dependentKey)
        @spinnerDiv = @$(selector)[0]
        @spinner ||= new Spinner(opts).spin(@spinnerDiv)
        $(@spinnerDiv).show()
        $(@spinnerDiv).addClass('spinning')
      else
        $(@spinnerDiv).hide()
        $(@spinnerDiv).removeClass('spinning')

`export default SpinnerMixin`
