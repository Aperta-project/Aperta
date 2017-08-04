import Ember from 'ember';

export default Ember.Component.extend({
  moment: Ember.inject.service(),
  dispatchDateFormat: 'MMMM D, h:mma z',
  dueAtTimezone: Ember.computed('dueDate', function() {
    let tz = moment.tz.guess();
    return moment(this.get('dueDate')).tz(tz).format('z');
  }),
});
