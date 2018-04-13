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

import { moment } from 'tahi/lib/aperta-moment';

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
