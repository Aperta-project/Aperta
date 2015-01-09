# The tahi live style-guide!

The goal of this project is to generate a Complete Styleguide for Tahi, that
stays updated with almost no effort.

## How do I view the styleguide?
Start the app server and then visit <http://localhost:5000/kss/styleguide>

Every time you reload the page with the styleguide, the CSS reflects your latest
changes.

## How do I pull the app's latest HTML into the styleguide?
Re-scraping the HTML from the app can take some time.
```sh
rake styleguide:generate
```

If you see an error when you run this, please open an issue and paste the error.

---

```
## High-Level UX/Design Notes (Communicating Design)

An App has:

* Use Cases
   In order to meet a Use Case, a User completes a Flow
* User Flows.
   A User Flow is made up of screens that are designed to accomplish a Use Case.
* Screens
   A Screen is a complete web page (or state of a page) where a User can do something
   Layout
      A common html page, that might have Components too (TODO: make this more clear)
   Component
     Custom sets of HTML Elements, plus styling, plus .js behavior
   Element
     Base level HTML Markup. A single instance of <div>s and <span>s and <p>, etc.


The goal of this project is to generate a Complete Styleguide for Tahi, that can
be completely updated with minimal effort.

To accomplish this, we will create a Styleguide page that will have placeholders
for certain components.

A script will then look at Tahi-Staging and pull live
markup from Tahi-Staging and paste it into the Styleguide.

When the script is run again, the pasted in Markup is refreshed, accordingly.

This could be done with Comments blocks,
or even a custom element that can have its contents replaced.

THE STYLEGUIDE ***************************************************************
This file is part of the Styleguide, which consists of 3 files.
STEP 1: HARVESTING *** THIS FILE ***
Crawl the app and capture all pages and states necessary to generate your Styleguide. This file sticks a bunch of .html and .png files in /doc/ux.
100% Coverage is a good goal, but probably not necessary, nor pragmatic.
STEP 2: DECLARATION
Declare all your UI Elements (name, page, selector). This file lives at /app/views/kss/home/styleguide2.html.erb
Example Declaration for your UI Element named "card-completed" that comes from
the .html file `paper_manager`
and it looks for css to match `source-page-selector`
then wraps it in a div with an ID or Class of `source-page-selector-context`
<div element-name="card-completed"
    source-page-name="paper_manager"
    source-page-selector=".card--completed"
    source-page-selector-context=".column">
</div>
STEP 3: HYDRATION
This file is responsible for updating styleguide.html with HTML
from the .html files in /docs/ux, based on the declared attributes
This is currently `testing.rb`.
STEP 4: UPDATING
This process should be run periodically
(every 1-2 on an active project, maybe more)
```
