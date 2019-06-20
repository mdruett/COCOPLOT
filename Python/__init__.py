name = "COCOpy"

import numpy as np
from PIL import Image as img
import astropy.io.fits as f
import matplotlib.pyplot as plt
import matplotlib.animation as animation

def cocofilter(wavelengths, filtername, pos_rgb, plot=0):
    '''
    Make filters for cocoplot
    INPUT:
        wavelengths     : a set of wavelengths or an np.arange() array if spacing is equidistant.
        filtername      : name of desired filter type. Chose from.

                        'single' :  single wavelength points
                                    uses keyword pos_rgb[r,g,b]
                                    specify which wavength points wanted
                                    with r,g,b
                                    
                        'band'   :  bands of wavelength points
                                    uses keyword pos_rgb[r,g,b]
                                    specify which wavength points are wanted
                                    to start the bands with r,g,b
                                    Give a two number list for each color
                                    to indicate the begining and end wavelength
                                    note that the end wavelength is not included!
                                    e.g. [[2, 3], [3, 4], [6, 7]]
                                    
                        'normal'    :  exponential filters, like the cones of the eye
                                    uses keyword pos_rgb[r,g,b]
                                    specify which wavength points are wanted
                                    to start the bands with r,g,b
                                    Give a two number list for each color
                                    to indicate the mean and std of each Gaussian.
                                    e.g. [[wavelength[index], std], [5, 3], [11, 3]]
                                    
        pos_rgb         : input list with desired filter locations.
        plot            : plots filters. Default = 0
    
    OUTPUT:
        filter          : 3 channel cube with length (wavelengths, 3) with applied filter
        
        Based on coco.pro:COCOFILTERS by M. Druett, Python version by A.G.M. Pietrow
    
    EXAMPLE:
        wavelengths = np.arange(10)
        cocofilter(wavelengths, 'band', [[2,4], [4,8], [9,9]])
        
        >>>array([  [ 0.  ,  0.  ,  0.  ],
                    [ 0.  ,  0.  ,  0.  ],
                    [ 0.5 ,  0.  ,  0.  ],
                    [ 0.5 ,  0.  ,  0.  ],
                    [ 0.  ,  0.25,  0.  ],
                    [ 0.  ,  0.25,  0.  ],
                    [ 0.  ,  0.25,  0.  ],
                    [ 0.  ,  0.25,  0.  ],
                    [ 0.  ,  0.  ,  0.  ],
                    [ 0.  ,  0.  ,  1.  ]])
    '''
    
    nL = len(wavelengths)
    filter = np.zeros([nL,3])
    
    if filtername == 'single':
        if len(pos_rgb) <> 3:
            raise ValueError("pos_rgb should have 3 values!")
        filter[pos_rgb[0],0] = 1.
        filter[pos_rgb[1],1] = 1.
        filter[pos_rgb[2],2] = 1.

    elif filtername == 'band':
        if len(pos_rgb) <> 3:
            raise ValueError("pos_rgb should have 3 values!")
        try:
            len(pos_rgb[0]) <> 2
        except TypeError:
            raise TypeError("Check pos_rgb, it should be im the shape of [[a,b],[c,d],[e,f]]")

        if len(pos_rgb[0]) <> 2 or len(pos_rgb[1]) <> 2 or len(pos_rgb[2]) <> 2:
            raise ValueError("pos_rgb should have 2 values for each color band.")

        for i in range(3):
            if (pos_rgb[i][1] - pos_rgb[i][0]) < 0:
                raise ValueError("invalid range.")
            
            if pos_rgb[i][0] == pos_rgb[i][1]: #check if bin is broader than 1
                filter[pos_rgb[i][0], i] = 1./(pos_rgb[i][1] - pos_rgb[i][0] + 1)
            else:
                filter[pos_rgb[i][0]:pos_rgb[i][1], i] = 1./(pos_rgb[i][1] - pos_rgb[i][0])
            
    elif filtername == 'normal':
        if len(pos_rgb) <> 3:
            raise ValueError("pos_rgb should have 3 values!")
        try:
            len(pos_rgb[0]) <> 2
        except TypeError:
            raise TypeError("Check pos_rgb, it should be im the shape of [[a,b],[c,d],[e,f]]")

        #mean, sigma
        for i in range(3):
            std = np.float(pos_rgb[i][1])
            mn  = np.float(pos_rgb[i][0])
            c = 1./(std * np.sqrt(2*np.pi))
            
            num = np.arange(len(filter[:,0]))
            num = wavelengths
            
            filter[:,i] =   (c*  np.e**(-0.5 * ( ( num - mn)/std )**2 ) )
            
    else:
        raise ValueError("filtername not recognised. Check help(cocofilter) for available filter types.")

    if plot:
        plt.plot(filter[:,0], color='r')
        plt.plot(filter[:,1], color='g')
        plt.plot(filter[:,2], color='b')
        plt.show()

    return filter


def cocoRGB(datacube, filters, threshold=0, thresmethod='percentile'):
    '''
    Color Convolves a 3D cube with an RGB filter.
    INPUT:
        datacube    : 3D or 4D cube of shape [lambda,x,y] or [t,lambda,x,y]
        filters     : output from cocofilters()
        threshold   : 2 element array that saturates all values below and above the provided values.
        thresmethod : set method of thesholding. Default: 'numeric'
                      numeric  - allows to give a min and max value in counts
                      fraction - give threshold value in fractional numbers between 0 and 1.
                      percentile - give threshold value in percentiles between 0 and 100 inclusive.
        
    OUTPUT:
        data_rgb    : 3d cube of size [x,y,3] to make images.
        
        Based on coco.pro:COCORGB by M. Druett, Python version by A.G.M. Pietrow
    '''
    #datacbe = 3d, numerical, filters have len n
    if len(datacube.shape) < 3 or  len(datacube.shape) > 4:
        raise ValueError("Array must be 3D or 4D")
    try:
        datacube.astype(float)
    except ValueError:
        raise ValueError("Array must be float")
    ##filters correct len


    #apply filter to cube and collapse cube int x,y,RGB
    if len(datacube.shape) == 3:
        data_collapsed = np.tensordot(datacube,filters,axes=(0,0))

    if len(datacube.shape) == 4:
        data_collapsed = np.tensordot(datacube,filters,axes=(1,0))

    if threshold:
        try:
            len(threshold) <> 2
        except TypeError:
            raise TypeError("threshold should be given as a 2 element list. e.g. [0,110]")
        
        if thresmethod == 'numeric':
            data_collapsed[np.where(data_collapsed > threshold[1])] = threshold[1]
            data_collapsed[np.where(data_collapsed < threshold[0])] = threshold[0]
        elif thresmethod == 'fraction':
            mx = np.max(datacube)
            mn = np.min(datacube)
            pmn = mn + threshold[0] * (mx - mn)
            pmx = mn + threshold[1] * (mx -mn)
            data_collapsed[np.where(data_collapsed >= pmx)] = pmx
            data_collapsed[np.where(data_collapsed <= pmn)] = pmn
            data_collapsed -= pmn
        elif thresmethod == 'percentile':
            pmn = np.percentile(datacube,threshold[0])
            pmx = np.percentile(datacube,threshold[1])
            data_collapsed[np.where(data_collapsed >= pmx)] = pmx
            data_collapsed[np.where(data_collapsed <= pmn)] = pmn
            data_collapsed -= pmn
        else:
            raise ValueError("thresmethod not recognised. Should be 'numeric', 'fraction' or 'percentile'.")
        if data_collapsed.size == 0:
            raise TypeError("Array empty after thresholding!")
    
    return data_collapsed

def cocoplot(datacube, filter, threshold=0, thresmethod='numeric', show=True, name=False, path=''):
    '''
        Color Convolves a 3D cube with an RGB filter and normalizes.
        
        INPUT:
        datacube    : 3D cube of shape [lambda,x,y]
        filters     : output from cocofilters()
        threshold   : 2 element array that saturates all values below and above the provided values.
        thresmethod : set method of thesholding. Default: 'numeric'
                      numeric  - allows to give a min and max value in counts
                      fraction - give threshold value in fractional numbers between 0 and 1.
        name        : Saves cocoplot to disk if name is set Default: False
        show        : Show resulting image. Default: True.
        path        : path to save image. Default: ''
        
        OUTPUT:
        data_rgb    : 3d cube of size [x,y,3] to make images.
        
        Based on coco.pro:COCOPLOT by M. Druett, Python version by A.G.M. Pietrow
    
    '''
    data_float = cocoRGB(datacube, filter, threshold=threshold, thresmethod=thresmethod)
    data_int   = np.uint8(np.round(data_float*255./np.max(data_float)))
    
    if show:
        plt.imshow(data_int, origin='lower')
        plt.show()
    if name:
        image = img.fromarray(data_int).transpose(img.FLIP_TOP_BOTTOM)
        image.save(path+name)

    return data_int

def cocovideo(datacube, filter, fps=3, threshold=0, thresmethod='numeric', show=True, name=False, path=''):
    '''
        Color Convolves a 4D cube with an RGB filter, normalizes and then makes a video.
        
        INPUT:
        datacube    : 4D cube of shape [t,lambda,x,y]
        filters     : output from cocofilters()
        fps         : frames per second. Default:3
        threshold   : 2 element array that saturates all values below and above the provided values.
        thresmethod : set method of thesholding. Default: 'numeric'
                      numeric  - allows to give a min and max value in counts
                      fraction - give threshold value in fractional numbers between 0 and 1.
        show        : Will show animation if True. Default: True
        name        : Saves cocoplot to disk if name is set Default: False
        path        : path to save image. Default: ''
        
        OUTPUT:
        data_rgb    : 4d cube of size [t,x,y,3] to make videos.
        
        Based on CRISpy:animate_cube by A.G.M. Pietrow
        
    '''
    if not show and not name:
        raise ValueError("Save and show are both set to False, so this function does nothing.")
    
    shape = np.shape(datacube)
    final_cube = cocoplot(datacube, filter, threshold=threshold, thresmethod=thresmethod, show=0)
    

    
    if show:
        fig = plt.figure()
        img = plt.imshow(final_cube[0], animated=True, origin='lower')
        img.axes.get_xaxis().set_visible(False)
        img.axes.get_yaxis().set_visible(False)

        interval = 1000./fps

        def updatefig(i):
            img.set_array(final_cube[i])
            return img,

        ani = animation.FuncAnimation(fig, updatefig, frames=final_cube.shape[0], interval=interval, blit=True)
        plt.show()

    if name:
        ani.save(path+name, fps=fps)

def flip3d(data):
    '''
    flips 3d cube of shape [L,x,y] to [x,y,L]
    '''
    data = np.swapaxes(np.swapaxes(data,0,-1), 0,1) #Make sure that it is x,y,L
    return data

def flip4d(data):
    '''
    flips 4d cube of shape [t,L,x,y] to [t,x,y,L]
    '''
    data = np.swapaxes(np.swapaxes(data,1,-1), 1,2) #Make sure that it is x,y,L
    return data

def cocopol(data):
    '''
        removes all NAN and negative values from dataset.
        '''
    data[np.isnan(data)] = 0
    data = data - data.min()
    return data

def cbarimg(Ticks=['Right Enhanced', 'Central Enhanded', 'Left Enhanced'], size=(0.5,6), show=0):
    '''
        Makes RGBR colorbar whith proper ticks.
        INPUT:
        Ticks   :   List of 3 values to describe what the 3 colors stand for.
        size    :   Size of the bar in inch
        show    :   Shows the colorbar. Default=0
        '''
    Ticks = np.append(Ticks, Ticks[0])
    a = np.array([[0,1]])
    plt.figure(figsize=size)
    plt.imshow(a, cmap="hsv")
    plt.gca().set_visible(False)
    cax = plt.axes([0.1, 0.2, 0.8, 0.6])
    cbar = plt.colorbar(cax=cax, ticks=[0,0.3,0.65,1] )
    cbar.ax.set_yticklabels(Ticks)
    plt.autoscale()
    plt.savefig('cbar.png',bbox_inches='tight')
    if show:
        plt.show()
    cbarimg = img.open('cbar.png')
    return cbarimg

#def cocoimage(data_int, name, cbarimg):
    '''
    Makes a composite image of COCO and a colorbar.
    INPUT:
        cocoimg :   PIL.Image of COCO data. Made with coco()
        name    :   name under which file should be saved
        cbarimg :   PIL.Image of colorbar. Made with cbarimg()
    '''
#    imx, imy = cocoimg.size
#    cx, cy = cbarimg.size
#    bg = img.new('RGB', (imx+20+cx,imy), (255,255,255))
#    bg.paste(cocoimg)
#    bg.paste(cbarimg, (imx + 20, (imy-cy)/2))
#    bg.show()
#    bg.save(name)
#    plt.close()

def plotfilt(line,filter,color=True, xlabel='Wavelengths', ylabel='Arbitrary Units', title=''):
    '''
    Convolve profile with filters to see result.
    INPUT:
        line:   1d profile
        filter: filter from cocofilter
        color:  If True the color of the profile will have the RGB value
                that the filter would give it. Otherwise profile is black.
                Defealt: True
        xlabel: text on xlabel. Default: 'Wavelengths'
        ylabel: text on ylabel. Default: 'Arbitrary Units'
        title:  title of plot. Deleault: ''
    
    OUTPUT:
        Image with filters, input profile and convolved results.
    '''
    RGB = np.sum(filter*line[:,np.newaxis],axis=0)
    RGB = np.uint8(np.round(RGB*255/np.max(RGB)))
    RGBn = RGB/255.
    filter = filter/np.max(filter)
    line = line/(np.max(line)*1.3)
    len_line = len(line)

    plt.plot(filter[:,0],'--', c='red',alpha=0.5)
    plt.plot(filter[:,1],'--', c='green',alpha=0.5)
    plt.plot(filter[:,2],'--', c='blue',alpha=0.5)
    plt.plot(line*filter[:,0], c='red')
    plt.plot(line*filter[:,1], c='green')
    plt.plot(line*filter[:,2], c='blue')
    if color:
        plt.plot(np.arange(len_line),line,c=RGBn,marker='o')
    else:
        plt.plot(np.arange(len_line),line,c='black',marker='o')
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.title(title)
    plt.show()
