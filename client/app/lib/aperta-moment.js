/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import moment from 'moment';
export { formatDate, formatFor, moment };
export default formatDate;

function formatDate(date, options) {
  let dateObj = moment(date);
  if (!dateObj.isValid()) { return date; }

  if (typeof options === 'string') {
    // convert string param to hash
    options = { format: options };
  }

  let dateFormat = formatFor(options.format);
  return dateObj.format(dateFormat);
}

function formatFor(format) {
  return formats[format] || format || formats.default;
}

const formats = {
  'default':                   'MMMM D, YYYY HH:mm', // "September 4, 1986 20:30"
  'year-month-day':            'YYYY-MM-DD', // "1986-09-04"
  'long-month-day-1':          'MMMM D', // "September 4"
  'long-date-1':               'MMMM D, YYYY', // "September 4, 1986"
  'long-date-time-1':          'MMMM D, YYYY HH:mm', // "September 4, 1986 20:30"
  'long-date-short-time-zone': 'MMMM D, YYYY h:mm a z',  // "September 4, 1986 8:30 pm PDT"
  'long-date-short-time':      'MMMM D, YYYY h:mm A',  // (alias: LLL) "September 4, 1986 8:30 PM"
  'long-date-hour':            'MMMM D, ha z', // "September 4, 8pm PDT"
  'long-month-day-2':          'MMMM DD', // "September 04"
  'long-date-2':               'MMMM DD, YYYY', // "September 04, 1986"
  'long-date-time-2':          'MMMM DD, YYYY H:mm', // "September 04, 1986 20:30"
  'long-date-day-ordinal':     'MMMM Do YYYY', // "September 4th 1986"
  'short-date':                'MMM D, YYYY', // (alias: ll) "Sep 4, 1986"
  'short-date-long-day':       'MMM DD, YYYY', // "Sep 04, 1986"
  'month-day-year':            'MM/DD/YYYY', // "09/04/1986"
  'month-day-year-time':       'MM/DD/YYYY H:m', // ""09/04/1986 20:30""
  'hour-minute-1':             'H:m', // "20:30"
  'hour-minute-2':             'H:mm', // "20:30"
  'short-time-zone':           'z', // "PDT"
};
