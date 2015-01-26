# How to Use

In your template:

```
{{flash-messages}}
```

If you need a custom class wrapped around your messages:

```
{{flash-messages classNames="custom-classes-here"}}
```

In your route or controller from an Ember Data save:

```
actions: {
  save: function() {
    var self = this;
    this.get('model').save().then(
      function() {},
      function(response) {
        self.flash.displayErrorMessagesFromResponse(response);
      }
    );
  }
}
```

To set a message manually from controller or route:

```
this.flash.displayMessage('success', 'You win');
```

The messages will be cleared out on the next route transition or overlay close. If you need to clear them out manually:

```
this.flash.clearMessages();
```

# How it Works

A singleton object is created and injected into all Routes and Controllers from an Ember Initializer as the property `flash`. When `displayMessage` or `displayErrorMessagesFromResponse` is called, all we're doing is pushing to an array of messages that are displayed in the templates.


# Methods

## displayMessage(type, message)

```
this.flash.displayMessage('error', 'Oh noes');
```

### Parameters

**type (string)**

*Used to generate final class `flash-message--success`*

**message (string)**

*Message displayed to user*

## displayErrorMessagesFromResponse(response)

```
this.flash.displayErrorMessagesFromResponse(response);
```

###Parameters

**response (hash)**

*Hash from Ember Data `save` failure. Expected to be in format Rails sends:*

```
{
  errors: {
    name: ['This and that', 'That and this']
  }
}
```

The array of messages will be joined into a single string, separated by comma.

## clearMessages()

```
this.flash.clearMessages();
```

Empties the messages array. Automatically called during route transitions and overlay close.
