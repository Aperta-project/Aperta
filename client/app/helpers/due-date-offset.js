import Ember from 'ember';

export default Ember.Helper.extend({
  compute([dueDate, dispatchDate]) {
    let diff = dueDate - dispatchDate;
    let dayDiff = Math.ceil(diff / (1000 * 3600 * 24));
    let absDiff = Math.abs(dayDiff);
    let diffDirection = dayDiff ? 'before' : 'after';
    return `(${absDiff} days ${diffDirection} due date)`;
  }
});
