CurrentUser =
  name: 'csrf'
  after: 'currentUser'
  initialize: (container, application) ->
    token = $('meta[name="csrf-token"]').attr('content')
    $.ajaxPrefilter (options, originalOptions, xhr) ->
      xhr.setRequestHeader('X-CSRF-Token', token)

`export default CurrentUser`
