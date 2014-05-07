ETahi.DatePickerComponent = Ember.TextField.extend
  tagName: 'input'
  attributeBindings: ['placeholder']
  classNames: ['datepicker', 'form-control', 'datepicker-field']

  didInsertElement: ->
    @.$().datepicker({
      autoclose: true
    })
