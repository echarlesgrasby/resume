/*
  This is a simple SAS program that I wrote to build out a map image that illustrates all of the US locations that I have traveled to as an adult.
  Eric C. Grasby
*/

data work.excursions;
	infile datalines dsd dlm=',';
	input city :$30. 
		  state :$2. 
		  type :$10.;
datalines;
Dallas,TX,Personal
Dallas,TX,Work
Los Angeles,CA,Work
Portland,OR,Personal
Las Vegas,NV,Work
New Haven,CT,Work
Boston,MA,Work
Boston,MA,Personal
Portland,ME,Personal
Manchester,NH,Personal
Burlington,VT,Personal
Philadelphia,PA,Work
Orlando,FL,Work
Raleigh,NC,Work
Flagstaff,AZ,Personal
Sedona,AZ,Personal
;
run;


/* Lookup on SASHELP.ZIPCODE to get geocoding data
*/
proc sql;
	create table work.excursions_geo as
	select e.*, g.x as lon, g.y as lat
	from work.excursions e
	left join sashelp.zipcode g
	on upcase(e.city)=upcase(g.city)
	and upcase(e.state)=upcase(g.statecode);
quit;

proc sort data=work.excursions_geo;
	by descending city descending state descending type;
run;

data work.excursion_final;
	set work.excursions_geo;
	by descending city descending state descending type;
	
	if first.type;
run;

data map_points;
	set work.excursion_final;
	
	if type='Work' then do;
		work_lon = lon;
		work_lat = lat;
	end;
	
	if type='Personal' then do;
		pers_lon = lon;
		pers_lat = lat;
	end;
run;

proc format;
    value $tripfmt
        'Personal'='Personal'
        'Work'='Work';
run;

/* Create Output File */
ods listing
	gpath="/home/&sysuserid"
	image_dpi=300;

ods graphics / reset
imagename="ecg_travel_map_20261104"
imagefmt=png
width=8in
height=5in;

proc sgmap plotdata=work.map_points;
    styleattrs datacontrastcolors=(cx0000FF cx32CD32);
    
    openstreetmap;
    
    /* Scatter plot for work trips */
    scatter x=work_lon y=work_lat /
        markerattrs=(symbol=diamondfilled
                     color=cx0000FF
                     size=12)
        name='Work'
        legendlabel='Work';

    /* Scatter plot for personal trips */
    scatter x=pers_lon y=pers_lat /
        markerattrs=(symbol=circlefilled
                     color=cx32CD32
                     size=7)
        name='Personal'
        legendlabel='Personal';

    keylegend 'Work' 'Personal';
run;
