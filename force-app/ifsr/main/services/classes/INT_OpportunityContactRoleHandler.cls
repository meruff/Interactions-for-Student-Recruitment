/**
* @author Accenture
* @date 11/12/19
*
* Uses the HEDA Table Driven Trigger Management to create OpportunityContactRole records.
*/
global without sharing class INT_OpportunityContactRoleHandler extends hed.TDTM_Runnable {
    global override DmlWrapper run(List<SObject> newList, List<SObject> oldList,
        hed.TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult
    ) {
        DmlWrapper dmlWrapper = new DmlWrapper();
        List<OpportunityContactRole> rolesToInsert = new List<OpportunityContactRole>();

        for (Opportunity anOpportunity : (List<Opportunity>) newList) {
            if (!String.isBlank(anOpportunity.Contact__c)) {
                rolesToInsert.add(
                    new OpportunityContactRole(
                        ContactId = anOpportunity.Contact__c,
                        OpportunityId = anOpportunity.Id,
                        Role = 'Opportunity Contact',
                        IsPrimary = true
                    )
                );
            }
        }

        if (!rolesToInsert.isEmpty()) {
            /**
             * Send existing roles to dmlWrapper for deletion since we're creating new, more accurate ones.
             * NOTE: Add this List prior to creating new ones so we don't delete those.
             */
            dmlWrapper.objectsToDelete.addAll((List<SObject>) [
                SELECT Id
                FROM OpportunityContactRole
                WHERE OpportunityId IN :newList
            ]);

            INT_Utilities.logPossibleErrors(Database.insert(rolesToInsert));

            /**
            * Retrieve Inserted Role Ids to update IsPrimary on. Doesn't work in same context as Lead Convert. Keep
            * an eye on Idea Exchange below, @future context is handling this for now
            * https://success.salesforce.com/ideaview?id=08730000000HKbnAAG
            */
            if (System.isBatch()) {
                updateRolesAsPrimary(rolesToInsert);
            } else {
                updateRolesAsPrimaryAsync(new Map<Id, OpportunityContactRole>(rolesToInsert).keySet());
            }
        }

        return dmlWrapper;
    }

    /**
     * Updates OpportunityContactRole records in an asynchronous context after creation. Salesforce doesn't
     * currently update the IsPrimary flag when creating new OCR records, so we need to call it separately.
     *
     * @param roleIds, a Set of OpportunityContactRole Ids to set IsPrimary on.
     */
    @Future
    public static void updateRolesAsPrimaryAsync(Set<Id> roleIds) {
        updateRolesAsPrimary([SELECT IsPrimary FROM OpportunityContactRole WHERE Id IN :roleIds]);
    }

    /**
     * Updates OpportunityContactRole records in a synchronous context after creation. Salesforce doesn't
     * currently update the IsPrimary flag when creating new OCR records, so we need to call it separately.
     *
     * @param roles, a List of OpportunityContactRole records to set IsPrimary on.
     */
    public static void updateRolesAsPrimary(List<OpportunityContactRole> roles) {
        for (OpportunityContactRole role : roles) {
            role.IsPrimary = true;
        }

        INT_Utilities.logPossibleErrors(Database.update(roles));
    }
}