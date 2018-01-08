import Ember from 'ember';
import { moment } from 'tahi/lib/aperta-moment';

export default Ember.Component.extend({
  isRecordLost: Ember.computed('submittedAt', function() {
    let dateSubmitted = moment(this.get('paper').get('firstSubmittedAt'));
    let dateChanged = moment('February 1, 2017');
    return dateSubmitted < dateChanged;
  }),
  sortedSentAt: Ember.computed('model.@each.sentAt', function() {
    let arr = this.get('model').toArray();
    arr.sort((a, b) => {
      return b.get('sentAt') - a.get('sentAt');
    });
    return arr;
  }),

  actions: {
    toggleHighlight(e) {
      Ember.$(e.target).prev('.most-recent-activity').toggleClass('highlighter');
    },
  }
});
