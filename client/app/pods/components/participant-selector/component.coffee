`import Ember from 'ember'`

ParticipantSelectorComponent = Ember.Component.extend
  classNames: ['participant-selector', 'select2-multiple']

  setupTooltips: (->
    Ember.run.schedule 'afterRender', @, ->
      @$('.select2-search-choice img').tooltip(placement: "bottom")
      @$('.add-participant-button').tooltip(placement: "bottom")
  ).on('didInsertElement').observes('currentParticipants.[]')

  resultsTemplate: (user) ->
    userInfo =
      if user.old_roles.length
        "#{user.username}, #{user.old_roles.join(', ')}"
      else
        user.username

    '<strong>' + user.full_name +
    '</strong><br><div class="suggestion-sub-value">' +
    userInfo + '</div>'

  selectedTemplate: (user) ->
    name = (user.full_name || user.get('fullName'))
    url  = (user.avatar_url || user.get('avatarUrl'))
    Ember.String.htmlSafe "<img alt='#{name}' class='user-thumbnail-small' src='#{url}' data-toggle='tooltip' title='#{name}'/>"

  sortByCollaboration: (a, b) ->
    # sort first by if they are collaborators, then by name
    # works, consider enhancing
    if a.old_roles.length && !b.old_roles.length
      -1
    else if !a.old_roles.length && b.old_roles.length
      1
    else
      if a.full_name < b.full_name
        -1
      else if a.full_name > b.full_name
        1
      else
        0

  remoteSource: (->
    url: "/api/filtered_users/users/#{@get('paperId')}/"
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
      @attrs.onSelect(newParticipant.id)
    removeParticipant: (participant) ->
      @attrs.onRemove(participant.id)
    dropdownClosed: ->
      @$('.select2-search-field input').removeClass('active')
      @$('.add-participant-button').removeClass('searching')
    activateDropdown: ->
      @$('.select2-search-field input').addClass('active').trigger('click')
      @$('.add-participant-button').addClass('searching')

`export default ParticipantSelectorComponent`
