/**
* @author Sierra-Cedar
* @date 11/10/19
*
* A utility class used by Interactions.
*/
public class INT_Utilities {
    public static final String NEW_STATUS = 'New';
    public static final String IMPORTED_STATUS = 'Imported';
    public static final String AUDIT_REQUIRED_STATUS = 'Audit Required';

    public static Boolean enableLogging = (Test.isRunningTest()) ? true : false;

    /**
     * Updates Interaction__c records based upon whether or not Interactions is running in a synchronous or
     * asynchronous context. This method logs possible update errors when logging is enabled and ensures the
     * INT_InteractionProcessor class is turned off during update.
     *
     * @param interactionsToUpdate, a List of Interaction__c records to update if running in asynchronous mode.
     */
    public static void updateInteractionsIfAsync(List<Interaction__c> interactionsToUpdate) {
        if (INT_InteractionProcessor.runAsync) {
            INT_InteractionProcessor.runProcessing = false;
            logPossibleErrors(Database.update(interactionsToUpdate, false));
            INT_InteractionProcessor.runProcessing = true;
        }
    }

    /**
     * Logs a System.debug message if logging is enabled.
     *
     * @param obj, an Object to log.
     */
    public static void log(Object obj) {
        if (enableLogging) {
            System.debug('****Interactions: ' + obj);
        }
    }

    /**
     * Logs a System.debug message is logging is enabled with LoggingLevel.
     *
     * @param level, the System.LoggingLevel to use.
     * @param obj, an Object to log.
     */
    public static void log(System.LoggingLevel level, Object obj) {
        if (enableLogging) {
            System.debug(level, '****Interactions: ' + obj);
        }
    }

    /**
     * Debugs SaveResult errors if they happen.
     *
     * @param saveResults, the Database.SaveResult List to check.
     */
    public static void logPossibleErrors(Database.SaveResult[] saveResults) {
        for (Database.SaveResult result : saveResults) {
            if (!result.isSuccess()) {
                log(
                    System.LoggingLevel.ERROR,
                    'Save result error - ' + result.getErrors() + ' ' + result.getId()
                );
            }
        }
    }

    /**
     * Debugs UpsertResult errors if they happen.
     *
     * @param upsertResults, the Database.UpsertResult List to check.
     */
    public static void logPossibleErrors(Database.UpsertResult[] upsertResults) {
        for (Database.UpsertResult result : upsertResults) {
            if (!result.isSuccess()) {
                log(
                    System.LoggingLevel.ERROR,
                    'Upsert error - ' + result.getErrors() + ' ' + result.getId()
                );
            }
        }
    }

    /**
     * Debugs UpsertResult errors if they happen and writes to Interaction Audit Reason. The List of UpsertResult
     * records must match the List of Interaction record's index numbers.
     *
     * @param upsertResults , the Database.UpsertResult List to check.
     * @param interactionsToWriteTo , a List of Interaction__c records to write upsert errors to.
     * @param messageString , a String message to write to the Audit_Reason__c field on the related Interaction__c record.
     */
    public static void logPossibleErrors(Database.UpsertResult[] upsertResults, List<Interaction__c> interactionsToWriteTo, String messageString) {
        Integer index = 0;

        for (Database.UpsertResult result : upsertResults) {
            if (!result.isSuccess()) {
                log(
                    System.LoggingLevel.ERROR,
                    'Upsert error - ' + result.getErrors() + ' ' + result.getId()
                );

                for (Database.Error error : result.getErrors()) {
                    log(
                        System.LoggingLevel.ERROR,
                        error.getStatusCode() + ' - ' + error.getMessage()
                    );

                    writeAuditReasonToInteraction(
                        interactionsToWriteTo[index],
                        messageString + error.getStatusCode() + ' - ' + error.getMessage()
                    );

                    if (error instanceof Database.DuplicateError) {
                        writeDuplicateErrorToInteraction(interactionsToWriteTo[index], (Database.DuplicateError) error);
                    }
                }
            }

            index++;
        }
    }

    /**
     * Debugs DeleteResult errors if they happen.
     *
     * @param deleteResults, the Database.DeleteResult List to check.
     */
    public static void logPossibleErrors(Database.DeleteResult[] deleteResults) {
        for (Database.DeleteResult result : deleteResults) {
            if (!result.isSuccess()) {
                log(
                    System.LoggingLevel.ERROR,
                    'Delete error - ' + result.getErrors() + ' ' + result.getId()
                );
            }
        }
    }

    /**
     * Writes an Audit_Reason__c to the provided Interaction__c record and sets the Interaction_Status__c to
     * 'Audit Required'.
     *
     * @param interaction, the Interaction__c record to write to.
     * @param auditReason, a String message to append to the Audit_Reason__c.
     */
    public static void writeAuditReasonToInteraction(Interaction__c interaction, String auditReason) {
        if (interaction.Interaction_Status__c != AUDIT_REQUIRED_STATUS) interaction.Interaction_Status__c = AUDIT_REQUIRED_STATUS;
        interaction.Audit_Reason__c = (!String.isBlank(interaction.Audit_Reason__c)) ? interaction.Audit_Reason__c + '\n' + auditReason : auditReason;
    }

    /**
     * Writes a Database.DuplicateError Audit_Reason__c to the provided Interaction__c record.
     *
     * @param interaction, the Interaction__c record to write to.
     * @param duplicateError, the Database.DuplicateError record to use.
     */
    public static void writeDuplicateErrorToInteraction(Interaction__c interaction, Database.DuplicateError duplicateError) {
        for (Datacloud.MatchResult matchResult : duplicateError.getDuplicateResult().getMatchResults()) {
            for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                writeAuditReasonToInteraction(
                    interaction,
                    'Matched record: ' + matchRecord.getRecord()
                );

                for (Datacloud.FieldDiff fieldDiff : matchRecord.getFieldDiffs()) {
                    if (fieldDiff.getDifference() == 'Same') {
                        writeAuditReasonToInteraction(
                            interaction,
                            'Matched field: ' + fieldDiff.getName()
                        );
                    }
                }
            }
        }
    }

    /**
     * Runs the processInteractionsAsync() method in INT_InteractionsProcessor for the provided list of
     * INT_SObjectHandler records and Interaction__c record Ids.
     *
     * @param handlersToProcess, a List of INT_SObjectHandler classes to run.
     * @param interactionIdsToProcess, a Set of Interaction__c record Ids to process asynchronously.
     */
    public static void runSObjectHandlersAsync(List<INT_SObjectHandler> handlersToProcess, Set<Id> interactionIdsToProcess) {
        if (!handlersToProcess.isEmpty()) {
            for (INT_SObjectHandler handler : handlersToProcess) {
                handler.processInteractionsAsync(interactionIdsToProcess);
            }
        }
    }

    /**
     * Runs the processInteractions() method in INT_InteractionsProcessor for the provided list of INT_SObjectHandler
     * records and Interaction__c record Ids.
     *
     * @param handlersToProcess, a List of INT_SObjectHandler classes to run.
     * @param interactionsToProcess, a List of Interaction__c records to process synchronously.
     */
    public static void runSObjectHandlers(List<INT_SObjectHandler> handlersToProcess, List<Interaction__c> interactionsToProcess) {
        if (!handlersToProcess.isEmpty()) {
            for (INT_SObjectHandler handler : handlersToProcess) {
                handler.processInteractions(interactionsToProcess);
            }
        }
    }

    /**
     * Emulates JavaScript slice for Apex Lists.
     *
     * @param input, a List of SObjects to slice.
     * @param firstIndex, the index to start a slice.
     * @param lastIndex, the index to end a slice.
     *
     * @return output, a sliced List of SObject records.
     */
    public static List<SObject> slice(List<SObject> input, Integer firstIndex, Integer lastIndex) {
        Integer elements = lastIndex - firstIndex;
        List<SObject> output = input.clone();
        for (Integer i = 0; i < firstIndex; i++) output.remove(0);
        while (output.size() > elements) output.remove(elements);
        return output;
    }

    /**
     * Builds a query String for an Interaction record from provided List of fields. Used by INT_SObjectHandlers.
     *
     * @param fieldsToQuery, a Set of field API names to build a query for.
     * @param idListNameString, the String name of the List of Ids to use in the a WHERE clause.
     *
     * @return queryString, a SOQL query String.
     */
    public static String buildInteractionQuery(Set<String> fieldsToQuery, String idListNameString) {
        String queryString = 'SELECT ';
        for (String s : fieldsToQuery) queryString += s + ', ';
        queryString = queryString.substringBeforeLast(', ');
        queryString += ' FROM Interaction__c WHERE Id IN :' + idListNameString;
        return queryString;
    }
}