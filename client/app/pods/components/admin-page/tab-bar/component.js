import Ember from 'ember';
import RSVP from 'rsvp';

export default Ember.Component.extend({
  classNames: ['admin-tab-bar'],
  can: Ember.inject.service(),

  canAdminJournal: Ember.computed('journal', function() {
    let canService = this.get('can');
    let journal = this.get('journal');
    if (journal) {
      return canService.can('administer', journal);
    } else {
      let promises = [];

      this.get('journals').forEach((journal) => {
        promises.push(new RSVP.Promise((resolve) => {
          resolve(canService.can('administer', journal));
        }));
      });

      return RSVP.Promise.all(promises).then((values) => {
        let falses = values.filter((value) => { value === false; });
        return Ember.isEmpty(falses);
      });
    }
  }),
});
