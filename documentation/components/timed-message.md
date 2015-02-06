# How to Use

In your template:

```
{{timed-message message=reallyImportantMessage
                class="custom-class-here"
                duration=8000}}
```

In your controller or component set the message:

```
save: function() {
  var self = this;
  this.get('model').save().then(function() {
    self.set('reallyImportantMessage', 'You did good');
  });
}
```

# How it Works

Go read the code.

# Properties

## message

**(string)**

*Text displayed to user*

## duration

**(integer)**

*Length of time in miliseconds before message is removed. The default is 5000.*