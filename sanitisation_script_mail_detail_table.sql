--Script to sanitize the mail_details table
--
--Nullify windows and bb logins 
--Replace alias and domain from generic_banks
--Set internal mail types to SRLABS bank
SET xact_abort ON;
GO

BEGIN TRANSACTION UpdateMail;
GO

USE PRESALES_DEIDENTIFIED;
GO

UPDATE mail_detail_lz 
set domain=null, alias=null, bb_login=null, windows_login=null;
GO

ALTER TABLE generic_banks ADD ID INT NOT NULL IDENTITY(1,1);
GO

CREATE UNIQUE NONCLUSTERED INDEX ix ON generic_banks(ID);
GO

UPDATE m
SET m.alias = b.bank_alias,
    m.domain = b.bank_domain
from mail_detail_lz m
JOIN generic_banks b on b.ID = (m.ID % 10) +1;
GO

UPDATE mail_detail_lz
SET domain='SRLABS', alias='SRLMainUser'
WHERE mail_type = 'Internal';
GO

UPDATE mail_detail_lz
SET windows_login=null, bb_login=null;
GO

DROP INDEX ix on generic_banks;
GO
ALTER TABLE generic_banks
DROP COLUMN ID;
GO

---Tests - should not return any records
SELECT * FROM mail_detail_lz 
WHERE domain is null;
GO

SELECT * FROM mail_detail_lz 
WHERE alias is null;
GO

--counts should return 0
SELECT COUNT(*) FROM mail_detail_lz where bb_login is not null;
GO

SELECT COUNT(*) FROM mail_detail_lz where windows_login is not null;
GO

COMMIT TRANSACTION UpdateMail;
GO
