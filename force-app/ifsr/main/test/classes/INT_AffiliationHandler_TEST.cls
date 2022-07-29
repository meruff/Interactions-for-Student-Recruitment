/**
* @author meruff
* @date 11/20/19
*
* Apex unit tests for INT_AffiliationHandler.cls
*/
@IsTest
public class INT_AffiliationHandler_TEST {
    private static final String EDU_INST = 'Educational_Institution';

    private static Map<String, Schema.RecordTypeInfo> accountRecordTypeInfosByStrings =
        Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();

    @TestSetup
    static void setUpTest() {
        insert INT_TestDataFactory.createTestMappings();
    }

    @IsTest
    static void testInteractionFieldsToQuery() {
        // Act
        Test.startTest();
        Set<String> interactionFieldsToQueryOpportunity =
            INT_AffiliationHandler.interactionFieldsToQuery();
        Test.stopTest();

        // Assert
        System.assert(interactionFieldsToQueryOpportunity.contains('Affiliated_Account__c'),
            'Affiliated_Account__c should be included in fields to query for Affiliation.');
        System.assert(interactionFieldsToQueryOpportunity.contains('Affiliation_Role__c'),
            'Affiliation_Role__c should be included in fields to query for Affiliation. This is a mapping field.');
    }

    @IsTest
    private static void testProcessAsync() {
        // Arrange
        Account testUniversityAccount =
            INT_TestDataFactory.createTestAccount('Connected University', accountRecordTypeInfosByStrings.get(EDU_INST).getRecordTypeId());
        insert testUniversityAccount;

        Contact testContact = INT_TestDataFactory.createBulkTestContacts(1)[0];
        insert testContact;

        Interaction__c testInteraction = INT_TestDataFactory.createTestInteraction();
        testInteraction.Contact__c = testContact.Id;
        testInteraction.Affiliated_Account__c = testUniversityAccount.Id;
        testInteraction.Affiliation_Role__c = 'Student';
        INT_InteractionProcessor.runProcessing = false;
        insert testInteraction;
        INT_InteractionProcessor.runProcessing = true;

        // Act
        Test.startTest();
        INT_AffiliationHandler.processInteractionsAsync(new Set<Id>{testInteraction.Id});
        Test.stopTest();

        // Assert
        hed__Affiliation__c assertAffiliation = [
            SELECT hed__Role__c
            FROM hed__Affiliation__c
            WHERE hed__Contact__c = :testContact.Id
        ];

        System.assertEquals('Student', assertAffiliation.hed__Role__c,
            'Student Role should have been mapped to the new Affiliation created for the Contact.');
    }
}