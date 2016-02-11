`import Ember from 'ember'`

Select2Component = Ember.TextField.extend
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
      Ember.run.schedule 'actions', this, ->
        @sendAction 'selectionSelected', e.choice

  setupRemovedListener: ->
    @.$().off 'select2-removing'
    @.$().on 'select2-removing', (e) =>
      Ember.run.schedule 'actions', this, ->
        @sendAction 'selectionRemoved', e.choice

  setupClearingListener: ->
    @.$().off 'select2-clearing'
    @.$().on 'select2-clearing', (e) =>
      Ember.run.schedule 'actions', this, ->
        @sendAction 'selectionCleared', e.choice

  setupClosedListener: ->
    @.$().off 'select2-close'
    @.$().on 'select2-close', =>
      Ember.run.schedule 'actions', this, ->
        @sendAction 'dropdownClosed'

  setSelectedData: (->
    @.$().select2('val', @get('selectedData').mapProperty('id'))
  ).observes('selectedData')

  initSelection: (el, callback) ->
    selectedData = @get('selectedData') || []
    callback(selectedData.compact())

  repaint: ->
    @teardown()
    @setup()

  setup:(->
    options                    = {}
    options.formatSelection    = @get('selectedTemplate') if @get('selectedTemplate')
    options.formatResult       = @get('resultsTemplate') if @get('resultsTemplate')
    options.multiple           = @get('multiSelect')
    options.data               = @get('source')
    options.ajax               = @get('remoteSource') if @get('remoteSource')
    options.dropdownCssClass   = @get('dropdownClass') if @get('dropdownClass')
    options.initSelection      = Ember.run.bind(this, @initSelection)

    # just pass these through to select2
    passThroughOptions = [
      'allowClear'
      'closeOnSelect'
      'minimumInputLength',
      'minimumResultsForSearch'
      'placeholder',
      'width']
    options[opt] = @get(opt) for opt in passThroughOptions when @get(opt)

    @.$().select2(options)
    @.$().select2('enable', @get('enable'))
    @setupSelectedListener()
    @setupRemovedListener()
    @setupClosedListener()
    @setupClearingListener()
    @setSelectedData()

    @addObserver('source', @, @repaint)
    @addObserver('enable', @, @repaint)
  ).on('didInsertElement')

  teardown: (->
    @.$().off 'select2-selecting'
    @.$().off 'select2-removing'
    @.$().off 'select2-close'
    @removeObserver('source', @, @repaint)
    @removeObserver('enable', @, @repaint)
  ).on('willDestroyElement')

`export default Select2Component`
