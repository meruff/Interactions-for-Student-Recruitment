/**
* @author Accenture
* @date 11/8/19
*
* Handles Interaction__c processing and logic.
*/
public class INT_InteractionProcessor {
    public static Boolean runAsync = true;
    public static Boolean runProcessing = true;

    /**
     * Converts existing Leads and creates new Contacts from Interaction__c records then kicks off related
     * object processing.
     *
     * @param newList, a List of Interaction__c records to process.
     */
    public static void processInteractions(List<Interaction__c> newList) {
        if (!runProcessing) return;
        if (newList.size() == 1 || System.isBatch()) runAsync = false;

        List<Id> leadIdsToDelete = new List<Id>();
        List<Lead> leadsToCheck = new List<Lead>();
        List<Lead> leadsToUpsert = new List<Lead>();
        List<Contact> contactsToUpsert = new List<Contact>();
        Set<String> interactionDuplicateKeys = new Set<String>();
        List<Interaction__c> interactionsToUpdate = new List<Interaction__c>();
        List<InteractionWrapper> interactionWrappers = new List<InteractionWrapper>();
        Map<Id, InteractionWrapper> interactionWrappersByLeadIds = new Map<Id, InteractionWrapper>();

        // Add Interaction and related objects to Map/Lists for processing by reference.
        for (Interaction__c newInteraction : newList) {
            if (newInteraction.Interaction_Status__c == INT_Utilities.NEW_STATUS) {
                Interaction__c interactionToProcess = newInteraction.clone(true, true, true, true);
                interactionToProcess.Audit_Reason__c = '';

                if (interactionDuplicateKeys.contains(
                    interactionToProcess.First_Name__c + interactionToProcess.Last_Name__c + interactionToProcess.Email__c
                )) {
                    INT_Utilities.writeAuditReasonToInteraction(
                        interactionToProcess,
                        'Reason: this Interaction was not processed because it is a possible duplicate of - ' +
                            interactionToProcess.Id + ': \'' + interactionToProcess.First_Name__c + ' ' +
                            interactionToProcess.Last_Name__c + '\', ' + interactionToProcess.Email__c
                    );

                    interactionsToUpdate.add(interactionToProcess);
                    continue;
                } else {
                    interactionToProcess.Interaction_Status__c = INT_Utilities.IMPORTED_STATUS;
                    interactionDuplicateKeys.add(interactionToProcess.First_Name__c + interactionToProcess.Last_Name__c + interactionToProcess.Email__c);

                    if (interactionToProcess.Lead_Only__c) {
                        interactionWrappers.add(
                            new InteractionWrapper(interactionToProcess, INT_LeadHandler.createLeadFromInteraction(interactionToProcess))
                        );

                        leadsToUpsert.add(interactionWrappers.get(interactionWrappers.size() - 1).lead);
                    } else {
                        interactionWrappers.add(
                            new InteractionWrapper(
                                interactionToProcess,
                                INT_LeadHandler.createLeadFromInteraction(interactionToProcess),
                                INT_ContactHandler.createContactFromInteraction(interactionToProcess)
                            )
                        );

                        contactsToUpsert.add(interactionWrappers.get(interactionWrappers.size() - 1).contact);
                    }

                    interactionsToUpdate.add(interactionToProcess);
                    leadsToCheck.add(interactionWrappers.get(interactionWrappers.size() - 1).lead);
                }
            }
        }

        if (!interactionWrappers.isEmpty() || !interactionsToUpdate.isEmpty()) {
            // Find existing Leads in the database using DataCloud class, populate Id.
            INT_DuplicateHelper.findDuplicateRecords(leadsToCheck);

            // Filter Leads into List for those that have an Id and apply data from Interaction record.
            INT_LeadHandler.filterAndPopulateInteractionsWithExistingLeadData(interactionWrappers, interactionWrappersByLeadIds);

            // Convert Leads and populate Contact Id on related wrapper.
            INT_LeadHandler.processConvertedLeads(
                Database.convertLead(INT_LeadHandler.createLeadConverts(interactionWrappers), false),
                interactionWrappersByLeadIds
            );

            // Find existing Contacts in the database using DataCloud class, populate Id. Upsert using Id.
            INT_DuplicateHelper.findDuplicateRecords(contactsToUpsert);
            INT_Utilities.logPossibleErrors(
                Database.upsert(contactsToUpsert, false),
                interactionsToUpdate,
                'Error upserting Contact: '
            );

            // Upsert any Leads
            INT_Utilities.logPossibleErrors(
                Database.upsert(leadsToUpsert, false),
                interactionsToUpdate,
                'Error upserting Lead: '
            );

            // Populate Interactions with lookup info and add any Leads Ids to delete to List.
            for (INT_InteractionProcessor.InteractionWrapper wrapper : interactionWrappers) {
                if (wrapper.lead != null && !String.isBlank(wrapper.lead.Id)) {
                    wrapper.interaction.Lead__c = wrapper.lead.Id;

                    if (!wrapper.interaction.Lead_Only__c) {
                        leadIdsToDelete.add(wrapper.lead.Id);
                    }
                }

                if (wrapper.contact != null && !String.isBlank(wrapper.contact.Id)) {
                    wrapper.interaction.Contact__c = wrapper.contact.Id;
                }
            }

            // If synchronous, run processing for related objects first to populate lookups if necessary.
            if (!runAsync) {
                INT_OpportunityHandler.processInteractions(interactionsToUpdate);
                INT_AffiliationHandler.processInteractions(interactionsToUpdate);
                INT_CampaignMemberHandler.processInteractions(interactionsToUpdate);
            }

            // Update Interactions for lookup/audit info. Set runProcessing to false to prevent recursion.
            runProcessing = false;
            INT_Utilities.logPossibleErrors(Database.update(interactionsToUpdate, false));
            runProcessing = true;

            // Delete any Leads that were converted from Interactions.
            INT_Utilities.logPossibleErrors(Database.delete(leadIdsToDelete));

            // Finally, if asynchronous, run @future handlers for processing.
            if (runAsync) {
                Set<Id> interactionIdsToProcess = new Map<Id, Interaction__c>(interactionsToUpdate).keySet();
                INT_OpportunityHandler.processInteractionsAsync(interactionIdsToProcess);
                INT_AffiliationHandler.processInteractionsAsync(interactionIdsToProcess);
                INT_CampaignMemberHandler.processInteractionsAsync(interactionIdsToProcess);
            }
        }
    }

    /**
     * A class to wrap Interaction__c records up with related Contact and Lead records.
     */
    public class InteractionWrapper {
        public Interaction__c interaction { get; set; }
        public Lead lead { get; set; }
        public Contact contact { get; set; }

        public InteractionWrapper(Interaction__c interaction, Lead lead) {
            this.interaction = interaction;
            this.lead = lead;
        }

        public InteractionWrapper(Interaction__c interaction, Lead lead, Contact contact) {
            this.interaction = interaction;
            this.lead = lead;
            this.contact = contact;
        }
    }
}