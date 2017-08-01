#!/usr/bin/env python
import FreeCAD, Part, Mesh
import os, sys
print 'Load step file this takes a while'
Part.open(os.path.abspath(sys.argv[1]))
objs = FreeCAD.getDocument("Unnamed").findObjects()
print 'Saving stl file this takes a while'
Mesh.export(objs, os.path.abspath(sys.argv[2]))
