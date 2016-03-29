export default function(date) {
  if(!date) { return ''; }
  var msPerDay =  1000*60*60*24;
  var ago = moment() - moment(date.toISOString());
  if (ago > msPerDay) {
    // Moment doens't have a way to *insist* that the delta be
    // displayed in days; it will round to months/years and we want
    // DAYS, specifically.
    return Math.floor(ago/msPerDay) + ' days ago';
  }
  return moment(date.toISOString()).fromNow();
}
