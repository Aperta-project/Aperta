export default function(date) {
  if(!date) { return ''; }
  return moment(date.toISOString()).fromNow();
}
