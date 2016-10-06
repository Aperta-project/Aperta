import Ember from 'ember';
import DS from 'ember-data';

export default DS.Model.extend({
  restless: Ember.inject.service('restless'),
  identifier: DS.attr('string'),
  name: DS.attr('string'),
  profile_url: DS.attr('string'),
  status: DS.attr('string'),
  oauthAuthorizeUrl: DS.attr('string'),

  clearRecord() {
    return this.get('restless').put(`/api/orcid_accounts/${this.get('id')}/clear`)
    .then((data) => {
      this.store.pushPayload(data);
    });
  },
  chooseRandomId() {
    return this.get('restless').put(`/api/orcid_accounts/${this.get('id')}/choose_random_id`)
  }
});
