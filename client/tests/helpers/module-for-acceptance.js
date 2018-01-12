import { module } from 'qunit';
import Ember from 'ember';
import startApp from 'tahi/tests/helpers/start-app';
import destroyApp from 'tahi/tests/helpers/destroy-app';
import { mockSetup, mockTeardown } from 'ember-data-factory-guy';

const { RSVP: { Promise } } = Ember;

export default function(name, options = {}) {
  module(name, {
    beforeEach() {
      this.application = startApp();
      mockSetup();

      if (options.beforeEach) {
        return options.beforeEach.apply(this, arguments);
      }
    },

    afterEach() {
      mockTeardown();
      $.mockjax.clear();
      let afterEach =
        options.afterEach && options.afterEach.apply(this, arguments);
      return Promise.resolve(afterEach).then(() =>
        destroyApp(this.application)
      );
    }
  });
}
