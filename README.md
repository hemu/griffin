> grunt serve 
for preview (use during development)

> grunt 
for building (production, dont need to do this for development)

> grunt serve:dist 
for a preview of the built app (preview of production app)


Code style guidelines
- variables camelCase
- folder names underscore between multiple words e.g. node_modules UNLESS they are modules
- file names that export a module have dash between multiple words e.g. game-effects
- tabs convert to spaces
- tab size of 2 spaces
- one new line between methods and functions
- two new lines at end of classes
- module.exports and exports statements at very end of file
- require statements at beginning of file
- variable what a require() module is assigned to starts with m (for 'module') and is camelCased:
    mInput = require './game-input'