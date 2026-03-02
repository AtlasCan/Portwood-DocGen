@IsTest
private class DocGenBulkTests {

    @TestSetup
    static void setup() {
        // Assign DocGen_Admin permission set for custom object/field access in 2GP context
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'DocGen_Admin' LIMIT 1];
        List<PermissionSetAssignment> existing = [
            SELECT Id FROM PermissionSetAssignment
            WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSetId = :ps.Id
            LIMIT 1
        ];
        if (existing.isEmpty()) {
            insert new PermissionSetAssignment(
                AssigneeId = UserInfo.getUserId(),
                PermissionSetId = ps.Id
            );
        }

        DocGen_Template__c t = new DocGen_Template__c(
            Name = 'Test Template',
            Base_Object_API__c = 'Account'
        );
        insert t;

        Account a = new Account(
            Name = 'Test Account',
            Website = 'https://www.example.com'
        );
        insert a;
    }

    @IsTest
    static void testGetBulkTemplates() {
        Test.startTest();
        List<DocGen_Template__c> templates = DocGenBulkController.getBulkTemplates();
        Test.stopTest();
        System.assertEquals(1, templates.size(), 'Should return 1 template');
    }

    @IsTest
    static void testValidateFilter() {
        Test.startTest();
        Integer count = DocGenBulkController.validateFilter('Account', 'Name = \'Test Account\'');
        Test.stopTest();
        System.assertEquals(1, count, 'Should find 1 record');
    }

    @IsTest
    static void testSubmitJob() {
        DocGen_Template__c t = [SELECT Id FROM DocGen_Template__c LIMIT 1];
        Test.startTest();
        Id jobId = DocGenBulkController.submitJob(t.Id, 'Name = \'Test Account\'');
        Test.stopTest();
        
        DocGen_Job__c job = [SELECT Id, Status__c FROM DocGen_Job__c WHERE Id = :jobId];
        System.assertNotEquals(null, job.Id, 'Job should be created');
    }

    @IsTest
    static void testSavedQueries() {
        DocGen_Template__c t = [SELECT Id FROM DocGen_Template__c LIMIT 1];
        
        // Save
        Test.startTest();
        DocGenBulkController.saveQuery(t.Id, 'My Query', 'Desc', 'Name != null');
        Test.stopTest();
        
        // Retrieve
        List<DocGen_Saved_Query__c> queries = DocGenBulkController.getSavedQueries(t.Id);
        System.assertEquals(1, queries.size());
        System.assertEquals('My Query', queries[0].Name);
        
        // Delete
        DocGenBulkController.deleteQuery(queries[0].Id);
        queries = DocGenBulkController.getSavedQueries(t.Id);
        System.assertEquals(0, queries.size());
    }
}