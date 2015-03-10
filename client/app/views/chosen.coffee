`import Ember from 'ember'`

ChosenView = Ember.Select.extend
  multiple: false
  width: '44%'
  disableSearchThreshold: 0
  disabled: false
  searchContains: true
  attributeBindings:['multiple', 'width', 'disableSearchThreshold', 'searchContains', 'data-placeholder']
  changeAction: null

  change: ->
    action = @get('changeAction')
    @get('controller').send(action, @get('value')) if action

  disabledDidChange: (->
    @.$().attr('disabled', @get('disabled')).trigger('chosen:updated')
  ).observes('disabled')

  setup: (->
    options =
      multiple: @get('multiple')
      width: @get('width')
      disable_search_threshold: @get('disableSearchThreshold')
      search_contains: @get('searchContains')
      no_results_text: @get('noResultsText')
      max_selected_options: @get('maxSelectedOptions')
      allow_single_deselect: @get('allowSingleDeselect')
      inherit_select_classes: true

    options.clean_search_text = @cleanSearchText
    options.calling_context = @

    @.$().chosen(options)

    @addObserver @get("optionLabelPath").replace(/^content/, "content.@each"), =>
      @rerenderChosen()
    @addObserver "value", =>
      @rerenderChosen()
  ).on('didInsertElement')

  teardown: (->
    @.$().chosen('destroy')
  ).on('willDestroyElement')

  cleanSearchText: (option, context) ->
    option.text

  warnValue: ( ->
    if @get('multiple') && !@get('selection')
      throw new Error("You should use the selection option with a multiple select rather than value")
  ).on('init')

  observeSelection: (->
    @rerenderChosen()
  ).observes('selection.@each')

  rerenderChosen: ->
    # Don't trigger Chosen update until after DOM elements have finished rendering.
    Ember.run.scheduleOnce 'afterRender', @, ->
      if @.$()
        @.$().trigger('chosen:updated')

`export default ChosenView`
