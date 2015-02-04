`import Ember from 'ember'`

UserRoleSelectorComponent = Ember.Component.extend
  classNames: ['user-role-selector', 'select2-multiple']

  actions:
    assignRole: (data) ->
      @sendAction("selected", data)
    removeRole: (data) ->
      @sendAction("removed", data)
    dropdownClosed: ->
      @$('.select2-search-field input').removeClass('active')
      @$('.assign-role-button').removeClass('searching')
    activateDropdown: ->
      @$('.select2-search-field input').addClass('active').trigger('click')
      @$('.assign-role-button').addClass('searching')

`export default UserRoleSelectorComponent`
