`import Ember from 'ember'`
`import SpinnerMixin from 'tahi/mixins/views/spinner'`

JournalIndexView = Ember.View.extend SpinnerMixin,
  toggleSpinner: (->
    @createSpinner('controller.epubCoverUploading', '#epub-cover-spinner', color: '#aaa')
  ).observes('controller.epubCoverUploading').on('didInsertElement')

`export default JournalIndexView`
