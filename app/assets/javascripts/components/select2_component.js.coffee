ETahi.Select2Component = Ember.TextField.extend
  tagName: 'div'
  classNames: ['testing-select2']

  autoFocus: false
  source: []
  closeOnSelect: false
  multiSelect: false

  setup:(->
    options                    = {}
    options.placeholder        = @get('placeholder')
    options.minimumInputLength = @get('minimumInputLength') if @get('minimumInputLength')
    options.formatSelection    = @get('selectedTemplate') if @get('selectedTemplate')
    options.formatResult       = @get('resultsTemplate') if @get('resultsTemplate')
    options.allowClear         = @get('allowClear')
    options.multiple           = @get('multiSelect')
    options.data               = @get('source')
    options.closeOnSelect      = @get('closeOnSelect')
    options.ajax               = @get('remoteSource') if @get('remoteSource')

    @.$().select2(options)
  ).on('didInsertElement').observes('source.[]')
