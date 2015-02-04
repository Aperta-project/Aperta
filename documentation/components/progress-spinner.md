# How to Use

In your template:

```
{{progress-spinner visible=someBoolean}}
```

In your controller or component toggle the boolean:

```
this.set('someBoolean', true);
```


# Properties

## visible

**(boolean)**

*Toggles visibility*

## size

**(string)**

*`small` or `large`* Small is default.

## color

**(string)**

*`green` or `blue` or `white`. Default is green.*