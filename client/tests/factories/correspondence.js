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

import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('correspondence', {
  default: {
    date: '2014-09-28T13:54:58.028Z',
    sentAt: 'Thu, 20 Jul 2017 14:58:40 UTC +00:00',
    subject: 'Thank you for submitting your manuscript to PLOS Abominable Snowman',
    body: 'This is a very long body message~~~~',
    recipient: 'john.doe@example.com',
    sender: 'joe@example.com',
    manuscriptVersion: 'v0.0',
    manuscriptStatus: 'rejected',
    attachments: FactoryGuy.hasMany('correspondence-attachment', 2)
  },

  traits: {
    externalCorrespondence: {
      external: true,
      date: '2014-09-28T13:54:58.028Z',
      sentAt: 'Thu, 20 Jul 2017 14:58:40 UTC +00:00',
      subject: 'Thank you for submitting your manuscript to PLOS Abominable Snowman',
      body: 'This is a very long body message~~~~',
      recipient: 'john.doe@example.com',
      sender: 'joe@example.com',
      manuscriptVersion: null,
      manuscriptStatus: null
    }
  }
});
