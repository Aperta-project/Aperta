import Ember from 'ember';

export default Ember.Component.extend({
  paper: null, // passed-in
  classNames: ['manuscript'],

  loadJournalStyles() {
    //paper's journal is async
    this.get('paper.journal').then(function(journal) {
      const style = journal.get('manuscriptCss');
      this.$('.manuscript').attr('style', style);
    });
  },

  didInsertElement() {
    this._super(...arguments);
    Ember.run.scheduleOnce('afterRender', this, this.loadJournalStyles);
  }
});
