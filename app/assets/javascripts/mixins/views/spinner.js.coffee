ETahi.SpinnerMixin = Em.Mixin.create
  createSpinner: (dependentKey, selector, color) ->
    return unless @$()
    Em.run =>
      if @get(dependentKey)
        @spinnerDiv = @$(selector)[0]
        @spinner ||= new Spinner(color: color).spin(@spinnerDiv)
        $(@spinnerDiv).show()
      else
        $(@spinnerDiv).hide()
