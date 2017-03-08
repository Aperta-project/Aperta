import { moduleForComponent } from 'ember-qunit';
import { manualSetup } from 'ember-data-factory-guy';
import { createQuestion, createQuestionWithAnswer } from 'tahi/tests/factories/nested-question';
import registerCustomAssertions from '../helpers/custom-assertions';
import FakeCanService from '../helpers/fake-can-service';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';

/**
 * moduleForComponentIntegration removes a some of the boilerplate that's sprung up when
 * we do component integration tests recently.  It also names our 
 *
 **/
export default function(componentModuleName, options = {}) {
  let moduleParts = componentModuleName.split('-');
  let testName;
  if (moduleParts.get('lastObject') === 'task') {
    moduleParts.pop();
    testName = `Integration | Component | Tasks | ${moduleParts.join(' ')}`;
  } else {
    testName = `Integration | Component | ${moduleParts.join(' ')}`;
  }
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
      // At this point using FakeCan is probably a better option than using the Factory.createPermission
      // option that exists in other places, as it shortcircuits the 'can' methods before having to fake out
      // any actual ajax requests
      if(!options.useRealCanService) {
        this.registry.register('service:can', FakeCanService);
        this.fakeCan = this.container.lookup('service:can');
      }

      // wait is a built-in ember helper that lets us wait for async stuff to finish.  It's actually
      // what powers the async helpers that we use in the full acceptance tests
      this.wait = wait;

      // ********** put other common helpers here and document what they do
      // createQuestion will put a nested question with the given ident and owner into the store
      this.createQuestion = createQuestion;
      // createQuestionWithAnswer will put a nested question with the given ident and owner into the store,
      // also creating an answer with the given value
      this.createQuestionWithAnswer = createQuestionWithAnswer;

      // just like moduleForAcceptance you can pass additional beforeEach and afterEach arguments
      // to moduleForComponentIntegration and they'll get called after the ones specified here.
      if (options.beforeEach) {
        return options.beforeEach.apply(this, arguments);
      }
    },

    afterEach() {
      $.mockjax.clear();
      let afterEach = options.afterEach && options.afterEach.apply(this, arguments);
      return Ember.RSVP.Promise.resolve(afterEach);
    }
  });
}
