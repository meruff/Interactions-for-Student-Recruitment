/**
* @author Sierra-Cedar
* @date 11/12/19
*
* Handles processing of CampaignMember records for Interactions.
*/
public class INT_CampaignMemberHandler implements INT_SObjectHandler {
    private static Set<String> campaignReferenceStrings = new Set<String>();

    private static Map<String, Id> campaignIdsByReferenceString {
        get {
            if (campaignIdsByReferenceString == null) {
                campaignIdsByReferenceString = new Map<String, Id>();
                for (Campaign campaign : [
                    SELECT Campaign_Key__c
                    FROM Campaign
                    WHERE (
                        Id IN :campaignReferenceStrings
                        OR Campaign_Key__c IN :campaignReferenceStrings
                    )
                ]) {
                    campaignIdsByReferenceString.put(campaign.Campaign_Key__c, campaign.Id);
                }
            }

            return campaignIdsByReferenceString;
        }

        set;
    }

    public static Set<String> interactionFieldsToQuery() {
        Set<String> campaignMemberFieldsToQuery = new Set<String>{
            'Interaction_Source__c',
            'Interaction_Status__c',
            'Audit_Reason__c',
            'Lead_Only__c',
            'Lead__c',
            'Contact__c',
            'Campaign_Key__c',
            'Campaign_Member_Status__c',
            'Additional_Campaign_Key__c',
            'Additional_Campaign_Member_Status__c'
        };

        for (Interaction_Mapping__c mapping : [
            SELECT Source_Field_API_Name__c
            FROM Interaction_Mapping__c
            WHERE Target_Object_API_Name__c = 'CampaignMember'
            AND Active__c = TRUE
            ORDER BY Source_Field_API_Name__c
        ]) {
            campaignMemberFieldsToQuery.add(mapping.Source_Field_API_Name__c);
        }

        return campaignMemberFieldsToQuery;
    }

    @Future
    public static void processInteractionsAsync(Set<Id> interactionIds) {
        processInteractions(Database.query(INT_Utilities.buildInteractionQuery(interactionFieldsToQuery(), 'interactionIds')));
    }

    public static void processInteractions(List<Interaction__c> interactionsToProcess) {
        Map<Id, Interaction__c> interactionsWithCampaignMembersByIds = new Map<Id, Interaction__c>();
        List<CampaignMember> campaignMembersToUpsert = new List<CampaignMember>();

        // Collect Campaign reference Ids to query for Campaign Ids.
        for (Interaction__c interaction : interactionsToProcess) {
            if (!String.isBlank(interaction.Campaign_Key__c)) {
                campaignReferenceStrings.add(interaction.Campaign_Key__c);
            }

            if (!String.isBlank(interaction.Additional_Campaign_Key__c)) {
                campaignReferenceStrings.add(interaction.Additional_Campaign_Key__c);
            }
        }

        for (Interaction__c interaction : interactionsToProcess) {
            if ((!String.isBlank(interaction.Lead__c) || !String.isBlank(interaction.Contact__c))) {
                if (!String.isBlank(interaction.Campaign_Key__c)
                    && !String.isBlank(interaction.Campaign_Member_Status__c)
                    && campaignIdsByReferenceString.containsKey(interaction.Campaign_Key__c)
                ) {
                    interactionsWithCampaignMembersByIds.put(interaction.Id, interaction);
                    campaignMembersToUpsert.add((CampaignMember) createSObjectFromInteraction(interaction));
                }

                if (!String.isBlank(interaction.Additional_Campaign_Key__c)
                    && !String.isBlank(interaction.Additional_Campaign_Member_Status__c)
                    && campaignIdsByReferenceString.containsKey(interaction.Additional_Campaign_Key__c)
                ) {
                    if (!interactionsWithCampaignMembersByIds.containsKey(interaction.Id)) {
                        interactionsWithCampaignMembersByIds.put(interaction.Id, interaction);
                    }

                    CampaignMember additionalCampaignMember = (CampaignMember) createSObjectFromInteraction(interaction);
                    additionalCampaignMember.CampaignId = campaignIdsByReferenceString.get(interaction.Additional_Campaign_Key__c);
                    additionalCampaignMember.Campaign_Member_Key__c =
                        (!String.isBlank(interaction.Lead__c) ? interaction.Lead__c : interaction.Contact__c) +
                        '.' + campaignIdsByReferenceString.get(interaction.Additional_Campaign_Key__c);
                    campaignMembersToUpsert.add(additionalCampaignMember);
                }
            }
        }

        if (!campaignMembersToUpsert.isEmpty()) {
            List<Interaction__c> interactionsWithCampaignMembers = interactionsWithCampaignMembersByIds.values();

            INT_Utilities.logPossibleErrors(
                Database.upsert(campaignMembersToUpsert, CampaignMember.Campaign_Member_Key__c, false),
                interactionsWithCampaignMembersByIds.values(),
                'Error creating CampaignMember: '
            );

            // Update Interactions with Audit Status only if there was an error creating a related CampaignMember record.
            for (Integer i = 0; i < interactionsWithCampaignMembers.size(); i++) {
                if (!String.isBlank(interactionsWithCampaignMembers[i].Audit_Reason__c)
                    && !String.valueOf(interactionsWithCampaignMembers[i].Audit_Reason__c).contains('Error creating CampaignMember')
                ) {
                    interactionsWithCampaignMembers.remove(i);
                }
            }

            if (!interactionsWithCampaignMembers.isEmpty()) {
                INT_Utilities.updateInteractionsIfAsync(interactionsWithCampaignMembers);
            }
        }
    }

    public static SObject createSObjectFromInteraction(Interaction__c interaction) {
        CampaignMember newCampaignMember = new CampaignMember(
            LeadId = (interaction.Lead_Only__c) ? interaction.Lead__c : null,
            ContactId = (interaction.Lead_Only__c) ? null : interaction.Contact__c,
            CampaignId = campaignIdsByReferenceString.get(interaction.Campaign_Key__c),
            Campaign_Member_Key__c =
                (!String.isBlank(interaction.Lead__c) ? interaction.Lead__c : interaction.Contact__c) +
                '.' + campaignIdsByReferenceString.get(interaction.Campaign_Key__c)
        );

        INT_InteractionMappingService.applyDataToSObject(interaction, newCampaignMember);
        INT_Utilities.log('New Campaign Member: ' + newCampaignMember);

        return newCampaignMember;
    }
}