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
import { task as concurrencyTask, timeout } from 'ember-concurrency';

let pusherConnectionState = 'pusher.pusher.connection.state';
export default Ember.Mixin.create({

  pusher: Ember.inject.service('pusher'),
  flash: Ember.inject.service('flash'),

  pusherNotConnected: Ember.computed.alias('pusher.isDisconnected'),

  pusherConnectionStatusChanged: Ember.on('init', Ember.observer('pusherNotConnected', function() {
    this.handlePusherConnectionStatusChange();
  })),

  handlePusherConnectionStatusChange() {
    if (this.get(pusherConnectionState) === 'connecting') {
      this.get('handlePusherConnecting').perform();
    } else {
      this.cleanupPusherConnecting();
    }
    if (this.get('pusherNotConnected')) {
      this.updatePusherConnectionMessage();
    }
  },

  cleanupPusherConnecting() {
    // remove the connecting message on connecting -> connected transition
    let messages = this.get('flash').get('systemLevelMessages');
    let connectionMessage = messages.findBy('text', this.pusherFailureMessages['connecting']);
    this.get('flash').removeSystemLevelMessage(connectionMessage);
  },

  handlePusherConnecting: concurrencyTask(function*() {
    // We observe pusherNotConnected which does not change on 'connecting' => 'unavailable'.
    // However, we know that 'connecting' ends after 10s. Handle the resulting connection state.
    if (!this.get('testing')) {
      yield timeout(10000);
    }

    this.handlePusherConnectingCompleted();
  }).drop(),

  handlePusherConnectingCompleted(){
    this.handlePusherConnectionStatusChange();
  },

  updatePusherConnectionMessage() {
    let message = this.pusherFailureMessages[this.get(pusherConnectionState)];
    let messages = this.get('flash').get('systemLevelMessages').filterBy('text', message);
    if (!messages.length) {
      this.get('flash').displaySystemLevelMessage('error', message);
    }
  },

  pusherFailureMessages: {
    unavailable: `Aperta is currently having trouble maintaining a live connection with your browser.
          This could impact updates to the interface, and we recommend you 
          <a href="#" onclick="window.location.reload(false)"> reload this page</a>
          to attempt to re-establish the connection`,
    failed: `Aperta is having trouble establishing a live connection with your browser
          due to lack of browser support for required software.
          <a href="http://browsehappy.com/">Please update your browser to the current version</a>`,
    disconnected: `Aperta\'s live connection with your browser has been dropped. 
          This could impact updates to the interface,
          and we recommend you <a href="#" onclick="window.location.reload(false)">reload this page</a> 
          to attempt to re-establish the connection.`,
    connecting: `Aperta is attempting to acquire a live connection. Please wait until connection is established.`
  },
});
