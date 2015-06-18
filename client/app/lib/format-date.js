export default function(date, options) {
  let dateObj = moment(date);
  if (!dateObj.isValid()) { return date; }
  return dateObj.format(options.hash.format || 'LL');
}
