`import Ember from 'ember'`

AutoSaveIconComponent = Ember.Component.extend
  didInsertElement: (journalTask) ->
    @get 'journalTask.isSaving'
  
  isLoaderShowing: false
  isCheckMarkShowing: false

  startShowingLoader:(->
    if @get 'journalTask.isSaving'
      @set 'isLoaderShowing', true
      Ember.run.later (=>
        @hideLoader()
        @hideCheckMark()
      ), 1500
  ).observes('journalTask.isSaving')

  hideLoader: ->
    @set('isCheckMarkShowing', true)
    $('.loader-component-circle--visible').fadeOut =>
      Ember.run.later (=>
        @set('isLoaderShowing', false)
      ), 500

  hideCheckMark: ->
    Ember.run.later (=>
      $('.save-message').fadeOut =>
        @set('isCheckMarkShowing', false)
    ), 1000

`export default AutoSaveIconComponent`
