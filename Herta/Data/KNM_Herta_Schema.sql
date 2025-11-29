-- KNM_Herta_Schema
-- Author: Konomi
-- DateCreated: 12/17/2022 6:11:47
--------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Mod_EndGameInfo (
	'LeaderType' TEXT NOT NULL,	
	'EndGameImage' TEXT,
    PRIMARY KEY(LeaderType),
	FOREIGN KEY (LeaderType) REFERENCES Types(Type) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO Mod_EndGameInfo 
		(LeaderType,					EndGameImage)
VALUES 	('LEADER_KNM_HERTA',			'ENDGAME_KNM_HERTA'),
	 	('LEADER_KNM_ASTA',				'ENDGAME_KNM_ASTA');
