ETahi.Select2SingleComponent = Ember.TextField.extend
  tagName: 'div'
  classNames: ['select2']

  autoFocus: false
  source: []
  closeOnSelect: false
  multiSelect: false
  selectedData: []
  placeholder: ""

  setupSelectedListener: ->
    @.$().off 'select2-selecting'
    @.$().on 'select2-selecting', (e) =>
      @sendAction 'selectionSelected', e.choice

  setupRemovedListener: ->
    @.$().off 'select2-removing'
    @.$().on 'select2-removing', (e) =>
      @sendAction 'selectionRemoved', e.choice

  setupClosedListener: ->
    @.$().off 'select2-close'
    @.$().on 'select2-close', =>
      @sendAction 'dropdownClosed'

  setSelectedData: (->
    @.$().select2('val', @get('selectedData'))
  ).observes('selectedData')

  setup:(->
    options                    = {}
    options.multiple           = false
    options.placeholder        = @get('placeholder')
    options.minimumInputLength = @get('minimumInputLength') if @get('minimumInputLength')
    options.formatSelection    = @get('selectedTemplate') if @get('selectedTemplate')
    options.formatResult       = @get('resultsTemplate') if @get('resultsTemplate')
    options.allowClear         = @get('allowClear')
    options.data               = @get('source')
    options.closeOnSelect      = @get('closeOnSelect')
    options.ajax               = @get('remoteSource') if @get('remoteSource')
    options.initSelection      = (el, callback) => callback(@get('selectedData'))

    @.$().select2(options)
    @setupSelectedListener()
    @setupRemovedListener()
    @setupClosedListener()
    @setSelectedData()
  ).on('didInsertElement')

  teardown: (->
    @.$().off 'select2-selecting'
    @.$().off 'select2-removing'
    @.$().off 'select2-close'
  ).on('willDestroyElement')
