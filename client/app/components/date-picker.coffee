`import Ember from 'ember'`

DatePickerComponent = Ember.TextField.extend
  tagName: 'input'
  classNames: ['datepicker', 'form-control', 'datepicker-field']
  elementInserted: false

  date: null

  didInsertElement: ->
    Ember.tryInvoke(@get('parentView'), 'registerPicker', [@])
    @set('value', @get('date'))
    $picker = @$().datepicker(autoclose: true)

    $picker.on('changeDate', (event) =>
      @set('date', event.format())
      Ember.tryInvoke(@get('parentView'), 'dateChanged', [@])
    )

    $picker.on('clearDate', (event) =>
      @set('date', null)
      Ember.tryInvoke(@get('parentView'), 'dateChanged', [@])
    )

    @set('$picker', $picker)
    @set('elementInserted', true)

  setStartDate: (dateString) ->
    @get('$picker').datepicker('setStartDate', dateString)

  setEndDate: (dateString) ->
    @get('$picker').datepicker('setEndDate', dateString)

`export default Ember`
