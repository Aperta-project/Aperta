ETahi.ChosenView = Ember.Select.extend
  multiple: false
  width: '200px'
  disableSearchThreshold: 10
  searchContains: true
  attributeBindings:['multiple', 'width', 'disableSearchThreshold', 'searchContains']
  changeAction: null
  change: ->
    action = @get('changeAction')
    @get('controller').send(action) if action

  didInsertElement: ->
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

    if @get('multiple')
      options.placeholder_text_multiple = @get('prompt');
    else
      options.placeholder_text_single = @get('prompt');

    @.$().chosen(options)

    @addObserver @get("optionLabelPath").replace(/^content/, "content.@each"), =>
      @rerenderChosen()

  cleanSearchText: (option, context) ->
    option.text

  rerenderChosen: ->
    # Don't trigger Chosen update until after DOM elements have finished rendering.
    Ember.run.scheduleOnce 'afterRender', @, ->
      @.$().trigger('chosen:updated')

Ember.Handlebars.helper('chosen', ETahi.ChosenView)
