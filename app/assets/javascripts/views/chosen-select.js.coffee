ETahi.ChosenView = Ember.Select.extend
  multiple: false
  width: '150px'
  disableSearchThreshold: 10
  searchContains: true
  attributeBindings:['multiple', 'width', 'disableSearchThreshold', 'searchContains', 'data-placeholder']
  changeAction: null
  change: ->
    action = @get('changeAction')
    @get('controller').send(action) if action

  setup: (->
    options =
      multiple: @get('multiple')
      width: @get('width')
      disable_search_threshold: @get('disableSearchThreshold')
      search_contains: @get('searchContains')
      no_results_text: @get('noResultsText')
      max_selected_options: @get('maxSelectedOptions')
      allow_single_deselect: @get('allowSingleDeselect')

    options.clean_search_text = @cleanSearchText
    options.calling_context = @

    @.$().chosen(options)

    @addObserver @get("optionLabelPath").replace(/^content/, "content.@each"), =>
      @rerenderChosen()
  ).on('didInsertElement')

  teardown: (->
    @.$().chosen('destroy')
  ).on('willDestroyElement')

  cleanSearchText: (option, context) ->
    option.text

  rerenderChosen: ->
    # Don't trigger Chosen update until after DOM elements have finished rendering.
    Ember.run.scheduleOnce 'afterRender', @, ->
      @.$().trigger('chosen:updated')

Ember.Handlebars.helper('chosen', ETahi.ChosenView)
