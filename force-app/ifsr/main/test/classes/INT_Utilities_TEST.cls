/**
* @author meruff
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
    private static void testLogPossibleErrorsDuplicateResult() {
        // Arrange
        insert INT_TestDataFactory.createTestContact();
        Contact testContact = INT_TestDataFactory.createTestContact();
        Interaction__c testInteraction = INT_TestDataFactory.createTestInteraction();

        // Act
        Test.startTest();
        INT_Utilities.logPossibleErrors(
            new List<Database.UpsertResult>{Database.upsert(testContact, false)},
            new List<Interaction__c>{testInteraction},
            'Upsert Error - '
        );
        Test.stopTest();

        // Assert
        System.assertEquals(INT_Utilities.AUDIT_REQUIRED_STATUS, testInteraction.Interaction_Status__c,
            'Interaction Status should have been set to Audit Required.');
        System.assertNotEquals(null, testInteraction.Audit_Reason__c,
            'Audit Reason should have been written to.');
        System.assert(testInteraction.Audit_Reason__c.contains('Upsert Error - '),
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