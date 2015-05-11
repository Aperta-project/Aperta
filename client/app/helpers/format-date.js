import Ember from 'ember';

var formatDate = function(date, options) {
  let dateObj = moment(date);
  if (!dateObj.isValid()) { return date; }
  return dateObj.format(options.hash.format || 'LL');
};

export { formatDate };
export default Ember.Handlebars.makeBoundHelper(formatDate);
