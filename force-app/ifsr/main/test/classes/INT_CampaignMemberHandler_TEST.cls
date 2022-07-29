/**
* @author meruff
* @date 11/19/19
*
* Unit Tests for INT_CampaignMemberHandler.cls
*/
@IsTest
private class INT_CampaignMemberHandler_TEST {
    @TestSetup
    static void setUpTest() {
        insert INT_TestDataFactory.createTestMappings();
    }

    @IsTest
    static void testInteractionFieldsToQuery() {
        // Act
        Test.startTest();
        Set<String> interactionFieldsToQueryCampaignMember =
            INT_CampaignMemberHandler.interactionFieldsToQuery();
        Test.stopTest();

        // Assert
        System.assert(interactionFieldsToQueryCampaignMember.contains('Campaign_Key__c'),
            'Campaign_Key__c should be included in fields to query for CampaignMember.');
        System.assert(interactionFieldsToQueryCampaignMember.contains('Campaign_Member_Status__c'),
            'Campaign_Member_Status__c should be included in fields to query for CampaignMember. This is a mapping field.');
    }

    @IsTest
    private static void testProcessAsync() {
        // Arrange
        List<Campaign> testCampaigns = new List<Campaign>{
            INT_TestDataFactory.createTestCampaign('Test Campaign Name'),
            INT_TestDataFactory.createTestCampaign('Test Additional Campaign Name')
        };
        insert testCampaigns;

        Contact testContact = INT_TestDataFactory.createBulkTestContacts(1)[0];
        insert testContact;

        Interaction__c testInteraction = INT_TestDataFactory.createTestInteraction();
        testInteraction.Contact__c = testContact.Id;
        testInteraction.Campaign__c = testCampaigns[0].Id;
        testInteraction.Campaign_Member_Status__c = 'Added to Campaign';
        testInteraction.Additional_Campaign__c = testCampaigns[1].Id;
        testInteraction.Additional_Campaign_Member_Status__c = 'Added to Campaign';
        INT_InteractionProcessor.runProcessing = false;
        insert testInteraction;
        INT_InteractionProcessor.runProcessing = true;

        // Act
        Test.startTest();
        INT_CampaignMemberHandler.processInteractionsAsync(new Set<Id>{testInteraction.Id});
        Test.stopTest();

        // Assert
        List<CampaignMember> assertCampaignMembers = [
            SELECT ContactId
            FROM CampaignMember
            WHERE CampaignId IN :testCampaigns
        ];

        System.assertEquals(2, assertCampaignMembers.size(),
            '2 CampaignMember records should have been created. ');
        System.assertEquals(testContact.Id, assertCampaignMembers[0].ContactId,
            'The test CampaignMember that was created should be connected to the test Contact record.');
        System.assertEquals(testContact.Id, assertCampaignMembers[1].ContactId,
            'The test second CampaignMember that was created should be connected to the test Contact record.');
    }
}