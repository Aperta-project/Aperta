import Ember from 'ember';
import RSVP from 'rsvp';
import DS from 'ember-data';

export default Ember.Component.extend({
  classNames: ['admin-tab-bar'],
  can: Ember.inject.service(),

  canAdminJournal: Ember.computed.alias('canAdminJournalPromise.content'),

  canAdminJournalPromise: Ember.computed('journal', function() {
    let journal = this.get('journal');

    if (journal) {
      let permission = this.get('can').can('administer', journal);
      return this._wrapInPromiseObject(permission);
    } else {

      let promiseArray = this.get('journals').map((journal) => {
        return this.get('can').can('administer', journal);
      });

      let returnPromise = RSVP.Promise.all(promiseArray).then((values) => {
        return values.every((value) => { return value === true; });
      });

      return this._wrapInPromiseObject(returnPromise);
    }
  }),

  // canAdminJournal() needs to return a promise based on its reliance on a set of
  // of `can` permissions which each make an ajax request. Wrapping that promise
  // in this DS.PromiseObject allows the ember computed to compute properly  off
  // of the the content property of the PromiseObject as seen in canAdminJournal()
  // More info at: https://www.emberjs.com/api/ember-data/2.14/classes/DS.PromiseObject
  _wrapInPromiseObject(value) {
    return DS.PromiseObject.create({promise: value});
  }
});
