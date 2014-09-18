ETahi.TypeAheadComponent = Ember.TextField.extend
  tagName: 'input'
  attributeBindings: ['typeahead:data-provide', 'placeholder']
  classNames: ['form-control']
  autoFocus: false
  sourceList: []
  setupSelectedListener: ->
    if @get 'suggestionSelected'
      @.$().on 'typeahead:selected', (e, item, index) =>
        @sendAction 'suggestionSelected', item

  autoFocusInput: -> @.$().focus() if @get 'autoFocus'

  didInsertElement: ->
    self = this
    engine = new Bloodhound
      name: 'schools'
      local: @get('sourceList').map (item) ->
        if Object.prototype.toString.call(item) is '[object Object]'
          value: item.value
          subvalue: self.get('subvalue')
          object: item.object
        else
          value: item
          subvalue: self.get('subvalue')
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

        suggestion: Handlebars.compile('<strong>{{value}}</strong>{{#if subvalue}}<br>{{subvalue}}{{/if}}')

    @setupSelectedListener()
    @autoFocusInput()
