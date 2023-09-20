
 @what - This repository started as fork of "freebsd-doc" as this had broken IRIX man page handling
       The initial expectation was to just do some "tweeks" of the FreeBSD Manual pages code
        to handle IRIX correctly
       After testing and trying various options, the IRIX part turned into a page cache based
        solution (vs request based on the fly rendering).

       The result is that none of the freebsd code was used and instead a much simpler set of
        cache creation tools were used.

        This then morphed into handling: IRIX, UNIX and BSD variants.

        I belive that having static pre-rendered pages make sense for:
          - security - as just serving static pages is more secure than calling CGI or other code
          - performance - pulling static pages performs better than on the fly rendering
          - overall efficiently - this approach is render once, read many time

        The code is under IRIX tree, as this was original place where the IRIX pre-processed man/cat file handling was put.

        @author: John Hartley (Graphica Software/Dokmai Pty Ltd)

        (C)opyright 2023 - All rights reservered

