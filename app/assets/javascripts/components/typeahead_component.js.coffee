ETahi.TypeAheadComponent = Ember.TextField.extend
  tagName: 'input'
  attributeBindings: ['typeahead:data-provide', 'placeholder']
  classNames: ['form-control']
  autoFocus: false
  sourceList: []
  setupSelectedListener: ->
    if @get 'suggestionSelected'
      @.$().on 'typeahead:selected', (e, item, index) =>
        # debugger
        @sendAction 'suggestionSelected', item.value

  autoFocusInput: -> @.$().focus() if @get 'autoFocus'

  didInsertElement: ->
    engine = new Bloodhound
      name: 'schools'
      local: @get('sourceList').map (str) -> value: str
      datumTokenizer: (d) -> Bloodhound.tokenizers.whitespace d.value
      queryTokenizer: Bloodhound.tokenizers.whitespace
      limit: 10

    engine.initialize()

    @.$().typeahead
      hint: true
      highlight: true
      minLength: 1
    ,
      source: engine.ttAdapter()
      displayKey: 'value'

    @setupSelectedListener()
    @autoFocusInput()

  substringMatcher: (chars) ->
    (query, callback) ->
      matches = []
      substrRegex = new RegExp query, 'i'
      chars.forEach (char) -> matches.push value: char if substrRegex.test char
      callback matches
