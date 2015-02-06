# How to Use

In your template:

```
{{#segmented-buttons selectedValue=sortBy action="setSortOrder"}}
  {{#segmented-button value="old"}}Sort by Oldest{{/segmented-button}}
  {{#segmented-button value="new"}}Sort by Newest{{/segmented-button}}
{{/segmented-buttons}}
```


# How it Works

The value of the clicked segmented-button is passed to the action set on the segmented-buttons component.

# Parameters