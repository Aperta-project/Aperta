`import Ember from 'ember'`

TypeAheadComponent = Ember.TextField.extend

  suggestionEngine: null
  displayKey: null
  selection: null
  url: null

  setupSuggestionEngine:(->
    self = @
    @_super()
    @suggestionEngine = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace(self.get('displayKey'))
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote:
        url: self.get('url')
        filter: (response) ->
          $.map response.filtered_users, (user) ->
            { name: user.full_name, email: user.email }
    )

    @suggestionEngine.initialize()
  ).on('init'),

  setup:(->
    @.$().typeahead {
      hint: true
      highlight: true
      minLength: 2
    },
      name: 'auto-complete'
      displayKey: @get('displayKey')
      source: @get('suggestionEngine').ttAdapter()
      templates:
        empty: ->
          "no results"
        suggestion: (context) ->
          "#{context.name} #{context.email}"


    @.$().on('typeahead:selected', (obj, data, name) ->
      console.log obj
      console.log data
      console.log name
    )

  ).on('didInsertElement'),

  willDestroyElement: ->
    @.$().typeahead('destroy')

`export default TypeAheadComponent`
