`import Ember from 'ember'`

DatePickerGroupComponent = Ember.Component.extend
  startPicker: null
  endPicker: null

  registerPicker: (datePicker) ->
    @set(datePicker.get('role'), datePicker)

  dateChanged: (datePicker) ->
    @enforceConsistency()

  enforceConsistency: ->
    Ember.run =>
      if @get('startPicker.elementInserted') && @get('endPicker.elementInserted')
        @get('endPicker').setStartDate(@get('startPicker.date'))
        @get('startPicker').setEndDate(@get('endPicker.date'))

`export default DatePickerGroupComponent`
