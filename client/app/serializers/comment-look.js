import ApplicationSerializer from "tahi/serializers/application";

export default ApplicationSerializer.extend({

  // TODO: Card Thumbnail is an ember model that doesn't exist on the server side.
  // Due to the implementation of flow manager, in order to display comment-looks,
  // we need to associate our comment look to the card thumbnail. Ideally, card
  // thumbnail could go away, and instead we could just provide a sparse view of
  // the task itself. At that point, this code would be unnecessary.
  //
  normalize: function(typeClass, hash, prop) {
    hash.card_thumbnail_id = hash.task.id;
    return this._super(typeClass, hash, prop);
  }

});
