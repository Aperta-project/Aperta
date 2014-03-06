Tahi.overlays.reviewerReport =
  Overlay: React.createClass
    render: ->
      {div, main, section, h3, h1, p, label, textarea, input} = React.DOM
      Overlay = Tahi.overlays.components.Overlay

      (main {className: 'reviewer-form'}, [
        (h1 {}, @props.taskTitle),
        (section {}, [
          (h3 {}, "Do you have any potential or perceived competing interests that may influence your review?"),
          (p {className: 'clarification'}, "Please review our Competing Interests policy and declare any potential interests that you feel the Editor should be aware of when considering your review. If you have no competing interests, please write:"),
          (p {}, '"I have no competing interests."'),
          (p {}, (textarea {}))]),
        (section {}, [
          (h3 {}, "Is the manuscript technically sound, and do the data support the conclusions?"),
          (p {className: 'clarification'}, "The manuscript must describe a technically sound piece of scientific research with data that supports the conclusions."),
          (p {className: 'clarification'}, "Experiments must have been conducted rigorously, with appropriate controls, replication, and sample sizes."),
          (p {className: 'clarification'}, "The conclusions must be drawn appropriately based on the data presented."),
          (div {className: 'yes-no-with-comments'}, [
            (div {}, [
              (label {}, [
                (input {type: 'checkbox'}),
                'Yes']),
              (label {}, [
                (input {type: 'checkbox'}),
                'No'])])
            (textarea {placeholder: "Type additional comments here."})])]),
        (section {}, [
          (h3 {}, "Has the statistical analysis been performed appropriately and rigorously?"),
          (p {className: 'clarification'}, "Authors must follow field-specific standards for data deposition in publicly available resources and should include accession numbers in the manuscript when relevant. The manuscript should explain what steps have been taken to make data available, particularly in cases where the data cannot be publicly deposited."),
          (div {className: 'yes-no-with-comments'}, [
            (div {}, [
              (label {}, [
                (input {type: 'checkbox'}),
                'Yes']),
              (label {}, [
                (input {type: 'checkbox'}),
                'No'])])
            (textarea {placeholder: "Type additional comments here."})]),
          (h3 {}, "Does the manuscript adhere to standards in this field for data availability?"),
          (p {className: 'clarification'}, "The manuscript should explain what steps have been taken to make data available, particularly in cases where the data cannot be publicly deposited."),
          (div {className: 'yes-no-with-comments'}, [
            (div {}, [
              (label {}, [
                (input {type: 'checkbox'}),
                'Yes']),
              (label {}, [
                (input {type: 'checkbox'}),
                'No'])])
            (textarea {placeholder: "Type additional comments here."})])]),
        (section {}, [
          (h3 {}, "Is the manuscript presented in an intelligible fashion and written in standard English?"),
          (p {className: 'clarification'}, "PLOS ONE does not copyedit accepted manuscripts, so the language in submitted articles must be clear, correct, and unambiguous. Any typographical or grammatical errors should be corrected at revision, so please note any specific errors below."),
          (div {className: 'yes-no-with-comments'}, [
            (div {}, [
              (label {}, [
                (input {type: 'checkbox'}),
                'Yes']),
              (label {}, [
                (input {type: 'checkbox'}),
                'No'])])
            (textarea {placeholder: "Type additional comments here."})])]),
        (section {}, [
          (h3 {}, "(Optional) Please offer any additional comments to the author."),
          (p {className: 'clarification'}, "Additional comments may include concerns about dual publication, research or publication ethics."),
          (p {}, (textarea {placeholder: "Type additional comments here."}))]),
        (section {}, [
          (h3 {}, "(Optional) If you'd like your identity to be revealed to the authors, please include your name here."),
          (p {className: 'clarification'}, "Your name and review will not be published with the manuscript."),
          (p {}, (textarea {placeholder: "Type your name here if you'd like the author to know who you are."}))])])

    submitFormsOnChange: (rootNode) ->
      form = $('form', rootNode)
      Tahi.setupSubmitOnChange form, $('textarea', form)

    componentDidMount: ->
      @submitFormsOnChange(@getDOMNode())
