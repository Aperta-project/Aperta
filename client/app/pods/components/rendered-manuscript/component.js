import Ember from 'ember';
import LazyLoader from 'ember-cli-lazyloader/lib/lazy-loader';
import ENV from 'tahi/config/environment';

export default Ember.Component.extend({
  paper: null, // passed-in
  classNames: ['manuscript'],

  loadJournalStyles() {
    //paper's journal is async
    this.get('paper.journal').then((journal) => {
      const style = journal.get('manuscriptCss');
      this.$('.manuscript').attr('style', style);
    });
  },

  didInsertElement() {
    this._super(...arguments);
    Ember.run.scheduleOnce('afterRender', this, this.loadJournalStyles);
  },

  didRender() {
    this._super(...arguments);
    Ember.run.scheduleOnce('afterRender', this, this.refreshEquations);
  },

  updateEquations: Ember.observer('paper.body', function() {
    Ember.run.scheduleOnce('afterRender', this, this.refreshEquations);
  }),

  loadMathJax: function() {
    LazyLoader.loadScripts([ENV.mathjax.url]).then(() => {
      this.refreshEquations();
    });
  },

  refreshEquations:  function() {
    if (!window.MathJax) { this.loadMathJax(); return; }
    else if (!window.MathJax.Hub) { return; }

    var view = this.$()[0];
    Ember.run.next(() => {
      MathJax.Hub.Queue(['Typeset', MathJax.Hub, view]);
    });
  }
});
