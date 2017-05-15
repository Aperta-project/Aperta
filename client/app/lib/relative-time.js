export default function(date, todaysMoment) {
  if(!date) { return ''; }

  if(!todaysMoment) { todaysMoment = moment(); }

  // Always start at the end of today. This allows any time occuring yesterday
  // will be considered as "1 day ago". Otherwise you run into weird boundaries
  todaysMoment = todaysMoment.utc().endOf('day');

  var msPerDay =  1000*60*60*24;
  var ago = todaysMoment - moment(date.toISOString());

  if (ago > msPerDay) {
    // Moment doesn't have a way to *insist* that the delta be
    // displayed in days; it will round to months/years and we want
    // DAYS, specifically.
    const days = Math.floor(ago/msPerDay);
    if (days === 1) {
      return '1 day ago';
    } else {
      return days + ' days ago';
    }
  }
  return moment(date.toISOString()).fromNow();
}
