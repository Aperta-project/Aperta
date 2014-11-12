ETahi.ParticipantSelectorComponent = Ember.Component.extend
  classNames: ['participant-selector']

  setupTooltips: (->
    Em.run.schedule 'afterRender', @, ->
      @$('.select2-search-choice img').tooltip(placement: "bottom")
      @$('.add-participant').tooltip(placement: "bottom")
  ).on('didInsertElement').observes('currentParticipants.@each')

  resultsTemplate: (user) ->
    userInfo =
      if user.roles.length
        "#{user.username}, #{user.roles.join(', ')}"
      else
        user.username

    '<strong>' + user.full_name +
    '</strong><br><div class="suggestion-sub-value">' +
    userInfo + '</div>'

  selectedTemplate: (user) ->
    name = (user.full_name || user.get('fullName'))
    url  = (user.avatar_url || user.get('avatarUrl'))
    new Handlebars.SafeString "<img alt='#{name}' class='user-thumbnail-small' src='#{url}' data-toggle='tooltip' title='#{name}'/>"

  sortByCollaboration: (a, b) ->
    # sort first by if they are collaborators, then by name
    # works, consider enhancing
    if a.roles.length && !b.roles.length
      -1
    else if !a.roles.length && b.roles.length
      1
    else
      if a.full_name < b.full_name
        -1
      else if a.full_name > b.full_name
        1
      else
        0

  remoteSource: (->
    url: "/filtered_users/users/#{@get('paperId')}/"
    dataType: "json"
    quietMillis: 500
    data: (term) ->
      query: term
    results: (data) =>
      data.filtered_users.sort(@sortByCollaboration)
      results: data.filtered_users
  ).property()



  actions:
    addParticipant: (newParticipant) ->
      @sendAction("onSelect", newParticipant.id)
    removeParticipant: (participant) ->
      @sendAction("onRemove", participant.id)
    dropdownClosed: ->
      $('.select2-search-field input').removeClass('active')
      $('.add-participant').removeClass('searching')
    activateDropdown: ->
      $('.select2-search-field input').addClass('active').trigger('click')
      $('.add-participant').addClass('searching')
