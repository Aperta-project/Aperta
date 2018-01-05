import Ember from 'ember';
import formatDate from 'tahi/lib/format-date';

export default Ember.Component.extend({
  classNames: ['scheduled-events'],
  moment: Ember.inject.service(),
  dispatchDateFormat: 'long-date-hour',
  dueAtTimezone: Ember.computed('dueDate', function() {
    let tz = moment.tz.guess();
    return formatDate(moment(this.get('dueDate')).tz(tz), 'short-time-zone');
  }),
  eventsAscendingSort: ['dispatchAt:asc'],
  eventsAscending: Ember.computed.sort('events', 'eventsAscendingSort')
});
