/**
* @author Sierra-Cedar
* @date 11/10/19
*
* A test data factory for Interactions
*/
@IsTest
public class INT_TestDataFactory {
    /**
     * Creates a new Account record for unit tests from provided information.
     *
     * @param name, a Name to give the new Account.
     * @param recordTypeId, a RecordTypeId to give the new Account.
     *
     * @return, a new Account record to use in unit tests.
     */
    public static Account createTestAccount(String name, String recordTypeId) {
        return new Account(
            Name = name,
            RecordTypeId = recordTypeId
        );
    }

    /**
     * Creates a new Campaign record for unit tests from provided information.
     *
     * @param name, a Name to give the new Account.
     *
     * @return, a new Campaign record to use in unit tests.
     */
    public static Campaign createTestCampaign(String name) {
        return new Campaign(
            Name = name
        );
    }

    /**
     * Creates a new Interaction record for unit tests.
     *
     * @return, a new Interaction__c record to use in unit tests.
     */
    public static Interaction__c createTestInteraction() {
        return new Interaction__c(
            First_Name__c = 'Super',
            Last_Name__c = 'Gary',
            Email__c = 'super.gary@nomail.com',
            Interaction_Source__c = 'Webform'
        );
    }

    /**
     * Creates a new Lead record for unit tests.
     *
     * @return, a new Lead record to use in unit tests.
     */
    public static Lead createTestLead() {
        return new Lead(
            FirstName = 'Super',
            LastName = 'Gary',
            Email = 'super.gary@nomail.com',
            Company = 'Gary, Super'
        );
    }

    /**
     * Creates and returns a List of Lead test data
     *
     * @return testLeadsToInsert, a List of Lead records for bulk unit tests.
     */
    public static List<Lead> createBulkTestLeads(Integer numberOfLeads) {
        List<Lead> testLeadsToInsert = new List<Lead>();

        for (Integer i = 0; i < numberOfLeads; i++) {
            testLeadsToInsert.add(
                new Lead(
                    FirstName = i + 'Test' + i,
                    LastName = i + 'Person' + i,
                    Email = i + 'test.person' + i + '@nomail.com',
                    Company = 'Person' + i + ', ' + 'Test' + i
                )
            );
        }

        return testLeadsToInsert;
    }

    /**
     * Creates and returns a List of Contact test data
     *
     * @return testContactsToInsert, a List of Contact records for bulk unit tests.
     */
    public static List<Contact> createBulkTestContacts(Integer numberOfContacts) {
        List<Contact> testContactsToInsert = new List<Contact>();

        for (Integer i = 0; i < numberOfContacts; i++) {
            testContactsToInsert.add(
                new Contact(
                    FirstName = i + 'Test' + i,
                    LastName = i + 'Person' + i,
                    Email = i + 'test.person' + i + '@nomail.com'
                )
            );
        }

        return testContactsToInsert;
    }

    /**
     * Creates and returns a List of Interaction__c test data
     *
     * @return testInteractionsToInsert, a List of Interaction__c records for bulk unit tests.
     */
    public static List<Interaction__c> createBulkTestInteractions(Integer numberOfInteractions) {
        List<Interaction__c> testInteractionsToInsert = new List<Interaction__c>();

        for (Integer i = 0; i < numberOfInteractions; i++) {
            testInteractionsToInsert.add(
                new Interaction__c(
                    First_Name__c = i + 'Test' + i,
                    Last_Name__c = i + 'Person' + i,
                    Email__c = i + 'test.person' + i + '@nomail.com'
                )
            );
        }

        return testInteractionsToInsert;
    }

    /**
     * Creates and returns a List of Interaction_Mapping__c test data
     *
     * @return testMappingsToInsert, a List of Interaction_Mapping__c records to use in unit tests.
     */
    public static List<Interaction_Mapping__c> createTestMappings() {
        List<Interaction_Mapping__c> testMappingsToInsert = new List<Interaction_Mapping__c>{
            /* CampaignMember Mappings */
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'CampaignMember',
                Source_Field_API_Name__c = 'Campaign_Member_Status__c',
                Target_Field_API_Name__c = 'Status',
                Active__c = true
            ),

            /* Contact Mappings */
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Contact',
                Source_Field_API_Name__c = 'Birthdate__c',
                Target_Field_API_Name__c = 'Birthdate',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Contact',
                Source_Field_API_Name__c = 'Constituent_ID__c',
                Target_Field_API_Name__c = 'Constituent_ID__c',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Contact',
                Source_Field_API_Name__c = 'Email__c',
                Target_Field_API_Name__c = 'Email',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Contact',
                Source_Field_API_Name__c = 'First_Name__c',
                Target_Field_API_Name__c = 'FirstName',
                Skip_Mapping__c = 'Webform',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Contact',
                Source_Field_API_Name__c = 'Gender__c',
                Target_Field_API_Name__c = 'hed__Gender__c',
                Skip_Mapping__c = 'Webform;Manual Entry',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Contact',
                Source_Field_API_Name__c = 'Home_Phone__c',
                Target_Field_API_Name__c = 'HomePhone',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Contact',
                Source_Field_API_Name__c = 'Last_Name__c',
                Target_Field_API_Name__c = 'LastName',
                Skip_Mapping__c = 'Webform',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Contact',
                Source_Field_API_Name__c = 'Lead_Source__c',
                Target_Field_API_Name__c = 'LeadSource',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Contact',
                Source_Field_API_Name__c = 'Mailing_City__c',
                Target_Field_API_Name__c = 'MailingCity',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Contact',
                Source_Field_API_Name__c = 'Mailing_Country__c',
                Target_Field_API_Name__c = 'MailingCountry',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Contact',
                Source_Field_API_Name__c = 'Mailing_Postal_Code__c',
                Target_Field_API_Name__c = 'MailingPostalCode',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Contact',
                Source_Field_API_Name__c = 'Mailing_State__c',
                Target_Field_API_Name__c = 'MailingState',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Contact',
                Source_Field_API_Name__c = 'Mailing_Street__c',
                Target_Field_API_Name__c = 'MailingStreet',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Contact',
                Source_Field_API_Name__c = 'Mobile_Phone__c',
                Target_Field_API_Name__c = 'MobilePhone',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Contact',
                Source_Field_API_Name__c = 'Salutation__c',
                Target_Field_API_Name__c = 'Salutation',
                Active__c = true
            ),

            /* hed__Affiliation__c Mappings */
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'hed__Affiliation__c',
                Source_Field_API_Name__c = 'Affiliated_Account__c',
                Target_Field_API_Name__c = 'hed__Account__c',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'hed__Affiliation__c',
                Source_Field_API_Name__c = 'Affiliation_Key__c',
                Target_Field_API_Name__c = 'Upsert_Key__c',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'hed__Affiliation__c',
                Source_Field_API_Name__c = 'Affiliation_Role__c',
                Target_Field_API_Name__c = 'hed__Role__c',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'hed__Affiliation__c',
                Source_Field_API_Name__c = 'Contact__c',
                Target_Field_API_Name__c = 'hed__Contact__c',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'hed__Affiliation__c',
                Source_Field_API_Name__c = 'Primary_Affiliation__c',
                Target_Field_API_Name__c = 'hed__Primary__c',
                Active__c = true
            ),

            /* Lead Mappings */
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Lead',
                Source_Field_API_Name__c = 'Email__c',
                Target_Field_API_Name__c = 'Email',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Lead',
                Source_Field_API_Name__c = 'First_Name__c',
                Target_Field_API_Name__c = 'FirstName',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Lead',
                Source_Field_API_Name__c = 'Home_Phone__c',
                Target_Field_API_Name__c = 'Phone',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Lead',
                Source_Field_API_Name__c = 'Last_Name__c',
                Target_Field_API_Name__c = 'LastName',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Lead',
                Source_Field_API_Name__c = 'Lead_Source__c',
                Target_Field_API_Name__c = 'LeadSource',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Lead',
                Source_Field_API_Name__c = 'Mailing_City__c',
                Target_Field_API_Name__c = 'City',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Lead',
                Source_Field_API_Name__c = 'Mailing_Country__c',
                Target_Field_API_Name__c = 'Country',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Lead',
                Source_Field_API_Name__c = 'Mailing_Postal_Code__c',
                Target_Field_API_Name__c = 'PostalCode',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Lead',
                Source_Field_API_Name__c = 'Mailing_State__c',
                Target_Field_API_Name__c = 'State',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Lead',
                Source_Field_API_Name__c = 'Mailing_Street__c',
                Target_Field_API_Name__c = 'Street',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Lead',
                Source_Field_API_Name__c = 'Mobile_Phone__c',
                Target_Field_API_Name__c = 'MobilePhone',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Lead',
                Source_Field_API_Name__c = 'Salutation__c',
                Target_Field_API_Name__c = 'Salutation',
                Active__c = true
            ),

            /* Opportunity Mappings */
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Opportunity',
                Source_Field_API_Name__c = 'Admit_Type__c',
                Target_Field_API_Name__c = 'Admit_Type__c',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Opportunity',
                Source_Field_API_Name__c = 'Contact__c',
                Target_Field_API_Name__c = 'Contact__c',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Opportunity',
                Source_Field_API_Name__c = 'Lead_Source__c',
                Target_Field_API_Name__c = 'LeadSource',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Opportunity',
                Source_Field_API_Name__c = 'Opportunity_Name__c',
                Target_Field_API_Name__c = 'Name',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Opportunity',
                Source_Field_API_Name__c = 'Opportunity_Stage__c',
                Target_Field_API_Name__c = 'StageName',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Opportunity',
                Source_Field_API_Name__c = 'Term__c',
                Target_Field_API_Name__c = 'Term__c',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Opportunity',
                Source_Field_API_Name__c = 'Academic_Interest__c',
                Target_Field_API_Name__c = 'Academic_Interest__c',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Opportunity',
                Source_Field_API_Name__c = 'Recruitment_Interest__c',
                Target_Field_API_Name__c = 'Recruitment_Interest__c',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Interaction__c',
                Source_Object_API_Name__c = 'Lead',
                Source_Field_API_Name__c = 'FirstName',
                Target_Field_API_Name__c = 'First_Name__c',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Interaction__c',
                Source_Object_API_Name__c = 'Lead',
                Source_Field_API_Name__c = 'LastName',
                Target_Field_API_Name__c = 'Last_Name__c',
                Active__c = true
            ),
            new Interaction_Mapping__c(
                Target_Object_API_Name__c = 'Interaction__c',
                Source_Object_API_Name__c = 'Lead',
                Source_Field_API_Name__c = 'MobilePhone',
                Target_Field_API_Name__c = 'Mobile_Phone__c',
                Active__c = true
            )
        };

        return testMappingsToInsert;
    }
}