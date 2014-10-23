ETahi.Select2Component = Ember.TextField.extend
  tagName: 'div'
  classNames: ['testing-select2']

  autoFocus: false
  source: []
  closeOnSelect: false
  multiSelect: false
  selectedData: []

  setupSelectedListener: ->
    @.$().off 'select2-selecting'
    @.$().on 'select2-selecting', (e) =>
      @sendAction 'selectionSelected', e.choice

  setupRemovedListener: ->
    @.$().off 'select2-removing'
    @.$().on 'select2-removing', (e) =>
      @sendAction 'selectionRemoved', e.choice

  setSelectedData: (->
    @.$().select2('val', @get('selectedData').mapProperty('id'))
  ).observes('selectedData')

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
    options.initSelection      = (el, callback) =>
                                   callback(_.without(@get('selectedData'), null))

    @.$().select2(options)
    @setupSelectedListener()
    @setupRemovedListener()
    @setSelectedData()
  ).on('didInsertElement')
