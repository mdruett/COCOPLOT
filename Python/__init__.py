name = "COCOpy"

import numpy as np
from PIL import Image as img
import astropy.io.fits as f
import matplotlib.pyplot as plt
import matplotlib.animation as animation

def filter(wavelengths, filtername, rgb_pos ='default', plot=False):
    '''
    Make filters for cocoplot
    
    Parameters
    ----------
    wavelengths : array
        a set of wavelengths or an np.arange() array if spacing is equidistant.
    filtername  : string
        name of desired filter type. Choose from the following options:
    
        'single' :
            single wavelength points uses keyword rgb_pos[r,g,b]
            r,g,b should be array elements not array values!
            default values are [n,n/2,0] for an array of length n
        'band'   :
            bands of wavelength points uses keyword rgb_pos[r,g,b]
            specify which wavength points are wanted to start the bands with r,g,b
            Give a two number list for each color to indicate the begining and end wavelength.
            These should be array elenents and not array values!
            note that the end wavelength is not included!
            e.g. [[0, 3], [3, 4], [6, 7]]
        'normal' :
            exponential filters, like the cones of the eye
            uses keyword rgb_pos[r,g,b], this takes the array values not elements!
            Give a two number list for each color
            to indicate the mean and std of each Gaussian.
            e.g. [[wavelength[index], std], [5, 3], [11, 3]]
    rgb_pos     : array
        input list with desired filter locations. See filtername keyword for default values
    plot        : bool
        plots filters. Default = False
    
    Returns
    -------
    filter      : array
        3 channel cube with length (wavelengths, 3) with applied filter
    
    Example
    --------
    import COCOpy as cp
    wavelengths = np.arange(10)
    filt = cp.filter(wavelengths, 'band', [[2,4], [4,8], [9,9]])
    
    Returns:
    array([  [ 0.  ,  0.  ,  0.  ],
    [ 0.  ,  0.  ,  0.  ],
    [ 0.5 ,  0.  ,  0.  ],
    [ 0.5 ,  0.  ,  0.  ],
    [ 0.  ,  0.25,  0.  ],
    [ 0.  ,  0.25,  0.  ],
    [ 0.  ,  0.25,  0.  ],
    [ 0.  ,  0.25,  0.  ],
    [ 0.  ,  0.  ,  0.  ],
    [ 0.  ,  0.  ,  1.  ]])
    
    :Authors:
        Based on coco.pro:COCOFILTERS by M. Druett, Python version by A Pietrow, May 2019
        Added default values and minor updates, A Pietrow, Jul 2019
        Updated to Python3, A Pietrow, Okt 2021
    

    '''
    
    #make empty filter of correct length
    nL = len(wavelengths)
    w = wavelengths
    filter = np.zeros([nL,3])
    
    #chose type of filter
    if filtername == 'single':
        if rgb_pos == 'default':
            print('Applying "single" filter. No positions were given for rgb_pos, assuming default values of R={0}, G={1}, B={2}.'.format(nL-1,nL//2, 0))
            rgb_pos = [nL-1,nL//2,0]
        
        if len(rgb_pos) != 3:
            raise ValueError("rgb_pos should have 3 values!")
        
        filter[rgb_pos[0],0] = 1.
        filter[rgb_pos[1],1] = 1.
        filter[rgb_pos[2],2] = 1.
        print('Applying "single" filter for R={0}, G={1}, B={2}'.format(rgb_pos[0],rgb_pos[1],rgb_pos[2]))
    
    elif filtername == 'band':
        if rgb_pos == 'default':
            print('Applying "band" filter. No positions were given for rgb_pos, assuming default values of R=[{4},{5}], G=[{2},{3}], B=[{0},{1}].'.format(0, int(np.floor(nL//3)), int(np.ceil(nL//3)), int(np.floor(2*nL//3)), int(np.ceil(2*nL//3)), nL))
            
            rgb_pos = [[int(np.ceil(2.*nL/3)), nL],[int(np.ceil(nL//3.)), int(np.floor(2.*nL//3))],[0, int(np.floor(nL//3.))]]
        
        if len(rgb_pos) != 3:
            raise ValueError("rgb_pos should have 3 values!")
        
        if len(rgb_pos[0]) != 2 or len(rgb_pos[1]) != 2 or len(rgb_pos[2]) != 2:
            raise TypeError("Check rgb_pos, it should be im the shape of [[a,b],[c,d],[e,f]]")
        
        for i in range(3):
            if (rgb_pos[i][1] - rgb_pos[i][0]) < 0:
                raise ValueError("Value Error.")
            
            if rgb_pos[i][0] == rgb_pos[i][1]: #check if bin is broader than 1
                filter[rgb_pos[i][0], i] = 1./(rgb_pos[i][1] - rgb_pos[i][0] + 1)
            else:
                filter[rgb_pos[i][0]:rgb_pos[i][1], i] = 1./(rgb_pos[i][1] - rgb_pos[i][0])

    elif filtername == 'normal':
        if rgb_pos == 'default':
            mR = w[-1]
            sR = sG = sB = (w[-1]-w[0])/(2*1.96)
            sG /= 2. #B and R are on the edge, so green would get twice the intensity if we don't divide by 2.
            mG = (w[-1] + w[0])/2.
            mB = w[0]
            print('Applying "normal" filter. No positions were given for rgb_pos, assuming default values of R=[{0},{1}], G=[{2},{3}], B=[{4},{5}].'.format(mR,sR,mG,sG,mB,sB))
                
            rgb_pos = [[mR,sR],[mG,sG],[mB,sB]]
            
            if len(rgb_pos) != 3:
                raise ValueError("rgb_pos should have 3 values!")
            try:
                len(rgb_pos[0]) != 2
            except TypeError:
                raise TypeError("Check rgb_pos, it should be im the shape of [[a,b],[c,d],[e,f]]")
        
            #mean, sigma
            for i in range(3):
                std = np.float(rgb_pos[i][1])
                mn  = np.float(rgb_pos[i][0])
                c = 1./(std * np.sqrt(2*np.pi))
                
                num = np.arange(len(filter[:,0]))
                num = wavelengths
                
                filter[:,i] =   (c*  np.e**(-0.5 * ( ( num - mn)/std )**2 ) )

    else:
        raise ValueError("filtername not recognised. Check help(filter) for available filter types.")
        
        if plot:
            plt.plot(wavelengths, filter[:,0], color='r', label='red')
            plt.plot(wavelengths, filter[:,1], color='g', label='green')
            plt.plot(wavelengths, filter[:,2], color='b', label='blue')
            plt.scatter(wavelengths, np.zeros_like(wavelengths), color='black', label='data')
            plt.legend()
            plt.show()

    return filter


def RGB(datacube, filters, threshold=0, thresmethod='percentile'):
    '''
    Color Convolves a 3D cube with an RGB filter.
    
    Parameters
    ----------
    datacube    : array
        3D or 4D cube of shape [lambda,x,y] or [t,lambda,x,y]
    filters     : array
        output from filter()
    threshold   : array
        2 element array that saturates all values below and above the provided values.
    thresmethod : string
        set method of thesholding. Default: 'numeric'
    
        numeric  - allows to give a min and max value in counts
        fraction - give threshold value in fractional numbers between 0 and 1.
        percentile - give threshold value in percentiles between 0 and 100 inclusive.
    
    Returns
    -------
    data_rgb    : array
        3d cube of size [x,y,3] to make images.
    
    :Authors:
        Based on coco.pro:COCORGB by M. Druett, Python version by A.G.M. Pietrow, may 2019
        Updated to Python3, A Pietrow, Okt 2021
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
            len(threshold) != 2
        except TypeError:
            raise TypeError("threshold should be given as a 2 element list. e.g. [0,110]")
        
        if thresmethod == 'numeric':
            data_collapsed.clip(threshold[0], threshold[1])
        elif thresmethod == 'fraction':
            mx = np.max(datacube)
            mn = np.min(datacube)
            pmn = mn + threshold[0] * (mx - mn)
            pmx = mn + threshold[1] * (mx -mn)
            data_collapsed.clip(pmn, pmx)
            data_collapsed -= pmn
        elif thresmethod == 'percentile':
            pmn = np.percentile(datacube,threshold[0])
            pmx = np.percentile(datacube,threshold[1])
            data_collapsed.clip(pmn, pmx)
            data_collapsed -= pmn
        else:
            raise ValueError("thresmethod not recognised. Should be 'numeric', 'fraction' or 'percentile'.")
        if data_collapsed.size == 0:
            raise TypeError("Array empty after thresholding!")
    
    return data_collapsed

def norm(data):
    '''
    Normalises data to value between 0 and 255.
    
    Parameters
    ----------
        data        : array
            datacube of shape [x,y,3], usually the output of the RGB function.
    
    Returns
    ----------
        data_norm   : RGB array
            datacube of shape [x,y,3] normalised to values between 0 and 255
    
    :Authors:
        Based on coco.pro:coconorm by M.Druett.
        Updated to Python3, A Pietrow, Okt 2021
    '''
    return np.uint8(np.round(data*255./np.max(data)))


def plot(datacube, filter, threshold=0, thresmethod='numeric', show=True, name=False, path=''):
    '''
    Color Convolves a 3D cube with an RGB filter and normalizes.
    
    Parameters
    ----------
    datacube    : array
        3D cube of shape [lambda,x,y]
    filters     : array
        output from filter()
    threshold   : array
        2 element array that saturates all values below and above the provided values.
    thresmethod : string
        set method of thesholding. Default: 'numeric'
        
        numeric  - allows to give a min and max value in counts
        fraction - give threshold value in fractional numbers between 0 and 1.
    name        : string
        Saves cocoplot to disk if name is set Default: False
    show        : bool
        Show resulting image. Default: True.
    path        : string
        path to save image. Default: ''
    
    Returns
    -------
    data_rgb    : RGB array
        3d cube of size [x,y,3] to make images.
        
    Example
    -------
    import COCOpy as cp
    import numpy as np
    wavelengths = np.arange(40)
    filt = cp.filter(wavelengths, 'band', [[2,4], [4,8], [9,9]])
    a = np.random.random([40,100,100])
    coco = cp.plot(a,filt)
    
    :Authors:
        Based on coco.pro:COCOPLOT by M. Druett, Python version by A.G.M. Pietrow
        Updated to Python3, A Pietrow, Okt 2021
    '''
    
    data_float = RGB(datacube, filter, threshold=threshold, thresmethod=thresmethod)
    data_int = norm(data_float)
    
    if show:
        plt.imshow(data_int, origin='lower')
        plt.show()
    if name:
        image = img.fromarray(data_int).transpose(img.FLIP_TOP_BOTTOM)
        image.save(path+name)
    
    return data_int

def video(datacube, filter, fps=3, threshold=0, thresmethod='numeric', show=True, name=False, path=''):
    '''
    Color Convolves a 4D cube with an RGB filter, normalizes and then makes a video.
    
    Parameters
    ----------
    datacube    : array
        4D cube of shape [t,lambda,x,y]
    filters     : array
        output from filter()
    fps         : int
        frames per second. Default:3
    threshold   : array
        2 element array that saturates all values below and above the provided values.
    thresmethod : string
        set method of thesholding. Default: 'numeric'
        
        numeric  - allows to give a min and max value in counts
        fraction - give threshold value in fractional numbers between 0 and 1.
        
    show        : bool
        Will show animation if True. Default: True
    name        : string
        Saves plot to disk if name is set Default: False
    path        : string
        path to save image. Default: ''
    
    Returns
    ----------
    data_rgb    : array
        4d cube of size [t,x,y,3] to make videos.
    
    :Authors:
        Based on CRISpy:animate_cube by A.G.M. Pietrow
        Updated to Python3, A Pietrow, Okt 2021
    '''
    if not show and not name:
        raise ValueError("Save and show are both set to False, so this function does nothing.")
    
    shape = np.shape(datacube)
    final_cube = plot(datacube, filter, threshold=threshold, thresmethod=thresmethod, show=0)



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

def filtplot(line,filter,color=True, xlabel='Wavelengths', ylabel='Arbitrary Units', title=''):
    '''
    Convolve profile with filters to see result.
    
    Parameters
    ----------
    line    : array
        1d profile
    filter  : array
        filter from cocofilter
    color   : bool
        If True the color of the profile will have the RGB value
        that the filter would give it. Otherwise profile is black.
        Defealt = True
    xlabel  : string
        text on xlabel. Default: 'Wavelengths'
    ylabel  : string
        text on ylabel. Default: 'Arbitrary Units'
    title   : string
        title of plot. Deleault: ''
    
    Returns
    ----------
    Image with filters, input profile and convolved results.
    
    :Authors:
        Updated to Python3, A Pietrow, Okt 2021
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
