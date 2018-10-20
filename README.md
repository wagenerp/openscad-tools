# openscad-tools
Various tools and modules I wrote for assisting me in designing objects using OpenSCAD.

This project is no longer being developed as I am currently mygrating towards generating OpenSCAD code using python.

## usage
Basic usage involves making the `lib` directory visible from OpenSCAD, i.e. using the `OPENSCADPATH` environment variable or whatever method you prefer.
Inside the `bin` directory you will find a `bake-openscad` script you can use to automatically generate .stl or .svg files out of a .scad file. Utilizing my library's `part` module, you can define multiple output files to be generated using `bake-openscad`.
