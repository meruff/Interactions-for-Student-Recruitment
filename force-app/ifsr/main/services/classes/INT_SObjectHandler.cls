/**
* @author Sierra-Cedar
* @date 11/11/19
*
* An interface for Interactions to use when creating SObject handlers
*/
public interface INT_SObjectHandler {
    /**
     * Creates a List of field API names as Strings to use to query for Interaction__c record data for processing. Be
     * sure to add all required fields for related records here.
     *
     * @return, a List<String> of field API names.
     */
    Set<String> interactionFieldsToQuery();

    /**
     * Process Interaction__c records from provided List of Ids and create related records in an
     * asynchronous context. Use @Future.
     *
     * @param interactionIds, a List of Interaction__c Ids to query for and process.
     */
    void processInteractionsAsync(Set<Id> interactionIds);

    /**
     * Process Interaction__c records from provided List of Interaction__c records.
     *
     * @param interactionsToProcess, a List of Interaction__c records to process.
     */
    void processInteractions(List<Interaction__c> interactionsToProcess);

    /**
     * Creates a related record from a provided Interaction__c record.
     *
     * @param interaction, the Interaction__c record to create the Opportunity from.
     *
     * @return, a new record (i.e. Opportunity, hed__Affiliation__c, etc.).
     */
    SObject createSObjectFromInteraction(Interaction__c interaction);
}