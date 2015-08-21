import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['control-bar'],
  hasJournalLogo: Ember.computed.notEmpty('paper.journal.logoUrl')
});
