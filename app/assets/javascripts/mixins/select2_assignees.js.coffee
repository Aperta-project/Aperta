ETahi.Select2Assignees = Ember.Mixin.create
  select2RemoteSource: (->
    url: @get('select2RemoteUrl')
    dataType: "json"
    quietMillis: 500
    data: (term) ->
      query: term
    results: (data) =>
      results: data.filtered_users
  ).property('select2RemoteUrl')

  resultsTemplate: (user) ->
    user.full_name

  selectedTemplate: (user) ->
    user.full_name || user.get('fullName')
