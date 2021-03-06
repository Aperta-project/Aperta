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
var Select2Component;

Select2Component = Ember.TextField.extend({
  tagName: 'div',
  classNameBindings: ['cannotClear'],
  cannotClear: Ember.computed.not('allowClear'),
  autoFocus: false,
  source: [],
  closeOnSelect: false,
  multiSelect: false,
  selectedData: [],
  placeholder: "",
  color: 'green', // green, blue

  setupSelectedListener: function() {
    this.$().off('select2-selecting');
    return this.$().on('select2-selecting', (function(_this) {
      return function(e) {
        return Ember.run.schedule('actions', _this, function() {
          return this.sendAction('selectionSelected', e.choice);
        });
      };
    })(this));
  },

  setupRemovedListener: function() {
    this.$().off('select2-removing');
    return this.$().on('select2-removing', (function(_this) {
      return function(e) {
        return Ember.run.schedule('actions', _this, function() {
          return this.sendAction('selectionRemoved', e.choice);
        });
      };
    })(this));
  },

  setupClearingListener: function() {
    this.$().off('select2-clearing');
    return this.$().on('select2-clearing', (function(_this) {
      return function(e) {
        return Ember.run.schedule('actions', _this, function() {
          return this.sendAction('selectionCleared', e.choice);
        });
      };
    })(this));
  },

  setupClosedListener: function() {
    this.$().off('select2-close');
    return this.$().on('select2-close', (function(_this) {
      return function() {
        return Ember.run.schedule('actions', _this, function() {
          return this.sendAction('dropdownClosed');
        });
      };
    })(this));
  },

  setSelectedData: (function() {
    return this.$().select2('val', this.get('selectedData').mapBy('id'));
  }).observes('selectedData'),

  initSelection: function(el, callback) {
    var selectedData;
    selectedData = this.get('selectedData') || [];
    return callback(selectedData.compact());
  },

  repaint: function() {
    this.teardown();
    return this.setup();
  },

  setup: (function() {
    var i, len, opt, options, passThroughOptions;
    options = {};
    if (this.get('color') === 'blue') {
      this.set('dropdownCssClass', 'admin');
      this.set('containerCss', 'admin');
    }
    if (this.get('selectedTemplate')) {
      options.formatSelection = this.get('selectedTemplate');
    }
    if (this.get('resultsTemplate')) {
      options.formatResult = this.get('resultsTemplate');
    }
    if(this.get('dropdownCssClass')) {
      options.dropdownCssClass = this.get('dropdownCssClass');
    }
    if(this.get('containerCss')) {
      options.containerCssClass = this.get('containerCss');
    }
    options.multiple = this.get('multiSelect');
    options.data = this.get('source');
    if (this.get('remoteSource')) {
      options.ajax = this.get('remoteSource');
    }
    if (this.get('dropdownClass')) {
      options.dropdownCssClass = this.get('dropdownClass');
    }
    options.initSelection = Ember.run.bind(this, this.initSelection);
    passThroughOptions = ['allowClear', 'closeOnSelect', 'minimumInputLength', 'minimumResultsForSearch', 'placeholder', 'width'];
    for (i = 0, len = passThroughOptions.length; i < len; i++) {
      opt = passThroughOptions[i];
      if (this.get(opt)) {
        options[opt] = this.get(opt);
      }
    }
    this.$().select2(options);
    this.$().select2('enable', this.get('enable'));
    this.setupSelectedListener();
    this.setupRemovedListener();
    this.setupClosedListener();
    this.setupClearingListener();
    this.setSelectedData();
    this.addObserver('source', this, this.repaint);
    return this.addObserver('enable', this, this.repaint);
  }).on('didInsertElement'),

  teardown: (function() {
    this.$().off('select2-selecting');
    this.$().off('select2-removing');
    this.$().off('select2-close');
    this.removeObserver('source', this, this.repaint);
    this.$().select2('destroy');
    return this.removeObserver('enable', this, this.repaint);
  }).on('willDestroyElement')
});

export default Select2Component;
