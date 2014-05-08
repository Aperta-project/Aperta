ETahi.TypeAheadComponent = Ember.TextField.extend
  tagName: 'input'
  attributeBindings: ['typeahead:data-provide', 'placeholder']
  classNames: ['form-control affiliation-field']
  sourceList: []

  didInsertElement: ->
    @.$().typeahead({
      hint: true,
      highlight: true,
      minLength: 1
    }, {
      name: 'schools',
      displayKey: 'value',
      source: @substringMatcher(@get('sourceList'))
    })

  substringMatcher: (strs)->
    (q, cb) ->
      matches = []
      substrRegex = new RegExp(q, 'i')

      strs.forEach (str)->
        if (substrRegex.test(str))
            matches.push({ value: str })

      cb(matches)

