import Ember from 'ember';

export default Ember.Component.extend({
  disabled: false,

  parseInstitutions(response) {
    return response.institutions;
  },

  displayInstitution(institution) {
    return institution.name;
  },

  unknownInstitution(name) {
    return {
      name: name,
      'institution-id': -1
    };
  },

  actions: {
    institutionSelected(institution) {
      if(this.attrs.validate) {
        this.attrs.validate(institution.name);
      }
      this.sendAction('institutionSelected', institution);
    }
  }
});
