Simple script for extracting all classes relevant to mission makers and print them out organized.
Currently it gets printed out in a tree like view. The plan is to give different export options: Tree and HTML.
Also contains a prefix filter, to filter out and only display a certain mod or mods.

How to use:
- in line l of printClasses.sqf change modTag = ["NORTH"]; to a modtag you want all class names of.
- For example modTag = ["LIB"];
- Can be multiple as well: modTag = ["NORTH","LIB"]; to get all IFA3 and northern front classnames.

Possibly WIP features:
- more information displayed next to classes, for ex: displayName, compatible magazines
- simple popup allowing you to switch between different outputs and loaded mods
- mission that inits the script for easier use
