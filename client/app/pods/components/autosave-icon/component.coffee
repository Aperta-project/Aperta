`import Ember from 'ember'`

AutoSaveIconComponent = Ember.Component.extend
  didInsertElement: (role) ->
    @get 'role.isSaving'
  
  isLoaderShowing: false
  isCheckMarkShowing: false

  startShowingLoader:(->
    @set 'isLoaderShowing', true
    debugger
    Ember.run.later (=>
      @showLoader()
      @showCheckMark()
    ), 1500
  ).observes('role.isSaving')

  showLoader: ->
    @set('isCheckMarkShowing', true)
    $('.loader-component-circle--visible').fadeOut =>
      Ember.run.later (=>
        @set('isLoaderShowing', false)
      ), 500

  showCheckMark: ->
    Ember.run.later (=>
      debugger
      $('.save-message').fadeOut =>
        @set('isCheckMarkShowing', false)
    ), 1000

`export default AutoSaveIconComponent`
