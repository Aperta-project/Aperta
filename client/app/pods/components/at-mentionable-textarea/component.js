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
import AtWhoSupport from 'ember-cli-at-js/mixins/at-who-support';
import {PropTypes} from 'ember-prop-types';

export default Ember.TextArea.extend(AtWhoSupport, {
  propTypes: {
    atMentionableUsers: PropTypes.array.isRequired
  },

  atWhoUsers: Ember.computed('atMentionableUsers.[]', function() {
    return this.getWithDefault('atMentionableUsers',[]).map(function(user) {
      const userObj = {
        name: user.get('name'),
        email: user.get('email'),
        username: user.get('username')
      };
      return userObj;
    });
  }),

  settings: Ember.computed('atWhoUsers.[]', function() {
    const settings = {
      at: '@',
      data: this.get('atWhoUsers'),
      displayTpl: this.displayTpl,
      callbacks: {
        filter: this.filter.bind(this),
        sorter: this.sorter.bind(this),
        highlighter: this.highlighter.bind(this)
      },
      insertTpl: '${atwho-at}${username}'
    };
    return settings;
  }),

  didInsertElement() {
    this._super(...arguments);

    const action = this.get('onChange');
    if(Ember.isEmpty(action)) { return; }

    this.$().on('keyup', function() {
      action(this.value);
    });
  },

  willDestroyElement() {
    this.$().atwho('destroy');
    this.$().off('keyup');
    this._super(...arguments);
  },

  // Inject new data into at.js if the list of at-mentionable users changes
  reloadData: Ember.observer('atWhoUsers.[]', function() {
    this.$().atwho('load', '@', this.get('atWhoUsers'));
  }),

  filter(query, data) {
    return _.filter(data, (item) => {
      return _.some(['username', 'email', 'name'], (key) => {
        return this.containsString(item[key], query);
      });
    });
  },

  /* eslint-disable camelcase */

  sorter(query, items) {
    if (!query) {
      return items;
    }
    return _.map(items, (item) => {
      let item_clone = _.clone(item);
      item_clone.atwho_order = this.indexOfStringInItem(item, query);
      return item_clone;
    }).sort(function(a, b) {
      return a.atwho_order - b.atwho_order;
    });
  },

  /* eslint-enable camelcase */

  highlighter(li, query) {
    if (!query) {
      return li;
    }
    const escapedQuery = query.replace('+', '\\+');
    const regex = new RegExp(`(.*?)(${escapedQuery})`, 'i');
    const node = $(li);
    node.find('span').each(function(_, nameElement) {
      const jNameElement = $(nameElement);
      const oldText = jNameElement.text();
      jNameElement.html(oldText.replace(regex, function(_, lookBehind, match){
        return `${lookBehind}<strong>${match}</strong>`;
      }));
    });
    return node.prop('outerHTML');
  },

  indexOfStringInItem(item, string) {
    const {username, email, name} = item;
    const searchString = [username, email, name].join(' ');
    return this.indexOfString(searchString, string);
  },

  indexOfString(string, substring) {
    return new String(string).toLowerCase().indexOf(substring.toLowerCase());
  },

  containsString(string, substring) {
    return (this.indexOfString(string, substring) !== -1);
  },

  displayTpl: '<li>' +
    '<span class="at-who-name">${name}</span> ' +
    '<span class="at-who-username">${atwho-at}${username}</span> ' +
    '<span class="at-who-email">${email}</span>' +
  '</li>',
});
