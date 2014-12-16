`import Select2Component from 'tahi/components/select-2'`

Select2SingleComponent = Select2Component.extend
  setSelectedData: (->
    @.$().select2('val', @get('selectedData'))
  ).observes('selectedData')

  initSelection: (el, callback) ->
    callback(@get('selectedData'))

`export default Select2SingleComponent`
