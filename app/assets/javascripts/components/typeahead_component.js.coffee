ETahi.TypeAheadComponent = Ember.TextField.extend
  tagName: 'input'
  attributeBindings: ['typeahead:data-provide', 'placeholder']
  classNames: ['form-control affiliation-field']
  sourceList: []

  didInsertElement: ->
    engine = new Bloodhound
      name: 'schools'
      local: @get('sourceList').map (str) ->
        {value: str}
      datumTokenizer: (d) ->
        Bloodhound.tokenizers.whitespace(d.value)
      queryTokenizer: Bloodhound.tokenizers.whitespace
      limit: 10

    engine.initialize()

    @.$().typeahead({
      hint: true,
      highlight: true,
      minLength: 1,
    }, {source: engine.ttAdapter(), displayKey: 'value'})

  substringMatcher: (strs)->
    (q, cb) ->
      matches = []
      substrRegex = new RegExp(q, 'i')

      strs.forEach (str)->
        if (substrRegex.test(str))
            matches.push({ value: str })

      cb(matches)

