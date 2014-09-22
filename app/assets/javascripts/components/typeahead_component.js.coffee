ETahi.TypeAheadComponent = Ember.TextField.extend
  tagName: 'input'
  attributeBindings: ['typeahead:data-provide', 'placeholder']
  classNames: ['form-control']
  autoFocus: false
  sourceList: []
  clearOnSelect: false
  setupSelectedListener: ->
    if @get 'suggestionSelected'
      @.$().on 'typeahead:selected', (e, item, index) =>
        @$().val('') if @get 'clearOnSelect'
        @sendAction 'suggestionSelected', item

  autoFocusInput: -> @.$().focus() if @get 'autoFocus'

  didInsertElement: ->
    subvalueProperty = @get('subvalueProperty') || "nonexistentProperty"
    valueProperty = @get('valueProperty')
    engine = new Bloodhound
      name: 'schools'
      local: @get('sourceList').map (item) ->
        if Object.prototype.toString.call(item) is '[object Object]'
          value: item.get(valueProperty)
          subvalue: item.get(subvalueProperty)
          object: item
        else
          value: item
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
      templates:
        suggestion: Handlebars.compile('<strong>{{value}}</strong>{{#if subvalue}}<br><div class="tt-suggestion-sub-value">{{subvalue}}</div>{{/if}}')

    @setupSelectedListener()
    @autoFocusInput()
