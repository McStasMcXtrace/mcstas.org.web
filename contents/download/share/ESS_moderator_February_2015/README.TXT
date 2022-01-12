This directory contains an updated ESS source component for use with McStas 2.x and 1.12c - dated February 2015!

The component comes with a library of ESS source brilliances, including:

    - 2001, legacy "Mezei moderators" from the original F. Mezei documents, rescaled to ESS TDR frequency, pulselength and power.
    - TDR,  Mezei moderators, with a wavelength-dependent correction term to the cold flux, derived from  2012 MCNPX calculations 
      by ESS neutronics group. Corrections calculated by K Lieutenant (Vitess) NOTE: uses the 2001 brilliance for the thermal moderator!
    - 2013, post-TDR update with non-Maxwellian cold spectrum, Troels Schoenfeldt, BEFORE the ESS pancake geometry was introduced.
    - 2014  updated brilliance using formulation by Troels Schoenfeldt, including support for the "pancacke", i.e. flat geometry and
      geometrical brilliance over the moderator surface.

IMPORTANT: This component DOES NOT implement the "optimized thermal" or "butterfly" like moderators - a new version will be released 
in connection with McStas 2.2 spring 2015.

An important detail about the 2014-pancake moderator is that the component origin is NOT at the centre of the cylindrical cold source, but
instead at the middle of the front face of the cylinder. For technical reasons, neutrons are in this case propagated from a tangential plane
at this point.

    - We further provide a set of example instruments for producing curves corresponding to each of the brilliance settings.
    - ... as well as an updated version of the Brilliance_monitor.comp, allowing multiple instances within an instrument file

The difference with respect to the July 2014 version released with McStas 2.1 and as a tarball to http://mcstas.org/download/share is a
bug reported by Jan Saroun regarding to solid angle correction in the 2014 / pancake case.

Please also read the "usage recommendations" provided in the enclosed PDF


Peter Willendrup
