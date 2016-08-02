import Ember from 'ember';

const { on } = Ember;

export default Ember.Mixin.create({
  _applyManuscriptCss: on('didInsertElement', function() {
    Ember.run.scheduleOnce('afterRender', ()=> {
      this.get('controller.model.journal').then(function(journal) {
        const style = journal.get('manuscriptCss');
        Ember.$('.manuscript').attr('style', style);
      });
    });
  })
});
