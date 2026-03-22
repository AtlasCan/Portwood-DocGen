// =====================================================================
// DocGen FULL End-to-End Test — ONE CLICK
// Tests: data retrieval, V3 tree walker, parent fields, grandchildren,
//        legacy compat, image rendering, document generation
// Run: sf apex run --target-org <org> -f scripts/e2e-test.apex
// =====================================================================

Integer pass = 0;
Integer fail = 0;

// === 1. DATA SETUP ===
Database.DMLOptions dml = new Database.DMLOptions();
dml.DuplicateRuleHeader.allowSave = true;
String uid = String.valueOf(Math.mod(Math.abs(Crypto.getRandomInteger()), 100000));

Account acc = new Account(Name='E2E-' + uid, Industry='Technology', Phone='(555) 999-' + uid.leftPad(4, '0').right(4), Website='www.test.com', BillingStreet='100 Test Dr', BillingCity='San Francisco', BillingState='CA', BillingPostalCode='94105');
Database.insert(acc, dml);

List<Contact> cons = new List<Contact>{
    new Contact(AccountId=acc.Id, FirstName='Alice', LastName='Johnson-'+uid, Title='CEO', Email='alice'+uid+'@test.com'),
    new Contact(AccountId=acc.Id, FirstName='Bob', LastName='Smith-'+uid, Title='CTO', Email='bob'+uid+'@test.com')
};
Database.insert(cons, dml);

Opportunity opp = new Opportunity(Name='Test Deal-'+uid, AccountId=acc.Id, Amount=100000, StageName='Proposal/Price Quote', CloseDate=Date.today().addDays(30));
Database.insert(opp, dml);

List<Pricebook2> pbs = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
if (!pbs.isEmpty()) {
    Product2 p1 = new Product2(Name='Widget Pro', IsActive=true);
    Product2 p2 = new Product2(Name='Support Plan', IsActive=true);
    insert new List<Product2>{p1, p2};
    PricebookEntry pe1 = new PricebookEntry(Pricebook2Id=pbs[0].Id, Product2Id=p1.Id, UnitPrice=5000, IsActive=true);
    PricebookEntry pe2 = new PricebookEntry(Pricebook2Id=pbs[0].Id, Product2Id=p2.Id, UnitPrice=1000, IsActive=true);
    insert new List<PricebookEntry>{pe1, pe2};
    insert new List<OpportunityLineItem>{
        new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=pe1.Id, Quantity=10, UnitPrice=5000),
        new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=pe2.Id, Quantity=5, UnitPrice=1000)
    };
}

// Create test image (100x100 red square PNG — ~200 bytes)
String pngB64 = 'iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAIAAAD/gAIDAAAA40lEQVR42u3QMQEAAAgDINc/9Mzg0QSJdnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dv4HAAD//9jQAQGH1FniAAAAAElFTkSuQmCC';
ContentVersion imgCv = new ContentVersion();
imgCv.Title = 'E2E Test Image ' + uid;
imgCv.PathOnClient = 'test_image.png';
imgCv.VersionData = EncodingUtil.base64Decode(pngB64);
imgCv.IsMajorVersion = true;
Database.insert(imgCv, dml);
imgCv = [SELECT Id FROM ContentVersion WHERE Id = :imgCv.Id];

// Store the image CV ID in Description (simulates an image field)
acc.Description = String.valueOf(imgCv.Id);
update acc;
System.debug('Setup: Account=' + acc.Id + ' | Image CV=' + imgCv.Id);

// === 2. V3 TREE WALKER TEST (with Description for image) ===
String v3 = '{"v":3,"root":"Account","nodes":[' +
    '{"id":"n0","object":"Account","fields":["Name","Industry","Phone","Description"],"parentFields":["Owner.Name"],"parentNode":null,"lookupField":null,"relationshipName":null},' +
    '{"id":"n1","object":"Contact","fields":["FirstName","LastName","Title","Email"],"parentFields":[],"parentNode":"n0","lookupField":"AccountId","relationshipName":"Contacts"},' +
    '{"id":"n2","object":"Opportunity","fields":["Name","Amount","StageName"],"parentFields":[],"parentNode":"n0","lookupField":"AccountId","relationshipName":"Opportunities"},' +
    '{"id":"n3","object":"OpportunityLineItem","fields":["Quantity","UnitPrice","TotalPrice"],"parentFields":["Product2.Name"],"parentNode":"n2","lookupField":"OpportunityId","relationshipName":"OpportunityLineItems"}' +
    ']}';

Map<String, Object> data = DocGenDataRetriever.getRecordData(acc.Id, 'Account', v3);

// Test 1: Account Name
if (data.get('Name') == acc.Name) { pass++; } else { fail++; System.debug('FAIL: Account Name'); }

// Test 2: Owner.Name parent field
Object owner = data.get('Owner');
if (owner instanceof Map<String, Object> && ((Map<String, Object>)owner).get('Name') != null) { pass++; } else { fail++; System.debug('FAIL: Owner.Name'); }

// Test 3: Contacts count
Object cObj = data.get('Contacts');
Integer cCount = 0;
if (cObj instanceof Map<String, Object>) { cCount = ((List<Object>)((Map<String, Object>)cObj).get('records')).size(); }
if (cCount == 2) { pass++; } else { fail++; System.debug('FAIL: Contacts count=' + cCount + ' expected 2'); }

// Test 4: Opportunities count
Object oObj = data.get('Opportunities');
Integer oCount = 0;
Integer liCount = 0;
if (oObj instanceof Map<String, Object>) {
    List<Object> oRecs = (List<Object>)((Map<String, Object>)oObj).get('records');
    oCount = oRecs.size();
    if (!oRecs.isEmpty()) {
        Map<String, Object> firstOpp = (Map<String, Object>)oRecs[0];
        Object liObj = firstOpp.get('OpportunityLineItems');
        if (liObj instanceof Map<String, Object>) {
            liCount = ((List<Object>)((Map<String, Object>)liObj).get('records')).size();
            // Test 5: Product2.Name parent field on line items
            List<Object> liRecs = (List<Object>)((Map<String, Object>)liObj).get('records');
            if (!liRecs.isEmpty()) {
                Map<String, Object> firstLi = (Map<String, Object>)liRecs[0];
                Object prod = firstLi.get('Product2');
                if (prod instanceof Map<String, Object> && ((Map<String, Object>)prod).get('Name') != null) { pass++; } else { fail++; System.debug('FAIL: Product2.Name on LineItem'); }
            }
        }
    }
}
if (oCount == 1) { pass++; } else { fail++; System.debug('FAIL: Opp count=' + oCount); }
// Test 6: Line Items count
if (liCount == 2) { pass++; } else { fail++; System.debug('FAIL: LineItem count=' + liCount + ' expected 2'); }

// Test 7: Description contains CV ID (image field)
String descVal = (String) data.get('Description');
if (descVal != null && descVal.startsWith('068')) { pass++; } else { fail++; System.debug('FAIL: Description CV ID = ' + descVal); }

// === 3. LEGACY V1 BACKWARD COMPAT ===
// Test 8: Legacy config still works
Map<String, Object> legData = DocGenDataRetriever.getRecordData(acc.Id, 'Account', 'Name, Industry, (SELECT FirstName, LastName FROM Contacts)');
Object lcObj = legData.get('Contacts');
Integer lcCount = 0;
if (lcObj instanceof Map<String, Object>) { lcCount = ((List<Object>)((Map<String, Object>)lcObj).get('records')).size(); }
if (lcCount == 2) { pass++; } else { fail++; System.debug('FAIL: Legacy contacts count=' + lcCount); }

// === 4. IMAGE CV VALIDATION ===
// Test 9: Image CV format
if (String.valueOf(imgCv.Id).startsWith('068')) { pass++; } else { fail++; System.debug('FAIL: Image CV ID format'); }

// Test 10: Image CV accessible with correct extension
List<ContentVersion> imgCheck = [SELECT Id, FileExtension, ContentSize FROM ContentVersion WHERE Id = :imgCv.Id];
if (!imgCheck.isEmpty() && imgCheck[0].FileExtension == 'png') { pass++; } else { fail++; System.debug('FAIL: Image CV not accessible'); }

// === 5. DOCUMENT GENERATION WITH IMAGES ===
// Test 11 + 12: Generate document from template (exercises full pipeline including image tags)
DocGen_Template__c tmpl = [SELECT Id FROM DocGen_Template__c WHERE Name = 'E2E Full Tree Test' LIMIT 1];
try {
    Id cdId = DocGenService.generateDocument(tmpl.Id, acc.Id);
    if (cdId != null) { pass++; } else { fail++; System.debug('FAIL: generateDocument returned null'); }
    List<ContentVersion> cvs = [SELECT ContentSize, FileExtension FROM ContentVersion WHERE ContentDocumentId = :cdId LIMIT 1];
    if (!cvs.isEmpty() && cvs[0].ContentSize > 0) {
        pass++;
        System.debug('Generated: ' + cvs[0].FileExtension + ' ' + cvs[0].ContentSize + ' bytes');
    } else {
        fail++;
        System.debug('FAIL: Generated file empty');
    }
} catch (Exception e) {
    fail += 2;
    System.debug('FAIL: Generation error: ' + e.getMessage());
}

// === 6. V2 JUNCTION TEST ===
// Test 13: V2 config with junction stitching
// Create contact roles first
insert new List<OpportunityContactRole>{
    new OpportunityContactRole(OpportunityId=opp.Id, ContactId=cons[0].Id, Role='Decision Maker', IsPrimary=true)
};

String v2Junction = '{"v":2,"baseObject":"Opportunity","baseFields":["Name","Amount"],"parentFields":["Account.Name"],"children":[],"junctions":[{"junctionRel":"OpportunityContactRoles","junctionFields":["Role"],"targetObject":"Contact","targetIdField":"ContactId","targetFields":["FirstName","LastName","Email"]}]}';
Map<String, Object> jData = DocGenDataRetriever.getRecordData(opp.Id, 'Opportunity', v2Junction);
Object ocrObj = jData.get('OpportunityContactRoles');
if (ocrObj instanceof Map<String, Object>) {
    List<Object> ocrRecs = (List<Object>)((Map<String, Object>)ocrObj).get('records');
    if (!ocrRecs.isEmpty()) {
        Map<String, Object> firstOcr = (Map<String, Object>)ocrRecs[0];
        Object contactData = firstOcr.get('Contact');
        if (contactData instanceof Map<String, Object> && ((Map<String, Object>)contactData).get('FirstName') != null) {
            pass++;
            System.debug('Junction: ' + firstOcr.get('Role') + ' => ' + ((Map<String, Object>)contactData).get('FirstName'));
        } else {
            fail++;
            System.debug('FAIL: Junction Contact data not stitched');
        }
    } else { fail++; System.debug('FAIL: No OCR records'); }
} else { fail++; System.debug('FAIL: No OpportunityContactRoles in data'); }

// === RESULTS ===
System.debug('');
System.debug('==============================');
System.debug('  PASS: ' + pass + '  FAIL: ' + fail);
System.debug('  ' + (fail == 0 ? 'ALL TESTS PASSED' : fail + ' TESTS FAILED'));
System.debug('==============================');
System.debug('Tests: Account name, Owner.Name, Contacts(2), Opps(1), Product2.Name, LineItems(2), Description CV, Legacy V1, Image CV format, Image CV access, Doc generation, Doc not empty, Junction stitching');

// === CLEANUP ===
// Delete test data to keep the org clean for repeated runs
try {
    // Delete image CV first (standalone, not linked to account)
    List<ContentVersion> imgCvClean = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :imgCv.Id];
    if (!imgCvClean.isEmpty()) {
        try { delete [SELECT Id FROM ContentDocument WHERE Id = :imgCvClean[0].ContentDocumentId]; } catch (Exception ex) {}
    }
    // Delete children before parents
    delete [SELECT Id FROM OpportunityContactRole WHERE OpportunityId = :opp.Id];
    delete [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];
    delete [SELECT Id FROM Opportunity WHERE Id = :opp.Id];
    delete [SELECT Id FROM Contact WHERE AccountId = :acc.Id];
    delete [SELECT Id FROM Account WHERE Id = :acc.Id];
    System.debug('Cleanup: DONE');
} catch (Exception e) {
    System.debug('Cleanup warning: ' + e.getMessage());
}
