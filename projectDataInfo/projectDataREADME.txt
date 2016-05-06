ProjectData.zip Information:

Contains all the timesteps for the following months:
September 2010
September 2011

Contains most of the timesteps for the following:
September 2012

Each .mat file is a 500x750 array of data related to the Western United States

Here are the prefixes and the data contained in their files:
	ytarget: indicates target rainfall data from radar (in mm)
	         If value is < 0, then there was no reading
	xdata: indicates feature data. these files are 500x750x13 arrays with last dimension being feature
			First feature is pixel wise temperature
			Next 12 features are related to its patch
			Features are described in this webpage: http://chrs.web.uci.edu/research/satellite_precipitation/activities01.html
	xone: indicates data for first feature, point-wise temperature (in Kevlin). 
		  If value is <= 0, then we ignore that pixel
	ccspred: indiciates predicted rainfall amount using ccs algorithm
		      Note, at the moment this is not available for Sep 2010
	seg: Each map is split into m cloud patches (m is different for each map). 
		 If value is 0, pixel was not put into any cloud patch. 
		 Otherwise, value is between 1 and m and indicates which cloud patch a pixel is part

Each suffix indicates time and date in the following format: 
	YYMMDDHHMM
Hour is by 24-hour clock

Instructions for viewing target and prediction map:
1. Make a 500x750 matrix containing the precipitation values. For this example, I will call it 'precipMatrix'
2. Make sure the following files included in the folder are added to the MATLAB path or are in the same folder as the code being run
	drwvect.m
	loadfn.m
3. Add the following code where the display should appear:
	figure;
	imagesc(precipMatrix)
	colormap([1 1 1;0.8 0.8 0.8;jet(20)])
	caxis([-1 20]) 
	drwvect([-130 25 -100 45],[500 750],'us_states_outl_ug.tmp','k')
	colorbar('vertical')