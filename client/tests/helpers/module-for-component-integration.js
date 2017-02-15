import { moduleForComponent } from 'ember-qunit';
import { manualSetup } from 'ember-data-factory-guy';
import { createCard } from 'tahi/tests/factories/card';
import { createAnswer } from 'tahi/tests/factories/answer';
import registerCustomAssertions from '../helpers/custom-assertions';
import FakeCanService from '../helpers/fake-can-service';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';

/**
 * moduleForComponentIntegration removes a some of the boilerplate that's sprung up when
 * we do component integration tests recently.
 *
 **/
export default function(componentModuleName, testName, options = {}) {
  moduleForComponent(componentModuleName, testName, {
    integration: true,
    beforeEach() {
      // we have a bunch of useful custom assertions that we have to manually register
      // each time
      registerCustomAssertions();

      // for component tests FactoryGuy needs to be set up manually
      manualSetup(this.container);

      // any time an ajax request gets made (even one that gets caught by mockjax or sinon)
      // it makes a call to the pusher service to set a header.  We don't care about it during
      // component tests, and that service normally gets created in an initializer.  Here we just
      // fake it out.
      this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));

      // The FakeCanService lets us avoid having to stub out network requests for a given resource.
      // Here's an example of using it (either in a beforeEach or in the test itself)
      //     ```
      //     let task = make('some-task-class');
      //     this.fakeCan.allowPermission('edit', task);
      //     ```
      //
      if(!options.useRealCanService) {
        this.registry.register('service:can', FakeCanService);
        this.fakeCan = this.container.lookup('service:can');
      }

      // wait is a built-in ember helper that lets us wait for async stuff to finish.  It's actually
      // what powers the async helpers that we use in the full acceptance tests
      this.wait = wait;

      // ********** put other common helpers here and document what they do
      // createCard relies on a hash that maps task names to cardContent idents.  It'll insert the
      // card and the relevant content into the store
      this.createCard = createCard;
      // `createAnswer` takes an owner, ident, and attrs object.  The CardContent with the specified
      // ident must already be in the store for it to work, which means you'll normally call it after
      // `createCard`
      this.createAnswer = createAnswer;

      // just like moduleForAcceptance you can pass additional beforeEach and afterEach arguments
      // to moduleForComponentIntegration and they'll get called after the ones specified here.
      if (options.beforeEach) {
        return options.beforeEach.apply(this, arguments);
      }
    },

    afterEach() {
      let afterEach = options.afterEach && options.afterEach.apply(this, arguments);
      return Ember.RSVP.Promise.resolve(afterEach);
    }
  });
}
