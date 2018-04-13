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

const matchesPaymentOption = function(task, answer) {
  return task.responseToQuestion('plos_billing--payment_method') == answer;
};

const numberMessage = `Must be a number and contain no symbols,
                or letters, e.g. $1,000.00 should be written 1000`;

const ringgoldMessage = `Must be a string`;

const PFA_VALIDATION = {
  type: 'number',
  allowBlank: true,
  onlyInteger: true,
  message: numberMessage
};

const RINGGOLD_VALIDATION = {
  type: 'presence',
  message: ringgoldMessage
};

const RINGGOLD_VALIDATION_WITH_SKIP = $.extend({
  skipCheck(key) {
    const task      = this.get('task');
    const RINGGOLD  = matchesPaymentOption(task, 'institutional');
    return !RINGGOLD;
  }
}, RINGGOLD_VALIDATION);

// Note: These answers depend on the value of other questions
// For example:
// 'plos_billing--pfa_question_1b' -> 'plos_billing--pfa_question_1'
// if `question_1` value is true, validate, else skip

const PFA_VALIDATION_WITH_SKIP = $.extend({
  skipCheck(key) {
    const parentKey = key.slice(0, -1);
    const task      = this.get('task');
    const notPFA    = !matchesPaymentOption(task, 'pfa');
    const notActive = !(task.responseToQuestion(parentKey));
    return notPFA || notActive;
  }
}, PFA_VALIDATION);

export default {
  'plos_billing--first_name':        ['presence'],
  'plos_billing--last_name':         ['presence'],
  'plos_billing--department':        ['presence'],
  'plos_billing--phone_number':      ['presence'],
  'plos_billing--email':             ['presence', 'email'],
  'plos_billing--address1':          ['presence'],
  'plos_billing--city':              ['presence'],
  'plos_billing--postal_code':       ['presence'],
  'plos_billing--payment_method':    ['presence'],
  'plos_billing--affiliation1':      ['presence'],

  'plos_billing--pfa_question_1b':   [PFA_VALIDATION_WITH_SKIP],
  'plos_billing--pfa_question_2b':   [PFA_VALIDATION_WITH_SKIP],
  'plos_billing--pfa_question_3a':   [PFA_VALIDATION_WITH_SKIP],
  'plos_billing--pfa_question_4a':   [PFA_VALIDATION_WITH_SKIP],

  'plos_billing--pfa_amount_to_pay': [$.extend({
    skipCheck() {
      return !matchesPaymentOption(this.get('task'), 'pfa');
    }
  }, PFA_VALIDATION)],

  'plos_billing--ringgold_institution': [RINGGOLD_VALIDATION_WITH_SKIP]
};
