import Ember from 'ember';
import moment from 'moment';

export default Ember.Component.extend({
  isRecordLost: Ember.computed('submittedAt', function() {
    let dateSubmitted = moment(this.get('paper').get('firstSubmittedAt'));
    let dateChanged = moment('February 1, 2017');
    return dateSubmitted < dateChanged;
  }),

  actions: {
    toggleHighlight(e) {
      Ember.$(e.target).prev('.most-recent-activity').toggleClass('highlighter');
    },
  }
});
