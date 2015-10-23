%% Reading events into a Catalog object
% GISMO can read events from many different earthquake catalog file formats
% (e.g. Seisan, Antelope) and data sources (e.g. IRIS DMC) using the
% readEvents() function.

%% The readEvents() function
% The readEvents() function is used to read event metadata (origin time, 
% lon, lat, depth, mag etc.) from a variety of catalog data sources and
% file formats into a Catalog object. 
%
% Usage:
%       catalogObject = readEvents(dataformat, 'param1', _value1_, ...
%                                                   'paramN', _valueN_)
% 
% dataformat may be:
%%
%
% * 'iris' (for IRIS DMC, using irisFetch.m), 
% * 'antelope' (for a CSS3.0 Antelope/Datascope database)
% * 'seisan' (for a Seisan database with a REA/YYYY/MM/ directory structure)
%

%%
% The name-value parameter pairs supported are the same as those supported
% by irisFetch.Events(). Currently these are:
%%
% 
% * _startTime_
% * _endTime_ 
% * _eventId_ 
% * _fetchLimit_
% * _magnitudeType_
% * _minimumLongitude_
% * _maximumLongitude_
% * _minimumLatitude_
% * _maximumLatitude_
% * _minimumMagnitude_
% * _maximumMagnitude_
% * _minimumDepth_
% * _maximumDepth_
% 
% And the two convenience parameters:
%%
%
% * _radialcoordinates_ = [ _centerLatitude_, _centerLongitude_, _maximumRadius_ ]
%
% * _boxcoordinates_ = [ _minimumLatitude_ _maximumLatitude_ _minimumLongitude_ _maximumLongitude_ ]
% 

%% Reading events from IRIS DMC
% To load events into a Catalog object we use the readEvents function. 
% The first argument is the data source/format - when this is given as 
% 'iris', readEvents uses the irisFetch.m program to retrieve event data 
% via the IRIS webservices. To narrow down our data search we can give 
% readEvents any name-value parameter pairs supported by irisFetch.
%
% In this example we will use readEvents to retrieve all events at IRIS DMC 
% with a magnitude of at least 7.9 between year 2000 and 2014 (inclusive):

catalogObject = readEvents('iris', 'minimumMagnitude', 7.9, 'starttime', '2000-01-01', 'endtime', '2015-01-01')

%%
% We have retrieved 26 events. To access any particular property we can use
% dot notation, as if the object were a structure, e.g.:

catalogObject.depth
catalogObject.mag

%%
% catalogObject is of type "Catalog". etype contains the event type for 
% each of the 26 events. In this case each is just  'earthquake', but when 
% dealing with more diverse dataset, many other etype's are possible. 
% magtype is whatever magnitude type was assigned by the agency that 
% provided the magnitude data.
%

%%
% Using the methods() function will tell us what operations we can perform
% on a Catalog object:

methods(catalogObject)

%%
% Now we'll do another example - we will get events within 200 km of the 
% great M9.0 Tohoku earthquake that occurred on 2011/03/11. 
% The mainshock parameters are: 
% 
%     Date/Time:  "2011/03/11 05:46:24"
%     Longitude:  142.372
%     Latitude:   38.297
%     Depth:      30 km
 
%%
% We will limit our search to 1 day before and after the earthquake:
 
mainshocktime = datenum('2011/03/11 05:46:24')
catalogObject = readEvents('iris', ...
            'radialcoordinates', [38.297 142.372 km2deg(200)], ...
            'starttime', mainshocktime - 1, ...
            'endtime', mainshocktime + 1);

%%
% This returns 1136 earthquakes. Let's get a summary:

catalogObject.summary()


%% Readings events from an Antelope database
% To load event data from an Antelope/Datascope CSS3.0 database you will 
% need to have Antelope (<http://www.brtt.com/software.html>) installed, 
% including the Antelope toolbox for MATLAB.
% 
%%
% *SCAFFOLD: NOTE THAT CURRENTLY NOT USING THE RTDB200903 AT ALL* 
% 
% For the purpose of this exercise we will be using data from Redoubt 
% volcano from 2009/03/20 to 2009/03/23. We will use snippets from two 
% catalogs that are provided with GISMO in Antelope format:
 
%%
%
% * The real-time catalog (rtdb200903).
% * The analyst-reviewed offical AVO catalog (avodb200903).

%%
% Both catalog segments are included in the "demo" directory. 
% We will now load the official AVO catalog into an Events object:
  
dbpath = demodb('avo');
catalogObject = readEvents('antelope', 'dbpath', dbpath);
 
%%
% This should load 1441 events. What if we only want events within 20km of 
% Redoubt volcano? There are two ways to do this. The first is the use the
% radialcoordinates parameter:

redoubtLon = -152.7431; 
redoubtLat = 60.4853;
maxR = 20.0;
catalogObject = readEvents('antelope', 'dbpath', dbpath, ...
	'radialcoordinates', [redoubtLat redoubtLon maxR]);
catalogObject.numberOfEvents

%%
% The second way is to use the 'subset_expression' which the Antelope
% expression evaluator interprets:
 
redoubtLon = -152.7431; 
redoubtLat = 60.4853;
expr = sprintf('deg2km(distance(lat, lon, %f, %f)) < %f',redoubtLat, redoubtLon,maxR)
catalogObject = readEvents('antelope', 'dbpath', dbpath, ...
	'subset_expression', expr);
catalogObject.numberOfEvents

%% Reading events from a Seisan database
% Here we load events from a Seisan catalog. A Seisan "Sfile" contains all
% the metadata for 1 event. These Sfiles are stored in a flat-file database
% structure the path to which is: $SEISAN_TOP/REA/databaseName. Sfiles are 
% organized in year/month subdirectories under this path.
%
% *SCAFFOLD: INCLUDE DEMO DATASET FROM MVOE*

%%
% The following will navigate this where in this case 
% $SEISAN_TOP = '/raid/data/seisan' and the databaseName is MVOE_ which 
% stands for the Montserrat Volcano Observatory Event database. 
% (In Seisan, databaseName is limited to exactly 5 characters).
%
% This example will load all Sfiles for January 1st, 2000. This is a slow 
% function to run as MATLAB is slow at parsing text files, and there are
% many events per day in this particular database.
 
catalogObject = readEvents('seisan', ...
    'dbpath', fullfile('/raid','data','seisan','REA','MVOE_'), ...
	'starttime', '2000/01/01', ....
	'endtime', '2000/01/02')

