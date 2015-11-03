import Ember from 'ember';
import RedirectsIfEditable from 'tahi/mixins/views/redirects-if-editable';

export default Ember.Mixin.create(RedirectsIfEditable, {
  classNames: ['edit-paper'],

  applyManuscriptCss: Ember.observer(
    'controller.model.journal.manuscriptCss',
    function() {
      const style = this.get('controller.model.journal.manuscriptCss');
      $('.manuscript').attr('style', style);
   })
});
