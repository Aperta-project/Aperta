ETahi.TypeAheadComponent = Ember.Component.extend
  tagName: 'input'
  attributeBindings: ['typeahead:data-provide']
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

