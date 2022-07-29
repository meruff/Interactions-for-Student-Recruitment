/**
* @author meruff
* @date 11/19/19
*
* Unit Tests for INT_ContactHandler.cls
*/
@IsTest
private class INT_ContactHandler_TEST {
    @TestSetup
    static void setUpTest() {
        insert INT_TestDataFactory.createTestMappings();
    }

    @IsTest
    static void testCreateContactFromInteraction() {
        // Arrange
        Interaction__c testInteraction = INT_TestDataFactory.createTestInteraction();
        testInteraction.Mailing_City__c = 'Tempe';

        // Act 
        Test.startTest();
        Contact assertContact = INT_ContactHandler.createContactFromInteraction(testInteraction);
        Test.stopTest();

        // Assert
        System.assertEquals(testInteraction.First_Name__c, assertContact.FirstName,
            'Interaction First_Name__c should have been mapped to the new Contact record.');
        System.assertEquals(testInteraction.Mailing_City__c, assertContact.MailingCity,
            'Interaction Mailing_City__c should have been mapped to the new Contact record.');
    }

    @IsTest
    private static void testFindMatchedContactId() {
        // Arrange
        insert INT_TestDataFactory.createBulkTestContacts(1)[0];

        Contact assertContact = INT_TestDataFactory.createBulkTestContacts(1)[0];

        // Act
        Test.startTest();
        for (Datacloud.FindDuplicatesResult findDupeResult :
            Datacloud.FindDuplicates.findDuplicates(new List<Contact>{assertContact})
        ) {
            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                    INT_ContactHandler.findMatchedContactId(assertContact, matchResult.getMatchRecords());
                }
            }
        }
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, assertContact.Id,
            'The assert Contact\'s Id should have been populated by the duplicate method.');
    }
}