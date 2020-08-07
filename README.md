# Toile

**Toile** is framework to create interactive dashboards and is based on **[Séléné](https://github.com/destroyedlolo/Selene)** with a graphical plug-in enabled.

Its aims is to hide all the dirty work to handle low-level API available in Séléné and provides to developer abstacted high level Lua classes to build their own dashboard.

It emancipates from my [HomeDashBoard](https://github.com/destroyedlolo/HomeDashboard) project : have a look on it to see useage examples.
I have stricly no time to wrote a decent tutorial/documentation for it, but classes and methods has some documentation (kind of) embedeed in the source code.

## Installation

Clone this package in the directory where you're storing libraries not managed by Luarocks.
For me it's "**/usr/local/lib/lua**" and ensure your LUA_PATH contains 
```/usr/local/lib/lua/?.lua;/home/laurent/Projets/?/init.lua
