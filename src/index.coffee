import FS from "node:fs/promises"
import Path from "node:path"
import * as M from "@dashkite/masonry"
import * as H from "@dashkite/masonry-hooks"
import { pug } from "@dashkite/masonry-pug"
import { markdown } from "@dashkite/masonry-markdown"
import T from "@dashkite/masonry-targets"


# we only support Pug now, but this approach is extensible
dictionary =
  pug: ( context ) ->
    context.build.preset = "html"
    pug context

wrapper = ( context ) ->

  if ( template = context.build.template )?

    extension = Path.extname context.build.template

    context.source.path = Path.format
      dir: context.source.directory
      name: context.source.name
      ext: extension
    context.source.extension = extension

    # Load the template contents into the input
    root = context.build.root ? context.root
    path = Path.join root, template
    context.input = await FS.readFile path, "utf8"

    # get the handler for this template
    handler = dictionary[ extension[ 1.. ]]

    handler context

  else

    md context

md = null
export default ( Genie ) ->

  md = await markdown()

  Genie.define "markdown:build", "markdown:clean", ->
    options = Genie.get "markdown"
    
    do M.start [
      T.glob options.targets
      H.read
      M.transform wrapper
      T.extension ".html"
      T.write "build/${ build.target }"
    ]

  Genie.define "markdown", "markdown:build"
  Genie.on "build", "markdown:build"
  Genie.define "markdown:clean", "clean"