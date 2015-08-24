import Ember from 'ember';
import RedirectsIfEditable from 'tahi/mixins/views/redirects-if-editable';

const { on } = Ember;

export default Ember.View.extend(RedirectsIfEditable, {

  applyManuscriptCss: on('didInsertElement', function() {
    $('#paper-body').attr('style', this.get('controller.model.journal.manuscriptCss'));
  }),

  setBackgroundColor: on('didInsertElement', function() {
    $('html').addClass('matte paper-submitted');
  }),

  resetBackgroundColor: on('willDestroyElement', function() {
    $('html').removeClass('matte paper-submitted');
  })

});
