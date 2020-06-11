/**
* @author Accenture
* @date 11/8/19
*
* Handles processing of Lead records for Interactions.
*/
public class INT_LeadHandler {
    // TODO: Issue #13 Github? https://github.com/SFDO-Community/Interactions-for-Student-Recruitment/issues/13
    private static LeadStatus convertStatus {
        get {
            if (convertStatus == null) {
                convertStatus = [SELECT ApiName FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
            }

            return convertStatus;
        }

        set;
    }

    /**
     * Creates a new Lead record from Interaction__c record data.
     *
     * @param interaction, the Interaction__c record to use.
     *
     * @return newLead, a new Lead record.
     */
    public static Lead createLeadFromInteraction(Interaction__c interaction) {
        Lead newLead = new Lead(
            FirstName = interaction.First_Name__c,
            LastName = interaction.Last_Name__c,
            Email = interaction.Email__c,
            Company = interaction.Last_Name__c + ', ' + interaction.First_Name__c
        );

        INT_InteractionMappingService.applyDataToSObject(interaction, newLead);
        INT_Utilities.log('New Lead - ' + newLead);

        return newLead;
    }

    /**
     * Populates the Interaction with found Lead data if a Lead Id is attached to the InteractionWrapper and
     * Interaction_Mapping__c records exist for Interaction__c records. Then populates a Map of
     * INT_InteractionProcessor.InteractionWrapper records by Lead Id for later use.
     *
     * @param interactionWrappers, a List of INT_InteractionProcessor.InteractionWrapper records to process.
     * @param interactionWrappersByLeadId, a Map of INT_InteractionProcessor.InteractionWrapper records by Lead Id
     * used during LeadConversion to populate converted Contact Ids or write errors to.
     */
    public static void filterAndPopulateInteractionsWithExistingLeadData(
        List<INT_InteractionProcessor.InteractionWrapper> interactionWrappers,
        Map<Id, INT_InteractionProcessor.InteractionWrapper> interactionWrappersByLeadId
    ) {
        List<Id> leadIds = new List<Id>();

        for (INT_InteractionProcessor.InteractionWrapper wrapper : interactionWrappers) {
            if (wrapper.lead != null && !String.isBlank(wrapper.lead.Id)) {
                leadIds.add(wrapper.lead.Id);
                interactionWrappersByLeadId.put(wrapper.lead.Id, wrapper);
            }
        }

        /**
         * If Interaction_Mapping__c records for Interaction__c exist, use them to query for existing Leads and
         * map data from the found Lead to the Interaction__c record. Reapply data to Contact as Lead data is preferred.
         */
        if (INT_InteractionMappingService.intMappingMap.containsKey('Interaction__c')) {
            String soqlString = 'SELECT Id';

            for (Interaction_Mapping__c mapping : INT_InteractionMappingService.intMappingMap.get('Interaction__c')) {
                soqlString += ', ' + mapping.Source_Field_API_Name__c;
            }

            soqlString = soqlString.removeEnd(',').trim();
            soqlString += ' FROM Lead WHERE Id IN :leadIds';
            Map<Id, Lead> existingLeadsByIds = new Map<Id, Lead>((List<Lead>) Database.query(soqlString));

            for (INT_InteractionProcessor.InteractionWrapper wrapper : interactionWrappers) {
                if (wrapper.lead != null && !String.isBlank(wrapper.lead.Id) && existingLeadsByIds.containsKey(wrapper.lead.Id)) {
                    INT_InteractionMappingService.applyDataToInteraction(existingLeadsByIds.get(wrapper.lead.Id), wrapper.interaction);
                    INT_Utilities.log(
                        'Interaction with Id ' + wrapper.interaction.Id + ' populated with found Lead data - ' + existingLeadsByIds.get(wrapper.lead.Id)
                    );

                    if (wrapper.contact != null) {
                        INT_InteractionMappingService.applyDataToSObject(wrapper.interaction, wrapper.contact);
                    }
                }
            }
        }
    }

    /**
     * Creates Database.LeadConvert records from supplied INT_InteractionProcessor.InteractionWrapper records for
     * Lead conversion.
     *
     * @param interactionWrappers, a List of INT_InteractionProcessor.InteractionWrapper records to build LeadConvert
     * records for.
     *
     * @return newLeadConverts, a List of new LeadConvert records for conversion.
     */
    public static List<Database.LeadConvert> createLeadConverts(List<INT_InteractionProcessor.InteractionWrapper> interactionWrappers) {
        List<Database.LeadConvert> newLeadConverts = new List<Database.LeadConvert>();

        for (INT_InteractionProcessor.InteractionWrapper wrapper : interactionWrappers) {
            if (!wrapper.interaction.Lead_Only__c && wrapper.lead != null && !String.isBlank(wrapper.lead.Id)) {
                Database.LeadConvert leadConvert = new Database.LeadConvert();
                leadConvert.setLeadId(wrapper.lead.Id);
                leadConvert.setConvertedStatus(convertStatus.ApiName);
                leadConvert.setContactId(wrapper.interaction.Contact__c);
                leadConvert.setAccountId(wrapper.interaction.Contact_Account_ID__c);
                leadConvert.setDoNotCreateOpportunity(true);
                newLeadConverts.add(leadConvert);
            }
        }

        return newLeadConverts;
    }

    /**
     * If successful, populates the converted Lead Id for each INT_InteractionProcessor.InteractionWrapper record.
     * Otherwise set related Interaction__c record to Audit Required status and set Audit Reason message.
     *
     * @param leadConvertResults, a List of Database.LeadConvertResult records to use.
     * @param interactionWrappersByLeadId, a Map of INT_InteractionProcessor.InteractionWrapper records by Lead Id to populate.
     */
    public static void processConvertedLeads(
        List<Database.LeadConvertResult> leadConvertResults,
        Map<Id, INT_InteractionProcessor.InteractionWrapper> interactionWrappersByLeadId
    ) {
        for (Database.LeadConvertResult lcr : leadConvertResults) {
            if (interactionWrappersByLeadId.containsKey(lcr.getLeadId())) {
                if (lcr.isSuccess()) {
                    interactionWrappersByLeadId.get(lcr.getLeadId()).contact.Id = lcr.getContactId();
                } else {
                    for (Database.Error error : lcr.getErrors()) {
                        INT_Utilities.writeAuditReasonToInteraction(
                            interactionWrappersByLeadId.get(lcr.getLeadId()).interaction,
                            'Error during Lead conversion: ' + error.getStatusCode() + ' ' + error.getMessage() + ' ' + error.getFields());
                        INT_Utilities.log(
                            System.LoggingLevel.ERROR,
                            'Error during Lead conversion: ' + error.getStatusCode() + ' ' + error.getMessage() + ' ' + error.getFields()
                        );
                    }
                }
            }
        }
    }

    /**
     * Handles match records for Lead. Grabs the first matched record's Id and populates the Id field.
     *
     * @param leadToPopulate, the Lead to write the Id value to.
     * @param matchRecords, a list of Datacloud.MatchRecord records to use.
     */
    public static void findMatchedLeadId(SObject leadToPopulate, List<Datacloud.MatchRecord> matchRecords) {
        leadToPopulate.Id = (Id) matchRecords[0].record.get('Id');
        INT_Utilities.log('Using duplicate Lead found: ' + leadToPopulate.get('FirstName') + '' +
            ' ' + leadToPopulate.get('LastName') + ' with Id ' + leadToPopulate.Id);
    }
}