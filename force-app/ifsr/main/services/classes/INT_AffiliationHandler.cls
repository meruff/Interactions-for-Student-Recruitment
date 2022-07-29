/**
* @author meruff
* @date 11/11/19
*
* Handles processing of hed__Affiliation__c records for Interactions.
*/
public class INT_AffiliationHandler implements INT_SObjectHandler {
    public static Set<String> interactionFieldsToQuery() {
        Set<String> affiliationFieldsToQuery = new Set<String>{
            'Interaction_Source__c',
            'Interaction_Status__c',
            'Audit_Reason__c',
            'Contact__c',
            'Affiliated_Account__c'
        };

        for (Interaction_Mapping__c mapping : [
            SELECT Source_Field_API_Name__c
            FROM Interaction_Mapping__c
            WHERE Target_Object_API_Name__c = 'hed__Affiliation__c'
            AND Active__c = TRUE
            ORDER BY Source_Field_API_Name__c
        ]) {
            affiliationFieldsToQuery.add(mapping.Source_Field_API_Name__c);
        }

        return affiliationFieldsToQuery;
    }

    @Future
    public static void processInteractionsAsync(Set<Id> interactionIds) {
        processInteractions(Database.query(INT_Utilities.buildInteractionQuery(interactionFieldsToQuery(), 'interactionIds')));
    }

    public static void processInteractions(List<Interaction__c> interactionsToProcess) {
        List<Interaction__c> interactionsWithAffiliations = new List<Interaction__c>();
        List<hed__Affiliation__c> affiliationsToUpsert = new List<hed__Affiliation__c>();

        for (Interaction__c interaction : interactionsToProcess) {
            if (!String.isBlank(interaction.Contact__c) && !String.isBlank(interaction.Affiliated_Account__c)) {
                interactionsWithAffiliations.add(interaction);
                affiliationsToUpsert.add((hed__Affiliation__c) createSObjectFromInteraction(interaction));
            }
        }

        if (!affiliationsToUpsert.isEmpty()) {
            INT_Utilities.logPossibleErrors(
                Database.upsert(affiliationsToUpsert, hed__Affiliation__c.Upsert_Key__c, false),
                interactionsWithAffiliations,
                'Error creating Affiliation: '
            );

            if (!interactionsWithAffiliations.isEmpty()) {
                INT_Utilities.updateInteractionsIfAsync(interactionsWithAffiliations);
            }
        }
    }

    public static SObject createSObjectFromInteraction(Interaction__c interaction) {
        return INT_InteractionMappingService.applyDataToSObject(
            interaction,
            new hed__Affiliation__c(
                Upsert_Key__c = interaction.Contact__c + interaction.Affiliation_Key__c
            )
        );
    }
}