import Ember from 'ember';
import RedirectsIfEditable from 'tahi/mixins/views/redirects-if-editable';

const { on } = Ember;

export default Ember.Mixin.create(RedirectsIfEditable, {
  classNames: ['edit-paper'],

  _applyManuscriptCss: on('didInsertElement', function() {
    Ember.run.scheduleOnce('afterRender', ()=> {
      this.get('controller.model.journal').then(function(journal) {
        const style = journal.get('manuscriptCss');
        Ember.$('.manuscript').attr('style', style);
      });
    });
  })
});
