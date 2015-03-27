`import Ember from 'ember'`

EditFiguresView = Ember.View.extend

  classNames: ['figures-overlay']

  toolbar: null

  propagateToolbar: ( ->
    @set('controller.toolbar', @get('toolbar'))
  ).observes('toolbar')

  showOverlay: ( ->
    $('body').addClass('modal-open');
  ).on('didInsertElement')

  hideOverlay: ( ->
    $('body').removeClass('modal-open');
  ).on('willDestroyElement')


`export default EditFiguresView`
