/**
* @author meruff
* @date 11/5/19
*
* Handles duplicate logic for Interactions.
*/
public class INT_DuplicateHelper {
    /**
     * Finds duplicate records in the system from supplied SObjects. This method slices the List into chunks of 50 and
     * calls findDuplicateRecordIds for each chunk (Datacloud.FindDuplicates.findDuplicates limit is 50 records).
     *
     * @param sObjects, a List of SObject records to check for duplicates.
     */
    public static void findDuplicateRecords(List<SObject> sObjects) {
        Integer first = 0, last = 50;

        while (sObjects.size() - 1 >= first && last <= 200) {
            findDuplicateRecordIds(INT_Utilities.slice(sObjects, first, last));
            first += 50; last += 50;
        }
    }

    /**
     * Finds duplicate records using Datacloud.FindDuplicates and populates the Id field on the supplied list of SObjects.
     *
     * @param sObjects, a List of SObject records to find duplicates for.
     */
    private static void findDuplicateRecordIds(List<SObject> sObjects) {
        Integer recordIndex = 0;

        for (Datacloud.FindDuplicatesResult findDuplicatesResult : Datacloud.FindDuplicates.findDuplicates(sObjects)) {
            Boolean duplicateFound = false;

            for (Datacloud.DuplicateResult duplicateResult : findDuplicatesResult.getDuplicateResults()) {
                for (Datacloud.MatchResult matchResult : duplicateResult.getMatchResults()) {
                    if (!matchResult.getMatchRecords().isEmpty()) {
                        if (sObjects[recordIndex].getSObjectType().getDescribe().getName() == 'Lead'
                            && matchResult.getEntityType() == 'Lead'
                        ) {
                            INT_LeadHandler.findMatchedLeadId(sObjects[recordIndex], matchResult.getMatchRecords());
                            duplicateFound = true;
                        } else if (sObjects[recordIndex].getSObjectType().getDescribe().getName() == 'Contact'
                            && matchResult.getEntityType() == 'Contact'
                        ) {
                            INT_ContactHandler.findMatchedContactId(sObjects[recordIndex], matchResult.getMatchRecords());
                            duplicateFound = true;
                        }

                        if (duplicateFound) break;
                    }
                }

                if (duplicateFound) break;
            }

            recordIndex++;
        }
    }
}