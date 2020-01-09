/**
* @author Sierra-Cedar
* @date 11/20/19
*
* Unit Tests for INT_Utilities.cls
*/
@IsTest
private class INT_Utilities_TEST {
    @TestSetup
    static void setUpTest() {
        insert INT_TestDataFactory.createTestMappings();
    }

    @IsTest
    static void testUpdateInteractionsIfAsync() {
        // Arrange
        List<Interaction__c> testInteractions = INT_TestDataFactory.createBulkTestInteractions(5);
        INT_InteractionProcessor.runProcessing = false;
        insert testInteractions;
        INT_InteractionProcessor.runProcessing = true;

        // Act 
        Test.startTest();
        INT_InteractionProcessor.runAsync = true;
        INT_Utilities.updateInteractionsIfAsync(testInteractions);
        Test.stopTest();

        // Assert
        for (Interaction__c interaction : testInteractions) {
            System.assertEquals(null, interaction.Contact__c,
                'Because we\'re emulating Async mode, the Interaction Processor should have been turned off when the ' +
                'method was called, meaning no Contact should have been created for this Interaction record.');
        }
    }

    @IsTest
    private static void testLog() {
        // Act
        Test.startTest();
        INT_Utilities.log('a test message');
        Test.stopTest();

        // Assert
        System.assert(INT_Utilities.enableLogging);
    }

    @IsTest
    private static void testLogSystemLevel() {
        // Act
        Test.startTest();
        INT_Utilities.log(System.LoggingLevel.ERROR, 'an error message');
        Test.stopTest();

        // Assert
        System.assert(INT_Utilities.enableLogging);
    }

    @IsTest
    private static void testLogPossibleErrorsSaveResult() {
        // Act
        Test.startTest();
        INT_Utilities.logPossibleErrors(
            (List<Database.SaveResult>) JSON.deserialize(
                '[{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}]',
                List<Database.SaveResult>.class
            )
        );
        Test.stopTest();

        // Assert
        System.assert(INT_Utilities.enableLogging);
    }

    @IsTest
    private static void testLogPossibleErrorsUpsertResult() {
        // Act
        Test.startTest();
        INT_Utilities.logPossibleErrors(
            (List<Database.UpsertResult>) JSON.deserialize(
                '[{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}]',
                List<Database.UpsertResult>.class
            )
        );
        Test.stopTest();

        // Assert
        System.assert(INT_Utilities.enableLogging);
    }

    @IsTest
    private static void testLogPossibleErrorsUpsertResultWithInteractions() {
        // Arrange
        List<Interaction__c> testInteractions = INT_TestDataFactory.createBulkTestInteractions(1);

        // Act
        Test.startTest();
        INT_Utilities.logPossibleErrors(
            (List<Database.UpsertResult>) JSON.deserialize(
                '[{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}]',
                List<Database.UpsertResult>.class
            ),
            testInteractions,
            'Error on this interaction'
        );
        Test.stopTest();

        // Assert
        System.assert(INT_Utilities.enableLogging);
        System.assert(testInteractions[0].Audit_Reason__c.contains('You cannot do this'),
            'The system level error should have been written to the Interaction.');
        System.assert(testInteractions[0].Audit_Reason__c.contains('Error on this interaction'),
            'The custom error message should have been written to the Interaction.');
    }

    @IsTest
    private static void testLogPossibleErrorsDeleteResult() {
        // Act
        Test.startTest();
        INT_Utilities.logPossibleErrors(
            (List<Database.DeleteResult>) JSON.deserialize(
                '[{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}]',
                List<Database.DeleteResult>.class
            )
        );
        Test.stopTest();

        // Assert
        System.assert(INT_Utilities.enableLogging);
    }

    @IsTest
    private static void testRunSObjectHandlersAsync() {
        // Arrange
        List<INT_SObjectHandler> sObjectHandlers = new List<INT_SObjectHandler>{
            (INT_SObjectHandler) new INT_OpportunityHandler()
        };

        List<Interaction__c> testInteractions = INT_TestDataFactory.createBulkTestInteractions(2);
        INT_InteractionProcessor.runProcessing = false;
        insert testInteractions;
        INT_InteractionProcessor.runProcessing = true;

        // Act
        Test.startTest();
        INT_Utilities.runSObjectHandlersAsync(sObjectHandlers, new Map<Id, Interaction__c>(testInteractions).keySet());
        Test.stopTest();

        // Assert
        System.assertEquals(0, [SELECT Id FROM Opportunity].size(), 'Opportunities should not have been processed.');
    }

    @IsTest
    private static void testRunSObjectHandlers() {
        // Act
        Test.startTest();
        INT_Utilities.runSObjectHandlers(
            new List<INT_SObjectHandler>{(INT_SObjectHandler) new INT_OpportunityHandler()},
            INT_TestDataFactory.createBulkTestInteractions(2)
        );
        Test.stopTest();

        // Assert
        System.assertEquals(0, [SELECT Id FROM Opportunity].size(), 'Opportunities should not have been processed.');
    }

    @IsTest
    private static void testSlice() {
        // Arrange
        List<Contact> testContacts = INT_TestDataFactory.createBulkTestContacts(20);

        // Act
        Test.startTest();
        List<Contact> assertContacts = (List<Contact>) INT_Utilities.slice(testContacts, 0, 10);
        Test.stopTest();

        // Assert
        System.assertEquals(10, assertContacts.size(),
            'The slice method should have sliced the list down to 10 Contacts.');
    }

    @IsTest
    private static void testBuildInteractionQuery() {
        // Arrange
        Set<String> fieldsToQuery = new Set<String>{
            'Interaction_Status__c',
            'Audit_Reason__c'
        };

        // Act
        Test.startTest();
        String assertQueryString = INT_Utilities.buildInteractionQuery(fieldsToQuery, 'interactionIds');
        Test.stopTest();

        // Assert
        System.assertEquals(
            'SELECT Interaction_Status__c, Audit_Reason__c FROM Interaction__c WHERE Id IN :interactionIds',
            assertQueryString,
            'The query should have been constructed as expected.'
        );
    }
}