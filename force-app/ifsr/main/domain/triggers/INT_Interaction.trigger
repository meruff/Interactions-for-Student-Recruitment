/**
* @author Accenture
* @date 11/8/19
*
* Interaction__c Trigger.
*/
trigger INT_Interaction on Interaction__c (after insert, after update) {
    INT_InteractionProcessor.processInteractions(Trigger.new); 
}