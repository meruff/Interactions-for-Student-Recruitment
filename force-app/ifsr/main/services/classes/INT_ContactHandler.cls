/**
* @author Accenture
* @date 11/8/19
*
* Handles processing of Contact records for Interactions.
*/
public class INT_ContactHandler {
    /**
     * Creates a new Contact record from the supplied Interaction and then maps data to it.
     *
     * @param interaction, the Interaction__c record to use as a source.
     * @param intMappingService, the INT_InteractionMappingService class to use to map data to.
     *
     * @return newContact, a new Contact record populated with Interaction__c data.
     */
    public static Contact createContactFromInteraction(Interaction__c interaction) {
        Contact newContact = new Contact(
            FirstName = interaction.First_Name__c,
            LastName = interaction.Last_Name__c,
            Email = interaction.Email__c
        );

        INT_InteractionMappingService.applyDataToSObject(interaction, newContact);
        INT_Utilities.log('New Contact - ' + newContact);

        return newContact;
    }

    /**
     * Handles match records for Contact. Loops through matched Contact records and uses the most recently created
     * Contact to populate the Id.
     *
     * @param contactToPopulate, the Contact record to write the Id value to.
     * @param matchRecords, a List of Datacloud.MatchRecord records to use.
     */
    public static void findMatchedContactId(SObject contactToPopulate, List<Datacloud.MatchRecord> matchRecords) {
        if (!matchRecords.isEmpty()) {
            contactToPopulate.Id = (Id) matchRecords[0].record.get('Id');
            INT_Utilities.log('Using duplicate Contact found: ' + contactToPopulate.get('FirstName') + '' +
                ' ' + contactToPopulate.get('LastName') + ' with Id ' + contactToPopulate.Id);
        }
    }
}