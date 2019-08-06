;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO COCOVIDEO, coco_datacube, filter, fps, name, FILEPATH=filepath, STARTSTOP=startstop, RGBTHRESH=rgbthresh, THRESHMETHOD=threshmethod, LOUD=loud, DIMS=dims
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;   COCOVIDEO
;
; PURPOSE:
;   Generate and save an animation of COCOPLOT images.
;
; CATEGORY:
;   COCOPLOT visualisation
;
; CALLING SEQUENCE:
;   COCOVIDEO, coco_datacube, filter, fps, name
;
; INPUTS:
;   coco_datacube:  Input 4D data cube of dimensions [nx, ny, nspect_points, nt].
;   filter:         Filter of dimensions [nspect_points, 3].
;   fps:            Frames per second.
;   name:           String containing output file name.
;
; KEYWORD PARAMETERS:
;   FILEPATH:       Output filepath prefixed to the "name" variable.
;   STARTSTOP:      Start and stop indices for time dimension. Defaults to
;                   [0,nt-1].
;   RGBTHRESH:      Flag to apply saturation thresholding. Defaults to not set.
;   THRESHMETHOD:   Scalar string specifying the Saturation thresholding method.
;                   Can be 'fraction', 'numeric' or 'percentile'. Defaults to not set.
;   LOUD:           Display the video. Defaults to not set.
;   DIMS:           Image dimensions for display. Defaults to [nx, ny] of
;                   input coco_datacube.
;
; OUTPUTS:
;   Save a series of COCOPLOT images as an animation.
;
; RESTRICTIONS:
;   Requires the following procedures and functions:
;     Functions:  IDLFFVIDEOWRITE(), COCOPLOT(), COCOIMAGE(), COCOSHOW()
;
; EXAMPLE:
;   TBD
;
; MODIFICATION HISTORY:
;   Written by: Malcolm Druett, May 2019
;-
  IF (N_PARAMS() LT 4) THEN BEGIN
    MESSAGE, 'Syntax: COCOVIDEO, coco_datacube, filter, fps, name '+$
      '[, FILEPATH=filepath] [, STARTSTOP=startstop] [, /RGBTHRESH] '+$
      '[, THRESHMETHOD=threshmethod] [, /LOUD] [, DIMS=dims]', /INFO
    RETURN
  ENDIF

  sz = SIZE(coco_datacube)
  IF (sz[0] NE 4) THEN BEGIN
    MESSAGE, 'ERROR: coco_datacube must be a 4D data cube of dimensions [nx, ny, nspect_points, nt]', /INFO
    RETURN
  ENDIF
  IF (N_ELEMENTS(DIMS) NE 2) THEN dims = sz[1:2]
  IF (N_ELEMENTS(STARTSTOP) NE 2) THEN startstop=[0,sz[4]-1]
  fileloc=name
  IF (N_ELEMENTS(FILEPATH) EQ 1) THEN fileloc=filepath+name
  video_object_name = idlffvideowrite(fileloc)
  video_stream_name =video_object_name.addvideostream(dims[0], dims[1], fps)
  ; Create video while showing images if loud keyword set
  w = WINDOW(DIMENSIONS=dims, BUFFER=(NOT KEYWORD_SET(LOUD)))
  FOR i_loop=startstop[0],startstop[1] DO BEGIN
        my_rgb=COCOPLOT(coco_datacube[*,*,*,i_loop], filter, RGBTHRESH=rgbthresh, THRESHMETHOD=threshmethod, CURRENT=1, DIMS=dims)
        my_image=w.copywindow()
        timestamp = video_object_name.put(video_stream_name, my_image)
  ENDFOR
  OBJ_DESTROY, video_object_name
END
