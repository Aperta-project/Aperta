import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['scheduled-events'],
  moment: Ember.inject.service(),
  dispatchDateFormat: 'long-date-hour',
  dueAtTimezone: Ember.computed('dueDate', function() {
    let tz = moment.tz.guess();
    return moment(this.get('dueDate')).tz(tz).format('z');
  }),
  eventsAscendingSort: ['dispatchAt:asc'],
  eventsAscending: Ember.computed.sort('events', 'eventsAscendingSort')
});
