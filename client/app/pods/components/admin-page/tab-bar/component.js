import Ember from 'ember';
import RSVP from 'rsvp';

export default Ember.Component.extend({
  classNames: ['admin-tab-bar'],
  can: Ember.inject.service(),

  canAdminJournal: Ember.computed('journal', function() {
    let journal = this.get('journal');
    if (journal) {
      return this.get('can').can('administer', journal);
    } else {
      let promises = this._journalPermissionPromises(this.get('journals'));
      return this._canAdministerAllJournals(promises);
    }
  }),

  _journalPermissionPromises(journals) {
    let promises = [];
    journals.forEach((journal) => {
      promises.push(new RSVP.Promise((resolve) => {
        resolve(this.get('can').can('administer', journal));
      }));
    });

    return promises;
  },

  _canAdministerAllJournals(permissionsPromises) {
    return RSVP.Promise.all(permissionsPromises).then((values) => {
      let falses = values.filter((value) => { value === false; });
      return Ember.isEmpty(falses);
    });
  }
});
