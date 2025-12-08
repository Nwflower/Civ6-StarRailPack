-- KNM_Herta_Notification
-- Author: Konomi
-- DateCreated: 7/29/2024 16:46:43
--------------------------------------------------------------

INSERT INTO Types
		(Type,											Kind)
VALUES	('NOTIFICATION_KNM_HERTA_HOW_TO_PURCHASE',		'KIND_NOTIFICATION');

INSERT INTO Notifications
		(NotificationType,								SeverityType,	ExpiresEndOfTurn,	AutoNotify, AutoActivate,	Message,							Summary)
VALUES	('NOTIFICATION_KNM_HERTA_HOW_TO_PURCHASE',		'MID',			1,					0,			0,				'LOC_TRAIT_LEADER_KNM_ASTA_NAME',	'LOC_NOTIFICATION_KNM_HERTA_HOW_TO_PURCHASE_DESC');
