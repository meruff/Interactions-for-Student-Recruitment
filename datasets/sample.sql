BEGIN TRANSACTION;
CREATE TABLE "Account" (
    sf_id VARCHAR(255) NOT NULL,
    "Name" VARCHAR(255), 
    "RecordTypeId" VARCHAR(255), 
    parent_id VARCHAR(255), 
    hed__current_address__c VARCHAR(255), 
    hed__primary_contact__c VARCHAR(255), 
    PRIMARY KEY (sf_id)
);
INSERT INTO "Account" VALUES('0018A00000QG7qQQAT','Liberty High School','0128A000000d352QAA','','','');
INSERT INTO "Account" VALUES('0018A00000QG7qRQAT','Connected Campus University','0128A000000d352QAA','','','');
INSERT INTO "Account" VALUES('0018A00000QG7qSQAT','North High School','0128A000000d352QAA','','','');
INSERT INTO "Account" VALUES('0018A00000QG7qTQAT','City College','0128A000000d352QAA','','','');
INSERT INTO "Account" VALUES('0018A00000QG7qUQAT','School of Business Administration','0128A000000d355QAA','','','');
INSERT INTO "Account" VALUES('0018A00000QG7qVQAT','College of Arts & Sciences','0128A000000d355QAA','','','');
CREATE TABLE "Account_rt_mapping" (
    record_type_id VARCHAR(18) NOT NULL, 
    developer_name VARCHAR(255), 
    PRIMARY KEY (record_type_id)
);
INSERT INTO "Account_rt_mapping" VALUES('0128A000000d34zQAA','Academic_Program');
INSERT INTO "Account_rt_mapping" VALUES('0128A000000d350QAA','Administrative');
INSERT INTO "Account_rt_mapping" VALUES('0128A000000d351QAA','Business_Organization');
INSERT INTO "Account_rt_mapping" VALUES('0128A000000d352QAA','Educational_Institution');
INSERT INTO "Account_rt_mapping" VALUES('0128A000000d353QAA','HH_Account');
INSERT INTO "Account_rt_mapping" VALUES('0128A000000d354QAA','Sports_Organization');
INSERT INTO "Account_rt_mapping" VALUES('0128A000000d355QAA','University_Department');
CREATE TABLE "Campaign" (
    sf_id VARCHAR(255) NOT NULL,
    "Name" VARCHAR(255),
    "Description" VARCHAR(255),
    "IsActive" VARCHAR(255),
    PRIMARY KEY (sf_id)
);
INSERT INTO "Campaign" VALUES('70155000000ya5NAAQ','Campus Visit','Visit SCI Campus','true');
CREATE TABLE "Interaction_Mapping__c" (
    sf_id VARCHAR(255) NOT NULL, 
    "Active__c" VARCHAR(255), 
    "Insert_Null__c" VARCHAR(255), 
    "Skip_Mapping__c" VARCHAR(255), 
    "Source_Field_API_Name__c" VARCHAR(255), 
    "Source_Object_API_Name__c" VARCHAR(255), 
    "Target_Field_API_Name__c" VARCHAR(255), 
    "Target_Object_API_Name__c" VARCHAR(255), 
    PRIMARY KEY (sf_id)
);
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBV0UAO','true','false','','Ethnicity__c','Interaction__c','Ethnicity__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBV1UAO','true','false','','Race__c','Interaction__c','Race__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBV2UAO','true','false','','Recruitment_Interest__c','Interaction__c','Recruitment_Interest__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBV3UAO','true','false','','Affiliated_Account__c','Interaction__c','Affiliated_Account__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBV4UAO','true','false','','Mobile_Phone__c','Interaction__c','MobilePhone','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBV5UAO','true','false','','Gender__c','Interaction__c','Gender__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBV6UAO','true','false','','Admit_Type__c','Interaction__c','Admit_Type__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBV7UAO','true','false','','Term__c','Interaction__c','Term__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBV8UAO','true','false','','Primary_Affiliation__c','Interaction__c','Primary_Affiliation__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBV9UAO','true','false','','Opportunity_Close_Date__c','Interaction__c','CloseDate','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBVAUA4','true','false','','Affiliated_Account__c','Interaction__c','Affiliated_Account__c','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBVBUA4','true','false','','Academic_Interest__c','Interaction__c','Academic_Interest__c','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBVCUA4','true','false','','Lead_Source__c','Interaction__c','LeadSource','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBVDUA4','true','false','','Contact__c','Interaction__c','Contact__c','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBVEUA4','true','false','','Term__c','Interaction__c','Term__c','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBVFUA4','true','false','','Opportunity_Stage__c','Interaction__c','StageName','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBVGUA4','true','false','','Admit_Type__c','Interaction__c','Admit_Type__c','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBVHUA4','true','false','','Opportunity_Name__c','Interaction__c','Name','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBVIUA4','true','false','','Recruitment_Interest__c','Interaction__c','Recruitment_Interest__c','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBVJUA4','true','false','','Application_Number__c','Interaction__c','Application_Number__c','Opportunity');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBULUA4','true','false','','Campaign_Member_Status__c','Interaction__c','Status','CampaignMember');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUMUA4','true','false','','Race__c','Interaction__c','hed__Race__c','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUNUA4','true','false','','Birthdate__c','Interaction__c','Birthdate','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUOUA4','true','false','','Contact_Title__c','Interaction__c','Title','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUPUA4','true','false','','Email__c','Interaction__c','Email','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUQUA4','true','false','','First_Name__c','Interaction__c','FirstName','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBURUA4','true','false','','Gender__c','Interaction__c','hed__Gender__c','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUSUA4','true','false','','Home_Phone__c','Interaction__c','HomePhone','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUTUA4','true','false','','Last_Name__c','Interaction__c','LastName','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUUUA4','true','false','','Lead_Source__c','Interaction__c','LeadSource','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUVUA4','true','false','','Mailing_City__c','Interaction__c','MailingCity','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUWUA4','true','false','','Mailing_Country__c','Interaction__c','MailingCountry','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUXUA4','true','false','','Mailing_Postal_Code__c','Interaction__c','MailingPostalCode','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUYUA4','true','false','','Mailing_State__c','Interaction__c','MailingState','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUZUA4','true','false','','Mailing_Street__c','Interaction__c','MailingStreet','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUaUAO','true','false','','Mobile_Phone__c','Interaction__c','MobilePhone','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUbUAO','true','false','','Salutation__c','Interaction__c','Salutation','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUcUAO','true','false','','University_Email__c','Interaction__c','hed__UniversityEmail__c','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUdUAO','true','false','','Constituent_ID__c','Interaction__c','Constituent_ID__c','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUeUAO','true','false','','Ethnicity__c','Interaction__c','hed__Ethnicity__c','Contact');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUfUAO','true','false','','Affiliation_Status__c','Interaction__c','hed__Status__c','hed__Affiliation__c');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUgUAO','true','false','','Affiliated_Account__c','Interaction__c','hed__Account__c','hed__Affiliation__c');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUhUAO','true','false','','Primary_Affiliation__c','Interaction__c','hed__Primary__c','hed__Affiliation__c');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUiUAO','true','false','','Contact__c','Interaction__c','hed__Contact__c','hed__Affiliation__c');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUjUAO','true','false','','Affiliation_Key__c','Interaction__c','Upsert_Key__c','hed__Affiliation__c');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUkUAO','true','false','','Affiliation_Role__c','Interaction__c','hed__Role__c','hed__Affiliation__c');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUlUAO','true','false','','Contact_Title__c','Interaction__c','Title','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUmUAO','true','false','','Email__c','Interaction__c','Email','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUnUAO','true','false','','First_Name__c','Interaction__c','FirstName','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUoUAO','true','false','','Home_Phone__c','Interaction__c','Phone','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUpUAO','true','false','','Last_Name__c','Interaction__c','LastName','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUqUAO','true','false','','Lead_Source__c','Interaction__c','LeadSource','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUrUAO','true','false','','Mailing_City__c','Interaction__c','City','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUsUAO','true','false','','Mailing_Country__c','Interaction__c','Country','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUtUAO','true','false','','Mailing_Postal_Code__c','Interaction__c','PostalCode','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUuUAO','true','false','','Mailing_State__c','Interaction__c','State','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUvUAO','true','false','','Mailing_Street__c','Interaction__c','Street','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUwUAO','true','false','','Salutation__c','Interaction__c','Salutation','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUxUAO','true','false','','Constituent_ID__c','Interaction__c','Constituent_ID__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUyUAO','true','false','','Affiliation_Role__c','Interaction__c','Affiliation_Role__c','Lead');
INSERT INTO "Interaction_Mapping__c" VALUES('a0T8A000002FBUzUAO','true','false','','Birthdate__c','Interaction__c','Birthdate__c','Lead');
CREATE TABLE "Interaction__c" (
    sf_id VARCHAR(255) NOT NULL, 
    "Additional_Campaign_Member_Status__c" VARCHAR(255), 
    "Additional_Campaign_Reference_ID__c" VARCHAR(255), 
    "Admit_Type__c" VARCHAR(255), 
    "Affiliation_Role__c" VARCHAR(255), 
    "Affiliation_Status__c" VARCHAR(255), 
    "Application_Number__c" VARCHAR(255), 
    "Audit_Reason__c" VARCHAR(255), 
    "Birthdate__c" VARCHAR(255), 
    "Campaign_Member_Status__c" VARCHAR(255), 
    "Campaign_Reference_ID__c" VARCHAR(255), 
    "Constituent_ID__c" VARCHAR(255), 
    "Contact_Title__c" VARCHAR(255), 
    "Email__c" VARCHAR(255), 
    "Ethnicity__c" VARCHAR(255), 
    "First_Name__c" VARCHAR(255), 
    "Gender__c" VARCHAR(255), 
    "Home_Phone__c" VARCHAR(255), 
    "Interaction_Source__c" VARCHAR(255), 
    "Interaction_Status__c" VARCHAR(255), 
    "Interaction_Upsert_Key__c" VARCHAR(255), 
    "Last_Name__c" VARCHAR(255), 
    "Lead_Only__c" VARCHAR(255), 
    "Lead_Source__c" VARCHAR(255), 
    "Mailing_City__c" VARCHAR(255), 
    "Mailing_Country__c" VARCHAR(255), 
    "Mailing_Postal_Code__c" VARCHAR(255), 
    "Mailing_State__c" VARCHAR(255), 
    "Mailing_Street__c" VARCHAR(255), 
    "Middle_Name__c" VARCHAR(255), 
    "Mobile_Phone__c" VARCHAR(255), 
    "Opportunity_Stage__c" VARCHAR(255), 
    "Primary_Affiliation__c" VARCHAR(255), 
    "Race__c" VARCHAR(255), 
    "Salutation__c" VARCHAR(255), 
    "University_Email__c" VARCHAR(255), 
    academic_interest__c VARCHAR(255), 
    additional_campaign__c VARCHAR(255), 
    affiliated_account__c VARCHAR(255), 
    campaign__c VARCHAR(255), 
    contact__c VARCHAR(255), 
    lead__c VARCHAR(255), 
    opportunity__c VARCHAR(255), 
    recruitment_interest__c VARCHAR(255), 
    term__c VARCHAR(255), 
    PRIMARY KEY (sf_id)
);
CREATE TABLE "Plan__c" (
    sf_id VARCHAR(255) NOT NULL, 
    "Name" VARCHAR(255), 
    "Active__c" VARCHAR(255), 
    "CIP_Code__c" VARCHAR(255), 
    "Career__c" VARCHAR(255), 
    "Degree__c" VARCHAR(255), 
    "Plan_Code__c" VARCHAR(255), 
    "Plan_Type__c" VARCHAR(255), 
    "RecordTypeId" VARCHAR(255), 
    "Type__c" VARCHAR(255), 
    department__c VARCHAR(255), 
    recruitment_interest__c VARCHAR(255), 
    PRIMARY KEY (sf_id)
);
INSERT INTO "Plan__c" VALUES('a0W8A000001hyXGUAY','BA - English','true','','Undergraduate','BA','','Major','','Recruitment','0018A00000QG7qVQAT','');
INSERT INTO "Plan__c" VALUES('a0W8A000001hyXHUAY','MBA - Business Administration','true','','Graduate','MBA','','Major','','Recruitment','0018A00000QG7qUQAT','');
INSERT INTO "Plan__c" VALUES('a0W8A000001hyXIUAY','MA - English','true','','Graduate','MA','','Major','','Recruitment','0018A00000QG7qVQAT','');
INSERT INTO "Plan__c" VALUES('a0W8A000001hyXFUAY','BA - Business','true','','Undergraduate','BA','','Major','','Recruitment','0018A00000QG7qUQAT','');
INSERT INTO "Plan__c" VALUES('a0W8A000001hyXKUAY','Business Administration MBA - Track 1','true','','Graduate','MBA','SBAMBA1','Major','','Academic','0018A00000QG7qUQAT','a0W8A000001hyXHUAY');
INSERT INTO "Plan__c" VALUES('a0W8A000001hyXLUAY','English BA','true','','Undergraduate','BA','CASEBA','Major','','Academic','0018A00000QG7qVQAT','a0W8A000001hyXGUAY');
INSERT INTO "Plan__c" VALUES('a0W8A000001hyXMUAY','Business Administration MBA - Track 2','true','','Graduate','MBA','SBAMBA2','Major','','Academic','0018A00000QG7qUQAT','a0W8A000001hyXHUAY');
INSERT INTO "Plan__c" VALUES('a0W8A000001hyXNUAY','English MA','true','','Graduate','MA','CASEMA','Major','','Academic','0018A00000QG7qVQAT','a0W8A000001hyXIUAY');
INSERT INTO "Plan__c" VALUES('a0W8A000001hyXOUAY','Business Administration BA','true','','Undergraduate','BA','SBABUSBA','Major','','Academic','0018A00000QG7qUQAT','a0W8A000001hyXFUAY');
CREATE TABLE "Plan__c_rt_mapping" (
    record_type_id VARCHAR(18) NOT NULL, 
    developer_name VARCHAR(255), 
    PRIMARY KEY (record_type_id)
);
INSERT INTO "Plan__c_rt_mapping" VALUES('0128A000000d35dQAA','Academic_Plan');
INSERT INTO "Plan__c_rt_mapping" VALUES('0128A000000d35eQAA','Recruitment_Plan');
CREATE TABLE "hed__Term__c" (
    sf_id VARCHAR(255) NOT NULL, 
    "Name" VARCHAR(255), 
    "hed__End_Date__c" VARCHAR(255), 
    "hed__Grading_Period_Sequence__c" VARCHAR(255), 
    "hed__Instructional_Days__c" VARCHAR(255), 
    "hed__Start_Date__c" VARCHAR(255), 
    "hed__Type__c" VARCHAR(255), 
    hed__account__c VARCHAR(255), 
    hed__parent_term__c VARCHAR(255), 
    PRIMARY KEY (sf_id)
);
INSERT INTO "hed__Term__c" VALUES('a0O8A000001gQUrUAM','Spring 2018','2018-04-30','','','2018-01-01','','0018A00000QG7qRQAT','');
INSERT INTO "hed__Term__c" VALUES('a0O8A000001gQUsUAM','Summer 2018','2018-08-31','','','2018-05-01','','0018A00000QG7qRQAT','');
INSERT INTO "hed__Term__c" VALUES('a0O8A000001gQUtUAM','Fall 2018','2018-12-31','','','2018-09-01','','0018A00000QG7qRQAT','');
INSERT INTO "hed__Term__c" VALUES('a0O8A000001gQUuUAM','Spring 2019','2019-04-30','','','2019-01-01','','0018A00000QG7qRQAT','');
INSERT INTO "hed__Term__c" VALUES('a0O8A000001gQUvUAM','Summer 2019','2019-08-31','','','2019-05-01','','0018A00000QG7qRQAT','');
INSERT INTO "hed__Term__c" VALUES('a0O8A000001gQUwUAM','Fall 2019','2019-12-31','','','2019-09-01','','0018A00000QG7qRQAT','');
COMMIT;