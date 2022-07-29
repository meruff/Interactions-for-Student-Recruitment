/**
* @author meruff
* @date 11/19/19
*
* Unit Tests for INT_OpportunityHandler.cls
*/
@IsTest
private class INT_OpportunityHandler_TEST {
    private static final String EDU_INST = 'Educational_Institution';
    private static final String UNIV_DEPARTMENT = 'University_Department';

    private static Map<String, Schema.RecordTypeInfo> accountRecordTypeInfosByStrings =
        Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();

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
            Active__c = true
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

    @IsTest
    static void testInteractionFieldsToQuery() {
        // Act
        Test.startTest();
        Set<String> interactionFieldsToQueryOpportunity =
            INT_OpportunityHandler.interactionFieldsToQuery();
        Test.stopTest();

        // Assert
        System.assert(interactionFieldsToQueryOpportunity.contains('Opportunity_Key__c'),
            'Opportunity_Key__c should be included in fields to query for Opportunity.');
        System.assert(interactionFieldsToQueryOpportunity.contains('Admit_Type__c'),
            'Admit_Type__c should be included in fields to query for Opportunity. This is a mapping field.');
    }

    @IsTest
    private static void testProcessAsync() {
        // Arrange
        Contact testContact = INT_TestDataFactory.createBulkTestContacts(1)[0];
        insert testContact;

        Interaction__c testInteraction = INT_TestDataFactory.createTestInteraction();
        testInteraction.Admit_Type__c = 'New Freshman';
        testInteraction.Academic_Interest__c = [SELECT Id FROM Plan__c LIMIT 1].Id;
        testInteraction.Term__c = [SELECT Id FROM hed__Term__c LIMIT 1].Id;
        testInteraction.Contact__c = testContact.Id;
        INT_InteractionProcessor.runProcessing = false;
        insert testInteraction;
        INT_InteractionProcessor.runProcessing = true;

        // Act
        Test.startTest();
        INT_OpportunityHandler.processInteractionsAsync(new Set<Id>{testInteraction.Id});
        Test.stopTest();

        // Assert
        Interaction__c assertInteraction = [
            SELECT Contact__c,
                Opportunity__c,
                Admit_Type__c,
                Opportunity__r.Admit_Type__c
            FROM Interaction__c
            WHERE Id = :testInteraction.Id
        ];
        System.assertNotEquals(null, assertInteraction.Opportunity__c,
            'The Opportunity should have been processed and attached to the test Interaction record.');
        System.assertEquals(testContact.Id, assertInteraction.Contact__c,
            'The Contact should have been associated with the newly created Opportunity record.');
        System.assertEquals('New Freshman', assertInteraction.Opportunity__r.Admit_Type__c,
            'The value of Admit Type should have been mapped from the Interactin to the newly created Opportunity record.');
    }
}