ETahi.TypeAheadComponent = Ember.TextField.extend
  tagName: 'input'
  attributeBindings: ['typeahead:data-provide', 'placeholder']
  classNames: ['form-control']
  autoFocus: false
  sourceList: []
  clearOnSelect: false
  setupSelectedListener: ->
    if @get 'suggestionSelected'
      @.$().off 'typeahead:selected'
      @.$().on 'typeahead:selected', (e, item, index) =>
        @sendAction 'suggestionSelected', item
        @$().typeahead('val', '') if @get 'clearOnSelect'
        @get('engine').clearRemoteCache()
        @_setup()

  autoFocusInput: -> @.$().focus() if @get 'autoFocus'

  formattedData: (item) ->
    subvalueProperty = @get('subvalueProperty') || "nonexistentProperty"
    valueProperty = @get('valueProperty')

    value: item.get(valueProperty)
    subvalue: item.get(subvalueProperty)
    object: item


  setData: (->
    engine = @get('engine')
    engine.local = @get('sourceList').map (item) =>
      item = Ember.Object.create(item) unless item.get
      @formattedData(item)

    engine.initialize(true)
  ).observes('sourceList.[]')

  _setup: (->
    options =
      name: 'schools'

      local: @get('sourceList').map (item) =>
        item = Ember.Object.create(item) unless item.get
        @formattedData(item)

      datumTokenizer: (d) -> Bloodhound.tokenizers.whitespace d.value
      queryTokenizer: Bloodhound.tokenizers.whitespace
      limit: 10

    if @get('remoteUrl')
      options.remote =
        url: @get('remoteUrl')
        filter: (response) =>
          response.map (item) =>
            item = Ember.Object.create(item)
            @formattedData(item)

    engine = new Bloodhound(options)
    engine.initialize()
    @set('engine', engine)

    @.$().typeahead
      hint: true
      highlight: true
      minLength: 1
    ,
      source: engine.ttAdapter()
      displayKey: 'value'
      templates:
        suggestion: Handlebars.compile('<strong>{{value}}</strong>{{#if subvalue}}<br><div class="tt-suggestion-sub-value">{{subvalue}}</div>{{/if}}')

    @setupSelectedListener()
    @autoFocusInput()
  ).on('didInsertElement')
