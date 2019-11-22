/**
* @author Sierra-Cedar
* @date 11/10/19
*
* Unit Tests for INT_InteractionProcessor.cls
*/
@IsTest
private class INT_InteractionProcessor_TEST {
    private static final String ACAD_PLAN = 'Academic_Plan';
    private static final String EDU_INST = 'Educational_Institution';
    private static final String UNIV_DEPARTMENT = 'University_Department';

    private static Map<String, Schema.RecordTypeInfo> accountRecordTypeInfosByStrings =
        Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
    private static Map<String, Schema.RecordTypeInfo> planRecordTypeInfosByStrings =
        Plan__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
    private static List<Id> schoolAccountIds = new List<Id>{
        accountRecordTypeInfosByStrings.get(UNIV_DEPARTMENT).getRecordTypeId(),
        accountRecordTypeInfosByStrings.get(EDU_INST).getRecordTypeId()
    };

    @TestSetup
    static void setUpTest() {
        insert INT_TestDataFactory.createTestMappings();

        List<Account> testAccounts = new List<Account>{
            INT_TestDataFactory.createTestAccount('College of Arts & Sciences', accountRecordTypeInfosByStrings.get(UNIV_DEPARTMENT).getRecordTypeId()),
            INT_TestDataFactory.createTestAccount('Connected University', accountRecordTypeInfosByStrings.get(EDU_INST).getRecordTypeId())
        };
        insert testAccounts;

        Plan__c acadPlan = new Plan__c(
            Name = 'Business Administration BA',
            Type__c = 'Academic',
            Department__c = testAccounts[0].Id,
            Career__c = 'Undergraduate',
            Active__c = true,
            RecordTypeId = planRecordTypeInfosByStrings.get(ACAD_PLAN).getRecordTypeId()
        );
        insert acadPlan;

        hed__Term__c testFallTerm = new hed__Term__c(
            Name = 'Fall ' + (System.today().year() + 1),
            hed__Start_Date__c = Date.newInstance((System.today().year() + 1), 8, 15),
            hed__End_Date__c = Date.newInstance((System.today().year() + 1), 12, 16),
            hed__Account__c = testAccounts[1].Id
        );
        insert testFallTerm;
    }

    /**
     * Tests duplicate pre-processing in Interactions by trying to insert duplicate students in the same contest.
     */
    @IsTest
    static void testDupeProcessing() {
        // Arrange
        List<Interaction__c> interactionsToInsert = new List<Interaction__c>();

        // Create 200 duplicate Interactions which should be de-duped once processed
        for (Integer i = 0; i < 200; i++) {
            Interaction__c testInt = new Interaction__c(
                First_Name__c = 'Test',
                Last_Name__c = 'Man',
                Email__c = 'test@nomail.com',
                Lead_Only__c = true
            );
            interactionsToInsert.add(testInt);
        }

        // Act
        Test.startTest();
        insert interactionsToInsert;
        Test.stopTest();

        // Assert
        System.assertEquals(1, [SELECT Id FROM Lead].size(),
            '1 Lead Expected - Only the first Interaction should have had a Lead created, the rest' +
                'should be set to Audit Required.');

        System.assertEquals(0, [SELECT Id FROM Contact].size(),
            '0 Contacts Expected - This test processes Leads only and does not process Interactions. ' +
                'Duplicate pre-processing should have prevented the processing of duplicate records.');

        System.assertEquals(0, [SELECT Id FROM Account WHERE RecordTypeId NOT IN :schoolAccountIds].size(),
            '0 Accounts Expected - This test processes Leads only and does not process Interactions. ' +
                'Duplicate pre-processing should have prevented the processing of duplicate records.'
        );

        Integer importedFound = 0;
        Integer auditFound = 0;
        for (Interaction__c interaction : [SELECT Interaction_Status__c, Audit_Reason__c FROM Interaction__c]) {
            if (interaction.Interaction_Status__c == INT_Utilities.IMPORTED_STATUS) importedFound++;
            if (interaction.Interaction_Status__c == INT_Utilities.AUDIT_REQUIRED_STATUS) auditFound++;
        }

        System.assertEquals(1, importedFound,
            '1 Imported Interaction expected - ' +
                'Duplicate pre-processing should have prevented the processing of duplicate records.');
        System.assertEquals(199, auditFound,
            '199 Audit Required Interactions expected - ' +
                'Duplicate pre-processing should have prevented the processing of duplicate records.');
    }

    /**
     * Tests skipping mapping of specified fields in Interactions.
     */
    @IsTest
    static void testSkipMappingSources() {
        // Arrange
        Interaction__c testInteraction = INT_TestDataFactory.createTestInteraction();
        testInteraction.Gender__c = 'Male';

        // Act
        Test.startTest();
        insert testInteraction;
        Test.stopTest();

        // Assert
        System.assertEquals(0, [SELECT Id FROM Lead].size(),
            'Lead count expected to be at 0. Once converted, the Leads should be deleted');
        System.assertEquals(1, [SELECT Id FROM Account WHERE RecordTypeId NOT IN :schoolAccountIds].size(),
            '1 Account Expected');

        List<Contact> contactList = new List<Contact>([SELECT hed__Gender__c FROM Contact]);
        System.assert(contactList.size() == 1, '1 Contact Expected');
        System.assert(String.isEmpty(contactList[0].hed__Gender__c),
            'Gender should not have been copied over for this skipped Interaction source.');
    }

    /**
     * Tests creating multiple CampaignMember records from a single Interaction.
     */
    @IsTest
    static void testCampaignMemberCreation() {
        // Arrange
        List<Campaign> testCampaigns = new List<Campaign>{
            INT_TestDataFactory.createTestCampaign('Test Campaign'),
            INT_TestDataFactory.createTestCampaign('Test Additional Campaign')
        };
        insert testCampaigns;

        Interaction__c testInteraction = INT_TestDataFactory.createTestInteraction();
        testInteraction.Campaign__c = testCampaigns[0].Id;
        testInteraction.Campaign_Member_Status__c = 'Sent';
        testInteraction.Additional_Campaign__c = testCampaigns[1].Id;
        testInteraction.Additional_Campaign_Member_Status__c = 'Sent';

        // Act
        Test.startTest();
        insert testInteraction;
        Test.stopTest();

        // Assert
        System.assertEquals(0, [SELECT Id FROM Lead].size(),
            'Lead count expected to be at 0. Once converted, the Leads should be deleted');
        System.assertEquals(1, [SELECT Id FROM Account WHERE RecordTypeId NOT IN :schoolAccountIds].size(),
            '1 Account Expected');

        List<Contact> assertContacts = [SELECT FirstName, LastName, hed__Gender__c, Account.Name FROM Contact];
        System.assertEquals(1, assertContacts.size(), '1 Contact expected');

        // Build out CM map for assertion.
        Map<Id, CampaignMember> campaignMemberMap = new Map<Id, CampaignMember>();
        for (CampaignMember cm : [SELECT Name, CampaignId, Status, ContactId FROM CampaignMember]) {
            campaignMemberMap.put(cm.CampaignId, cm);
        }
        System.assertEquals(2, campaignMemberMap.size(), '2 CampaignMembers expected, one for each Campaign.');

        // First Campaign
        System.assert(campaignMemberMap.containsKey(testCampaigns[0].Id),
            'CampaignMember should exist for this Campaign.');
        System.assertEquals(testCampaigns[0].Id, campaignMemberMap.get(testCampaigns[0].Id).CampaignId,
            'CampaignMember should have been created for test Campaign.');
        System.assertEquals(assertContacts[0].Id, campaignMemberMap.get(testCampaigns[0].Id).ContactId,
            'Contact Id should match Contact created.');

        // Additional Campaign
        System.assert(campaignMemberMap.containsKey(testCampaigns[1].Id),
            'CampaignMember should exist for this Campaign.');
        System.assertEquals(testCampaigns[1].Id, campaignMemberMap.get(testCampaigns[1].Id).CampaignId,
            'CampaignMember should have been created for test Campaign.');
        System.assertEquals(assertContacts[0].Id, campaignMemberMap.get(testCampaigns[1].Id).ContactId,
            'Contact Id should match Contact created.');
    }

    /**
     * Tests converting an existing Lead through Interactions that is a member of a Campaign.
     */
    @IsTest
    static void testCMCreationWithExistingLeadAndCM() {
        // Arrange
        List<Campaign> testCampaigns = new List<Campaign>{
            INT_TestDataFactory.createTestCampaign('Test Campaign'),
            INT_TestDataFactory.createTestCampaign('Test Campaign 2')
        };
        insert testCampaigns;

        Lead testLead = INT_TestDataFactory.createTestLead();
        insert testLead;

        CampaignMember testCM = new CampaignMember(
            LeadId = testLead.Id,
            CampaignId = testCampaigns[0].Id,
            Status = 'Added to Campaign'
        );
        insert testCM;

        Interaction__c testInteraction = INT_TestDataFactory.createTestInteraction();
        testInteraction.Campaign__c = testCampaigns[0].Id;
        testInteraction.Campaign_Member_Status__c = 'Added to Campaign';

        // Act
        Test.startTest();
        insert testInteraction;
        Test.stopTest();

        // Assert
        Interaction__c assertInteraction = [
            SELECT Interaction_Status__c,
                Contact__c
            FROM Interaction__c
            WHERE Id = :testInteraction.Id
        ];

        System.assertEquals(INT_Utilities.IMPORTED_STATUS, assertInteraction.Interaction_Status__c, 'Interaction should have successfully imported.');
        System.assertEquals(0, [SELECT Id FROM Lead].size(), 'The existing Lead should have been found and converted.');

        List<CampaignMember> assertCampaignMembers = [SELECT ContactId, LeadId FROM CampaignMember];
        System.assertEquals(1, assertCampaignMembers.size(),
            '1 Campaign Member should exist. It should have been upserted from Interactions.');
        System.assertEquals(null, assertCampaignMembers[0].LeadId,
            'The Lead on the Campaign Member should have been converted, so the LeadId should be null.');
        System.assertEquals(assertInteraction.Contact__c, assertCampaignMembers[0].ContactId,
            'The Lead should have been converted and the ContactId on it should match that of the test Interaction.');
    }

    /**
     * Tests inserting Interactions in Lead Only Mode with CampaignMember creation.
     */
    @IsTest
    static void testCMCreationLeadOnly() {
        // Arrange
        Campaign testCampaign = INT_TestDataFactory.createTestCampaign('Test Campaign');
        insert testCampaign;

        List<Interaction__c> testInteractions = INT_TestDataFactory.createBulkTestInteractions(50);
        for (Interaction__c interaction : testInteractions) {
            interaction.Lead_Only__c = true;
            interaction.Campaign__c = testCampaign.Id;
            interaction.Campaign_Member_Status__c = 'Added to Campaign';
        }

        // Act
        Test.startTest();
        insert testInteractions;
        Test.stopTest();

        // Assert
        Map<Id, CampaignMember> campaignMembersByContactIds = new Map<Id, CampaignMember>();
        for (CampaignMember cm : [
            SELECT LeadId,
                Status
            FROM CampaignMember
        ]) {
            if (!String.isBlank(cm.LeadId)) {
                campaignMembersByContactIds.put(cm.LeadId, cm);
            }
        }

        System.assertEquals(50, [SELECT Id FROM Lead].size(),
            '50 Lead records should have been created from the test Interactions.');
        System.assertEquals(50, campaignMembersByContactIds.size(),
            '50 CampaignMembers should have been created.');

        for (Interaction__c assertInteraction : [
            SELECT Interaction_Status__c,
                Lead__c,
                Campaign__c
            FROM Interaction__c
            WHERE Id = :testInteractions
        ]) {
            System.assertEquals(INT_Utilities.IMPORTED_STATUS, assertInteraction.Interaction_Status__c,
                'Interaction should have successfully imported.');
            System.assertEquals(testCampaign.Id, assertInteraction.Campaign__c,
                'The Campaign Id should have been stored on the Interaction created.');
            System.assert(campaignMembersByContactIds.containsKey(assertInteraction.Lead__c),
                'This Interaction should have a Lead Id attached to it that also exists as a CampaignMember.');
        }
    }

    /**
     * Tests bulk processing Interactions with an existing Lead record.
     */
    @IsTest
    static void testBulkInteractionInsertExistingLead() {
        // Arrange
        List<Lead> testLeads = INT_TestDataFactory.createBulkTestLeads(10);
        testLeads.add(INT_TestDataFactory.createTestLead());
        insert testLeads;

        List<Interaction__c> interactionsToInsert = INT_TestDataFactory.createBulkTestInteractions(200);

        interactionsToInsert.addAll(
            new List<Interaction__c>{
                new Interaction__c(
                    First_Name__c = 'Test',
                    Last_Name__c = 'Man',
                    Email__c = 'test@nomail.com',
                    Mobile_Phone__c = '1111111112'
                ),
                new Interaction__c(
                    First_Name__c = 'Super',
                    Last_Name__c = 'Gary',
                    Email__c = 'super.gary@nomail.com',
                    Contact_Title__c = 'Mr.',
                    Constituent_ID__c = '123456',
                    Gender__c = 'Male',
                    Race__c = 'White',
                    Birthdate__c = Date.newInstance(1998, 1, 1),
                    Admit_Type__c = 'New Freshman',
                    Academic_Interest__c = [
                        SELECT Id
                        FROM Plan__c
                        LIMIT 1
                    ].Id,
                    Term__c = [
                        SELECT Id
                        FROM hed__Term__c
                        LIMIT 1
                    ].Id,
                    Lead_Source__c = 'Office Visit',
                    Affiliated_Account__c = [
                        SELECT Id
                        FROM Account
                        WHERE RecordTypeId = :accountRecordTypeInfosByStrings.get(EDU_INST).getRecordTypeId()
                    ].Id,
                    Affiliation_Role__c = 'Student',
                    Primary_Affiliation__c = true
                )
            }
        );

        // Act
        Test.startTest();
        insert interactionsToInsert;
        Test.stopTest();

        // Assert
        System.assertEquals(0, [SELECT Id FROM Lead].size(),
            'Lead count expected to be at 0. Once converted, the Leads should be deleted');
        System.assertEquals(202, [SELECT Id FROM Account WHERE RecordTypeId NOT IN :schoolAccountIds].size(),
            '202 Accounts Expected - 1 for each of the 202 Interactions');

        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT FirstName FROM Contact]);
        System.assertEquals(202, contactMap.size(),
            '202 Contacts Expected - 1 for each of the 202 Interactions');

        for (Interaction__c interaction : [
            SELECT First_Name__c,
                Email__c,
                Contact__c,
                Opportunity__c
            FROM Interaction__c
        ]) {
            System.assertNotEquals(null, interaction.Contact__c,
                'The Contact__c field should have been populated on each Interaction.');
            System.assertEquals(interaction.Contact__c, contactMap.get(interaction.Contact__c).Id,
                'Interaction Contact Id does not match Contact in system');
            System.assertEquals(interaction.First_Name__c, contactMap.get(interaction.Contact__c).FirstName,
                'Interaction First Name should match Contact First Name.');

            if (interaction.Email__c == 'super.gary@nomail.com') {
                System.assertNotEquals(null, interaction.Opportunity__c,
                    'Opportunity for Super Gary should have ben created based on Term and Plan info.');
            }
        }
    }

    /**
     * Tests bulk inserting Interactions in Lead Only mode.
     */
    @IsTest
    static void testBulkInteractionInsertLeadOnly() {
        // Arrange
        Lead testDupeLead = new Lead(
            FirstName = 'Test',
            LastName = 'Man',
            Email = 'test@nomail.com',
            Company = 'Man, Test'
        );
        insert testDupeLead;

        List<Interaction__c> interactionsToInsert = INT_TestDataFactory.createBulkTestInteractions(200);
        for (Interaction__c interaction : interactionsToInsert) interaction.Lead_Only__c = true;

        Interaction__c testInt = new Interaction__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Man',
            Email__c = 'test@nomail.com',
            Mobile_Phone__c = '1111111112',
            Lead_Only__c = true
        );
        interactionsToInsert.add(testInt);

        Interaction__c testInt2 = new Interaction__c(
            First_Name__c = 'Super',
            Last_Name__c = 'Gary',
            Email__c = 'super.gary@nomail.com',
            Lead_Only__c = true
        );
        interactionsToInsert.add(testInt2);

        // Act
        Test.startTest();
        insert interactionsToInsert;
        Test.stopTest();

        // Assert
        System.assertEquals(
            0, [SELECT Id FROM Contact].size(),
            '0 Contacts Expected'
        );

        Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT FirstName FROM Lead]);
        System.assertEquals(202, leadMap.size(), '202 Leads Expected - 1 for each of the 202 Interactions.');

        Map<Id, Account> accountMap = new Map<Id, Account>([
            SELECT Name
            FROM Account
            WHERE RecordTypeId NOT IN :schoolAccountIds
        ]);
        System.assertEquals(0, accountMap.size(), '0 Accounts Expected');

        for (Interaction__c interaction : [
            SELECT First_Name__c,
                Lead__c
            FROM Interaction__c
            ORDER BY Interaction_Status__c
        ]) {
            System.assertNotEquals(null, interaction.Lead__c,
                'The Lead__c field should have been populated on each Interaction.');
            System.assertEquals(interaction.Lead__c, leadMap.get(interaction.Lead__c).Id,
                'Interaction Lead Id does not match Lead in system');
            System.assertEquals(interaction.First_Name__c, leadMap.get(interaction.Lead__c).FirstName,
                'Interaction First Name should match Lead First Name.');
        }
    }

    /**
     * Tests bulk inserting Interactions with bulk existing Contacts.
     */
    @IsTest
    static void testBulkInteractionInsertAllDupeContacts() {
        // Arrange
        insert INT_TestDataFactory.createBulkTestContacts(50);

        // Act
        Test.startTest();
        insert INT_TestDataFactory.createBulkTestInteractions(200);
        Test.stopTest();

        // Assert
        System.assertEquals(0, [SELECT Id FROM Lead].size(),
            'Lead count expected to be at 0. Once converted, the Leads should be deleted');
        System.assertEquals(200, [SELECT Id FROM Account WHERE RecordTypeId NOT IN :schoolAccountIds].size(),
            '200 Accounts Expected - 1 for each of the 200 Interactions');

        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT FirstName FROM Contact]);
        System.assertEquals(200, contactMap.size(),
            '200 Contacts Expected - 1 for each of the 200 Interactions');

        for (Interaction__c interaction : [
            SELECT First_Name__c,
                Contact__c
            FROM Interaction__c
        ]) {
            System.assertNotEquals(null, interaction.Contact__c,
                'The Contact__c field should have been populated on each Interaction.');
            System.assertEquals(interaction.Contact__c, contactMap.get(interaction.Contact__c).Id,
                'Interaction Contact Id does not match Contact in system');
            System.assertEquals(interaction.First_Name__c, contactMap.get(interaction.Contact__c).FirstName,
                'Interaction First Name should match Contact First Name.');
        }
    }


    @IsTest
    private static void testMappingExistingLeadDataToInteraction() {
        // Arrange
        Lead testLead = INT_TestDataFactory.createTestLead();
        testLead.MobilePhone = '4444444444';
        insert testLead;

        Interaction__c testInteraction = INT_TestDataFactory.createTestInteraction();

        // Act
        Test.startTest();
        insert testInteraction;
        Test.stopTest();

        // Assert
        Interaction__c assertInteraction = [
            SELECT First_Name__c,
                Last_Name__c,
                Mobile_Phone__c,
                Interaction_Status__c
            FROM Interaction__c
            WHERE Id = :testInteraction.Id
        ];
        System.assertEquals(INT_Utilities.IMPORTED_STATUS, assertInteraction.Interaction_Status__c,
            'The Interaction should have been imported without any errors.');
        System.assertEquals('4444444444', assertInteraction.Mobile_Phone__c,
            'The value of MobilePhone on Lead should have been copied to the Interaction based on mapping records.');
    }

    /**
     * Tests duplicate Contact record match-handling.
     */
    @IsTest
    private static void testMultipleDuplicateExistingContacts() {
        // Arrange
        Contact testContactExisting = INT_TestDataFactory.createTestContact();
        insert testContactExisting;

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.duplicateRuleHeader.allowSave = true;

        Contact testContactDuplicate = INT_TestDataFactory.createTestContact();
        Database.insert(testContactDuplicate, dml);

        Interaction__c testInteraction = INT_TestDataFactory.createTestInteraction();

        // Act
        Test.startTest();
        insert testInteraction;
        Test.stopTest();

        // Assert
        Interaction__c assertInteraction = [SELECT Contact__c FROM Interaction__c WHERE Id = :testInteraction.Id];
        System.assertEquals(testContactExisting.Id, assertInteraction.Contact__c,
            'Interactions should have found the oldest Contact to use, the testContactExisting record.');
    }
}