import Ember from 'ember';
import { task as concurrencyTask } from 'ember-concurrency';

export default Ember.Component.extend({
  reviewerRecommendation: null,

  loadCard: concurrencyTask( function * () {
    let model = this.get('reviewerRecommendation');
    yield Ember.RSVP.all([
      model.get('card'),
      model.get('answers')
    ]);
  }),

  affiliation: Ember.computed('reviewerRecommendation', function() {
    if (this.get('reviewerRecommendation.affiliation')) {
      return {
        id: this.get('reviewerRecommendation.ringgoldId'),
        name: this.get('reviewerRecommendation.affiliation')
      };
    }
  }),

  actions: {

    institutionSelected(institution) {
      this.set('reviewerRecommendation.affiliation', institution.name);
      this.set('reviewerRecommendation.ringgoldId', institution['institution-id']);
    },

    cancelRecommendation() {
      this.attrs.cancelRecommendation(this.get('reviewerRecommendation'));
    },

    saveRecommendation() {
      this.attrs.saveRecommendation(this.get('reviewerRecommendation'));
    }
  }
});
