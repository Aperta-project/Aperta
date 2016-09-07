import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin,{

  affiliation: null,
  countries: null,
  editAffiliation: false,


  today: new Date(),

  select2Helper: function(item) {
    return { id: item, text: item };
  },

  formattedCountries: Ember.computed('countries.data', function() {
    return this.get('countries.data').map(this.select2Helper);
  }),

  selectedCountry: Ember.computed('affiliation.country',function(){
    if (!this.get('affiliation.country')) { return null; }
    return this.select2Helper(this.get('affiliation.country'));
  }),

  institution: Ember.computed('affiliation.name', 'affiliation.ringgoldId', function() {
    if (!this.get('affiliation.name')){ return null; }

    return {
      name: this.get('affiliation.name'),
      'institution-id': this.get('affiliation.ringgoldId')
    };
  }),

  actions:{
    editAffiliation(affiliation) {
      this.set('editAffiliation', true);
    },

    institutionSelected(institution) {
      this.set('affiliation.name', institution.name);
      this.set('affiliation.ringgoldId', institution['institution-id']);
    },

    countrySelected(country) {
      this.set('affiliation.country', country.text);
    },

    removeAffiliation(affiliation){
      this.sendAction('removeAffiliation', affiliation);
    },

    commitAffiliation(affiliation) {
      this.set('editAffiliation', false);
      this.sendAction('commitAffiliation', affiliation);
    },

    hideNewAffiliationForm() {
      this.set('editAffiliation', false);
      this.sendAction('hideNewAffiliationForm');
    }
  }
});
