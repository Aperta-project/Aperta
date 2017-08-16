import Ember from 'ember';
import moment from 'moment';

export default Ember.Helper.extend({
  compute([dueDate, dispatchDate]) {
    let diff = new Date(dueDate) - new Date(dispatchDate);
    let duration = moment.duration(diff).humanize();
    let direction = diff < 0 ? 'before' : 'after';
    return `(${duration} ${direction} due date)`;
  }
});
