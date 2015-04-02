`import Ember from 'ember'`

AutoSaveIconComponent = Ember.Component.extend
  didInsertElement: (journalTask) ->
    @get 'journalTask.isSaving'
  
  isLoaderShowing: false
  isCheckMarkShowing: false

  startShowingLoader:(->
    # Check journalTask.role in case the role is not in the 'availableTaskRoles.'
    # If it isn't, the value is null and should not fire the loader event
    if @get 'journalTask.role'
      @set 'isLoaderShowing', true
      Ember.run.later (=>
        @showLoader()
        @showCheckMark()
      ), 1500
  ).observes('journalTask.isSaving')

  showLoader: ->
    @set('isCheckMarkShowing', true)
    $('.loader-component-circle--visible').fadeOut =>
      Ember.run.later (=>
        @set('isLoaderShowing', false)
      ), 500

  showCheckMark: ->
    Ember.run.later (=>
      $('.save-message').fadeOut =>
        @set('isCheckMarkShowing', false)
    ), 1000

`export default AutoSaveIconComponent`
