`import Select2Component from 'tahi/pods/components/select-2/component'`

Select2MultipleComponent = Select2Component.extend
  multiSelect: true

  setSelectedData: (->
    @$().select2('val', (@get('selectedData') || []).mapProperty('id'))
  ).observes('selectedData')

`export default Select2MultipleComponent`
