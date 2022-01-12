This directory contains an updated ESS source component for use with McStas 2.x and 1.12c.

The component comes with a library of ESS source brilliances, including:

    - 2001, legacy "Mezei moderators" from the original F. Mezei documents, rescaled to ESS TDR frequency, pulselength and power.
    - TDR,  Mezei moderators, with a wavelength-dependent correction term to the cold flux, derived from  2012 MCNPX calculations 
      by ESS neutronics group. Corrections calculated by K Lieutenant (Vitess) NOTE: uses the 2001 brilliance for the thermal moderator!
    - 2013, post-TDR update with non-Maxwellian cold spectrum, Troels Schoenfeldt, BEFORE the ESS pancake geometry was introduced.
    - 2014  updated brilliance using formulation by Troels Schoenfeldt, including support for the "pancacke", i.e. flat geometry and
      geometrical brilliance over the moderator surface.

An important detail about the 2014-pancake moderator is that the component origin is NOT at the centre of the cylindrical cold source, but
instead at the middle of the front face of the cylinder. For technical reasons, neutrons are in this case propagated from a tangential plane
through that point.

    - We further provide a set of example instruments for producing curves corresponding to each of the brilliance settings.
    - ... as well as an updated version of the Brilliance_monitor.comp, allowing multiple instances within an instrument file
    
We hope you will find this useful even though the official McStas 2.1 is still pending... 
(We are still hunting a couple of bugs, release will be post vacation-season 2014)

Peter Willendrup
