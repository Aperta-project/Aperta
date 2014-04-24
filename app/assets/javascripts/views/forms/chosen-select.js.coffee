ETahi.ChosenView = Ember.Select.extend
  multiple: false
  width: '200px'
  disableSearchThreshold: 0
  searchContains: true
  attributeBindings:['multiple', 'width', 'disableSearchThreshold', 'searchContains', 'data-placeholder']
  changeAction: null

  change: ->
    action = @get('changeAction')
    @get('controller').send(action, @get('value')) if action

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

  rerenderChosen: ->
    # Don't trigger Chosen update until after DOM elements have finished rendering.
    Ember.run.scheduleOnce 'afterRender', @, ->
      if @.$()
        @.$().trigger('chosen:updated')

Ember.Handlebars.helper('chosen', ETahi.ChosenView)
