use dcoda_acme;
CREATE TABLE session ( 
	appl varchar(20), 
	sessionid varchar(25) 
	PRIMARY KEY,  userid char(15), 
	username char(10), 
	DATE_TS datetime, 
	UPDATE_TS datetime, 
	SESSIONDATA varchar(1000)
);

