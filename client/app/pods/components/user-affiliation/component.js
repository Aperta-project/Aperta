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
  today: new Date(),

  newAffiliation: null,

  _fetchCountries: Ember.on('init', function() {
    this.get('countries').fetch();
  }),

  didInsertElement() {
    this._super(...arguments);
    let store = this.get('store');
    let userId = this.get('user.id');

    this.get('restless')
    .get(`/api/affiliations/user/${userId}`)
    .then((data) => {
      store.pushPayload(data);
      this.set(
        'affiliations',
        store.peekAll('affiliation').filterBy('user.id', userId)
      );
    });
  },

  formattedCountries: Ember.computed('countries.data', function() {
    return this.get('countries.data').map(function(c) {
      return { id: c, text: c };
    });
  }),

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
      if (confirm('Are you sure you want to destroy this affiliation?')) {
        this.get('affiliations').removeObject(affiliation);
        affiliation.destroyRecord();
      }
    },

    commitAffiliation(affiliation) {

      this.get('store').findRecord('user', this.get('user.id')).then((user)=>{
        user.get('affiliations').addObject(affiliation);
        this.clearAllValidationErrors();

        affiliation.save().then(() => {
          this.send('hideNewAffiliationForm');
          this.get('affiliations').pushObject(affiliation);
        }, (response) => {
          affiliation.set('user', null);
          this.displayValidationErrorsFromResponse(response);
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
})
