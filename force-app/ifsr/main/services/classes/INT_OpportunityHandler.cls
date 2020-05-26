/**
* @author Sierra-Cedar
* @date 11/11/19
*
* Handles processing of Opportunity records for Interactions.
*/
public class INT_OpportunityHandler implements INT_SObjectHandler {
    public static Set<String> interactionFieldsToQuery() {
        Set<String> opportunityFieldsToQuery = new Set<String>{
            'Interaction_Source__c',
            'Interaction_Status__c',
            'Audit_Reason__c',
            'Contact__c',
            'Opportunity_Stage__c',
            'Opportunity_Key__c',
            'Contact_Account_ID__c'
        };

        for (Interaction_Mapping__c mapping : [
            SELECT Source_Field_API_Name__c
            FROM Interaction_Mapping__c
            WHERE Target_Object_API_Name__c = 'Opportunity'
            AND Active__c = TRUE
            ORDER BY Source_Field_API_Name__c
        ]) {
            opportunityFieldsToQuery.add(mapping.Source_Field_API_Name__c);
        }

        return opportunityFieldsToQuery;
    }

    @Future
    public static void processInteractionsAsync(Set<Id> interactionIds) {
        processInteractions(Database.query(INT_Utilities.buildInteractionQuery(interactionFieldsToQuery(), 'interactionIds')));
    }

    public static void processInteractions(List<Interaction__c> interactionsToProcess) {
        List<Interaction__c> interactionsWithOpportunities = new List<Interaction__c>();
        List<Opportunity> opportunitiesToUpsert = new List<Opportunity>();

        for (Interaction__c interaction : interactionsToProcess) {
            if ((!String.isBlank(interaction.Academic_Interest__c) || !String.isBlank(interaction.Recruitment_Interest__c))
                && !String.isBlank(interaction.Term__c) && !String.isBlank(interaction.Contact__c)
            ) {
                interactionsWithOpportunities.add(interaction);
                opportunitiesToUpsert.add((Opportunity) createSObjectFromInteraction(interaction));
            }
        }

        if (!opportunitiesToUpsert.isEmpty()) {
            INT_Utilities.logPossibleErrors(
                Database.upsert(opportunitiesToUpsert, Opportunity.Opportunity_Key__c, false),
                interactionsWithOpportunities,
                'Error creating Opportunity: '
            );

            for (Interaction__c interaction : interactionsWithOpportunities) {
                if (interaction.Opportunity__r != null && !String.isBlank(interaction.Opportunity__r.Id)) {
                    interaction.Opportunity__c = interaction.Opportunity__r.Id;
                }

                interaction.Opportunity__r = null;
            }

            INT_Utilities.updateInteractionsIfAsync(interactionsWithOpportunities);
        }
    }

    public static SObject createSObjectFromInteraction(Interaction__c interaction) {
        Opportunity newOpportunity = new Opportunity(
            CloseDate = System.today(),
            StageName = interaction.Opportunity_Stage__c,
            Opportunity_Key__c = interaction.Contact__c + interaction.Opportunity_Key__c,
            AccountId = interaction.Contact_Account_ID__c,
            Contact__c = interaction.Contact__c
        );

        INT_InteractionMappingService.applyDataToSObject(interaction, newOpportunity);
        INT_Utilities.log('New Opportunity: ' + newOpportunity);
        interaction.Opportunity__r = newOpportunity;

        return newOpportunity;
    }
}