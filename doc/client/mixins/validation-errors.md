# How to Use

# How it Works

# Methods

## displayValidationError(key, message)

```
this.displayValidationError('error', 'Oh noes');
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
{ errors: { } }
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