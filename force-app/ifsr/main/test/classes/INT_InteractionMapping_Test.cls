/**
* @author Accenture
* @date 11/22/19
*
* Unit Tests for INT_InteractionMapping.trigger
*/
@IsTest
private class INT_InteractionMapping_Test {
    /**
     * Tests validation creating a new Interaction_Mapping__c record with a source field that does not exist on Interaction__c.
     */
    @IsTest
    private static void testErrorCreatingInteractionMapping() {
        // Arrange
        Interaction_Mapping__c testInteractionMappingError = new Interaction_Mapping__c(
            Target_Object_API_Name__c = 'Lead',
            Source_Object_API_Name__c = 'Interaction__c',
            Source_Field_API_Name__c = 'Some_Field_That_Is_Wrong__c',
            Target_Field_API_Name__c = 'Mobile_Phone__c',
            Active__c = true
        );

        // Act
        Test.startTest();
        try {
            insert testInteractionMappingError;
        } catch (Exception e) {
            // Assert
            System.assert(e.getMessage().contains('Source Field API Name \'Some_Field_That_Is_Wrong__c\' does not exist on Interaction'),
                'The test should have failed to create the mapping as \'Some_Field_That_Is_Wrong__c\' does not exist on Interaction__c.');
        }
        Test.stopTest();
    }

    /**
     * Tests validation creating a new Interaction_Mapping__c record with a source field that does not exist on Interaction__c.
     */
    @IsTest
    private static void testErrorCreatingSObjectMapping() {
        // Arrange
        Interaction_Mapping__c testLeadMappingError = new Interaction_Mapping__c(
            Target_Object_API_Name__c = 'Interaction__c',
            Source_Object_API_Name__c = 'Lead',
            Source_Field_API_Name__c = 'Some_Field_That_Is_Wrong__c',
            Target_Field_API_Name__c = 'Mobile_Phone__c',
            Active__c = true
        );

        // Act
        Test.startTest();
        try {
            insert testLeadMappingError;
        } catch (Exception e) {
            // Assert
            System.assert(e.getMessage().contains('Source Field API Name \'Some_Field_That_Is_Wrong__c\' does not exist on Lead'),
                'The test should have failed to create the mapping as \'Some_Field_That_Is_Wrong__c\' does not exist on Lead.');
        }
        Test.stopTest();
    }
}