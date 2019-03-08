# Data

Data modules fit the following criteria:

* Export a single type, possibly opaque, that is central to the module
* If the type is opaque, exports getters/setters for it
* If the type will be converted to/from JSON, exports encode & decoder
* Does not import modules external to `Data/` inside the project
