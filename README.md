# Sketchspace - A drawing app

A Drawing app built with Flutter.
I was inspured by how annoying and bad Onenote is at times. Another major inspiration was [Saber](https://github.com/saber-notes/saber). I wanted to practice my flutter skills and build something that I could possibly use.
My plans for the feature include a proper uI as well as folders and tags. I want to also include pictures and pdfs and maybe some other stuff.
And storing files - even though open source formats are great - i will likely move to a small database like SQLite for fast and easy access to individual strokes. iterating over every stroke is not ideal. Hashmaps might be an alternative.

## Methods

- Using [LazyPainter](https://github.com/lalondeph/flutter_performance_painter) by Philip Lalonde for the rendering and drawing of CustomPainter strokes.
- Using a modified [Zoom Widget](https://github.com/semakers/zoom-widget/tree/master) for Handling the zoom and pan.

## Features

- Double tap to disable the UI on the canvas
- Dark mode!
- Saving and loading files into a json format (SVG and png coming soon!)
- Renaming files
- Drawing! Obviously
- Zooming & Panning the canvas! (Limited size, more coming soon!)

## Drawing Context

    - The Drawing context is responsible for managing the different states of drawing, such as worldspace.
    - it should not manipulate the worldspace itself, but rather  call it's methods.
    - Handling files should be left to seperaate functions within draw_file
