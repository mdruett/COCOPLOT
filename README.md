# COCOPLOT
COlor COllapsed PLOTting software (COCOPLOT) generates quick-look and context images. The aim is to convey spectral profile information from all of the spatial pixels in a 3D datacube via a single 2D image, using color. Filters for red, green, and blue channels are convolved with the datacube to produce an RGB a color image. This process avoids the user needing to scan through many different wavelengths when searching for regions in the datacube that satisfy multiple criteria.

Although applicable to any 3D datacube, this software was inspired by a single thought: what would the Sun look like if we could only see light from one spectral line? In an absorption line, with low emission in the central wavelengths, and high wings on either side, the blue and red cone receptors of our thought experiment would be triggered, making the Sun appear purple. For a strong, narrow emission line the converse is true, and so the line would appear green. A red or blue Doppler-shifted emission would appear in those colours respectively.

## Citing this method
These routines were developed as part of a publication by
[M. Druett et al. (2022)](https://ui.adsabs.harvard.edu/abs/2021arXiv211110786D/abstract).
Please if you use them in your project we would appreciate
it if you cite our publication.

## Acknowledgements
This work was supported by The Swedish Research Council, grant number 2017-04099
