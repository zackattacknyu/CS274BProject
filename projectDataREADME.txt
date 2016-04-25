ProjectData.zip Information:

Contains all the timesteps for the following months:
September 2010
September 2011

Contains most of the timesteps for the following:
September 2012

Each .mat file is a 500x750 array of data related to the Western United States

Here are the prefixes and the data contained in their files:
	ytarget: indicates target rainfall data from radar (in mm)
	xdata: indicates feature data. 
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


Instructions for viewing data: