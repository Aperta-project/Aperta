import Ember from 'ember';
import formatNumber from 'tahi/lib/format-number';

export default Ember.Handlebars.makeBoundHelper(function(number) {
  return formatNumber(number);
});
