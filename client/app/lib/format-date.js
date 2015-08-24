export default function(date, options) {
  let dateObj = moment(date);
  if (!dateObj.isValid()) { return date; }
  return dateObj.format(options.format || 'MMMM D, YYYY h:mm A [GMT]');
}
