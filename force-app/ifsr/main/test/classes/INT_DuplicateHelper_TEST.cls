/**
* @author meruff
* @date 11/20/19
*
* Unit Tests for INT_DuplicateHelper.cls
*/
@IsTest
private class INT_DuplicateHelper_TEST {
    @IsTest
    static void testFindDuplicateLeads() {
        // Arrange
        Lead existingLead = INT_TestDataFactory.createTestLead();
        insert existingLead;

        Lead assertLead = INT_TestDataFactory.createTestLead();

        // Act
        Test.startTest();
        INT_DuplicateHelper.findDuplicateRecords(new List<Lead>{assertLead});
        Test.stopTest();

        // Assert
        System.assertEquals(existingLead.Id, assertLead.Id,
            'The duplicate helper should have found the existing Lead Id and populated the test Lead with it.');
    }

    @IsTest
    static void testFindDuplicateContacts() {
        // Arrange
        Contact existingContact = INT_TestDataFactory.createBulkTestContacts(1)[0];
        insert existingContact;

        Contact assertContact = INT_TestDataFactory.createBulkTestContacts(1)[0];

        // Act
        Test.startTest();
        INT_DuplicateHelper.findDuplicateRecords(new List<Contact>{assertContact});
        Test.stopTest();

        // Assert
        System.assertEquals(existingContact.Id, assertContact.Id,
            'The duplicate helper should have found the existing Contact Id and populated the test Contact with it.');
    }
}