// Creates Closed Won Opportunities on an Account for Giant Query PDF testing.
// Run multiple times until 10K reached. Each run creates up to 9,000.
// sf apex run -o <org> -f scripts/create-10k-opps.apex

List<Account> accs = [SELECT Id, Name FROM Account WHERE Name = 'Giant Query Test Corp' LIMIT 1];
Account acc;
if (accs.isEmpty()) {
    acc = new Account(Name = 'Giant Query Test Corp', Industry = 'Technology', Phone = '(555) 123-4567',
        BillingStreet = '100 Main Street', BillingCity = 'San Francisco', BillingState = 'CA', BillingPostalCode = '94105');
    insert acc;
    System.debug('Created account: ' + acc.Id);
} else {
    acc = accs[0];
}

Integer existing = [SELECT COUNT() FROM Opportunity WHERE AccountId = :acc.Id];
System.debug('Existing: ' + existing);

Integer target = 10000;
Integer toCreate = Math.min(target - existing, 9000); // Stay under 10K DML row limit
if (toCreate <= 0) {
    System.debug('DONE. Total: ' + existing + ' on ' + acc.Id);
    return;
}

List<String> prefixes = new List<String>{'Enterprise', 'Standard', 'Premium', 'Basic', 'Professional',
    'Ultimate', 'Starter', 'Growth', 'Scale', 'Custom'};
List<String> products = new List<String>{'License', 'Support', 'Implementation', 'Training', 'Consulting',
    'Integration', 'Migration', 'Addon', 'Renewal', 'Expansion'};
List<String> types = new List<String>{'New Customer', 'Existing Customer - Upgrade', 'Existing Customer - Replacement'};
List<String> sources = new List<String>{'Web', 'Phone Inquiry', 'Partner Referral', 'Purchased List', 'Other'};

List<Opportunity> batch = new List<Opportunity>();
for (Integer i = 0; i < toCreate; i++) {
    Integer idx = existing + i;
    batch.add(new Opportunity(
        Name = prefixes[Math.mod(idx, 10)] + ' ' + products[Math.mod(idx / 10, 10)] + ' #' + (idx + 1),
        AccountId = acc.Id,
        StageName = 'Closed Won',
        Amount = Math.round(Math.random() * 50000) + 500,
        CloseDate = Date.today().addDays(-(Integer)(Math.random() * 730)),
        Type = types[Math.mod(idx, 3)],
        LeadSource = sources[Math.mod(idx, 5)]
    ));
}
insert batch;
System.debug('Created ' + toCreate + '. Total: ' + (existing + toCreate) + '. Account: ' + acc.Id);
