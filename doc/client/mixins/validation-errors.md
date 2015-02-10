# How to Use

In your template:

```
{{error-message message=validationErrors.email}}
<label>
  Email <input>
</label>
```

In your Controller or Component:

```
import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

SomeController = Ember.Controller.extend(ValidationErrorsMixin, {
  actions: {
    save: function() {
      @get('model').save().then(() => {
        this.clearValidationErrors();
      }).catch((response) => {
        this.displayValidationErrorsFromResponse(response);
      });
    }
  }
});
```

# How it Works

The mixin adds a `validationErrors` property to your Object.

# Methods

## displayValidationError(key, message)

```
this.displayValidationError('someProperty', 'Oh noes');
```

### Parameters

**type (string)**

*Used as key in `validationErrors` object*

**message (string|array)**

*Message(s) displayed to user. If passed an array they will be joined with a comma.*


## displayValidationErrorsFromResponse(response)

```
this.displayValidationErrorsFromResponse(resonse);
```

### Parameters

**response (hash)**

*Response expected in format from Rails:*

```
{ errors: { someProperty: ["is invalid", "another error"] } }
```

## clearValidationErrors()

```
this.clearValidationErrors();
```

Reset all validation errors.

## clearValidationErrorsForModel(model)

```
this.clearValidationErrorsForModel(model);
```

### Parameters

**type (DS.Model)**

*Remove errors for a specific model.*


## validationErrorsForModel(model)

## validationErrorsForType(model)

## createModelProxyObjectWithErrors(models)