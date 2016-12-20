# Reasoning

"Why?" you ask. And *why* you shall receive.

It seems at a glance that we can use a pre-built `bower`, `node`, or `ember`
package. We cannot use these out-of-the-box for two main reasons. First, we
want to customize the viewer. Second, we want to restrict the javascript
delivery to only the pages that require the viewer.

To customize the viewer, we had to not only modify the HTML, but we also had
to edit some of the viewer implementation. There were some functions that
broke if it didn't find elements on the DOM.

To restrict the viewer download to only the manuscript pages, we pull it in
only through the `pdf-manuscript` component. This then loads any extra worker
javascript code, images, or cmaps.

# Maintenance

## Updating the pdfjs-viewer library

The library we use can be found at
<https://github.com/legalthings/pdf.js-viewer>. Updating to the latest release
of this library should be easy. Download and unpack the release. Then run
`update.sh` in this directory.

## Updating the patch file

You may need to modify the root pdf.js file. This will make the local `pdf.js`
diverge from the repository copy. After the edits are complete, follow these
steps to update `aperta.pdf.patch`.

If you need to update `pdf.js` feel free to make the edits to that file
directly. Then update the patch file so that any update of the underlying
`pdfjs-viewer` can patch easily. Try the following command for patch generation

    diff -u --label original/pdf.js <PATH_TO_PDFJS> pdf.js > aperta.pdf.patch

If an update of the `pdfjs-viewer` fails, you will have to resolve any issues
and generate a new patch file.

# Implementation notes

The fingerprinting of assets causes an issue for us when using this code. The
javascript files themselves get precompiled successfully, but the images,
cmaps, and locale files require special attention.

We include a rake task to copy over our assets right after the precompilation phase.
This is automatically added to `assets:precompile`.

