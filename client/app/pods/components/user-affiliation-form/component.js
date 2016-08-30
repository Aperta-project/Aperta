import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin,{
  countries: Ember.inject.service(),
  today: new Date(),

  _fetchCountries: Ember.on('init', function() {
    this.get('countries').fetch();
  }),

  formattedCountries: Ember.computed('countries.data', function() {
    return this.get('countries.data').map(function(c) {
      return { id: c, text: c };
    });
  }),

  actions:{
    institutionSelected(institution) {
      this.set('newAffiliation.name', institution.name);
      this.set('newAffiliation.ringgoldId', institution['institution-id']);
    },

    countrySelected(country) {
      this.set('newAffiliation.country', country.text);
    },
    commitAffiliation(affiliation) {
      console.log('committing affiliation');
      this.sendAction('commitAffiliation', affiliation);
    },
    hideNewAffiliationForm() {
      console.log('hiding affiliation');
      this.sendAction('hideNewAffiliationForm');
    }
  }
});
