large_warn = paste("the supplied feature layer has more points/vertices than the set threshold.",
                   "using special rendering function, hence things may not behave as expected from a standard leaflet map,",
                   "e.g. you will likely need to zoom in to popup-query features\n",
                   "to see the number of points/vertices of the layer use 'npts(x)'",
                   "to see the threshold for the feature type use 'mapview:::getMaxFeatures(x)'",
                   "to adjust the threshold use argument 'maxpoints'",
                   sep = "\n  ")

### sf ####################################################################
leaflet_sf <- function(x,
                       map,
                       zcol,
                       cex,
                       lwd,
                       alpha,
                       alpha.regions,
                       color,
                       col.regions,
                       at,
                       na.color,
                       map.types,
                       verbose,
                       popup,
                       layer.name,
                       label,
                       legend,
                       legend.opacity,
                       homebutton,
                       native.crs,
                       highlight,
                       maxpoints,
                       ...) {

  if (!is.null(zcol)) {
    layer.name <- paste(layer.name, zcol)
    if (length(unique(x[[zcol]])) <= 1) {
      warning(
        sprintf(
          "column %s has only one unique value/level, ignoring coloring and legend",
          zcol
        )
      )
      zcol <- NULL
    }
  }

  cex <- circleRadius(x, cex)
  # if (!native.crs) x <- checkAdjustProjection(x)
  if (legend & !is.null(zcol)) {
    if (getGeometryType(x) == "ln") leg_clrs <- color else leg_clrs <- col.regions
    legend <- mapviewLegend(values = x[[zcol]],
                            colors = leg_clrs,
                            at = at,
                            na.color = col2Hex(na.color),
                            layer.name = layer.name)
  }

  clrs <- vectorColors(x = x,
                       zcol = zcol,
                       colors = color,
                       at = at,
                       na.color = na.color)
  clrs.regions <- vectorColRegions(x = x,
                                   zcol = zcol,
                                   col.regions = col.regions,
                                   at = at,
                                   na.color = na.color)

  leaflet_sfc(sf::st_geometry(x),
              map = map,
              zcol = zcol,
              color = clrs,
              col.regions = clrs.regions,
              at = at,
              na.color = na.color,
              cex = cex,
              lwd = lwd,
              alpha = alpha,
              alpha.regions = alpha.regions,
              map.types = map.types,
              verbose = verbose,
              popup = popup,
              layer.name = layer.name,
              label = label,
              legend = legend,
              legend.opacity = legend.opacity,
              homebutton = homebutton,
              native.crs = native.crs,
              highlight = highlight,
              maxpoints = maxpoints,
              attributes = sf2DataFrame(x, drop_sf_column = TRUE),
              ...)

}


### sfc ###################################################################
leaflet_sfc <- function(x,
                        map,
                        zcol,
                        cex,
                        lwd,
                        alpha,
                        alpha.regions,
                        color,
                        col.regions,
                        at,
                        na.color,
                        map.types,
                        verbose,
                        popup,
                        layer.name,
                        label,
                        legend,
                        legend.opacity,
                        homebutton,
                        native.crs,
                        highlight,
                        maxpoints,
                        attributes = NULL,
                        ...) {

  if (inherits(x, "XY")) x = sf::st_cast(st_sfc(x)) else x = sf::st_cast(x)

  if (!native.crs) x <- checkAdjustProjection(x)
  if (is.na(sf::st_crs(x)$proj4string)) native.crs <- TRUE

  if (is.null(map.types)) {
    if (getGeometryType(x) %in% c("pl", "pt")) {
      if (is.function(col.regions)) col.regions <- standardColRegions(x)
      map.types <- basemaps(col.regions)
    } else {
      if (is.function(color)) color <- standardColor(x)
      map.types <- basemaps(color)
    }
  }

  m <- initMap(map, map.types, sf::st_crs(x), native.crs)

  if (npts(x) > maxpoints) {
    if (getGeometryType(x) == "ln") clrs <- color else clrs <-  col.regions
    warning(large_warn)
    m <- addLargeFeatures(m,
                          data = x,
                          radius = cex,
                          weight = lwd,
                          opacity = alpha,
                          fillOpacity = alpha.regions,
                          color = clrs,
                          popup = popup,
                          label = label,
                          group = layer.name,
                          maxpoints = maxpoints,
                          attributes = attributes,
                          ...)

  } else {

  m <- addFeatures(m,
                   data = x,
                   radius = cex,
                   weight = lwd,
                   opacity = alpha,
                   fillOpacity = alpha.regions,
                   color = color,
                   fillColor = col.regions,
                   popup = popup,
                   label = label,
                   group = layer.name,
                   highlightOptions = highlight,
                   ...)

  }

  funs <- list(if (!native.crs) leaflet::addScaleBar,
               if (homebutton) addHomeButton,
               mapViewLayersControl,
               addMouseCoordinates)
  funs <- funs[!sapply(funs, is.null)]

  args <- list(if (!native.crs) list(position = "bottomleft"),
               if (homebutton) list(ext = createExtent(x),
                                    layer.name = layer.name),
               list(map.types = map.types,
                    names = layer.name,
                    native.crs = native.crs),
               list(style = "detailed",
                    epsg = sf::st_crs(x)$epsg,
                    proj4string = sf::st_crs(x)$proj4string,
                    native.crs = native.crs))
  args <- args[!sapply(args, is.null)]

  m <- decorateMap(map = m,
                   funs = funs,
                   args = args)

  if (is.function(legend)) m <- legend(m)
  out <- new("mapview", object = list(x), map = m)

  return(out)

}




### MISC ==================================================================
sf2DataFrame <- function(x, drop_sf_column = FALSE) {
  stopifnot(inherits(x, "sf") | inherits(x, "sfc"))
  if (inherits(x, "sf")) {
    if (drop_sf_column) {
      return(as.data.frame(x)[setdiff(names(x), attr(x, "sf_column"))])
      # geompos <- which(names(x) == attr(x, "sf_column"))
      # return(data.frame(x)[, -geompos, drop = FALSE])
    } else return(x)
  } else {
    d <- data.frame("a" = seq(length(x)))
    names(d) <- "Feature ID"
    return(d)
  }
}


nNodes = function(x) {
  sum(sapply(x, function(y) {
    if (is.list(y)) nNodes(y) else nrow(y)
  }))
}

#' count the number of points/vertices/nodes of sf objects
#' @param x an sf/sfc object
#'
#' @export
#'
#' @examples
#' npts(franconia)
#' npts(sf::st_geometry(franconia[1, ])) # first polygon
#'
#' npts(breweries) # is the same as
#' nrow(breweries)
#'
npts = function(x) {
  if (getGeometryType(x) == "pt") {
    length(sf::st_geometry(x))
  } else {
    nNodes(sf::st_geometry(x))
  }
}
