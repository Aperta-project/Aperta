import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin,{

  //pass this in
  user: null,

  restless: Ember.inject.service(),
  store: Ember.inject.service(),
  countries: Ember.inject.service(),

  showAffiliationForm: false,
  affiliations: Ember.computed(function() { return []; }),
  loading: true,

  newAffiliation: null,

  init() {
    this._super(...arguments);
    this.get('countries').fetch();
  },

  didInsertElement() {
    this._super(...arguments);
    const store = this.get('store');
    const userId = this.get('user.id');

    this.get('restless')
    .get(`/api/affiliations/user/${userId}`)
    .then((data) => {
      store.pushPayload(data);
      this.set(
        'affiliations',
        store.peekAll('affiliation').filterBy('user.id', userId)
      );
      this.set('loading', false);
    });
  },

  actions: {
    hideNewAffiliationForm() {
      this.clearAllValidationErrors();
      this.set('showAffiliationForm', false);
      if (this.get('newAffiliation.isNew')) {
        this.get('newAffiliation').deleteRecord();
      }
    },

    showNewAffiliationForm() {
      this.set('newAffiliation', this.get('store').createRecord('affiliation'));
      this.set('showAffiliationForm', true);
    },

    removeAffiliation(affiliation) {
      if (window.confirm('Are you sure you want to destroy this affiliation?')) {
        this.get('affiliations').removeObject(affiliation);
        affiliation.destroyRecord();
      }
    },

    commitAffiliation(affiliation) {
      return this.get('store').findRecord('user', this.get('user.id')).then((user)=>{
        user.get('affiliations').addObject(affiliation);
        this.clearAllValidationErrors();
        const isNew = affiliation.get('isNew');
        return affiliation.save().then(() => {
          this.send('hideNewAffiliationForm');
          if (isNew) { this.get('affiliations').pushObject(affiliation); }
        });
      });
    },

    institutionSelected(institution) {
      this.set('newAffiliation.name', institution.name);
      this.set('newAffiliation.ringgoldId', institution['institution-id']);
    },

    countrySelected(country) {
      this.set('newAffiliation.country', country.text);
    },
  }
});
