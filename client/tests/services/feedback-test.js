import { moduleFor, test } from 'ember-qunit';
import sinon from 'sinon';


moduleFor('service:feedback', 'Unit | Service | Feedback',
          {integration: true});


test('sendFeedback calls Restless with the appropriate params', function(assert) {
  let shots = [];
  let referrerAddress = "http://localhost";
  let remarkText = "I have feedback";

  let fakeRestless = {
    post: sinon.spy()
  };

  let fakePaper = {
    id: 42
  };

  let service = this.subject({restless: fakeRestless});
  service.setContext(fakePaper);

  service.sendFeedback(referrerAddress, remarkText, shots);

  // if this fails use `sinon.assert.calledWith` to diagnose
  assert.ok(fakeRestless.post.calledWith(
    '/api/feedback', {
      feedback: {
        referrer: referrerAddress,
        remarks: remarkText,
        paper_id: 42,
        screenshots: shots
      }
    }));
});
