/**
* @author Accenture
* @date 11/19/19
*
* Unit Tests for INT_LeadHandler.cls
*/
@IsTest
private class INT_LeadHandler_TEST {
    @TestSetup
    static void setUpTest() {
        insert INT_TestDataFactory.createTestMappings();
    }

    @IsTest
    static void testCreateLeadFromInteraction() {
        Interaction__c testInteraction = INT_TestDataFactory.createTestInteraction();
        testInteraction.Mailing_City__c = 'Tempe';

        // Act
        Test.startTest();
        Lead assertLead = INT_LeadHandler.createLeadFromInteraction(testInteraction);
        Test.stopTest();

        // Assert
        System.assertEquals(testInteraction.First_Name__c, assertLead.FirstName,
            'Interaction First_Name__c should have been mapped to the new Lead record.');
        System.assertEquals(testInteraction.Mailing_City__c, assertLead.City,
            'Interaction Mailing_City__c should have been mapped to the new Lead record.');
    }

    @IsTest
    private static void testFilterAndPopulateInteractionsWithExistingLeadData() {
        // Arrange
        Lead testLead = INT_TestDataFactory.createTestLead();
        testLead.MobilePhone = '5555555555';
        Interaction__c testInteraction = INT_TestDataFactory.createTestInteraction();
        INT_InteractionProcessor.InteractionWrapper testInteractionWrapper =
            new INT_InteractionProcessor.InteractionWrapper(testInteraction, testLead, new Contact());
        insert testLead;

        Map<Id, INT_InteractionProcessor.InteractionWrapper> interactionWrappersByLeadId =
            new Map<Id, INT_InteractionProcessor.InteractionWrapper>();

        List<INT_InteractionProcessor.InteractionWrapper> interactionWrappers =
            new List<INT_InteractionProcessor.InteractionWrapper>{testInteractionWrapper};

        // Act
        Test.startTest();
        INT_LeadHandler.filterAndPopulateInteractionsWithExistingLeadData(
            interactionWrappers, interactionWrappersByLeadId
        );
        Test.stopTest();

        // Assert
        System.assert(interactionWrappersByLeadId.containsKey(testLead.Id),
            'The InteractionWrapper map should have been populated with the related wrapper\'s Lead Id as a Key.');
        System.assertEquals('5555555555', testInteraction.Mobile_Phone__c,
            'The test Lead\'s MobilePhone field should have been copied to the test Interaction.');
    }

    @IsTest
    private static void testCreatLeadConverts() {
        // Arrange
        Lead testLead = INT_TestDataFactory.createTestLead();
        Interaction__c testInteraction = INT_TestDataFactory.createTestInteraction();
        INT_InteractionProcessor.InteractionWrapper testInteractionWrapper =
            new INT_InteractionProcessor.InteractionWrapper(testInteraction, testLead);
        insert testLead;

        // Act
        Test.startTest();
        List<Database.LeadConvert> assertLeadConverts =
            INT_LeadHandler.createLeadConverts(
                new List<INT_InteractionProcessor.InteractionWrapper>{testInteractionWrapper}
            );
        Test.stopTest();

        // Assert
        System.assertEquals(1, assertLeadConverts.size(),
            '1 Lead Convert should be created.');
        System.assertEquals(testLead.Id, assertLeadConverts[0].getLeadId(),
            'The test Lead Id should match that of the new Lead Convert record.');
    }

    @IsTest
    private static void testProcessConvertedLeads() {
        // Arrange
        Lead testLead = INT_TestDataFactory.createTestLead();
        Interaction__c testInteraction = INT_TestDataFactory.createTestInteraction();
        INT_InteractionProcessor.InteractionWrapper testInteractionWrapper =
            new INT_InteractionProcessor.InteractionWrapper(testInteraction, testLead, new Contact());
        insert testLead;

        Map<Id, INT_InteractionProcessor.InteractionWrapper> interactionWrappersByLeadId =
            new Map<Id, INT_InteractionProcessor.InteractionWrapper>{
                testLead.Id => testInteractionWrapper
            };

        // Act
        Test.startTest();
        List<Database.LeadConvert> testLeadConverts =
            INT_LeadHandler.createLeadConverts(
                new List<INT_InteractionProcessor.InteractionWrapper>{testInteractionWrapper}
            );

        INT_LeadHandler.processConvertedLeads(Database.convertLead(testLeadConverts), interactionWrappersByLeadId);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, interactionWrappersByLeadId.get(testLead.Id).contact.Id,
            'The test method should have populated the Contact__c lookup with the converted Contact Id.');
    }

    @IsTest
    private static void testProcessConvertedLeadsError() {
        // Arrange
        Contact existingContact = INT_TestDataFactory.createTestContact();
        insert existingContact;

        Lead testLead = INT_TestDataFactory.createTestLead();
        Interaction__c testInteraction = INT_TestDataFactory.createTestInteraction();
        INT_InteractionProcessor.InteractionWrapper testInteractionWrapper =
            new INT_InteractionProcessor.InteractionWrapper(testInteraction, testLead, new Contact());
        insert testLead;

        Map<Id, INT_InteractionProcessor.InteractionWrapper> interactionWrappersByLeadId =
            new Map<Id, INT_InteractionProcessor.InteractionWrapper>{
                testLead.Id => testInteractionWrapper
            };

        // Act
        Test.startTest();
        List<Database.LeadConvert> testLeadConverts =
            INT_LeadHandler.createLeadConverts(
                new List<INT_InteractionProcessor.InteractionWrapper>{testInteractionWrapper}
            );

        INT_LeadHandler.processConvertedLeads(Database.convertLead(testLeadConverts, false), interactionWrappersByLeadId);
        Test.stopTest();

        // Assert
        System.assertEquals(null, interactionWrappersByLeadId.get(testLead.Id).contact.Id,
            'The test method should have failed to populate the Contact Id on the Interaction as a Lead conversion ' +
            'error should have been found.');
        System.assertEquals(INT_Utilities.AUDIT_REQUIRED_STATUS, testInteraction.Interaction_Status__c,
            'Interaction should have been flipped to Audit Required status.');
        System.assert(testInteraction.Audit_Reason__c.contains('Error during Lead conversion'),
            'A Lead conversion error should have been written to the Interaction audit status.');
    }

    @IsTest
    private static void testFindMatchedLeadId() {
        // Arrange
        insert INT_TestDataFactory.createTestLead();

        Lead assertLead = INT_TestDataFactory.createTestLead();

        // Act
        Test.startTest();
        for (Datacloud.FindDuplicatesResult findDupeResult :
            Datacloud.FindDuplicates.findDuplicates(new List<Lead>{assertLead})
        ) {
            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                    INT_LeadHandler.findMatchedLeadId(assertLead, matchResult.getMatchRecords());
                }
            }
        }
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, assertLead.Id,
            'The assert Leads\'s Id should have been populated by the duplicate method.');
    }
}