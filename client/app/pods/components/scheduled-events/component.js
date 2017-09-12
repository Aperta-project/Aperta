import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['scheduled-events'],
  moment: Ember.inject.service(),
  dispatchDateFormat: 'MMMM D, ha z',
  dueAtTimezone: Ember.computed('dueDate', function() {
    let tz = moment.tz.guess();
    return moment(this.get('dueDate')).tz(tz).format('z');
  }),
  defaultState: {value: true}
});
