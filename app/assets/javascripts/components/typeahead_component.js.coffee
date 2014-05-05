ETahi.TypeAheadComponent = Ember.Component.extend
  tagName: 'input'
  attributeBindings: ['typeahead:data-provide']

  didInsertElement: ->
    @.$().typeahead({
      hint: true,
      highlight: true,
      minLength: 1
    }, {
      name: 'states',
      displayKey: 'value',
      source: @substringMatcher(@usStates)
    })

  substringMatcher: (strs)->
    (q, cb) ->
      matches = []
      substrRegex = new RegExp(q, 'i')

      strs.forEach (str)->
        if (substrRegex.test(str))
            matches.push({ value: str })

      cb(matches)

  usStates: [
    'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California',
    'Colorado', 'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii',
    'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'
  ]

