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
      this.sendAction('institutionSelected', institution);
    }
  }
});
