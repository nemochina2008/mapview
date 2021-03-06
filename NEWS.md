## mapview 2.0.1

new features:
  * addMouseCoordinates has gained argument 'style' to specify whether to show 'basic' (lat, lon, zoom) or 'detailed' (x, y, epsg, proj4, lat, lon, zoom) information. Factory-fresh default is 'detailed'.
  * addLogo has gained argument 'alpha' to set the opacity of the image.
  * Someone draws quickest...
  * added new method for list of objects so that we can do mapview(list(x, y, z)) which is great for computational outputs such as lapply.
  * slideView has gained arguments 'label1' and 'label2' to supply slider names for the respective images, img1 and img2.
  * new popup layout (making more use of the space available).
  * added new function addLargeFeatures to render large datasets of up to ~100k features which is used automatically. To lower/elevate the threshold use maxpoints = ... (See ?mapview for details).
  * mapview methods for all basic sf classes (XY/sfg, sfc, sf)
  * added support for sf to "+"
  * we can now render features/objects with arbitrary CRS (without map background) by setting 'native.crs = TRUE'.
  * mapview will now decide which default base map to use based on average luminence of rendered colors.
  * mapview now provides subtle highlighting of polygons (changing opacity slightly) and lines (changing thickness).
  * plainView, slideView and cubeView have gained argument legend. default is TRUE. Legends only available for non-RGB methods!
  * new data sets:
      - 'franconia' (administrative district boundaries of Franconia)
      - 'breweries' (extended version of the 'breweries91' data)
      - 'trails' (selected hiking trails in franconia to connect the breweries)
  * data sets 'breweries91', 'gadmCHE' and 'atlStorms2005' have been deleted and moved to leaflet.

bugfixes:
  * sync, addMouseCoordinates and addLogo did not work anymore. Now fixed thanks to @timelyportfolio

changes:
  * MAJOR internal change: All vector data are now processed as sf objects internally. This also means that objects returned in slot `@object` will be of class sf (regardless of input class).
  * polygons and points now have a darkish gray line frame (unless add*LargeFeatures is used - where the overhead of passing two sets of colors would be too high).
  * updated examples (in line with new data).
  * github repository moved from https://github.com/environmentalinformatics-marburg/mapview to https://github.com/r-spatial/mapview

## mapview 1.2.0

new features:
  * garnishMap: function to add multiple decoration elements, such as leaflet::addLayersControl or addHomeButton to a map (mainly for internal use).
  * addHomeButton: add a zoom-to-layer button to a map.
  * addLogo: add an image to a map.
  * plainview now shows CRS and dimension info.

bugfixes:
  * na.color was not respected for Raster* and SpatialPiXelsDF.
  * removed lat and lon entries in popupTable for polygons as we now have mousecoordinates.
  * for raster objects the legend did not respect the intervals specified by 'at'.
  * mapview working again for objects with no projection (NA).
  * mapview for SPoints* with only one point did through an error #36.

## mapview 1.1.0

new features:
  * addMouseCoordinates: add cursor position information to mapview or leaflet map. (thanks to Kent Russell).
  * if available from leaflet version, a scalebar is added to the map.
  * latticeView: view mapview or leaflet maps as small multiples and sync some, all or none (thanks to Kent Russell).
  * sync: synchronise two or more leaflet maps (thanks to Kenton Russell).
  * mapshot: to save maps as html page or static image or both.
  * knitr integration (i.e. no need to call the @map slot anymore to render in knitr).
  * cubeView: view raster bricks or stacks hovmoeller style, use keys up & down, left & right, page up & page down to navigate through y, x, z dimensions, respectively.
  * labels: if zcol is set, mouseover will now show the repesctive values of zcol, if zcol is not set moseover shows feature ID. Only available if suitable leaflet package version is installed.
  * new popup functions popupTable, popupGraph and popupImage.
  * functions to turn coordinates into spatial lines or spatial polygons.
  * mapview objects now work natively on shiny applications (i.e. renderMapview and mapviewOutput now available).
  * "zcol = Var" in combination with burst = TRUE now plots one layer for each unique value of the variable supplied to zcol.

changes:
  * spplot method has been removed.
  * colors: viridis based colors now default if viridisLite package is available.
  * basemaps: new default basemap is "CartoDB.Positron" as colors of features are better visible on the grey background.
  * layer names now include the name of the object they originate from (e.g. "meuse lead" instead of "lead").

bugfixes:
  * if attribute was of class "character" mapview did through an error if passed to zcol.
  * user provided layer names were not respected when zcol was set. See also note on changes in default layer names.


## mapview 1.0.0

* Initial release
