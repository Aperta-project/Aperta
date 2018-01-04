import moment from 'moment';

export default function(date, options) {
  let dateObj = moment(date);
  if (!dateObj.isValid()) { return date; }

  let formats = {
    'long-date-short-time': 'MMMM D, YYYY h:mm A',  //(aka LLL) "September 4, 1986 8:30 PM"
    'long-date': 'MMMM D, YYYY', // "September 4, 1986"
    'short-date': 'MMM D, YYYY', //(aka ll) "Sep 4, 1986"
    'long-month-day': 'MMMM DD', // "September 04"
    'long-date-military-time': 'MMMM DD, YYYY H:mm', // "September 04, 1986 20:30"
  };

  let format = formats[options.format] || options.format || 'MMMM D, YYYY HH:mm';

  return dateObj.format(format);
}
