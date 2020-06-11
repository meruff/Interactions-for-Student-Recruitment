/**
* @author Accenture
* @date 11/8/19
*
* Interaction_Mapping__c Trigger. Validates new mapping records to validate that the fields they reference exist
* on the related Object.
*/
trigger INT_InteractionMapping on Interaction_Mapping__c (after insert, after update) {
    private Set<String> sObjectNames = new Set<String>{'Interaction__c'};
    private Map<String, Set<String>> sObjectFieldStringsMap = new Map<String, Set<String>>();

    private static Map<String, SObjectType> globalSObjectTypesByStrings {
        get {
            if (globalSObjectTypesByStrings == null) {
                globalSObjectTypesByStrings = Schema.getGlobalDescribe();
            }

            return globalSObjectTypesByStrings;
        }

        set;
    }

    // Collect Target Object names to validate field API names
    for (Interaction_Mapping__c mapping : Trigger.new) {
        sObjectNames.add(mapping.Target_Object_API_Name__c);
    }

    // Loop through Object names and collect all possible field API names into the sObjectFieldStringsMap
    for (String objectName : sObjectNames) {
        if (globalSObjectTypesByStrings.containsKey(objectName)) {
            Set<String> fieldNames = new Set<String>();
            Map<String, Schema.SObjectField> fieldMap =
                globalSObjectTypesByStrings.get(objectName).newSObject().getSObjectType().getDescribe().fields.getMap();

            for (Schema.SObjectField fieldName : fieldMap.values()) {
                fieldNames.add(String.valueOf(fieldName));
            }

            if (!sObjectFieldStringsMap.containsKey(objectName)) {
                sObjectFieldStringsMap.put(objectName, fieldNames);
            }
        }
    }

    /**
     * Finally, loop through the new Interaction Mappings and check if the value provided in the
     * Target API field matches a possible valid API name on the Target Object.
     */
    for (Interaction_Mapping__c mapping : Trigger.new) {
        String errorString = '';

        // Validate Target Field API Name on the Target Object
        if (sObjectFieldStringsMap.containsKey(mapping.Target_Object_API_Name__c)) {
            if (!sObjectFieldStringsMap.get(mapping.Target_Object_API_Name__c).contains(mapping.Target_Field_API_Name__c)) {
                errorString += 'Target Field API Name \'' + mapping.Target_Field_API_Name__c + '\' does not exist on ' +
                    mapping.Target_Object_API_Name__c + '. Please choose a valid field to map to and ensure it is in API name format.';
            }
        }

        // Validate source field API name from the Interaction
        if (sObjectFieldStringsMap.containsKey(mapping.Source_Object_API_Name__c)) {
            if (!sObjectFieldStringsMap.get(mapping.Source_Object_API_Name__c).contains(mapping.Source_Field_API_Name__c)) {
                if (!String.isEmpty(errorString)) errorString += ' ';
                errorString += 'Source Field API Name \'' + mapping.Source_Field_API_Name__c + '\' does not exist ' +
                    'on Interaction. Please choose a valid field to map from and ensure it is in API name format.';
            }
        }

        if (!String.isEmpty(errorString)) mapping.addError(errorString);
    }
}