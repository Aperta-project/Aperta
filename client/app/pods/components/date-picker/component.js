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

import Ember from 'ember';
import { moment } from 'tahi/lib/aperta-moment';

export default Ember.TextField.extend({
  tagName: 'input',
  classNames: ['datepicker', 'form-control', 'datepicker-field'],
  attributeBindings: ['content.isRequired:required', 'aria-required'],
  'aria-required': Ember.computed.reads('content.isRequiredString'),
  ready: false,
  date: null,

  _setup: Ember.on('didInsertElement', function() {
    const partOfGroup = !!this.get('group');

    if(partOfGroup) {
      this.get('group').registerPicker(this);
    }

    let $picker = this.$().datepicker({
      autoclose: true,
      endDate: this.get('endDate')
    });

    $picker.on('changeDate', (event)=> {
      this.updateDate(event.format());
    });

    $picker.on('clearDate', ()=> {
      this.updateDate(null);
    });

    this.set('value', this.get('date'));

    this.set('$picker', $picker);
    this.set('ready', true);
  }),

  change: function(){
    this.updateDate(this.element.value);
  },

  updateDate: function(newDate){
    this.set('date', newDate);
    this.sendAction('dateChanged', newDate);
    if(this.get('group')) { this.get('group').dateChanged(); }
  },

  setStartDate(dateString) {
    this.get('$picker').datepicker('setStartDate', dateString);
  },

  setEndDate(dateString) {
    let newDate = dateString;
    let endDate = this.get('endDate');

    // if developer has set an endDate and newDate
    // is empty from another field being cleared
    if(endDate && Ember.isEmpty(newDate)) {
      this.get('$picker').datepicker('setEndDate', endDate);
      return;
    }

    // If the developer set an endDate, don't let
    // the newDate go into the future
    let pastEndDate = moment(newDate).isAfter(endDate);
    if(pastEndDate) {
      this.get('$picker').datepicker('setEndDate', endDate);
      return;
    }

    this.get('$picker').datepicker('setEndDate', dateString);
  },
});
